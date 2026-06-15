import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/graph/graph_base.dart' show GraphImpl;

void main() {
  test('Graph.reverseLink swaps source and target', () {
    final g = Graph();
    final a = GraphNode();
    final b = GraphNode();
    g.addNode(a);
    g.addNode(b);
    final l = GraphLink(
      source: a,
      target: b,
      direction: GraphLinkDirection.outgoing,
    );
    g.addLink(l);

    expect(l.source.id, a.id);
    expect(l.target.id, b.id);

    g.reverseLink(l.id);

    expect(l.source.id, b.id);
    expect(l.target.id, a.id);
  });

  // A3: reverseLink must notify layout listeners so the UI updates.
  test('Graph.reverseLink notifies layout change', () {
    final g = Graph();
    final a = GraphNode();
    final b = GraphNode();
    g
      ..addNode(a)
      ..addNode(b);
    final l = GraphLink(
      source: a,
      target: b,
      direction: GraphLinkDirection.outgoing,
    );
    g.addLink(l);

    var notified = 0;
    void listener() => notified++;
    (g as GraphImpl).layoutChangeListenable.addListener(listener);
    addTearDown(() => g.layoutChangeListenable.removeListener(listener));

    g.reverseLink(l.id);

    expect(notified, greaterThan(0));
  });

  // A3: adjacency indexes must follow the new source/target after reversal.
  test('Graph.reverseLink updates incoming/outgoing indexes', () {
    final g = Graph();
    final a = GraphNode();
    final b = GraphNode();
    g
      ..addNode(a)
      ..addNode(b);
    final l = GraphLink(
      source: a,
      target: b,
      direction: GraphLinkDirection.outgoing,
    );
    g.addLink(l);

    // Before: a -> b. a has the outgoing link, b the incoming.
    expect(g.getOutgoingLinks(a.id).map((e) => e.id), contains(l.id));
    expect(g.getIncomingLinks(b.id).map((e) => e.id), contains(l.id));
    expect(g.getIncomingLinks(a.id), isEmpty);
    expect(g.getOutgoingLinks(b.id), isEmpty);

    g.reverseLink(l.id);

    // After: b -> a. The link must move sides in both indexes.
    expect(g.getOutgoingLinks(b.id).map((e) => e.id), contains(l.id));
    expect(g.getIncomingLinks(a.id).map((e) => e.id), contains(l.id));
    expect(g.getOutgoingLinks(a.id), isEmpty);
    expect(g.getIncomingLinks(b.id), isEmpty);
  });
}
