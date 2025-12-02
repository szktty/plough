import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

void main() {
  test('reverseLink keeps link selection invariant', () {
    final g = Graph();
    final a = GraphNode();
    final b = GraphNode();
    g..addNode(a)..addNode(b);

    final l = GraphLink(source: a, target: b, direction: GraphLinkDirection.outgoing);
    g.addLink(l);

    // select link, record selection ids
    g.selectLink(l.id);
    expect(g.selectedLinkIds, contains(l.id));
    expect(l.isSelected, isTrue);

    // reverse and verify selection unchanged
    g.reverseLink(l.id);
    expect(g.selectedLinkIds, contains(l.id));
    expect(l.isSelected, isTrue);

    // node selections should remain empty
    expect(g.selectedNodeIds, isEmpty);
  });
}

