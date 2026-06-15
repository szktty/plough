// C1 safety net: node/link selection must have a single source of truth
// (GraphData.selectedNodeIds/selectedLinkIds). node.isSelected is a derived
// view of that set, so it can never diverge from it.
//
// Before C1 these cases fail:
// - canSelect=false drops node._isSelected but leaves selectedNodeIds (the
//   [R1] divergence).
// Written first as a regression net per the safety-net-first rule.
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/graph/graph_base.dart' show GraphImpl;

void main() {
  group('selection single source of truth', () {
    test('selecting a node reflects in both isSelected and selectedNodeIds',
        () {
      final graph = Graph();
      final a = GraphNode(properties: const {'label': 'a'});
      graph.addNode(a);

      graph.selectNode(a.id);

      expect(a.isSelected, isTrue);
      expect(graph.selectedNodeIds, contains(a.id));
    });

    test('deselecting a node clears both', () {
      final graph = Graph();
      final a = GraphNode(properties: const {'label': 'a'});
      graph.addNode(a);
      graph.selectNode(a.id);

      graph.deselectNode(a.id);

      expect(a.isSelected, isFalse);
      expect(graph.selectedNodeIds, isNot(contains(a.id)));
    });

    test('canSelect=false on a selected node clears it without divergence', () {
      final graph = Graph();
      final a = GraphNode(properties: const {'label': 'a'});
      graph.addNode(a);
      graph.selectNode(a.id);
      expect(a.isSelected, isTrue);

      a.canSelect = false;

      // Both views must agree: the node is no longer selected AND it is gone
      // from selectedNodeIds. Pre-C1 the flag drops but the id lingers.
      expect(a.isSelected, isFalse);
      expect(
        graph.selectedNodeIds,
        isNot(contains(a.id)),
        reason: 'selectedNodeIds must not diverge from isSelected',
      );
    });

    test('clearSelection clears all nodes and links', () {
      final graph = Graph();
      final a = GraphNode(properties: const {'label': 'a'});
      final b = GraphNode(properties: const {'label': 'b'});
      graph
        ..addNode(a)
        ..addNode(b);
      final link = GraphLink(
        source: a,
        target: b,
        direction: GraphLinkDirection.outgoing,
      );
      graph.addLink(link);
      (graph as GraphImpl).state.value =
          graph.state.value.copyWith(allowMultiSelection: true);
      graph
        ..selectNode(a.id)
        ..selectNode(b.id)
        ..selectLink(link.id);

      graph.clearSelection();

      expect(a.isSelected, isFalse);
      expect(b.isSelected, isFalse);
      expect(link.isSelected, isFalse);
      expect(graph.selectedNodeIds, isEmpty);
      expect(graph.selectedLinkIds, isEmpty);
    });

    test('removing a selected node clears it from selectedNodeIds', () {
      final graph = Graph();
      final a = GraphNode(properties: const {'label': 'a'});
      graph.addNode(a);
      graph.selectNode(a.id);
      expect(graph.selectedNodeIds, contains(a.id));

      graph.removeNode(a.id);

      expect(graph.selectedNodeIds, isEmpty);
      // selectedNodes must not throw (no stale id).
      expect(graph.selectedNodes, isEmpty);
    });

    test('removing a selected link clears it from selectedLinkIds', () {
      final graph = Graph();
      final a = GraphNode(properties: const {'label': 'a'});
      final b = GraphNode(properties: const {'label': 'b'});
      graph
        ..addNode(a)
        ..addNode(b);
      final link = GraphLink(
        source: a,
        target: b,
        direction: GraphLinkDirection.outgoing,
      );
      graph.addLink(link);
      graph.selectLink(link.id);
      expect(graph.selectedLinkIds, contains(link.id));

      graph.removeLink(link.id);

      expect(graph.selectedLinkIds, isEmpty);
      expect(graph.selectedLinks, isEmpty);
    });

    test('removing a node also clears its connected selected links', () {
      final graph = Graph();
      final a = GraphNode(properties: const {'label': 'a'});
      final b = GraphNode(properties: const {'label': 'b'});
      graph
        ..addNode(a)
        ..addNode(b);
      final link = GraphLink(
        source: a,
        target: b,
        direction: GraphLinkDirection.outgoing,
      );
      graph.addLink(link);
      graph.selectLink(link.id);
      expect(graph.selectedLinkIds, contains(link.id));

      // Removing node a cascades to remove the link.
      graph.removeNode(a.id);

      expect(graph.selectedLinkIds, isEmpty);
      expect(graph.selectedLinks, isEmpty);
    });

    test('link selection stays consistent with selectedLinkIds', () {
      final graph = Graph();
      final a = GraphNode(properties: const {'label': 'a'});
      final b = GraphNode(properties: const {'label': 'b'});
      graph
        ..addNode(a)
        ..addNode(b);
      final link = GraphLink(
        source: a,
        target: b,
        direction: GraphLinkDirection.outgoing,
      );
      graph.addLink(link);

      graph.selectLink(link.id);
      expect(link.isSelected, isTrue);
      expect(graph.selectedLinkIds, contains(link.id));

      graph.deselectLink(link.id);
      expect(link.isSelected, isFalse);
      expect(graph.selectedLinkIds, isNot(contains(link.id)));
    });
  });
}
