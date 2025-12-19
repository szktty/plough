import 'package:flutter/widgets.dart';
import 'package:plough/src/graph/node.dart';
import 'package:plough/src/graph_view/shape.dart';

/// Widget that displays a circular node.
///
/// * [node]: Target node
/// * [radius]: Circle radius (optional)
/// * [child]: Child widget to display inside the circle
class GraphCircleNodeView extends StatelessWidget {
  const GraphCircleNodeView({
    required this.node,
    required this.child,
    this.radius,
    super.key,
  });

  final GraphNode node;
  final double? radius;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    (node as GraphNodeImpl).shape = GraphCircle(radius: radius);
    return child ?? const SizedBox();
  }
}

/// Widget that displays a rectangular node.
///
/// * [node]: Target node
/// * [child]: Child widget to display inside the rectangle
class GraphRectangleNodeView extends StatelessWidget {
  const GraphRectangleNodeView({
    required this.node,
    required this.child,
    super.key,
  });

  final GraphNode node;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    (node as GraphNodeImpl).shape = const GraphRectangle();
    return child ?? const SizedBox();
  }
}
