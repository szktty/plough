import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:plough/src/layout_strategy/quadtree.dart';

/// Bodies that share a position must not subdivide the tree forever.
///
/// A quadrant always contains both of them however far it is halved, so an
/// insert that keeps subdividing until they separate never finishes. Nodes are
/// constructed at the origin, so two that have yet to be placed sit exactly on
/// top of each other — the layout ran on a graph like that and overflowed the
/// stack, which left the nodes wherever they already were.
void main() {
  const bounds = Rect.fromLTWH(0, 0, 1000, 1000);

  test('two bodies at the same point build a tree', () {
    final tree = QuadtreeNode.build(const [
      QuadtreeBody(id: 'a', x: 0, y: 0),
      QuadtreeBody(id: 'b', x: 0, y: 0),
    ], bounds);

    // Reaching here at all is the point: this used to overflow the stack.
    expect(tree, isNotNull);
  });

  test('many bodies at the same point still build', () {
    final bodies = [
      for (var i = 0; i < 50; i++) QuadtreeBody(id: i, x: 120, y: 340),
    ];

    expect(() => QuadtreeNode.build(bodies, bounds), returnsNormally);
  });

  test('coincident bodies still push, in proportion to how many there are', () {
    const observer = QuadtreeBody(id: 'observer', x: 500, y: 500);

    Offset repulsionFrom(int count) {
      final tree = QuadtreeNode.build([
        for (var i = 0; i < count; i++) QuadtreeBody(id: i, x: 10, y: 10),
      ], bounds);
      return tree.computeRepulsion(observer, 1000, 0.5);
    }

    // Capping the depth must not lose the bodies that stopped there: the
    // traversal reads an internal node's centre of mass, which they are part
    // of. Ten bodies push about ten times as hard as one.
    final one = repulsionFrom(1).distance;
    final ten = repulsionFrom(10).distance;
    expect(ten, closeTo(one * 10, one));
  });

  test('bodies at distinct points are unaffected', () {
    final tree = QuadtreeNode.build(const [
      QuadtreeBody(id: 'a', x: 100, y: 100),
      QuadtreeBody(id: 'b', x: 200, y: 200),
    ], bounds);

    // Off to one side of both, so their pushes add rather than cancel.
    const observer = QuadtreeBody(id: 'observer', x: 800, y: 800);
    final force = tree.computeRepulsion(observer, 1000, 0.5);
    expect(force.distance, greaterThan(0));
    // Pushed away from the pair, so further out along both axes.
    expect(force.dx, greaterThan(0));
    expect(force.dy, greaterThan(0));
  });
}
