import 'package:flutter/widgets.dart';
import 'package:plough/plough.dart';

/// A layout strategy that positions nodes randomly within the available space.
///
/// Key features:
///
/// - Reproducible layouts using [seed] parameter
/// - Configurable [padding] to maintain margins
/// - Simple and fast initial positioning
///
/// Primary use cases:
///
/// - Initial layout generation
/// - Base positioning for other layout algorithms
///
/// Example:
/// ```dart
/// final layout = GraphRandomLayoutStrategy(
///   seed: 42,  // For reproducible layouts
///   padding: const EdgeInsets.all(50),  // Add margins
/// );
///
/// return GraphView(
///   graph: graph,
///   layoutStrategy: layout,
/// );
/// ```
base class GraphRandomLayoutStrategy extends GraphLayoutStrategy {
  /// Creates a random layout strategy with optional configuration.
  GraphRandomLayoutStrategy({
    super.seed,
    super.padding,
  });

  @override
  bool shouldRelayout(GraphRandomLayoutStrategy oldStrategy) {
    return !baseEquals(oldStrategy);
  }

  @override
  void performLayout(Graph graph, Size size) {
    super.performLayout(graph, size);

    final width = size.width;
    final height = size.height;
    for (final node in graph.nodes) {
      final dx = random.nextDouble() * (width - padding.left - padding.right) +
          padding.left;
      final dy = random.nextDouble() * (height - padding.top - padding.bottom) +
          padding.top;
      positionNode(node, Offset(dx, dy));
    }
  }
}
