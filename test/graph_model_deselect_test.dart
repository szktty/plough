import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

// A4: in single-selection mode, deselectNode(otherId) used to wipe the whole
// selectedNodeIds list (and only flip the target node's flag), leaving state
// and per-node flags inconsistent. deselect must only affect the given id.

void main() {
  group('deselectNode (A4)', () {
    test('deselecting a non-selected node leaves the current selection', () {
      final graph = Graph();
      final a = GraphNode(properties: {'label': 'a'});
      final b = GraphNode(properties: {'label': 'b'});
      graph
        ..addNode(a)
        ..addNode(b);

      graph.selectNode(a.id);
      expect(graph.isSelected(a.id), isTrue);

      // Deselect a different, non-selected node. a must stay selected.
      graph.deselectNode(b.id);

      expect(graph.isSelected(a.id), isTrue);
      expect(graph.selectedNodeIds, contains(a.id));
      expect(graph.isSelected(b.id), isFalse);
    });

    test('deselecting the selected node clears it', () {
      final graph = Graph();
      final a = GraphNode(properties: {'label': 'a'});
      graph.addNode(a);

      graph.selectNode(a.id);
      expect(graph.isSelected(a.id), isTrue);

      graph.deselectNode(a.id);

      expect(graph.isSelected(a.id), isFalse);
      expect(graph.selectedNodeIds, isEmpty);
    });

    test('state list and node flags do not diverge', () {
      final graph = Graph();
      final a = GraphNode(properties: {'label': 'a'});
      final b = GraphNode(properties: {'label': 'b'});
      graph
        ..addNode(a)
        ..addNode(b);

      graph.selectNode(a.id);
      // Deselect the other node; the invariant is that every id in
      // selectedNodeIds is reported selected, and vice versa.
      graph.deselectNode(b.id);

      for (final id in [a.id, b.id]) {
        expect(
          graph.isSelected(id),
          graph.selectedNodeIds.contains(id),
          reason: 'isSelected($id) must agree with selectedNodeIds',
        );
      }
    });
  });

  group('deselectLink (A4)', () {
    test('deselecting a non-selected link leaves the current selection', () {
      final graph = Graph();
      final a = GraphNode();
      final b = GraphNode();
      final c = GraphNode();
      graph
        ..addNode(a)
        ..addNode(b)
        ..addNode(c);
      final l1 = GraphLink(
        source: a,
        target: b,
        direction: GraphLinkDirection.outgoing,
      );
      final l2 = GraphLink(
        source: b,
        target: c,
        direction: GraphLinkDirection.outgoing,
      );
      graph
        ..addLink(l1)
        ..addLink(l2);

      graph.selectLink(l1.id);
      expect(graph.isSelected(l1.id), isTrue);

      graph.deselectLink(l2.id);

      expect(graph.isSelected(l1.id), isTrue);
      expect(graph.selectedLinkIds, contains(l1.id));
    });
  });
}
