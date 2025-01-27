import 'package:flutter/material.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/graph/node.dart';
import 'package:plough/src/graph_view/widget/shape.dart';
import 'package:signals/signals_flutter.dart';

/// A builder function type for customizing node rendering.
///
/// Use this builder to implement custom node appearances, such as
/// conditional displays or dynamic layouts.
typedef GraphDefaultNodeRendererWidgetBuilder = Widget Function(
  BuildContext context,
  Graph graph,
  GraphNode node,
  Widget? child,
);

/// A highly customizable default node widget used by [GraphNodeViewBehavior].
///
/// This widget provides a practical implementation that covers most common use cases
/// while remaining fully customizable through style options and builder patterns.
/// Used as the default node renderer in [GraphNodeViewBehavior], but can be replaced
/// with custom widgets if needed.
///
/// Provides circle and rectangle shapes, comprehensive styling options, state management
/// (selection, hover, highlight), and content customization through builder pattern.
///
/// Example:
/// ```dart
/// GraphDefaultNodeRenderer(
///   node: node,
///   style: const GraphDefaultNodeRendererStyle(),
///   child: Text(node['label']),
/// )
/// ```
///
/// See also:
/// * [GraphNodeViewBehavior] for the core node view system
/// * [GraphCircleNodeView] and [GraphRectangleNodeView] for shape models
class GraphDefaultNodeRenderer extends StatefulWidget {
  /// Creates a node renderer with the specified configuration.
  ///
  /// The [node] parameter is required, while [builder], [child], [style], and
  /// [tooltip] are optional.
  const GraphDefaultNodeRenderer({
    required this.node,
    this.builder,
    this.child,
    this.style = const GraphDefaultNodeRendererStyle(),
    this.tooltip,
    super.key,
  });

  /// The node to render.
  final GraphNode node;

  /// Custom builder function for node content.
  final GraphDefaultNodeRendererWidgetBuilder? builder;

  /// Content widget for the node.
  final Widget? child;

  /// Tooltip widget shown on configured gesture.
  final Widget? tooltip;

  /// Style configuration for the node.
  final GraphDefaultNodeRendererStyle style;

  @override
  State<StatefulWidget> createState() => _GraphDefaultNodeRendererState();
}

class _GraphDefaultNodeRendererState extends State<GraphDefaultNodeRenderer> {
  final _rectangleKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final style = widget.style;
      final node = widget.node;
      final geometry = (node as GraphNodeImpl).geometry;
      final radius =
          style.radius ?? (geometry != null ? geometry.bounds.width / 2 : 0);
      final child = widget.builder != null
          ? widget.builder!(context, node.graph!, node, widget.child)
          : widget.child;
      switch (style.shape) {
        case GraphDefaultNodeRendererShape.circle:
          return IntrinsicWidth(
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: node.isSelected
                        ? style.selectedBorderColor
                        : Colors.transparent,
                    width: style.selectedBorderWidth,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: style.color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: style.borderColor,
                      width: style.borderWidth,
                    ),
                  ),
                  width: style.width,
                  height: style.height,
                  child: GraphCircleNodeView(
                    node: node,
                    radius: radius,
                    child: child,
                  ),
                ),
              ),
            ),
          );
        case GraphDefaultNodeRendererShape.rectangle:
          return Container(
            constraints: BoxConstraints(
              minWidth: style.minWidth,
              minHeight: style.minHeight,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: node.isSelected
                    ? style.selectedBorderColor
                    : Colors.transparent,
                width: style.selectedBorderWidth,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: style.color,
                border: Border.all(
                  color: style.borderColor,
                  width: style.borderWidth,
                ),
              ),
              width: style.width,
              height: style.height,
              child: GraphRectangleNodeView(
                key: _rectangleKey,
                node: node,
                child: child,
              ),
            ),
          );
      }
    });
  }
}
