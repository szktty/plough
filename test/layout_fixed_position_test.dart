import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

void main() {
  group('fixed node positions', () {
    test('a fixed position is applied to a node that has never been laid out',
        () {
      final graph = Graph();
      final pinned = GraphNode();
      final other = GraphNode();
      graph
        ..addNode(pinned)
        ..addNode(other)
        ..addLink(GraphLink(
            source: pinned, target: other, direction: GraphLinkDirection.none));

      const target = Offset(677.4, 352.1);
      final strategy = GraphForceDirectedLayoutStrategy(
        seed: 1,
        nodePositions: [
          GraphNodeLayoutPosition(id: pinned.id, position: target, fixed: true),
        ],
      )..performLayout(graph, const Size(800, 600));

      expect(strategy, isNotNull);
      expect(pinned.logicalPosition, target);
    });

    test('a fixed node stays put across a full layout run', () {
      final graph = Graph();
      final pinned = GraphNode();
      final a = GraphNode();
      final b = GraphNode();
      graph
        ..addNode(pinned)
        ..addNode(a)
        ..addNode(b)
        ..addLink(GraphLink(
            source: pinned, target: a, direction: GraphLinkDirection.none))
        ..addLink(GraphLink(
            source: pinned, target: b, direction: GraphLinkDirection.none));

      const target = Offset(300, 250);
      GraphForceDirectedLayoutStrategy(
        seed: 7,
        nodePositions: [
          GraphNodeLayoutPosition(id: pinned.id, position: target, fixed: true),
        ],
      ).performLayout(graph, const Size(800, 600));

      expect(pinned.logicalPosition, target);
      expect(a.logicalPosition, isNot(Offset.zero));
      expect(b.logicalPosition, isNot(Offset.zero));
    });

    test('incremental layout keeps a fixed node at its pinned position', () {
      final graph = Graph();
      final pinned = GraphNode();
      final a = GraphNode();
      graph
        ..addNode(pinned)
        ..addNode(a)
        ..addLink(GraphLink(
            source: pinned, target: a, direction: GraphLinkDirection.none));

      const target = Offset(120, 480);
      final strategy = GraphForceDirectedLayoutStrategy(
        seed: 3,
        nodePositions: [
          GraphNodeLayoutPosition(id: pinned.id, position: target, fixed: true),
        ],
      )..initIncrementalLayout(graph, const Size(800, 600));

      expect(pinned.logicalPosition, target);

      var steps = 0;
      while (strategy.stepIncrementalLayout(graph) && steps < 500) {
        steps++;
        expect(pinned.logicalPosition, target);
      }

      expect(pinned.logicalPosition, target);
    });

    test('an unfixed nodePositions entry seeds the starting position', () {
      final graph = Graph();
      final seeded = GraphNode();
      graph.addNode(seeded);

      const start = Offset(400, 300);
      GraphForceDirectedLayoutStrategy(
        seed: 5,
        nodePositions: [
          GraphNodeLayoutPosition(id: seeded.id, position: start),
        ],
      ).performLayout(graph, const Size(800, 600));

      // With no links and no other nodes there is nothing to push it away, so
      // the seeded position is preserved rather than randomised.
      expect(seeded.logicalPosition, start);
    });
  });
}
