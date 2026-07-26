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
import 'package:plough/src/viewport/widget/viewport.dart'
    show GraphViewportCanvasMode;
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
    this.suppressDragMovement = false,
    this.globalToScene,
    this.canvasMode = GraphViewportCanvasMode.bounded,
    this.debugShowBorder = false,
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

  /// Transforms a drag delta from screen pixels to scene (logical) coordinates.
  ///
  /// Typically `(delta) => delta / viewportController.scale` when a
  /// [GraphViewport] is in use.  When null, deltas are used as-is.
  final Offset Function(Offset delta)? dragDeltaTransform;

  /// When true, drags report their progress but do not move the entity.
  ///
  /// Set this while a drag means something other than "move" — drawing a link
  /// from a node, for instance. See
  /// [GraphGestureManager.suppressDragMovement].
  final bool suppressDragMovement;

  /// Converts a global screen position to scene coordinates.
  ///
  /// Used by [GraphGestureManager] for node hit-testing.  When null, local
  /// positions are used directly.
  final Offset Function(Offset globalPosition)? globalToScene;

  /// When true, draws a red border around the GraphView bounds for debugging.
  final bool debugShowBorder;

  /// Canvas mode controlling node boundary behaviour.
  ///
  /// - [GraphViewportCanvasMode.bounded]: nodes snap back when dragged outside
  ///   the initial bounds.
  /// - [GraphViewportCanvasMode.infinite]: nodes can be placed anywhere; the
  ///   scene grows by panning (owned by [GraphViewport]'s controller), so no
  ///   snap-back occurs here.
  final GraphViewportCanvasMode canvasMode;

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
class GraphViewState extends State<GraphView> with TickerProviderStateMixin {
  late GraphViewData _data;

  GraphImpl get _graph => widget.graph as GraphImpl;

  // Snap-back boundary for bounded mode, in scene pixels.  Set once to the
  // initial viewport size on first layout and never changed.  In infinite mode
  // it is unused (the scene rect, and thus the pannable region, is owned by the
  // GraphViewport controller instead).
  Size _canvasSize = Size.zero;

  // Per-node snap-back positions: original logicalPosition before a drag.
  final Map<GraphId, Offset> _dragStartPositions = {};

  Size get canvasSize => _canvasSize;

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
  final Map<GraphId, GlobalKey> _linkKeys = {};

  /// Number of cached node/link entries. Exposed for tests that verify removed
  /// entities are pruned from the caches (see [_pruneRemovedEntityCaches]).
  @visibleForTesting
  int get debugCachedEntityCount =>
      _nodeKeys.length + _nodeViews.length + _linkKeys.length;

  GraphId? _entityIdShowingTooltip;

  bool _isGeometryUpdateScheduled = false;

