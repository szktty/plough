import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:plough/src/graph/entity.dart';
import 'package:plough/src/graph/graph_base.dart';
import 'package:plough/src/graph/id.dart';
import 'package:plough/src/graph/link.dart';
import 'package:plough/src/graph/node.dart';
import 'package:plough/src/graph_view/behavior.dart';
import 'package:plough/src/graph_view/data.dart';
import 'package:plough/src/graph_view/geometry.dart';
import 'package:plough/src/graph_view/hit_test.dart';
import 'package:plough/src/graph_view/inherited_data.dart';
import 'package:plough/src/graph_view/widget/link.dart';
import 'package:plough/src/graph_view/widget/node.dart';
import 'package:plough/src/interactive/widget/interactive_overlay.dart';
import 'package:plough/src/layout_strategy/base.dart';
import 'package:plough/src/utils/logger.dart';
import 'package:plough/src/utils/widget.dart';

/// The main widget for displaying a graph.
///
/// Features:
/// - Node and link rendering
/// - Automatic layout using configurable algorithms
/// - Node movement animations
/// - Selection state management
/// - Interaction handling
///
/// Example:
/// ```dart
/// final behavior = GraphViewDefaultBehavior(
///   nodeRenderer: GraphDefaultNodeRenderer(
///     style: const GraphDefaultNodeRendererStyle(
///       shape: GraphCircle(),
///       width: 100,
///       height: 100,
///     ),
///   ),
/// );
///
/// final layoutStrategy = GraphForceDirectedLayoutStrategy(
///   springLength: 200.0,
///   springConstant: 0.1,
/// );
///
/// return GraphView(
///   graph: graph,
///   behavior: behavior,
///   layoutStrategy: layoutStrategy,
///   allowSelection: true,
///   animationEnabled: true,
/// );
/// ```
///
/// See also:
///
/// * [GraphViewBehavior], for customizing appearance and interaction
/// * [GraphLayoutStrategy], for customizing node positioning
class GraphView extends StatefulWidget {
  /// Creates a graph visualization widget.
  const GraphView({
    required this.graph,
    required this.behavior,
    required this.layoutStrategy,
    this.allowSelection = false,
    this.allowMultiSelection = false,
    this.animationEnabled = true,
    this.nodeAnimationStartPosition,
    this.nodeAnimationDuration = const Duration(milliseconds: 500),
    this.nodeAnimationCurve = Curves.easeOutQuint,
    this.gestureMode = GraphGestureMode.exclusive,
    this.shouldConsumeGesture,
    this.onBackgroundTapped,
    this.onBackgroundPanStart,
    this.onBackgroundPanUpdate,
    this.onBackgroundPanEnd,
    this.dragDeltaTransform,
    this.globalToScene,
    super.key,
  });

  /// The graph data model.
  final Graph graph;

  /// Defines the appearance and interaction behavior.
  final GraphViewBehavior behavior;

  /// The algorithm for positioning nodes.
  final GraphLayoutStrategy layoutStrategy;

  /// Whether node selection is enabled.
  final bool allowSelection;

  /// Whether multiple nodes can be selected.
  final bool allowMultiSelection;

  /// Whether node movement animations are enabled.
  final bool animationEnabled;

  /// Starting position for node animations. Defaults to screen center if null.
  final Offset? nodeAnimationStartPosition;

  /// Duration of node movement animations.
  final Duration nodeAnimationDuration;

  /// Easing curve for node movement animations.
  final Curve nodeAnimationCurve;

  /// How gestures should be handled by the graph view.
  ///
  /// - [GraphGestureMode.exclusive]: Consume all gestures (default)
  /// - [GraphGestureMode.nodeEdgeOnly]: Only consume gestures on nodes/edges
  /// - [GraphGestureMode.transparent]: Pass all gestures to parent
  /// - [GraphGestureMode.custom]: Use [shouldConsumeGesture] callback
  final GraphGestureMode gestureMode;

  /// Custom callback for determining gesture consumption.
  ///
  /// Only used when [gestureMode] is [GraphGestureMode.custom].
  /// Return `true` to consume the gesture, `false` to pass it through.
  final GraphGestureConsumptionCallback? shouldConsumeGesture;

  /// Callback for background tap gestures.
  ///
  /// Only called when the gesture is not consumed by graph elements.
  final GraphBackgroundGestureCallback? onBackgroundTapped;

