// Regression coverage for the self-contained segment/shape intersection math.
//
// Unlike geometry_intersect_parity_test.dart (which cross-checks against flame
// and is removed with the dependency), this test asserts against hand-computed
// expected values, so it stays valid permanently.
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:plough/src/utils/geometry_intersect.dart';

/// Compares two unordered point sets with a tolerance, regardless of order.
void _expectSetsClose(
  Set<Offset> actual,
  Set<Offset> expected, {
  double tol = 1e-6,
}) {
  expect(
    actual.length,
    expected.length,
    reason: 'expected $expected but got $actual',
  );
  for (final e in expected) {
    final match = actual.any((a) => (a - e).distance <= tol);
    expect(match, isTrue, reason: 'no point near $e in $actual');
  }
}

void main() {
  group('segmentCircleIntersections', () {
    const center = Offset(100, 100);
    const r = 30.0;

    test('horizontal chord through center hits both sides', () {
      _expectSetsClose(
        segmentCircleIntersections(
          const Offset(0, 100),
          const Offset(200, 100),
          center,
          r,
        ),
        {const Offset(70, 100), const Offset(130, 100)},
      );
    });

    test('vertical chord through center hits both sides', () {
      _expectSetsClose(
        segmentCircleIntersections(
          const Offset(100, 0),
          const Offset(100, 200),
          center,
          r,
        ),
        {const Offset(100, 70), const Offset(100, 130)},
      );
    });

    test('segment starting at center yields the far-side point only', () {
      _expectSetsClose(
        segmentCircleIntersections(
          const Offset(100, 100),
          const Offset(300, 100),
          center,
          r,
        ),
        {const Offset(130, 100)},
      );
    });

    test('tangent line touches at a single point', () {
      _expectSetsClose(
        segmentCircleIntersections(
          const Offset(0, 70),
          const Offset(200, 70),
          center,
          r,
        ),
        {const Offset(100, 70)},
      );
    });

    test('segment that misses the circle returns empty', () {
      expect(
        segmentCircleIntersections(
          const Offset(0, 200),
          const Offset(200, 200),
          center,
          r,
        ),
        isEmpty,
      );
    });

    test('degenerate zero-length segment on the circle returns the point', () {
      _expectSetsClose(
        segmentCircleIntersections(
          const Offset(130, 100),
          const Offset(130, 100),
          center,
          r,
        ),
        {const Offset(130, 100)},
      );
    });
  });

  group('segmentRectIntersections', () {
    // 80..120 square.
    const bounds = Rect.fromLTWH(80, 80, 40, 40);

    test('horizontal line through the rect enters and exits', () {
      _expectSetsClose(
        segmentRectIntersections(
          const Offset(0, 100),
          const Offset(200, 100),
          bounds,
        ),
        {const Offset(80, 100), const Offset(120, 100)},
      );
    });

    test('vertical line through the rect enters and exits', () {
      _expectSetsClose(
        segmentRectIntersections(
          const Offset(100, 0),
          const Offset(100, 200),
          bounds,
        ),
        {const Offset(100, 80), const Offset(100, 120)},
      );
    });

    test('diagonal through the rect hits two corners', () {
      _expectSetsClose(
        segmentRectIntersections(
          const Offset(0, 0),
          const Offset(200, 200),
          bounds,
        ),
        {const Offset(80, 80), const Offset(120, 120)},
      );
    });

    test('segment starting inside the rect yields only the exit point', () {
      _expectSetsClose(
        segmentRectIntersections(
          const Offset(100, 100),
          const Offset(300, 100),
          bounds,
        ),
        {const Offset(120, 100)},
      );
    });

    test('segment ending inside the rect yields only the entry point', () {
      _expectSetsClose(
        segmentRectIntersections(
          const Offset(0, 0),
          const Offset(90, 90),
          bounds,
        ),
        {const Offset(80, 80)},
      );
    });

    test('segment that misses the rect returns empty', () {
      expect(
        segmentRectIntersections(
          const Offset(0, 300),
          const Offset(200, 300),
          bounds,
        ),
        isEmpty,
      );
    });
  });
}
