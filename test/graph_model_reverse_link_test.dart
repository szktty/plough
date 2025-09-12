import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

void main() {
  test('Graph.reverseLink swaps source and target', () {
    final g = Graph();
    final a = GraphNode();
    final b = GraphNode();
    g.addNode(a);
    g.addNode(b);
    final l = GraphLink(source: a, target: b, direction: GraphLinkDirection.outgoing);
    g.addLink(l);

    expect(l.source.id, a.id);
    expect(l.target.id, b.id);

    g.reverseLink(l.id);

    expect(l.source.id, b.id);
    expect(l.target.id, a.id);
  });
}

