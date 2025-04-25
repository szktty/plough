import 'package:example/app_state.dart';
import 'package:flutter/material.dart';
import 'package:platform/platform.dart';
import 'package:plough/plough.dart';
import 'package:provider/provider.dart';

// lib/widget/graph_area.dart
class GraphArea extends StatelessWidget {
  const GraphArea({super.key});

  @override
  Widget build(BuildContext context) {
    // Providerを使用してデータを監視
    return Consumer<AppState>(
      builder: (context, state, child) {
        return GraphView(
          graph: state.selectedData.graph,
          layoutStrategy: state.selectedData.layoutStrategy,
          behavior: GraphAreaBehavior(
            linkRouting: state.selectedData.linkRouting,
          ),
          allowSelection: true,
        );
      },
    );
  }
}

class GraphAreaBehavior extends GraphViewDefaultBehavior {
  GraphAreaBehavior({super.linkRouting});

  @override
  GraphNodeViewBehavior createNodeViewBehavior() {
    const platform = LocalPlatform();
    return GraphNodeViewBehavior.defaultBehavior(
      tooltipTriggerMode: platform.isAndroid || platform.isIOS
          ? GraphTooltipTriggerMode.tap
          : GraphTooltipTriggerMode.hover,
      tooltipBuilder: (context, node) => Padding(
        padding: const EdgeInsets.all(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 280,
          ),
          child: GraphTooltip(
            node: node as GraphNode,
            contentBuilder: (context, node) {
              return Text(
                (node['description'] as String?) ?? 'No description',
                style: const TextStyle(color: Colors.black),
              );
            },
          ),
        ),
      ),
      nodeRendererBuilder: (context, graph, node, child) {
        final state = context.read<AppState>();
        return state.selectedData.nodeRendererBuilder(context, node, child);
      },
    );
  }

  @override
  void onNodeSelect(List<GraphNode> nodes, {required bool isSelected}) {
    super.onNodeSelect(nodes, isSelected: isSelected);
    if (nodes.isNotEmpty) {
      debugPrint(
          '[GraphAreaBehavior] Node selection changed: ${nodes.map((n) => n.id.toString()).join(', ')} - isSelected: $isSelected');
    }
  }

  @override
  void onNodeTap(List<GraphNode> nodes) {
    super.onNodeTap(nodes);
    if (nodes.isNotEmpty) {
      debugPrint(
          '[GraphAreaBehavior] Node tapped: ${nodes.map((n) => n.id.toString()).join(', ')}');
    }
  }
}
