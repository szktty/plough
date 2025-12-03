import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/graph/graph_base.dart';
import 'package:plough/src/graph/node.dart';
import 'package:plough/src/graph_view/data.dart';
import 'package:plough/src/graph_view/inherited_data.dart';
import 'package:plough/src/tooltip/widget/container.dart';
import 'package:plough/src/utils/widget.dart';
import 'package:plough/src/utils/widget/position_plotter.dart';

/// A widget that renders a node in the graph.
///
/// Features:
/// - Node position and geometry management
/// - Movement animations
/// - Tooltip display
/// - Visibility state management
///
/// This widget should not be used directly - use [GraphView] instead.
///
/// See also:
/// * [GraphView], which manages the complete graph visualization
/// * [GraphNodeViewBehavior], for customizing node appearance
final class GraphNodeView extends StatefulWidget with Diagnosticable {
  const GraphNodeView({
    required this.node,
    required this.behavior,
    required this.animationEnabled,
    required this.animationDuration,
    required this.animationCurve,
    required this.showTooltip,
    required this.buildState,
    super.key,
  });

  /// The node to be rendered.
  final GraphNodeImpl node;

  /// Configuration for node appearance and behavior.
  final GraphNodeViewBehavior behavior;

  /// Whether movement animations are enabled.
  final bool animationEnabled;

  /// Duration of movement animations.
  final Duration animationDuration;

  /// Animation curve for movement.
  final Curve animationCurve;

  /// Whether to show the tooltip.
  final bool showTooltip;

  /// Current build state of the graph view.
  final ValueNotifier<GraphViewBuildState> buildState;

  @override
  State<GraphNodeView> createState() => GraphNodeViewState();
}

