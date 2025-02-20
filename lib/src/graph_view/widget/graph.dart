import 'package:flutter/material.dart';
import 'package:plough/src/graph/entity.dart';
import 'package:plough/src/graph/graph_base.dart';
import 'package:plough/src/graph/id.dart';
import 'package:plough/src/graph/link.dart';
import 'package:plough/src/graph/node.dart';
import 'package:plough/src/graph_view/behavior.dart';
import 'package:plough/src/graph_view/data.dart';
import 'package:plough/src/graph_view/geometry.dart';
import 'package:plough/src/graph_view/widget/link.dart';
import 'package:plough/src/graph_view/widget/node.dart';
import 'package:plough/src/interactive/widget/interactive_overlay.dart';
import 'package:plough/src/layout_strategy/base.dart';
import 'package:plough/src/utils/logger.dart';
import 'package:plough/src/utils/widget.dart';
import 'package:provider/provider.dart';
import 'package:signals/signals_flutter.dart';

/// Build state of the graph view.
enum GraphViewBuildState {
  /// Initial state, renders transparent for geometry calculation
  initialize,

  /// Executing layout algorithm
  performLayout,

  /// Ready for rendering
  ready;

  static GraphViewBuildState of(BuildContext context) {
    return Provider.of<GraphViewBuildState>(context, listen: false);
  }
}

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
class GraphViewState extends State<GraphView> with SignalsMixin {
  late GraphViewData _data;

  GraphImpl get _graph => widget.graph as GraphImpl;

  final _buildState = signal(GraphViewBuildState.initialize);

  GraphLayoutStrategy get _layoutStrategy => widget.layoutStrategy;
  GraphLayoutStrategy? _oldLayoutStrategy;

  bool get _animationEnabled => widget.animationEnabled;

  late GraphNodeViewBehavior _nodeViewBehavior;
  late GraphLinkViewBehavior _linkViewBehavior;

  final _layoutKey = GlobalKey();

  final Map<GraphId, GlobalKey> _nodeKeys = {};
  final Map<GraphId, Widget> _nodeViews = {};

  // TODO: Not used
  final Map<GraphId, GlobalKey> _linkKeys = {};

  GraphId? _entityIdShowingTooltip;

  @override
  void initState() {
    super.initState();
    _initBehavior();
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
    _buildState.value = GraphViewBuildState.initialize;
    _nodeViews.clear();
  }

  @override
  void didUpdateWidget(covariant GraphView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.graph != oldWidget.graph ||
        widget.layoutStrategy != oldWidget.layoutStrategy ||
        widget.behavior != oldWidget.behavior) {
      _initBehavior();
    }
  }

  void _updateGraphGeometry() {
    WidgetUtils.withSizedRenderBoxIfPresent(_layoutKey, (renderBox) {
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      _graph.geometry = GraphViewGeometry(
        position: position,
        size: size,
      );
      log
        ..d('GraphView: update geometry')
        ..d('    position: $position')
        ..d('    size: $size');
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
        node.geometry = GraphNodeViewGeometry(bounds: bounds);
        log
          ..d('GraphView: update node geometry')
          ..d('    node: ${node.id}')
          ..d('    position: $position')
          ..d('    size: ${renderBox.size}');
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
    log.d('GraphView: perform layout');

    if (_graph.needsLayout ||
        _oldLayoutStrategy == null ||
        !_layoutStrategy.isSameStrategy(_oldLayoutStrategy!) ||
        _layoutStrategy.shouldRelayout(_oldLayoutStrategy!)) {
      if (widget.animationEnabled) {
        _layoutStrategy.nodeAnimationStartPosition =
            _getNodeAnimationStartPosition(constrains);
      }
      _layoutStrategy.performLayout(
        _graph,
        Size(constrains.maxWidth, constrains.maxHeight),
      );
      _oldLayoutStrategy = _layoutStrategy;
      _graph.onLayoutFinished();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Watch((context) {
          late List<GraphEntity> elements;
          if (_buildState.value == GraphViewBuildState.initialize) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _updateGraphGeometry();
                _updateNodeGeometry();
                _buildState.value = GraphViewBuildState.performLayout;
              });
            });
            elements = [..._graph.nodes];
          } else if (_buildState.value == GraphViewBuildState.performLayout) {
            _performLayout(context: context, constrains: constraints);
            elements = [..._graph.nodes];
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _updateGraphGeometry();
                _buildState.value = GraphViewBuildState.ready;
              });
            });
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
                      onTooltipShow: (entity) {
                        setState(() {
                          _entityIdShowingTooltip = entity.id;
                        });
                      },
                      onTooltipHide: (entity) {
                        setState(() {
                          _entityIdShowingTooltip = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildCommonProviders(
    BuildContext context, {
    required BoxConstraints constrains,
    required Widget child,
  }) {
    return MultiProvider(
      providers: [
        Provider.value(value: _data),
        Provider.value(value: _buildState.value),
        Provider.value(value: widget.behavior),
        Provider.value(value: _nodeViewBehavior),
        Provider.value(value: _linkViewBehavior),
        Provider.value(value: constrains),
        ListenableProvider.value(value: _graph),
      ],
      child: child,
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