  /// Callback for background pan start gestures.
  final GraphBackgroundGestureCallback? onBackgroundPanStart;

  /// Callback for background pan update gestures.
  final GraphBackgroundPanCallback? onBackgroundPanUpdate;

  /// Callback for background pan end gestures.
  final GraphBackgroundGestureCallback? onBackgroundPanEnd;

  /// Optional transform applied to drag delta before updating node positions.
  ///
  /// Use this when [GraphView] is inside a transformed parent (e.g.
  /// [InteractiveViewer]) to convert the screen-space drag delta into the
  /// graph's logical coordinate space.  If null, the raw delta is used as-is.
  ///
  /// Example — strip the InteractiveViewer scale:
  /// ```dart
  /// dragDeltaTransform: (delta) {
  ///   final scale = transformationController.value.getMaxScaleOnAxis();
  ///   return delta / scale;
  /// },
  /// ```
  final Offset Function(Offset delta)? dragDeltaTransform;

  /// Optional transform that converts a global screen position to the graph's
  /// logical (scene) coordinate space.
  ///
  /// Typically set to `transformationController.toScene` when [GraphView] is
  /// inside an [InteractiveViewer].
  final Offset Function(Offset globalPosition)? globalToScene;

  @override
  State<GraphView> createState() => GraphViewState();
}

/// State class for [GraphView] that manages graph layout and rendering.
///
/// Primary responsibilities:
/// - Layout calculation and application
/// - Node and link view generation and management
/// - Animation control
/// - Tooltip display management
///
/// See also:
/// * [GraphView], the stateful widget using this state
/// * [GraphViewData], which holds view-specific data
class GraphViewState extends State<GraphView> with TickerProviderStateMixin {
  late GraphViewData _data;

  GraphImpl get _graph => widget.graph as GraphImpl;

  final ValueNotifier<GraphViewBuildState> _buildState = ValueNotifier(
    GraphViewBuildState.initialize,
  );

  void _setBuildState(GraphViewBuildState newState) {
    if (_buildState.value != newState) {
      logDebug(
        LogCategory.state,
        '🏗️ GraphView _buildState changed: ${_buildState.value} -> $newState',
      );
      _buildState.value = newState;
    }
  }

  GraphLayoutStrategy get _layoutStrategy => widget.layoutStrategy;
  GraphLayoutStrategy? _oldLayoutStrategy;

  // Cache for sorted elements — rebuilt only when stackOrder changes.
  List<GraphEntity>? _sortedElements;
  bool _sortDirty = true;

  void _markSortDirty() => _sortDirty = true;

  bool get _animationEnabled => widget.animationEnabled;

  late GraphNodeViewBehavior _nodeViewBehavior;
  late GraphLinkViewBehavior _linkViewBehavior;

  final GlobalKey _layoutKey = GlobalKey();

  final Map<GraphId, GlobalKey> _nodeKeys = {};
  final Map<GraphId, Widget> _nodeViews = {};

  // TODO(user): Not used
  final Map<GraphId, GlobalKey> _linkKeys = {};

  GraphId? _entityIdShowingTooltip;

  bool _isGeometryUpdateScheduled = false;

  // --- Incremental layout (streaming simulation) ---
  Ticker? _layoutTicker;
  bool _isIncrementalLayoutRunning = false;
  // Pending constraints for the next incremental layout start.
  BoxConstraints? _pendingIncrementalConstraints;

