import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

void main() {
  test('GraphViewDefaultBehavior.isEquivalentTo compares routing', () {
    const a = GraphViewDefaultBehavior(linkRouting: GraphLinkRouting.straight);
    const b = GraphViewDefaultBehavior(linkRouting: GraphLinkRouting.straight);
    const c = GraphViewDefaultBehavior(linkRouting: GraphLinkRouting.orthogonal);

    expect(a.isEquivalentTo(b), isTrue);
    expect(a.isEquivalentTo(c), isFalse);
  });
}

