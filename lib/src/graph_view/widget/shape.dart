import 'package:flutter/widgets.dart';
import 'package:plough/src/graph/node.dart';
import 'package:plough/src/graph_view/shape.dart';

/// 円形のノードを表示するウィジェット。
///
/// * [node]: 対象のノード
/// * [radius]: 円の半径（オプション）
/// * [child]: 円の中に表示する子ウィジェット
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

/// 矩形のノードを表示するウィジェット。
///
/// * [node]: 対象のノード
/// * [child]: 矩形の中に表示する子ウィジェット
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