  // True when a non-incremental layout has just been computed during build and
  // its completion (graph state update + listener notification) still needs to
  // run.  The notification is deferred to a post-frame callback so it does not
  // mark other listeners (e.g. a GraphViewport's AnimatedBuilder) dirty while
  // the framework is still building.
  bool _layoutFinishPending = false;

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
  void didUpdateWidget(covariant GraphView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reinitialize only under stricter conditions
    final needsReinit = widget.graph != oldWidget.graph ||
        widget.layoutStrategy.runtimeType !=
            oldWidget.layoutStrategy.runtimeType ||
        !widget.behavior.isEquivalentTo(oldWidget.behavior);
    if (needsReinit) {
      _initBehavior();
    }
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
        // Bounds live in logical (scene) space: position comes straight from
        // the node's logical position (the same value used to lay it out), and
        // the rendered size is used as-is.  Nodes are laid out inside the
        // viewport's Transform, which only scales at paint time — it does not
        // affect layout — so renderBox.size is already in logical units and
        // must NOT be divided by scale.  Dividing shrank the bounds while
        // zoomed, which made links briefly jump on drag start (this geometry
        // path runs in refreshAllNodeGeometry) and pulled link endpoints into
        // the node.  Keeping it raw makes bounds invariant under pan/zoom so
        // hit-testing — which compares against logical hit positions — stays
        // correct at any scale.
        final pos = node.logicalPosition;
        final bounds = Rect.fromLTWH(
          pos.dx,
          pos.dy,
          renderBox.size.width,
          renderBox.size.height,
        );
        final newGeometry = GraphNodeViewGeometry(bounds: bounds);
        if (node.geometry == null || node.geometry!.bounds != bounds) {
          node.geometry = newGeometry;
          logDebug(LogCategory.rendering, 'GraphView: update node geometry');
          logDebug(LogCategory.rendering, '    node: ${node.id}');
          logDebug(LogCategory.rendering, '    logicalPos: $pos');
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
    // Notify so GraphInteractiveOverlay rebuilds the spatial hit-test index
    // with the updated node bounds.
    _graph.notifyLayoutStep();
  }

  /// Records the node's current position before a drag starts.
  void recordDragStart(GraphId nodeId) {
    final node = _graph.getNode(nodeId) as GraphNodeImpl?;
    if (node != null) {
      _dragStartPositions[nodeId] = node.logicalPosition;
    }
  }

  /// Called when a node drag ends.
  ///
  /// In [GraphViewportCanvasMode.bounded] mode: if the node ends up outside the
  /// snap-back boundary, restore it to its pre-drag position.
  /// In [GraphViewportCanvasMode.infinite] mode: nodes may be placed anywhere,
  /// so nothing is restored — the scene is grown by panning, owned by the
  /// [GraphViewport] controller.
  void handleDragEnd(GraphId nodeId) {
    final node = _graph.getNode(nodeId) as GraphNodeImpl?;
    if (node == null) return;

    if (widget.canvasMode == GraphViewportCanvasMode.bounded &&
        _canvasSize != Size.zero) {
      final pos = node.logicalPosition;
      final canvas = _canvasSize;
      final outside = pos.dx < 0 ||
          pos.dy < 0 ||
          pos.dx > canvas.width ||
          pos.dy > canvas.height;
      if (outside) {
        final original = _dragStartPositions[nodeId];
        if (original != null) {
          node.logicalPosition = original;
          _graph.notifyLayoutStep();
        }
      }
    }

    _dragStartPositions.remove(nodeId);

    // geometry.bounds is already correct (a logical-space invariant), but the
    // gesture manager's spatial hit-test index is only rebuilt on a layout
    // notification.  Without this, a node dragged to a new location — most
    // visibly one dragged outside the viewport — keeps its old index cell and
    // becomes unhittable at its new position.  refreshAllNodeGeometry() ends
    // with notifyLayoutStep(), which triggers the index rebuild.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) refreshAllNodeGeometry();
    });
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
      // Defer onLayoutFinished (which notifies GraphData listeners) to the
      // post-frame callback below: calling it here notifies listeners during
      // build, which throws "setState() called during build" for any other
      // widget (e.g. a GraphViewport) listening to the same graph.
      _layoutFinishPending = true;
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
        return _buildWithConstraints(context, constraints);
      },
    );
  }

  Widget _buildWithConstraints(
      BuildContext context, BoxConstraints constraints) {
    // Initialise canvas size to viewport size on first layout.
    if (_canvasSize == Size.zero) {
      _canvasSize = constraints.biggest;
    }
    return AnimatedBuilder(
      animation: Listenable.merge([
        _graph.layoutChangeListenable,
        _buildState,
      ]),
      builder: (context, child) {
        _markSortDirty();
        late List<GraphEntity> elements;
        if (_buildState.value == GraphViewBuildState.initialize) {
          if (!_isGeometryUpdateScheduled) {
            _isGeometryUpdateScheduled = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
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
          elements = _isIncrementalLayoutRunning
              ? [..._graph.nodes, ..._graph.links]
              : [..._graph.nodes];
          if (!_isIncrementalLayoutRunning && !_isGeometryUpdateScheduled) {
            _isGeometryUpdateScheduled = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                if (_layoutFinishPending) {
                  _layoutFinishPending = false;
                  _graph.onLayoutFinished();
                }
                _updateGraphGeometry();
                _setBuildState(GraphViewBuildState.ready);
                _isGeometryUpdateScheduled = false;
              }
            });
          }
        } else {
          elements = [..._graph.nodes, ..._graph.links];
        }

        if (_sortDirty || _sortedElements == null) {
          elements.sort((a, b) => a.stackOrder.compareTo(b.stackOrder));
          _sortedElements = elements;
          _sortDirty = false;
        } else {
          elements = _sortedElements!;
        }

        _pruneRemovedEntityCaches();

        final graphContent = _buildCommonProviders(
          context,
          constrains: constraints,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Stack(
                key: _layoutKey,
                clipBehavior: Clip.none,
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
                  suppressDragMovement: widget.suppressDragMovement,
                  globalToScene: widget.globalToScene,
                  onNodeDragStart: recordDragStart,
                  onNodeDragEnd: handleDragEnd,
                  onTooltipShow: (entity) {
                    _entityIdShowingTooltip = entity.id;
                  },
                  onTooltipHide: (entity) {
                    _entityIdShowingTooltip = null;
                  },
                ),
              ),
              if (widget.debugShowBorder)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFF44336),
                          width: 3,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            'GraphView',
                            style: TextStyle(
                              color: const Color(0xFFF44336),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              background: Paint()
                                ..color = const Color(0x88F44336),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );

        return KeyedSubtree(
          // Key on the stable graph id, not hashCode: hashCode can collide
          // across different graphs and is not guaranteed stable, which would
          // make the subtree key unreliable on graph swaps.
          key: ValueKey(_graph.id),
          child: graphContent,
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

  /// Drops cached views/keys for nodes and links that no longer exist in the
  /// graph. Without this, `_nodeKeys`/`_linkKeys` (and stale `_nodeViews`
  /// entries) grow monotonically as entities are removed, leaking GlobalKeys
  /// and widgets for the lifetime of the GraphView.
  void _pruneRemovedEntityCaches() {
    final liveNodeIds = _graph.nodes.map((n) => n.id).toSet();
    final liveLinkIds = _graph.links.map((l) => l.id).toSet();

    _nodeKeys.removeWhere((id, _) => !liveNodeIds.contains(id));
    _nodeViews.removeWhere((id, _) => !liveNodeIds.contains(id));
    _linkKeys.removeWhere((id, _) => !liveLinkIds.contains(id));
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
