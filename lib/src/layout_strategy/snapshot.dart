import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:plough/plough.dart';

/// A layout that puts nodes back where a snapshot says they were.
///
/// Pair it with [Graph.nodePositionSnapshot] to survive a round-trip through
/// removal. Filtering a graph by removing nodes destroys the objects that held
/// their positions, so nodes that come back are rebuilt at the origin — usually
/// off screen, with their links trailing off to nothing. Recording the
/// positions before the removal and replaying them here restores the layout
/// exactly, with no physics re-run and no drift for the nodes that stayed.
///
/// ```dart
/// // Before hiding part of the graph:
/// final snapshot = graph.nodePositionSnapshot();
///
/// // After putting the hidden nodes back:
/// GraphView(
///   graph: graph,
///   layoutStrategy: GraphSnapshotLayoutStrategy(
///     snapshot: snapshot,
///     fallback: GraphForceDirectedLayoutStrategy(),
///   ),
/// );
/// ```
///
/// Nodes missing from [snapshot] — genuinely new ones — are placed by
/// [fallback], which runs with the snapshotted nodes pinned so it arranges the
/// newcomers around them without disturbing what was already there. Without a
/// [fallback] the new nodes keep whatever position they already have.
///
/// See also:
///
/// * [GraphManualLayoutStrategy], for positions the application computes
///   itself rather than recovering from a previous layout
base class GraphSnapshotLayoutStrategy extends GraphLayoutStrategy {
  /// Creates a layout that restores node positions from [snapshot].
  ///
  /// [fallback] places nodes that [snapshot] does not cover.
  GraphSnapshotLayoutStrategy({
    required this.snapshot,
    this.fallback,
    super.seed,
    super.padding,
  }) : super(
          nodePositions: [
            for (final entry in snapshot.entries)
              GraphNodeLayoutPosition(
                id: entry.key,
                position: entry.value,
                fixed: true,
              ),
          ],
        ) {
    fallback?.overlaidNodePositions = nodePositions;
  }

  /// The positions to restore, keyed by node id.
  ///
  /// Typically produced by [Graph.nodePositionSnapshot].
  final Map<GraphId, Offset> snapshot;

  /// Places nodes that [snapshot] has no entry for.
  ///
  /// Runs with every snapshotted node pinned, so it only arranges the nodes it
  /// needs to. When null, uncovered nodes keep the position they already have.
  final GraphLayoutStrategy? fallback;

  /// Whether [graph] holds a node the snapshot says nothing about.
  bool _hasUnsnapshottedNode(Graph graph) =>
      graph.nodes.any((node) => !snapshot.containsKey(node.id));

  @override
  void performLayout(Graph graph, Size size) {
    super.performLayout(graph, size);

    // Running the fallback with nothing new to place would only cost a physics
    // pass whose every output the pins discard.
    if (fallback == null || !_hasUnsnapshottedNode(graph)) return;
    fallback!.performLayout(graph, size);
  }

  @override
  bool get supportsIncrementalLayout =>
      fallback?.supportsIncrementalLayout ?? false;

  @override
  void initIncrementalLayout(Graph graph, Size size) {
    super.performLayout(graph, size);
    _steppingFallback = _hasUnsnapshottedNode(graph) ? fallback : null;
    _steppingFallback?.initIncrementalLayout(graph, size);
  }

  @override
  bool stepIncrementalLayout(Graph graph) =>
      _steppingFallback?.stepIncrementalLayout(graph) ?? false;

  GraphLayoutStrategy? _steppingFallback;

  @override
  bool shouldRelayout(covariant GraphSnapshotLayoutStrategy oldStrategy) {
    return !baseEquals(oldStrategy) ||
        !const MapEquality<GraphId, Offset>().equals(
          snapshot,
          oldStrategy.snapshot,
        ) ||
        fallback.runtimeType != oldStrategy.fallback.runtimeType;
  }
}