  /// Schedules incremental layout to start after the current build frame.
  ///
  /// Must NOT be called during build (would create a Ticker inside build).
  void _scheduleIncrementalLayout(BoxConstraints constraints) {
    _pendingIncrementalConstraints = constraints;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final pending = _pendingIncrementalConstraints;
      if (pending == null) return;
      _pendingIncrementalConstraints = null;
      _startIncrementalLayout(pending);
    });
  }

  void _startIncrementalLayout(BoxConstraints constraints) {
    _stopIncrementalLayout();
    _isIncrementalLayoutRunning = true;

    final strategy = _layoutStrategy;
    final size = Size(constraints.maxWidth, constraints.maxHeight);
    strategy.initIncrementalLayout(_graph, size);

    _layoutTicker = createTicker((_) {
      if (!mounted) {
        _stopIncrementalLayout();
        return;
      }
      final hasMore = strategy.stepIncrementalLayout(_graph);
      // Bump the layout notifier so AnimatedBuilder rebuilds this frame.
      _graph.notifyLayoutStep();

      if (!hasMore) {
        _stopIncrementalLayout();
        _graph.onLayoutFinished();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _updateGraphGeometry();
            _setBuildState(GraphViewBuildState.ready);
          }
        });
      }
    })
      ..start();
  }

  void _stopIncrementalLayout() {
    _layoutTicker?.stop();
    _layoutTicker?.dispose();
    _layoutTicker = null;
    _isIncrementalLayoutRunning = false;
    _pendingIncrementalConstraints = null;
  }

  @override
  void initState() {
    super.initState();
    _initBehavior();
  }

  @override
  void dispose() {
    _stopIncrementalLayout();
    _buildState.dispose();
    super.dispose();
  }

  void _initBehavior() {
    _stopIncrementalLayout();
    _nodeViewBehavior = widget.behavior.createNodeViewBehavior();
    _linkViewBehavior = widget.behavior.createLinkViewBehavior();
    _data = GraphViewData(
      graph: widget.graph,
      behavior: widget.behavior,
      layoutStrategy: _layoutStrategy,
      allowSelection: widget.allowSelection,
      allowMultiSelection: widget.allowMultiSelection,
      animationEnabled: widget.animationEnabled,
      nodeAnimationStartPosition: widget.nodeAnimationStartPosition,
      nodeAnimationDuration: widget.nodeAnimationDuration,
      nodeAnimationCurve: widget.nodeAnimationCurve,
    );
    _setBuildState(GraphViewBuildState.initialize);
    _nodeViews.clear();
    _sortedElements = null;
    _sortDirty = true;
  }

  @override
  void didUpdateWidget(covariant GraphView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reinitialize only under stricter conditions
    final needsReinit = widget.graph != oldWidget.graph ||
        widget.layoutStrategy.runtimeType !=
            oldWidget.layoutStrategy.runtimeType ||
        !widget.behavior.isEquivalentTo(oldWidget.behavior);

    if (needsReinit) {
      logDebug(
        LogCategory.state,
        '🔄 GraphView didUpdateWidget: reinitializing behavior (reason: graph=${widget.graph != oldWidget.graph}, layout=${widget.layoutStrategy.runtimeType != oldWidget.layoutStrategy.runtimeType}, behaviorEquivalent=${!widget.behavior.isEquivalentTo(oldWidget.behavior)})',
      );
      _initBehavior();
    } else {
      logDebug(
        LogCategory.state,
        '🔄 GraphView didUpdateWidget: skipping reinit (no significant changes)',
      );
    }
  }

  void _updateGraphGeometry() {
    WidgetUtils.withSizedRenderBoxIfPresent(_layoutKey, (renderBox) {
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      final newGeometry = GraphViewGeometry(position: position, size: size);

      // Only update if geometry actually changed
      if (_graph.geometry == null ||
          _graph.geometry!.position != position ||
          _graph.geometry!.size != size) {
        _graph.geometry = newGeometry;
        logDebug(LogCategory.rendering, 'GraphView: update geometry');
        logDebug(LogCategory.rendering, '    position: $position');
        logDebug(LogCategory.rendering, '    size: $size');
      }
    });
  }

  void _updateNodeGeometry() {
    for (final node in _graph.nodes.cast<GraphNodeImpl>()) {
      final key = _nodeKeys[node.id];
      WidgetUtils.withSizedRenderBoxIfPresent(key, (renderBox) {
        if (_graph.geometry == null) {
          return;
        }
        final globalTopLeft = renderBox.localToGlobal(Offset.zero);
        final position = globalTopLeft - _graph.geometry!.position;
        final bounds = Rect.fromLTWH(
          position.dx,
          position.dy,
          renderBox.size.width,
          renderBox.size.height,
        );
        final newGeometry = GraphNodeViewGeometry(bounds: bounds);
        // Only update if geometry actually changed
        if (node.geometry == null || node.geometry!.bounds != bounds) {
          node.geometry = newGeometry;
          logDebug(LogCategory.rendering, 'GraphView: update node geometry');
          logDebug(LogCategory.rendering, '    node: ${node.id}');
          logDebug(LogCategory.rendering, '    position: $position');
          logDebug(LogCategory.rendering, '    size: ${renderBox.size}');
        }
      });
    }
  }

  /// Returns the current global screen position of the GraphView's layout
  /// origin (the inner Stack that holds nodes).
  ///
  /// This can be used to build a correct [GraphView.globalToScene] function:
  /// ```dart
  /// globalToScene: (globalPos) {
  ///   final origin = graphViewStateKey.currentState!.layoutGlobalOrigin
  ///       ?? Offset.zero;
  ///   return (globalPos - origin) / viewportController.scale;
  /// }
  /// ```
  Offset? get layoutGlobalOrigin {
    final box = _layoutKey.currentContext?.findRenderObject() as RenderBox?;
    return box?.localToGlobal(Offset.zero);
  }

  /// Refreshes geometry for all nodes after a viewport transform change.
  ///
  /// Call this after a pan or zoom to keep hit-test bounds in sync with the
  /// visual positions of nodes.  Also updates the GraphView container geometry
  /// because the Transform inside GraphViewport shifts the global positions of
  /// all child render boxes.
  void refreshAllNodeGeometry() {
    _updateGraphGeometry();
    _updateNodeGeometry();
  }

  Offset _getNodeAnimationStartPosition(BoxConstraints constraints) {
    return widget.nodeAnimationStartPosition ??
        constraints.biggest.center(Offset.zero);
  }

  void _performLayout({
    required BuildContext context,
    required BoxConstraints constrains,
  }) {
    logDebug(LogCategory.layout, 'GraphView: perform layout');

    if (_graph.needsLayout ||
        _oldLayoutStrategy == null ||
        !_layoutStrategy.isSameStrategy(_oldLayoutStrategy!) ||
        _layoutStrategy.shouldRelayout(_oldLayoutStrategy!)) {
      _layoutStrategy.nodeAnimationStartPosition =
          _getNodeAnimationStartPosition(constrains);
      _oldLayoutStrategy = _layoutStrategy;

      if (_layoutStrategy.supportsIncrementalLayout) {
        // Schedule start after the current build frame to avoid creating a
        // Ticker inside a build callback (which is forbidden).
        _scheduleIncrementalLayout(constrains);
        // Return early — buildState stays as performLayout until the ticker
        // finishes and sets it to ready.
        return;
      }

      // Non-incremental (instant) layout path.
      final shouldAnimateLayout =
          widget.animationEnabled && _graph.shouldAnimateLayout;

      if (shouldAnimateLayout) {
        for (final node in _graph.nodes) {
          (node as GraphNodeImpl).resetAnimationState();
        }
      }
      _layoutStrategy.performLayout(
        _graph,
        Size(constrains.maxWidth, constrains.maxHeight),
      );
      _graph.onLayoutFinished();
    } else {
      // Layout not performed, ensure nodes are not stuck in animating state
      for (final node in _graph.nodes) {
        final nodeImpl = node as GraphNodeImpl;
        if (nodeImpl.isAnimating && !nodeImpl.isAnimationCompleted) {
          nodeImpl.isAnimating = false;
          nodeImpl.isAnimationCompleted = true;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: Listenable.merge([
            _graph.layoutChangeListenable,
            _buildState,
          ]),
          builder: (context, child) {
            // Any layout change may have altered stackOrder.
            _markSortDirty();
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            logDebug(
              LogCategory.rendering,
              'AnimatedBuilder.builder called at $timestamp, buildState: ${_buildState.value}',
            );
            late List<GraphEntity> elements;
            if (_buildState.value == GraphViewBuildState.initialize) {
              if (!_isGeometryUpdateScheduled) {
                _isGeometryUpdateScheduled = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    logDebug(
                      LogCategory.rendering,
                      'PostFrameCallback in initialize phase',
                    );
                    _updateGraphGeometry();
                    _updateNodeGeometry();
                    _setBuildState(GraphViewBuildState.performLayout);
                    _isGeometryUpdateScheduled = false;
                  }
                });
              }
              elements = [..._graph.nodes];
            } else if (_buildState.value == GraphViewBuildState.performLayout) {
              _performLayout(context: context, constrains: constraints);
              // During incremental layout show nodes and links so the simulation
              // is visible as it converges.
              elements = _isIncrementalLayoutRunning
                  ? [..._graph.nodes, ..._graph.links]
                  : [..._graph.nodes];
              // When incremental layout is running, the ticker controls the
              // transition to ready — don't schedule a competing postFrameCallback.
              if (!_isIncrementalLayoutRunning && !_isGeometryUpdateScheduled) {
                _isGeometryUpdateScheduled = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    logDebug(
                      LogCategory.rendering,
                      'PostFrameCallback in performLayout phase',
                    );
                    _updateGraphGeometry();
                    _setBuildState(GraphViewBuildState.ready);
                    _isGeometryUpdateScheduled = false;
                  }
                });
              }
            } else {
              elements = [..._graph.nodes, ..._graph.links];
            }

            // Sort by stackOrder only when the order has changed.
            if (_sortDirty || _sortedElements == null) {
              elements.sort((a, b) => a.stackOrder.compareTo(b.stackOrder));
              _sortedElements = elements;
              _sortDirty = false;
            } else {
              elements = _sortedElements!;
            }

            return KeyedSubtree(
              key: ValueKey(_graph.hashCode),
              child: _buildCommonProviders(
                context,
                constrains: constraints,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Stack(
                        key: _layoutKey,
                        children: elements.map((e) {
                          if (e is GraphNodeImpl) {
                            return _buildNodeView(context, constraints, e);
                          } else if (e is GraphLinkImpl) {
                            return _buildLinkView(context, e);
                          } else {
                            throw StateError('Unknown element: $e');
                          }
                        }).toList(),
                      ),
                    ),
                    Positioned.fill(
                      child: GraphInteractiveOverlay(
                        graph: _graph,
                        behavior: widget.behavior,
                        viewportSize: constraints.biggest,
                        nodeTooltipTriggerMode:
                            _nodeViewBehavior.tooltipBehavior?.triggerMode,
                        linkTooltipTriggerMode:
                            _linkViewBehavior.tooltipBehavior?.triggerMode,
                        gestureMode: widget.gestureMode,
                        shouldConsumeGesture: widget.shouldConsumeGesture,
                        onBackgroundTapped: widget.onBackgroundTapped,
                        onBackgroundPanStart: widget.onBackgroundPanStart,
                        onBackgroundPanUpdate: widget.onBackgroundPanUpdate,
                        onBackgroundPanEnd: widget.onBackgroundPanEnd,
                        dragDeltaTransform: widget.dragDeltaTransform,
                        globalToScene: widget.globalToScene,
                        onTooltipShow: (entity) {
                          _entityIdShowingTooltip = entity.id;
                        },
                        onTooltipHide: (entity) {
                          _entityIdShowingTooltip = null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCommonProviders(
    BuildContext context, {
    required BoxConstraints constrains,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: _graph,
      builder: (context, _) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        logDebug(
          LogCategory.rendering,
          '_buildCommonProviders AnimatedBuilder.builder called at $timestamp',
        );
        return GraphInheritedData(
          data: _data,
          buildState: _buildState.value,
          behavior: widget.behavior,
          nodeViewBehavior: _nodeViewBehavior,
          linkViewBehavior: _linkViewBehavior,
          constraints: constrains,
          graph: _graph,
          globalToScene: widget.globalToScene,
          child: child,
        );
      },
    );
  }

  Widget _buildNodeView(
    BuildContext context,
    BoxConstraints constraints,
    GraphNodeImpl node,
  ) {
    final key = _nodeKeys[node.id] ??= GlobalKey();
    node.animationStartPosition = _getNodeAnimationStartPosition(constraints);

    return _nodeViews[node.id] = GraphNodeView(
      key: key,
      node: node,
      behavior: _nodeViewBehavior,
      animationEnabled: _animationEnabled,
      animationDuration: widget.nodeAnimationDuration,
      animationCurve: widget.nodeAnimationCurve,
      showTooltip: _entityIdShowingTooltip == node.id,
      buildState: _buildState,
    );
  }

  Widget _buildLinkView(BuildContext context, GraphLinkImpl link) {
    final sourceView = _nodeViews[link.source.id];
    final targetView = _nodeViews[link.target.id];
    // During incremental layout the node views may not have been built yet.
    if (sourceView == null || targetView == null)
      return const SizedBox.shrink();
    final key = _linkKeys[link.id] ??= GlobalKey();
    return GraphLinkView(
      key: key,
      link: link,
      sourceView: sourceView,
      targetView: targetView,
      behavior: _linkViewBehavior,
    );
  }
}
