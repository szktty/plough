import 'package:flutter/material.dart';
import 'package:plough/src/graph/graph.dart';

class GraphTooltip extends StatelessWidget {
  /// Widget for displaying node tooltips.
  ///
  /// Provides tooltips to display additional information about nodes.
  /// Custom display content can be specified using [contentBuilder].
  /// If not specified, the node's `description` property will be displayed.
  ///
  /// Example usage:
  /// ```dart
  /// GraphTooltip(
  ///   node: node,
  ///   contentBuilder: (context, node) => Column(
  ///     children: [
  ///       Text(node['label']),
  ///       Text(node['details']),
  ///     ],
  ///   ),
  /// );
  /// ```

  const GraphTooltip({required this.node, this.contentBuilder, super.key});

  final GraphNode node;
  final Widget Function(BuildContext context, GraphNode node)? contentBuilder;

  @override
  Widget build(BuildContext context) {
    final content = contentBuilder?.call(context, node) ??
        Text(
          '${node['description']}',
          style: const TextStyle(color: Colors.black),
        );
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: content,
    );
  }
}
