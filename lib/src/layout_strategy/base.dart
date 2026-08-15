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

  // Value equality so that baseEquals — and through it shouldRelayout — compares
  // what the positions say rather than which objects hold them. Callers rebuild
  // these lists on every build, so identity would report a change every time and
  // relayout the graph continuously.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraphNodeLayoutPosition &&
          id == other.id &&
          position == other.position &&
          fixed == other.fixed;

  @override
  int get hashCode => Object.hash(id, position, fixed);
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

  /// Extra positions layered on top of [nodePositions] by the caller.
  ///
  /// [nodePositions] is final, so a strategy handed to another strategy as a
  /// delegate cannot be given more pins at construction. This is the seam for
  /// that: [GraphSnapshotLayoutStrategy] uses it to pin the nodes it has
  /// already restored before letting a fallback strategy place the rest.
  ///
  /// Entries in [nodePositions] take precedence, so an explicitly requested
  /// position always wins over one layered on here.
  List<GraphNodeLayoutPosition> overlaidNodePositions = const [];

  /// All positions that apply to this run, [nodePositions] first.
  Iterable<GraphNodeLayoutPosition> get effectiveNodePositions sync* {
    yield* nodePositions;
    if (overlaidNodePositions.isEmpty) return;
    final own = nodePositions.map((p) => p.id).toSet();
    yield* overlaidNodePositions.where((p) => !own.contains(p.id));
  }

  /// Gets the predefined position for a node, if any exists.
  GraphNodeLayoutPosition? getNodePosition(GraphNode node) {
    return effectiveNodePositions
        .firstWhereOrNull((element) => element.id == node.id);
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
        const IterableEquality<GraphNodeLayoutPosition>().equals(
          nodePositions,
          oldStrategy.nodePositions,
        );
  }

  /// Calculates and applies node positions based on the layout algorithm.
  ///
  /// Override this method in subclasses to implement specific layout behavior.
  void performLayout(Graph graph, Size size) {
    logDebug(LogCategory.layout, '$runtimeType: perform layout');
    logDebug(LogCategory.layout, '    size: $size');
    logDebug(LogCategory.layout, '    seed: $seed');

    applyNodePositions(graph);

    for (final node in graph.nodes.cast<GraphNodeImpl>()) {
      node.animationStartPosition = _nodeAnimationStartPosition;
    }
  }

  /// Whether this strategy supports incremental (frame-by-frame) layout.
  ///
  /// When `true`, [GraphView] will call [initIncrementalLayout] once,
  /// then [stepIncrementalLayout] each frame until it returns `false`.
  /// This creates a smooth animation as nodes settle into their final positions.
  ///
  /// Override to return `true` and implement [initIncrementalLayout] and
  /// [stepIncrementalLayout] in subclasses that support it.
  bool get supportsIncrementalLayout => false;

  /// Initialises the incremental layout state.
  ///
  /// Called once before the first [stepIncrementalLayout] call.
  /// Subclasses that support incremental layout must override this.
  void initIncrementalLayout(Graph graph, Size size) {}

  /// Executes one frame's worth of layout computation.
  ///
  /// Returns `true` if more steps are needed, `false` when converged.
  /// Subclasses that support incremental layout must override this.
  bool stepIncrementalLayout(Graph graph) => false;

  /// Writes every entry of [nodePositions] to its node.
  ///
  /// This is the one place allowed to move a fixed node, and it must run before
  /// the algorithm starts iterating: [positionNode] deliberately refuses to
  /// move fixed nodes, so without this seeding pass a `fixed: true` entry would
  /// pin a node to wherever it already happened to be — the origin, for a node
  /// that was just constructed — instead of to the requested position.
  ///
  /// Subclasses that do not call `super.performLayout` must call this
  /// themselves before positioning anything.
  @protected
  void applyNodePositions(Graph graph) {
    for (final nodePosition in effectiveNodePositions) {
      final node = graph.getNode(nodePosition.id);
      if (node != null) {
        (node as GraphNodeImpl).logicalPosition = nodePosition.position;
      }
    }
  }

  /// Positions a node at the specified coordinates.
  ///
  /// Respects fixed node positions and handles state updates. Fixed nodes are
  /// seeded once by [applyNodePositions]; every later write goes through here
  /// and is ignored for them.
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
