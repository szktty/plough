import 'package:flutter/cupertino.dart';
import 'package:plough/plough.dart';

typedef SampleDataNodeRendererBuilder = GraphDefaultNodeRenderer Function(
  BuildContext context,
  GraphNode node,
  Widget? child,
);

class SampleData {
  const SampleData({
    required this.name,
    required this.graph,
    required this.layoutStrategy,
    SampleDataNodeRendererBuilder? nodeRendererBuilder,
    this.linkRouting = GraphLinkRouting.straight,
  }) : _nodeRendererBuilder = nodeRendererBuilder;

  final String name;
  final Graph graph;
  final GraphLayoutStrategy layoutStrategy;
  final GraphLinkRouting linkRouting;

  SampleDataNodeRendererBuilder get nodeRendererBuilder =>
      _nodeRendererBuilder ?? _baseNodeRenderer;

  final SampleDataNodeRendererBuilder? _nodeRendererBuilder;

  GraphDefaultNodeRenderer _baseNodeRenderer(
    BuildContext context,
    GraphNode node,
    Widget? child,
  ) {
    return GraphDefaultNodeRenderer(
      node: node,
      child: SizedBox(
        width: 40,
        child: Center(
          child: Text(
            '${node['label']}',
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }

  String get layoutName {
    if (layoutStrategy is GraphForceDirectedLayoutStrategy) {
      return 'Force Directed';
    } else if (layoutStrategy is GraphRandomLayoutStrategy) {
      return 'Random';
    } else if (layoutStrategy is GraphTreeLayoutStrategy) {
      return 'Tree';
    } else if (layoutStrategy is GraphManualLayoutStrategy) {
      return 'Manual';
    } else if (layoutStrategy is GraphCustomLayoutStrategy) {
      return 'Custom';
    } else {
      throw UnimplementedError('Unknown layout strategy');
    }
  }
}
