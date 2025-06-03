import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:plough/plough.dart';

import 'package:plough/src/graph/node.dart';
import 'package:plough/src/utils/logger.dart';

/// Holds position information for a node in the graph layout system.
///
/// Provides the position and fixation state of nodes during layout calculations.
/// Fixed nodes maintain their positions regardless of the layout algorithm's
/// calculations.
class GraphNodeLayoutPosition {
  /// Creates a node position configuration.
  const GraphNodeLayoutPosition({
    required this.id,
    required this.position,
    this.fixed = false,
  });

  /// Creates a list of node positions from a map of IDs to positions.
  static List<GraphNodeLayoutPosition> fromMap(Map<GraphId, Offset> map) =>
      map.entries
          .map((e) => GraphNodeLayoutPosition(id: e.key, position: e.value))
          .toList();

  /// The unique identifier of the node.
  final GraphId id;

  /// The position of the node in logical coordinates.
  final Offset position;

  /// Whether this node's position should remain fixed during layout calculations.
  final bool fixed;
}

/// The base class for graph layout algorithms.
///
/// Provides core functionality for positioning nodes within a graph visualization.
/// Subclasses implement the [performLayout] and [shouldRelayout] methods to define
/// specific layout algorithms.
///
/// Features:
///
/// - Configurable [padding] around the layout area
/// - Support for [nodePositions] to set initial or fixed positions
/// - Reproducible layouts through optional [seed] value
/// - Fixed node handling to maintain specific positions
/// - Animation state management for smooth transitions
///
/// Layout algorithms can handle both automatic and manual positioning:
///
/// ```dart
/// class CustomLayoutStrategy extends GraphLayoutStrategy {
///   @override
///   void performLayout(Graph graph, Size size) {
///     for (final node in graph.nodes) {
///       // Custom layout logic
///       final position = calculatePosition(node);
///       positionNode(node, position);
///     }
///   }
///
///   @override
///   bool shouldRelayout(GraphLayoutStrategy oldStrategy) {
///     return !baseEquals(oldStrategy);
///   }
/// }
/// ```
///
/// See also:
///
/// * [GraphForceDirectedLayoutStrategy] for force-directed layouts
/// * [GraphTreeLayoutStrategy] for hierarchical layouts
/// * [GraphManualLayoutStrategy] for user-controlled layouts
abstract base class GraphLayoutStrategy {
  /// Creates a layout strategy with optional configuration.
  GraphLayoutStrategy({
    this.seed,
    this.padding = const EdgeInsets.all(100),
    this.nodePositions = const [],
  }) : random = math.Random(seed);

  /// Optional seed for reproducible random number generation.
  ///
  /// When provided, ensures consistent layouts across different runs.
  final int? seed;

  /// Random number generator initialized with [seed].
  final math.Random random;

  /// Padding around the layout area.
  ///
  /// Ensures nodes are not positioned too close to the visualization boundaries.
  final EdgeInsets padding;

  /// List of predefined node positions.
  ///
  /// Used to set initial positions or fix nodes at specific locations during layout.
  final List<GraphNodeLayoutPosition> nodePositions;

  Offset _nodeAnimationStartPosition = Offset.zero;

  /// Checks if the given strategy is of the same type as this one.
  bool isSameStrategy(GraphLayoutStrategy other) {
    return runtimeType == other.runtimeType;
  }

  /// Retrieves the current size of a node.
  ///
  /// Used for layout calculations to avoid overlaps.
  Size? getNodeSize(GraphNode node) {
    return (node as GraphNodeImpl).geometry?.bounds.size;
  }

  /// Gets the predefined position for a node, if any exists.
  GraphNodeLayoutPosition? getNodePosition(GraphNode node) {
    return nodePositions.firstWhereOrNull(
      (element) => element.id == node.id,
    );
  }

  /// Checks if a node's position should remain fixed during layout.
  bool isNodeFixed(GraphNode node) {
    final position = getNodePosition(node);
    return position?.fixed ?? false;
  }

  /// Determines if the layout needs to be recalculated.
  ///
  /// Called when layout parameters or graph structure changes.
  bool shouldRelayout(covariant GraphLayoutStrategy oldStrategy);

  /// Compares basic layout properties for equality.
  ///
  /// Used by subclasses to implement [shouldRelayout].
  bool baseEquals(covariant GraphLayoutStrategy oldStrategy) {
    return padding == oldStrategy.padding &&
        const IterableEquality<GraphNodeLayoutPosition>()
            .equals(nodePositions, oldStrategy.nodePositions);
  }

  /// Calculates and applies node positions based on the layout algorithm.
  ///
  /// Override this method in subclasses to implement specific layout behavior.
  void performLayout(Graph graph, Size size) {
    log
      ..d('$runtimeType: perform layout')
      ..d('    size: $size')
      ..d('    seed: $seed');

    // node positions
    for (final nodePosition in nodePositions) {
      final node = graph.getNode(nodePosition.id);
      if (node != null) {
        positionNode(node, nodePosition.position);
      }
    }

    for (final node in graph.nodes.cast<GraphNodeImpl>()) {
      node.animationStartPosition = _nodeAnimationStartPosition;
    }
  }

  /// Positions a node at the specified coordinates.
  ///
  /// Respects fixed node positions and handles state updates.
  void positionNode(GraphNode node, Offset position) {
    if (isNodeFixed(node)) {
      return;
    }

    final impl = node as GraphNodeImpl;
    impl.logicalPosition = position;
  }
}

extension GraphLayoutStrategyInternal on GraphLayoutStrategy {
  Offset get nodeAnimationStartPosition => _nodeAnimationStartPosition;

  set nodeAnimationStartPosition(Offset position) {
    _nodeAnimationStartPosition = position;
  }
}
