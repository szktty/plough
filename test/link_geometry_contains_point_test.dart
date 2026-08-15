import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/src/graph_view/geometry.dart';

/// Regression guard for link hit-testing.
///
/// [GraphLinkViewGeometry.bounds] spans the two endpoints and nothing else, so
/// an axis-aligned link has a rect of zero height (or width). `Rect.contains`
/// is false for every point of an empty rect, so hit-testing a horizontal or
/// vertical link failed everywhere — even on its own centre line. The visible
/// band is `thickness` wide, and that is what the test has to use.
GraphLinkViewGeometry _geometry({
  required Offset from,
  required Offset to,
  double thickness = 30,
}) {
  return GraphLinkViewGeometry(
    bounds: Rect.fromPoints(from, to),
    connection: GraphConnectionGeometry(
      source:
          GraphNodeViewGeometry(bounds: Rect.fromLTWH(from.dx, from.dy, 0, 0)),
      target: GraphNodeViewGeometry(bounds: Rect.fromLTWH(to.dx, to.dy, 0, 0)),
      connectionPoints: GraphConnectionPoints(outgoing: from, incoming: to),
    ),
    thickness: thickness,
    angle: math.atan2(to.dy - from.dy, to.dx - from.dx),
  );
}

void main() {
  group('GraphLinkViewGeometry.containsPoint', () {
    test('a horizontal link is hit on its centre line', () {
      final geometry = _geometry(
        from: const Offset(100, 200),
        to: const Offset(300, 200),
      );

      expect(geometry.containsPoint(const Offset(200, 200)), isTrue);
    });

    test('a horizontal link is hit within its thickness', () {
      final geometry = _geometry(
        from: const Offset(100, 200),
        to: const Offset(300, 200),
      );

      expect(geometry.containsPoint(const Offset(200, 210)), isTrue);
      expect(geometry.containsPoint(const Offset(200, 190)), isTrue);
      expect(geometry.containsPoint(const Offset(200, 230)), isFalse);
      expect(geometry.containsPoint(const Offset(200, 170)), isFalse);
    });

    test('a vertical link is hit on its centre line and within its thickness',
        () {
      final geometry = _geometry(
        from: const Offset(200, 100),
        to: const Offset(200, 300),
      );

      expect(geometry.containsPoint(const Offset(200, 200)), isTrue);
      expect(geometry.containsPoint(const Offset(210, 200)), isTrue);
      expect(geometry.containsPoint(const Offset(240, 200)), isFalse);
    });

    test('a diagonal link is hit along its own axis', () {
      final geometry = _geometry(
        from: const Offset(100, 100),
        to: const Offset(300, 300),
      );

      expect(geometry.containsPoint(const Offset(200, 200)), isTrue);
      // Perpendicular to a 45° link: still inside half the thickness.
      expect(geometry.containsPoint(const Offset(205, 195)), isTrue);
    });

    test('points beyond the endpoints miss', () {
      final geometry = _geometry(
        from: const Offset(100, 200),
        to: const Offset(300, 200),
      );

      expect(geometry.containsPoint(const Offset(50, 200)), isFalse);
      expect(geometry.containsPoint(const Offset(350, 200)), isFalse);
    });

    test('a thinner link has a correspondingly smaller hit area', () {
      final geometry = _geometry(
        from: const Offset(100, 200),
        to: const Offset(300, 200),
        thickness: 4,
      );

      expect(geometry.containsPoint(const Offset(200, 201)), isTrue);
      expect(geometry.containsPoint(const Offset(200, 210)), isFalse);
    });
  });
}
