import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:plough/src/graph/graph_base.dart';
import 'package:plough/src/graph/node.dart';
import 'package:plough/src/layout_strategy/base.dart';

/// A layout strategy that enables custom node positioning through a delegate pattern.
///
/// Provides a flexible framework for implementing custom graph layout algorithms while
/// maintaining consistent handling of common layout features like padding and node
/// positioning. The actual layout logic is implemented by a
/// [GraphCustomLayoutStrategyDelegate].
///
/// The delegate pattern allows for clean separation between the layout infrastructure
/// and the specific positioning algorithm, making it easy to create and switch
/// between different layout implementations while ensuring proper state management
/// and position calculations.
///
/// See also:
///
/// * [GraphCustomLayoutStrategyDelegate] for implementing custom layout algorithms
/// * [GraphLayoutStrategy] for the base layout functionality and features
/// * [GraphNodeLayoutPosition] for controlling individual node positions
base class GraphCustomLayoutStrategy extends GraphLayoutStrategy {
  GraphCustomLayoutStrategy({
    required this.delegate,
    super.seed,
    super.padding,
    super.nodePositions,
  }) {
    delegate._strategy = this;
  }

  /// The delegate that implements the custom layout algorithm logic.
  ///
  /// The delegate handles node positioning while the strategy manages the layout
  /// infrastructure and state.
  final GraphCustomLayoutStrategyDelegate delegate;

  @override
  void performLayout(Graph graph, Size size) {
    super.performLayout(graph, size);

    final contentSize = Size(
      size.width - padding.left - padding.right,
      size.height - padding.top - padding.bottom,
    );
    delegate.performLayout(graph, contentSize);
  }

  @override
  bool shouldRelayout(GraphLayoutStrategy oldStrategy) {
    return !baseEquals(oldStrategy) || delegate.shouldRelayout(oldStrategy);
  }
}

/// Interface for implementing custom graph layout algorithms.
///
/// Provides access to layout utilities and state management while allowing complete
/// control over node positioning logic. Implementations define how nodes should be
/// arranged within the graph visualization area.
///
/// Layout calculations should respect the content area boundaries and any fixed node
/// positions. The content area dimensions provided exclude padding, which is
/// automatically applied when positioning nodes.
///
/// See also:
///
/// * [GraphCustomLayoutStrategy] for the parent strategy that manages this delegate
/// * [GraphLayoutStrategy] for the base layout functionality and features
abstract class GraphCustomLayoutStrategyDelegate {
  late final GraphCustomLayoutStrategy _strategy;

  /// Access to the padding configuration from the parent strategy.
  EdgeInsets get padding => _strategy.padding;

  /// Random number generator for layouts with random elements.
  ///
  /// Uses the same seed as the parent strategy for reproducibility.
  math.Random get random => _strategy.random;

  /// List of predefined node positions for initialization or fixed nodes.
  List<GraphNodeLayoutPosition> get nodePositions => _strategy.nodePositions;

  /// Gets the position data for a specific node.
  ///
  /// Returns null if no predefined position exists for the node.
  GraphNodeLayoutPosition? getNodePosition(GraphNode node) =>
      _strategy.getNodePosition(node);

  /// Calculates and applies node positions.
  ///
  /// The [size] parameter provides the content area dimensions (excluding padding).
  /// Use [positionNode] to set the calculated positions.
  void performLayout(Graph graph, Size size);

  /// Determines if the layout needs to be recalculated.
  ///
  /// Compare with [oldStrategy] to decide if a relayout is needed.
  bool shouldRelayout(GraphLayoutStrategy oldStrategy);

  /// Positions a node at the specified location.
  ///
  /// The [position] is relative to the content area. Padding adjustment
  /// is handled automatically.
  void positionNode(GraphNode node, Offset position) {
    _strategy.positionNode(node, position + Offset(padding.left, padding.top));
  }
}
