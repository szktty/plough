import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

GraphLink _link(GraphNode source, GraphNode target) => GraphLink(
    source: source, target: target, direction: GraphLinkDirection.none);

void main() {
  group('GraphNode position at construction', () {
    test('logicalPosition places the node before any layout runs', () {
      const at = Offset(321, 123);
      final node = GraphNode(logicalPosition: at);

      expect(node.logicalPosition, at);
      expect(node.isArranged, isFalse);
    });

    test('isArranged marks the position as worth preserving', () {
      final node =
          GraphNode(logicalPosition: const Offset(50, 60), isArranged: true);

      expect(node.isArranged, isTrue);
    });

    test('a restored node keeps its position through a force-directed layout',
        () {
      final graph = Graph();
      const restoredAt = Offset(677.4, 352.1);
      final restored = GraphNode(
        logicalPosition: restoredAt,
        isArranged: true,
      );
      final other = GraphNode(
        logicalPosition: const Offset(200, 200),
        isArranged: true,
      );
      graph
        ..addNode(restored)
        ..addNode(other)
        ..addLink(_link(restored, other));

      GraphForceDirectedLayoutStrategy(seed: 1).performLayout(
        graph,
        const Size(800, 600),
      );

      // It moves under the physics, but it starts from where it was restored
      // rather than being randomised away from the origin.
      expect(restored.logicalPosition, isNot(Offset.zero));
      expect((restored.logicalPosition - restoredAt).distance, lessThan(200));
    });

    test('the default constructor still starts at the origin', () {
      expect(GraphNode().logicalPosition, Offset.zero);
    });
  });

  group('nodePositionSnapshot', () {
    test('covers only arranged nodes by default', () {
      final graph = Graph();
      final arranged = GraphNode(
        logicalPosition: const Offset(10, 20),
        isArranged: true,
      );
      final fresh = GraphNode();
      graph
        ..addNode(arranged)
        ..addNode(fresh);

      final snapshot = graph.nodePositionSnapshot();

      expect(snapshot, {arranged.id: const Offset(10, 20)});
    });

    test('includeUnarranged covers every node', () {
      final graph = Graph();
      final arranged = GraphNode(
        logicalPosition: const Offset(10, 20),
        isArranged: true,
      );
      final fresh = GraphNode();
      graph
        ..addNode(arranged)
        ..addNode(fresh);

      final snapshot = graph.nodePositionSnapshot(includeUnarranged: true);

      expect(snapshot, hasLength(2));
      expect(snapshot[fresh.id], Offset.zero);
    });
  });

  group('GraphSnapshotLayoutStrategy', () {
    test('restores every snapshotted node exactly', () {
      final graph = Graph();
      final a = GraphNode();
      final b = GraphNode();
      graph
        ..addNode(a)
        ..addNode(b)
        ..addLink(_link(a, b));

      final snapshot = {
        a.id: const Offset(120, 340),
        b.id: const Offset(560, 210),
      };

      GraphSnapshotLayoutStrategy(
        snapshot: snapshot,
        fallback: GraphForceDirectedLayoutStrategy(seed: 2),
      ).performLayout(graph, const Size(800, 600));

      expect(a.logicalPosition, const Offset(120, 340));
      expect(b.logicalPosition, const Offset(560, 210));
    });

    test('places an unsnapshotted node without moving the snapshotted ones',
        () {
      final graph = Graph();
      final kept = GraphNode();
      final added = GraphNode();
      graph
        ..addNode(kept)
        ..addNode(added)
        ..addLink(_link(kept, added));

      final snapshot = {kept.id: const Offset(400, 300)};

      GraphSnapshotLayoutStrategy(
        snapshot: snapshot,
        fallback: GraphForceDirectedLayoutStrategy(seed: 4),
      ).performLayout(graph, const Size(800, 600));

      expect(kept.logicalPosition, const Offset(400, 300));
      expect(added.logicalPosition, isNot(Offset.zero));
    });

    test('without a fallback, unsnapshotted nodes are left alone', () {
      final graph = Graph();
      final kept = GraphNode();
      final added = GraphNode();
      graph
        ..addNode(kept)
        ..addNode(added);

      GraphSnapshotLayoutStrategy(
        snapshot: {kept.id: const Offset(400, 300)},
      ).performLayout(graph, const Size(800, 600));

      expect(kept.logicalPosition, const Offset(400, 300));
      expect(added.logicalPosition, Offset.zero);
    });

    test('survives the hide-then-restore round trip', () {
      final graph = Graph();
      final stays = GraphNode();
      final hidden = GraphNode();
      graph
        ..addNode(stays)
        ..addNode(hidden)
        ..addLink(_link(stays, hidden));

      GraphForceDirectedLayoutStrategy(seed: 9)
          .performLayout(graph, const Size(800, 600));
      // GraphView does this once a layout completes.
      for (final node in graph.nodes) {
        expect(node.logicalPosition, isNot(Offset.zero));
      }
      final snapshot = graph.nodePositionSnapshot(includeUnarranged: true);
      final staysAt = stays.logicalPosition;
      final hiddenAt = hidden.logicalPosition;

      // Hide: the node and its links leave the graph, taking the position with
      // them. Restore: a brand-new object with the same id comes back.
      graph.removeNode(hidden.id);
      final restored = GraphNode(id: hidden.id);
      graph
        ..addNode(restored)
        ..addLink(_link(stays, restored));

      GraphSnapshotLayoutStrategy(
        snapshot: snapshot,
        fallback: GraphForceDirectedLayoutStrategy(seed: 9),
      ).performLayout(graph, const Size(800, 600));

      expect(stays.logicalPosition, staysAt);
      expect(restored.logicalPosition, hiddenAt);
    });

    test('incremental layout keeps snapshotted nodes pinned throughout', () {
      final graph = Graph();
      final pinned = GraphNode();
      final added = GraphNode();
      graph
        ..addNode(pinned)
        ..addNode(added)
        ..addLink(_link(pinned, added));

      const at = Offset(250, 450);
      final strategy = GraphSnapshotLayoutStrategy(
        snapshot: {pinned.id: at},
        fallback: GraphForceDirectedLayoutStrategy(seed: 6),
      );

      expect(strategy.supportsIncrementalLayout, isTrue);
      strategy.initIncrementalLayout(graph, const Size(800, 600));
      expect(pinned.logicalPosition, at);

      var steps = 0;
      while (strategy.stepIncrementalLayout(graph) && steps < 500) {
        steps++;
        expect(pinned.logicalPosition, at);
      }

      expect(pinned.logicalPosition, at);
      expect(added.logicalPosition, isNot(Offset.zero));
    });

    test('shouldRelayout ignores an equal snapshot', () {
      final id = GraphId.unique(GraphIdType.node);
      GraphSnapshotLayoutStrategy build() => GraphSnapshotLayoutStrategy(
            snapshot: {id: const Offset(1, 2)},
          );

      expect(build().shouldRelayout(build()), isFalse);
    });

    test('shouldRelayout fires when the snapshot changes', () {
      final id = GraphId.unique(GraphIdType.node);
      final older =
          GraphSnapshotLayoutStrategy(snapshot: {id: const Offset(1, 2)});
      final newer =
          GraphSnapshotLayoutStrategy(snapshot: {id: const Offset(9, 9)});

      expect(newer.shouldRelayout(older), isTrue);
    });
  });
}
