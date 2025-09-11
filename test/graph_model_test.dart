import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/graph/node.dart' show GraphNodeImpl;

void main() {
  group('Graph data model', () {
    test('can add and retrieve nodes', () {
      final graph = Graph();
      final node = GraphNode(properties: {'label': 'test'});

      graph.addNode(node);

      expect(graph.nodes.length, 1);
      expect(graph.getNode(node.id), isNotNull);
    });

    test('can add links with proper endpoints and direction', () {
      final graph = Graph();
      final a = GraphNode(properties: {'label': 'a'});
      final b = GraphNode(properties: {'label': 'b'});
      graph
        ..addNode(a)
        ..addNode(b);

      final link = GraphLink(
        source: a,
        target: b,
        direction: GraphLinkDirection.outgoing,
      );
      graph.addLink(link);

      expect(graph.links.length, 1);
      final added = graph.links.first;
      expect(added.source.id, a.id);
      expect(added.target.id, b.id);
      expect(added.direction, GraphLinkDirection.outgoing);
    });

    test('selection state toggling works', () {
      final graph = Graph();
      final a = GraphNode(properties: {'label': 'a'});
      graph.addNode(a);

      expect(graph.isSelected(a.id), isFalse);

      graph.selectNode(a.id);
      expect(graph.isSelected(a.id), isTrue);
      expect(graph.selectedNodeIds, contains(a.id));

      graph.toggleSelectNode(a.id);
      expect(graph.isSelected(a.id), isFalse);

      graph.selectNode(a.id);
      graph.clearSelection();
      expect(graph.isSelected(a.id), isFalse);
      expect(graph.selectedNodeIds, isEmpty);
    });

    test('bringToFront updates stack order monotonically', () {
      final graph = Graph();
      final a = GraphNode(properties: {'label': 'a'});
      final b = GraphNode(properties: {'label': 'b'});
      graph..addNode(a)..addNode(b);

      final ai = graph.getNode(a.id) as GraphNodeImpl;
      final bi = graph.getNode(b.id) as GraphNodeImpl;

      // initial order
      final initialMax = [ai.stackOrder, bi.stackOrder].reduce((x, y) => x > y ? x : y);

      graph.bringToFront(a.id);
      expect(ai.stackOrder, greaterThanOrEqualTo(initialMax));

      final prevA = ai.stackOrder;
      graph.bringToFront(b.id);
      expect(bi.stackOrder, greaterThan(prevA));
    });
  });
}

