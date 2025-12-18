import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/geometry.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/graph_view/geometry.dart';
import 'package:plough/src/graph_view/graph_view.dart';

/// A line segment between two points in a graph.
///
/// Used for calculating intersections between nodes and links.
/// The line has a start and end point specified in the graph's coordinate system.
///
/// See also:
///
/// * [GraphShape], which uses lines to calculate intersection points
/// * [GraphConnectionPoints], which represents node-link connection points
class GraphLine {
  /// Creates a line between two points.
  const GraphLine(this.start, this.end);

  /// The starting point of the line.
  final Offset start;

  /// The ending point of the line.
  final Offset end;

  /// Internal helper to convert to Flame's line segment representation.
  @internal
  LineSegment get flameLineSegment =>
      LineSegment(Vector2(start.dx, start.dy), Vector2(end.dx, end.dy));
}

/// An interface for defining node shapes in the graph.
///
/// Provides intersection calculation between a shape and a line, which is used
/// to determine where links should connect to nodes.
///
/// Implementations include [GraphCircle] and [GraphRectangle] for standard
/// node shapes.
///
/// See also:
///
/// * [GraphLine], used for intersection calculations
/// * [GraphConnectionGeometry], which uses these shapes for link routing
abstract interface class GraphShape {
  /// Calculates intersection points between this shape and a line.
  ///
  /// Parameters:
  /// - [bounds]: The shape's bounding rectangle
  /// - [line]: Line to check for intersections
  ///
  /// Returns a set of points where the line intersects the shape.
  Set<Offset> getLineIntersections(Rect bounds, GraphLine line);
}

/// A circular node shape.
///
/// Calculates intersections based on a circle's geometry. The radius can be explicitly
/// specified or computed from the node's bounds.
///
/// See also:
///
/// * [GraphRectangle], for rectangular node shapes
class GraphCircle implements GraphShape {
  /// Creates a circular shape with a specified [radius].
  const GraphCircle({required this.radius});

  /// Optional radius for the circle.
  ///
  /// When null, the radius is computed from the node's bounds.
  final double? radius;

  @override
  Set<Offset> getLineIntersections(Rect bounds, GraphLine line) {
    final flameCircle = CircleComponent(
      position: Vector2(bounds.left, bounds.top),
      radius: radius,
    );
    final intersections = flameCircle.lineSegmentIntersections(
      line.flameLineSegment,
    );
    return _vector2SetToOffsetSet(intersections);
  }
}

/// A rectangular node shape.
///
/// Calculates intersections based on the node's bounding rectangle.
///
/// See also:
///
/// * [GraphCircle], for circular node shapes
class GraphRectangle implements GraphShape {
  /// Creates a rectangular shape. Dimensions are determined by the node's bounds.
  const GraphRectangle();

  @override
  Set<Offset> getLineIntersections(Rect bounds, GraphLine line) {
    final flameRect = Rectangle.fromRect(bounds);
    final intersections = flameRect.intersections(line.flameLineSegment);
    return _vector2SetToOffsetSet(intersections);
  }
}

Set<Offset> _vector2SetToOffsetSet(Iterable<Vector2> vectors) {
  return vectors.map((v) => Offset(v.x, v.y)).toSet();
}