/// State class for [GraphNodeView].
///
/// Responsibilities:
/// - Updating node geometry
/// - Managing movement animations
/// - Controlling tooltip display
///
/// See also:
/// * [GraphNodeView], the stateful widget using this state
/// * [GraphNodeViewGeometry], which defines the node's spatial properties
class GraphNodeViewState extends State<GraphNodeView>
    with SingleTickerProviderStateMixin {
  AnimationController? _positionController;
  Animation<Offset>? _positionAnimation;
  bool _previousIsAnimating = false;
  bool _previousIsCompleted = false;
  Offset? _lastAnimatedToPosition; // Track the last position we animated to
  VoidCallback? _animationListener; // Store listener for disposal

  GraphNodeImpl get _node => widget.node;

  GraphImpl? get _graph => _node.graph as GraphImpl?;

  GlobalKey? get _key => widget.key as GlobalKey?;

  GraphDefaultNodeRenderer? _renderer;

  GraphDefaultNodeRenderer? get renderer => _renderer;

  @override
  void initState() {
    super.initState();

    if (widget.animationEnabled) {
      _initializeAnimation();
    }
  }

  void _initializeAnimation() {
    _positionController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _configureAnimationListener();

    void updateAnimationListener() {
      if (_node.isArranged && _node.isAnimationReady) {
        // Only animate if the position has actually changed
        if (_node.logicalPosition != _node.animationStartPosition) {
          _updateAnimationPosition(begin: _node.animationStartPosition);
        }
      }
    }

    // Store listener reference for disposal
    _animationListener = updateAnimationListener;
    // Only listen to layout changes, not all graph changes
    _graph?.layoutChangeListenable.addListener(_animationListener!);
  }

  void _configureAnimationListener() {
    _positionController!.addStatusListener((status) {
      final newIsAnimating = status == AnimationStatus.forward ||
          status == AnimationStatus.reverse;
      final newIsCompleted = status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed;

      _updateAnimationState(newIsAnimating, newIsCompleted);
    });
  }

  @override
  void didUpdateWidget(GraphNodeView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reset tracked position if animation is disabled
    if (!widget.animationEnabled && oldWidget.animationEnabled) {
      _lastAnimatedToPosition = null;
    }
  }

  void _updateAnimationState(bool newIsAnimating, bool newIsCompleted) {
    if (_previousIsAnimating != newIsAnimating) {
      _previousIsAnimating = newIsAnimating;
      _node.isAnimating = newIsAnimating;
    }

    if (_previousIsCompleted != newIsCompleted) {
      _previousIsCompleted = newIsCompleted;
      _node.isAnimationCompleted = newIsCompleted;

      if (newIsCompleted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateGeometry();
        });
      }
    }
  }

  void _updateAnimationPosition({
    required Offset begin,
  }) {
    // Only start a new animation if we're moving to a different position
    if (_lastAnimatedToPosition == _node.logicalPosition) {
      return;
    }

    _lastAnimatedToPosition = _node.logicalPosition;

    _positionAnimation = Tween<Offset>(
      begin: begin,
      end: _node.logicalPosition,
    ).animate(
      CurvedAnimation(
        parent: _positionController!,
        curve: widget.animationCurve,
      ),
    );

    _positionController!
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    // Remove animation listener
    if (_animationListener != null) {
      _graph?.layoutChangeListenable.removeListener(_animationListener!);
    }
    _positionController?.dispose();
    super.dispose();
  }

  GraphNodeViewBehavior get behavior => widget.behavior;

  void _updateGeometry() {
    WidgetUtils.withSizedRenderBoxIfPresent(_key, (renderBox) {
      if (_graph?.geometry == null) return;

      final size = renderBox.size;
      final position =
          renderBox.localToGlobal(Offset.zero) - _graph!.geometry!.position;

      _node.geometry = GraphNodeViewGeometry(
        bounds: Rect.fromLTWH(
          position.dx,
          position.dy,
          size.width,
          size.height,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final graphViewData = GraphViewData.of(context);
    return ValueListenableBuilder<GraphViewBuildState>(
      valueListenable: widget.buildState,
      builder: (context, buildState, _) {
        return AnimatedBuilder(
          animation: _node.positionListenable,
          builder: (context, _) {
            if (buildState == GraphViewBuildState.initialize) {
              return _buildInitialPosition(context);
            }

            if (!_node.isArranged) {
              return _buildPreArrangedPosition(context);
            }

            return AnimatedBuilder(
              animation: _node.renderStateListenable,
              builder: (context, _) {
                return _buildArrangedPosition(context, graphViewData);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildInitialPosition(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateGeometry();
    });

    return Positioned(
      left: -10000,
      top: -10000,
      child: _buildNode(context),
    );
  }

  Widget _buildPreArrangedPosition(BuildContext context) {
    return Positioned(
      left: _node.logicalPosition.dx,
      top: _node.logicalPosition.dy,
      child: Opacity(opacity: 0, child: _buildNode(context)),
    );
  }

  Widget _buildArrangedPosition(
    BuildContext context,
    GraphViewData graphViewData,
  ) {
    final left = _node.logicalPosition.dx;
    final top = _node.logicalPosition.dy;
    final child = _buildTooltipContainer(context, graphViewData.graph, _node);

    // Only show animated position if animation is actually running
    if (widget.animationEnabled &&
        _node.isAnimating &&
        _positionController != null &&
        _positionController!.isAnimating) {
      return _buildAnimatedPosition(child);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateGeometry();
    });

    return Positioned(
      left: left,
      top: top,
      child: child,
    );
  }

  Widget _buildAnimatedPosition(Widget child) {
    return AnimatedBuilder(
      animation: _positionAnimation!,
      builder: (context, _) {
        // Defer animated position update to avoid setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _node.animatedPosition = _positionAnimation!.value;
        });
        _updateNodeGeometryDuringAnimation();

        return Positioned(
          left: _positionAnimation!.value.dx,
          top: _positionAnimation!.value.dy,
          child: child,
        );
      },
      child: child,
    );
  }

  void _updateNodeGeometryDuringAnimation() {
    if (_node.geometry == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateGeometry();
      });
    } else {
      // Defer geometry update to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_node.geometry != null) {
          _node.geometry = GraphNodeViewGeometry(
            bounds: Rect.fromLTWH(
              _node.animatedPosition.dx,
              _node.animatedPosition.dy,
              _node.geometry!.bounds.width,
              _node.geometry!.bounds.height,
            ),
          );
        }
      });
    }
  }

  Widget _buildTooltipContainer(
    BuildContext context,
    Graph graph,
    GraphNode node,
  ) {
    if (widget.showTooltip && behavior.tooltipBehavior != null) {
      return GraphTooltipContainer(
        behavior: behavior.tooltipBehavior,
        entity: node,
        child: _buildNode(context),
      );
    }

    return _buildNode(context);
  }

  Widget _buildNode(BuildContext context) {
    final widget = behavior.builder(context, _graph!, _node, behavior.child);
    if (widget is GraphDefaultNodeRenderer) {
      _renderer = widget;
    }
    return GraphPositionPlotter.wrapOr(
      child: widget,
    );
  }
}
