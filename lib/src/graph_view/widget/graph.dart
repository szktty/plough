import 'package:flutter/material.dart';
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
class GraphViewState extends State<GraphView> {
  late GraphViewData _data;

  GraphImpl get _graph => widget.graph as GraphImpl;

  final ValueNotifier<GraphViewBuildState> _buildState =
      ValueNotifier(GraphViewBuildState.initialize);

  void _setBuildState(GraphViewBuildState newState) {
    if (_buildState.value != newState) {
      debugPrint(
          '🏗️ GraphView _buildState changed: ${_buildState.value} -> $newState');
      _buildState.value = newState;
    }
  }

  GraphLayoutStrategy get _layoutStrategy => widget.layoutStrategy;
  GraphLayoutStrategy? _oldLayoutStrategy;

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

  @override
  void initState() {
    super.initState();
    _initBehavior();
  }

  @override
  void dispose() {
    _buildState.dispose();
    super.dispose();
  }

  void _initBehavior() {
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
  }

  @override
  void didUpdateWidget(covariant GraphView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // より厳密な条件でのみ再初期化を行う
    final needsReinit = widget.graph != oldWidget.graph ||
        widget.layoutStrategy.runtimeType !=
            oldWidget.layoutStrategy.runtimeType ||
        widget.behavior.runtimeType != oldWidget.behavior.runtimeType ||
        widget.behavior != oldWidget.behavior; // Also check for instance changes

    if (needsReinit) {
      debugPrint(
          '🔄 GraphView didUpdateWidget: reinitializing behavior (reason: graph=${widget.graph != oldWidget.graph}, layout=${widget.layoutStrategy.runtimeType != oldWidget.layoutStrategy.runtimeType}, behavior=${widget.behavior.runtimeType != oldWidget.behavior.runtimeType}, instance=${widget.behavior != oldWidget.behavior})');
      _initBehavior();
    } else {
      debugPrint(
          '🔄 GraphView didUpdateWidget: skipping reinit (no significant changes)');
    }
  }

  void _updateGraphGeometry() {
    WidgetUtils.withSizedRenderBoxIfPresent(_layoutKey, (renderBox) {
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      final newGeometry = GraphViewGeometry(
        position: position,
        size: size,
      );

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
        final position =
            renderBox.localToGlobal(Offset.zero) - _graph.geometry!.position;
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
      // Enable animation only when explicitly requested AND widget allows it
      final shouldAnimateLayout =
          widget.animationEnabled && _graph.shouldAnimateLayout;

      if (shouldAnimateLayout) {
        logDebug(LogCategory.layout,
            'GraphView: Enabling animation - explicitly requested');
        _layoutStrategy.nodeAnimationStartPosition =
            _getNodeAnimationStartPosition(constrains);
        // Reset animation states for all nodes
        for (final node in _graph.nodes) {
          (node as GraphNodeImpl).resetAnimationState();
        }
      } else {
        logDebug(LogCategory.layout,
            'GraphView: Skipping animation - not requested (widget.animationEnabled=${widget.animationEnabled}, graph.shouldAnimateLayout=${_graph.shouldAnimateLayout})');
      }
      _layoutStrategy.performLayout(
        _graph,
        Size(constrains.maxWidth, constrains.maxHeight),
      );
      _oldLayoutStrategy = _layoutStrategy;
      _graph.onLayoutFinished();
    } else {
      // Layout not performed, ensure nodes are not stuck in animating state
      for (final node in _graph.nodes) {
        final nodeImpl = node as GraphNodeImpl;
        if (nodeImpl.isAnimating && !nodeImpl.isAnimationCompleted) {
          // Force complete any lingering animations
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
          animation:
              Listenable.merge([_graph.layoutChangeListenable, _buildState]),
          builder: (context, child) {
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            debugPrint(
                '🔄 GraphView AnimatedBuilder.builder called at $timestamp, buildState: ${_buildState.value}');
            logDebug(LogCategory.rendering,
                'AnimatedBuilder.builder called at $timestamp, buildState: ${_buildState.value}');
            late List<GraphEntity> elements;
            if (_buildState.value == GraphViewBuildState.initialize) {
              if (!_isGeometryUpdateScheduled) {
                _isGeometryUpdateScheduled = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    logDebug(LogCategory.rendering,
                        'PostFrameCallback in initialize phase');
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
              elements = [..._graph.nodes];
              if (!_isGeometryUpdateScheduled) {
                _isGeometryUpdateScheduled = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    logDebug(LogCategory.rendering,
                        'PostFrameCallback in performLayout phase');
                    _updateGraphGeometry();
                    _setBuildState(GraphViewBuildState.ready);
                    _isGeometryUpdateScheduled = false;
                  }
                });
              }
            } else {
              elements = [..._graph.nodes, ..._graph.links];
            }

            elements.sort((a, b) => a.stackOrder.compareTo(b.stackOrder));

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
        logDebug(LogCategory.rendering,
            '_buildCommonProviders AnimatedBuilder.builder called at $timestamp');
        return GraphInheritedData(
          data: _data,
          buildState: _buildState.value,
          behavior: widget.behavior,
          nodeViewBehavior: _nodeViewBehavior,
          linkViewBehavior: _linkViewBehavior,
          constraints: constrains,
          graph: _graph,
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
    final key = _linkKeys[link.id] ??= GlobalKey();
    return GraphLinkView(
      key: key,
      link: link,
      sourceView: _nodeViews[link.source.id]!,
      targetView: _nodeViews[link.target.id]!,
      behavior: _linkViewBehavior,
    );
  }
}
