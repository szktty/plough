import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/graph_view/graph_view.dart';
import 'package:signals/signals_flutter.dart';

part 'geometry.freezed.dart';

/// Defines the connection points between nodes for link calculation and rendering.
///
/// See also:
///
/// * [GraphConnectionGeometry], which uses these points for link rendering
/// * [GraphShape], which calculates these intersection points
@freezed
class GraphConnectionPoints with _$GraphConnectionPoints {
  /// Creates a connection points configuration.
  const factory GraphConnectionPoints({
    /// The point where the link enters the target node.
    required Offset incoming,

    /// The point where the link exits the source node.
    required Offset outgoing,
  }) = _GraphConnectionPoints;

  const GraphConnectionPoints._();

  /// Represents the origin point (0, 0).
  static const GraphConnectionPoints zero = GraphConnectionPoints(
    incoming: Offset.zero,
    outgoing: Offset.zero,
  );

  /// The distance between connection points.
  double get distance => (incoming - outgoing).distance;

  /// The angle of the link in radians.
  double get angle =>
      math.atan2(incoming.dy - outgoing.dy, incoming.dx - outgoing.dx);
}

/// Defines a node's layout bounds for rendering and hit testing.
///
/// See also:
///
/// * [GraphLinkViewGeometry], which uses this information for link routing
/// * [GraphViewBehavior], which uses this for hit testing and interactions
@freezed
class GraphNodeViewGeometry with _$GraphNodeViewGeometry {
  /// Creates node geometry with the specified [bounds] rectangle.
  const factory GraphNodeViewGeometry({
    required Rect bounds,
  }) = _GraphNodeViewGeometry;
}

/// Combines spatial information needed to render and interact with links.
///
/// See also:
///
/// * [GraphConnectionGeometry], which defines node connection details
/// * [GraphViewBehavior], which uses this for hit testing and interactions
@freezed
class GraphLinkViewGeometry with _$GraphLinkViewGeometry {
  /// Creates link geometry with the specified layout parameters.
  const factory GraphLinkViewGeometry({
    required Rect bounds,
    required GraphConnectionGeometry connection,
    required double thickness,
    required double angle,
  }) = _GraphLinkViewGeometry;

  const GraphLinkViewGeometry._();

  /// Determines if a point is within the link's area.
  bool containsPoint(Offset point) {
    final center = bounds.center;
    final rotatedPoint = _rotatePoint(point, center, -angle);
    return bounds.contains(rotatedPoint);
  }

  Offset _rotatePoint(Offset point, Offset center, double angle) {
    final dx = point.dx - center.dx;
    final dy = point.dy - center.dy;

    final rotatedDx = dx * math.cos(angle) - dy * math.sin(angle);
    final rotatedDy = dx * math.sin(angle) + dy * math.cos(angle);

    return Offset(
      center.dx + rotatedDx,
      center.dy + rotatedDy,
    );
  }
}

/// Manages geometric relationships between connected nodes.
///
/// See also:
///
/// * [GraphLinkViewGeometry], which uses this for link rendering
/// * [GraphViewBehavior], which calculates connection points
@freezed
class GraphConnectionGeometry with _$GraphConnectionGeometry {
  /// Creates connection geometry between two nodes.
  const factory GraphConnectionGeometry({
    /// The source node's layout geometry from which the link originates.
    required GraphNodeViewGeometry source,

    /// The target node's layout geometry where the link terminates.
    required GraphNodeViewGeometry target,

    /// The specific points where the link intersects with source and target nodes.
    required GraphConnectionPoints connectionPoints,
  }) = _GraphConnectionGeometry;

  /// Retrieves the current connection geometry from the widget tree.
  ///
  /// Returns null if no connection geometry is available in the current context.
  static GraphConnectionGeometry? of(BuildContext context) {
    return SignalProvider.of<FlutterSignal<GraphConnectionGeometry?>>(context)
        ?.value;
  }
}

/// Tracks graph view layout within the widget tree.
///
/// See also:
///
/// * [GraphView], which manages this geometry
/// * [GraphViewBehavior], which uses this for coordinate transformations
@freezed
class GraphViewGeometry with _$GraphViewGeometry {
  /// Creates view geometry with the specified [position] and [size].
  const factory GraphViewGeometry({
    required Offset position,
    required Size size,
  }) = _GraphViewGeometry;

  static GraphViewGeometry? of(BuildContext context) {
    return SignalProvider.of<FlutterSignal<GraphViewGeometry?>>(context)?.value;
  }
}
