import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/graph/graph_base.dart' show GraphImpl;

GraphLink _link(GraphNode source, GraphNode target) => GraphLink(
      source: source,
      target: target,
      direction: GraphLinkDirection.outgoing,
    );

void main() {
  group('Graph removal paths', () {
    // A1: removeNode must also drop links connected to the removed node from
    // the links map (not just from the adjacency index).
    group('removeNode link cleanup (A1)', () {
      test('removes links connected to the removed node from links map', () {
        final graph = Graph();
        final a = GraphNode(properties: {'label': 'a'});
        final b = GraphNode(properties: {'label': 'b'});
        final c = GraphNode(properties: {'label': 'c'});
        graph
          ..addNode(a)
          ..addNode(b)
          ..addNode(c);

        // a->b (a is source), c->a (a is target), b->c (unrelated to a).
        final ab = _link(a, b);
        final ca = _link(c, a);
        final bc = _link(b, c);
        graph
          ..addLink(ab)
          ..addLink(ca)
          ..addLink(bc);

        expect(graph.links.length, 3);

        graph.removeNode(a.id);

        // Links touching a must be gone from the links map; bc remains.
        final remaining = graph.links.map((l) => l.id).toSet();
        expect(remaining, {bc.id});
        expect(graph.getLink(ab.id), isNull);
        expect(graph.getLink(ca.id), isNull);
        expect(graph.getLink(bc.id), isNotNull);
      });

      test('adjacency index is consistent after node removal', () {
        final graph = Graph();
        final a = GraphNode(properties: {'label': 'a'});
        final b = GraphNode(properties: {'label': 'b'});
        graph
          ..addNode(a)
          ..addNode(b);
        final ab = _link(a, b);
        graph.addLink(ab);

        graph.removeNode(a.id);

        // b had an incoming link from a; after removing a it must be empty.
        expect(graph.getIncomingLinks(b.id), isEmpty);
        expect(graph.getOutgoingLinks(b.id), isEmpty);
      });

      test('removing a node with no links leaves other links intact', () {
        final graph = Graph();
        final a = GraphNode(properties: {'label': 'a'});
        final b = GraphNode(properties: {'label': 'b'});
        final c = GraphNode(properties: {'label': 'c'});
        graph
          ..addNode(a)
          ..addNode(b)
          ..addNode(c);
        final bc = _link(b, c);
        graph.addLink(bc);

        graph.removeNode(a.id);

        expect(graph.links.length, 1);
        expect(graph.getLink(bc.id), isNotNull);
      });

      // A self loop (source == target) appears in both the incoming and the
      // outgoing index, so removeNode collects affected links into a unique
      // set. Guards against a regression where the set is turned back into a
      // list (double-remove) or the links map cleanup is skipped.
      test('removing a node with a self-loop drops the loop link', () {
        final graph = Graph();
        final a = GraphNode(properties: {'label': 'a'});
        graph.addNode(a);
        final aa = _link(a, a);
        graph.addLink(aa);

        expect(graph.links.length, 1);
        expect(graph.getIncomingLinks(a.id).length, 1);
        expect(graph.getOutgoingLinks(a.id).length, 1);

        graph.removeNode(a.id);

        expect(graph.nodes, isEmpty);
        expect(graph.links, isEmpty);
        expect(graph.getLink(aa.id), isNull);
      });
    });

    // A8: removeLink must notify layout listeners, mirroring addLink.
    group('removeLink notifies layout change (A8)', () {
      test('removeLink fires layoutChangeListenable', () {
        final graph = Graph();
        final a = GraphNode(properties: {'label': 'a'});
        final b = GraphNode(properties: {'label': 'b'});
        graph
          ..addNode(a)
          ..addNode(b);
        final ab = _link(a, b);
        graph.addLink(ab);

        var notified = 0;
        void listener() => notified++;
        (graph as GraphImpl).layoutChangeListenable.addListener(listener);
        addTearDown(
          () => (graph as GraphImpl)
              .layoutChangeListenable
              .removeListener(listener),
        );

        graph.removeLink(ab.id);

        expect(notified, greaterThan(0));
        expect(graph.getLink(ab.id), isNull);
        expect(graph.links, isEmpty);
      });

      test('removeNode also fires layoutChangeListenable', () {
        final graph = Graph();
        final a = GraphNode(properties: {'label': 'a'});
        graph.addNode(a);

        var notified = 0;
        void listener() => notified++;
        (graph as GraphImpl).layoutChangeListenable.addListener(listener);
        addTearDown(
          () => (graph as GraphImpl)
              .layoutChangeListenable
              .removeListener(listener),
        );

        graph.removeNode(a.id);

        expect(notified, greaterThan(0));
      });
    });
  });
}
