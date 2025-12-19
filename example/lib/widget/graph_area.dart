import 'dart:math' as math;

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
    // Monitor data using Provider
    return Consumer<AppState>(
      builder: (context, state, child) {
        return GraphView(
          graph: state.selectedData.graph,
          layoutStrategy: state.selectedData.layoutStrategy,
          behavior: GraphAreaBehavior(
            linkRouting: state.selectedData.linkRouting,
            appState: state,
          ),
          allowSelection: true,
        );
      },
    );
  }
}

class GraphAreaBehavior extends GraphViewDefaultBehavior {
  GraphAreaBehavior({
    required this.appState,
    super.linkRouting,
  });

  final AppState appState;

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
        return appState.selectedData.nodeRendererBuilder(context, node, child);
      },
    );
  }

  @override
  void onSelectionChange(GraphSelectionChangeEvent event) {
    super.onSelectionChange(event);

    if (event.selectedIds.isNotEmpty || event.deselectedIds.isNotEmpty) {
      // Shorten IDs for cleaner debug output
      String idStr(GraphId id) =>
          id.value.substring(0, math.min(4, id.value.length));
      debugPrint('Selection changed: '
          'Selected: ${event.selectedIds.map(idStr).join(', ')}, '
          'Deselected: ${event.deselectedIds.map(idStr).join(', ')}, '
          'Current: ${event.currentSelectionIds.map(idStr).join(', ')}');
    }
  }

  @override
  void onTap(GraphTapEvent event) {
    super.onTap(event);
    if (event.entityIds.isNotEmpty) {
      final graph = appState.selectedData.graph;
      final isNodeTap = graph.getNode(event.entityIds.first) != null;
      final type = isNodeTap ? 'Node' : 'Link';
      String idStr(GraphId id) =>
          id.value.substring(0, math.min(4, id.value.length));
      debugPrint(
        '$type tapped (${event.tapCount}x): ${event.entityIds.map(idStr).join(', ')} at ${event.details.localPosition}',
      );
    }
  }

  @override
  void onDragStart(GraphDragStartEvent event) {
    super.onDragStart(event);
    if (event.entityIds.isNotEmpty) {
      String idStr(GraphId id) =>
          id.value.substring(0, math.min(4, id.value.length));
      debugPrint(
        'Drag started for: ${event.entityIds.map(idStr).join(', ')} from ${event.details.localPosition}',
      );
    }
  }

  @override
  void onDragEnd(GraphDragEndEvent event) {
    super.onDragEnd(event);
    if (event.entityIds.isNotEmpty) {
      String idStr(GraphId id) =>
          id.value.substring(0, math.min(4, id.value.length));
      debugPrint(
        'Drag ended for: ${event.entityIds.map(idStr).join(', ')} at ${event.details.localPosition}',
      );
    }
  }

  @override
  void onHoverEnter(GraphHoverEvent event) {
    super.onHoverEnter(event);
    final graph = appState.selectedData.graph;
    final entityType = graph.getNode(event.entityId) != null ? 'Node' : 'Link';
    String idStr(GraphId id) =>
        id.value.substring(0, math.min(4, id.value.length));
    debugPrint(
      'Hover Enter $entityType: ${idStr(event.entityId)} at ${event.details.localPosition}',
    );
  }

  @override
  void onHoverEnd(GraphHoverEndEvent event) {
    super.onHoverEnd(event);
    final graph = appState.selectedData.graph;
    final entityType = graph.getNode(event.entityId) != null ? 'Node' : 'Link';
    String idStr(GraphId id) =>
        id.value.substring(0, math.min(4, id.value.length));
    debugPrint(
      'Hover End $entityType: ${idStr(event.entityId)} at ${event.details.localPosition}',
    );
  }

  @override
  void onTooltipShow(GraphTooltipShowEvent event) {
    super.onTooltipShow(event);
    final graph = appState.selectedData.graph;
    final entityType = graph.getNode(event.entityId) != null ? 'Node' : 'Link';
    String idStr(GraphId id) =>
        id.value.substring(0, math.min(4, id.value.length));
    debugPrint(
      'Tooltip Show $entityType: ${idStr(event.entityId)} (Trigger: ${event.triggerMode})',
    );
  }

  @override
  void onTooltipHide(GraphTooltipHideEvent event) {
    super.onTooltipHide(event);
    final graph = appState.selectedData.graph;
    final entityType = graph.getNode(event.entityId) != null ? 'Node' : 'Link';
    String idStr(GraphId id) =>
        id.value.substring(0, math.min(4, id.value.length));
    debugPrint(
      'Tooltip Hide $entityType: ${idStr(event.entityId)}',
    );
  }
}
