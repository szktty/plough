// Geometry helpers for computing intersections between a line segment and
// simple shapes (circles, axis-aligned rectangles).
//
// These replace the previous dependency on the `flame` game engine, which was
// pulled in only for line-segment intersection math. The functions here are
// self-contained and web-safe.
//
// All inputs and outputs use Flutter's Offset. A "segment" is the finite line
// from start to end; intersection points outside [start, end] are excluded
// (matching the segment semantics flame provided).

import 'dart:math' as math;
import 'dart:ui';

/// Tolerance used when deciding whether a parametric value lies within the
/// `[0, 1]` segment range, or whether a discriminant is effectively zero.
const double _epsilon = 1e-9;

/// Returns the points where the segment [start]–[end] crosses the circle
/// centered at [center] with the given [radius].
///
/// The result contains 0, 1 (tangent), or 2 points and only includes
/// intersections that fall on the finite segment.
Set<Offset> segmentCircleIntersections(
  Offset start,
  Offset end,
  Offset center,
  double radius,
) {
  // Parameterize the segment as P(t) = start + t * d, t in [0, 1].
  // Solve |P(t) - center|^2 = radius^2 for t.
  final dx = end.dx - start.dx;
  final dy = end.dy - start.dy;
  final fx = start.dx - center.dx;
  final fy = start.dy - center.dy;

  final a = dx * dx + dy * dy;
  if (a <= _epsilon) {
    // Degenerate segment (start == end): treat as a point test.
    final distSq = fx * fx + fy * fy;
    if ((distSq - radius * radius).abs() <= _epsilon) {
      return {start};
    }
    return <Offset>{};
  }

  final b = 2 * (fx * dx + fy * dy);
  final c = fx * fx + fy * fy - radius * radius;

  final discriminant = b * b - 4 * a * c;
  if (discriminant < -_epsilon) {
    return <Offset>{};
  }

  final results = <Offset>{};
  final sqrtDisc = math.sqrt(math.max(discriminant, 0));

  final t1 = (-b - sqrtDisc) / (2 * a);
  final t2 = (-b + sqrtDisc) / (2 * a);

  for (final t in {t1, t2}) {
    if (t >= -_epsilon && t <= 1 + _epsilon) {
      results.add(Offset(start.dx + t * dx, start.dy + t * dy));
    }
  }
  return results;
}

/// Returns the points where the segment [start]–[end] crosses the boundary of
/// the axis-aligned rectangle [bounds].
///
/// Only boundary crossings are returned; a segment fully contained within the
/// rectangle produces no points. Uses the Liang–Barsky parametric clip to find
/// where the segment enters and exits the rectangle, then keeps the parameters
/// that correspond to an actual edge crossing.
///
/// When [start] is already on or inside the rectangle, the entry point is not
/// emitted (only the exit is); symmetrically, an [end] on or inside the
/// rectangle omits the exit. For the center-to-center link routing this is
/// used for, [start] is the node center (always interior), so callers get the
/// single boundary crossing toward [end].
Set<Offset> segmentRectIntersections(
  Offset start,
  Offset end,
  Rect bounds,
) {
  final dx = end.dx - start.dx;
  final dy = end.dy - start.dy;

  // p/q pairs for the four clip edges (left, right, top, bottom).
  final p = <double>[-dx, dx, -dy, dy];
  final q = <double>[
    start.dx - bounds.left,
    bounds.right - start.dx,
    start.dy - bounds.top,
    bounds.bottom - start.dy,
  ];

  var tEnter = 0.0;
  var tExit = 1.0;

  for (var i = 0; i < 4; i++) {
    if (p[i].abs() <= _epsilon) {
      // Segment parallel to this edge: reject if it starts outside the slab.
      if (q[i] < -_epsilon) {
        return <Offset>{};
      }
      continue;
    }
    final t = q[i] / p[i];
    if (p[i] < 0) {
      if (t > tEnter) tEnter = t;
    } else {
      if (t < tExit) tExit = t;
    }
  }

  if (tEnter > tExit) {
    return <Offset>{};
  }

  final results = <Offset>{};
  // tEnter is a boundary crossing only if it lies strictly after the segment
  // start (otherwise the start is already inside or on the rectangle).
  if (tEnter > _epsilon) {
    results.add(Offset(start.dx + tEnter * dx, start.dy + tEnter * dy));
  }
  if (tExit < 1 - _epsilon) {
    results.add(Offset(start.dx + tExit * dx, start.dy + tExit * dy));
  }
  return results;
}
