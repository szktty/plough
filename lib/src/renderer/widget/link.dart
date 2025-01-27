import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:plough/src/graph/graph_data.dart';
import 'package:plough/src/graph/link.dart';
import 'package:plough/src/graph_view/behavior.dart';
import 'package:plough/src/graph_view/geometry.dart';
import 'package:plough/src/renderer/style/link.dart';

/// A comprehensive default link widget used by [GraphLinkViewBehavior].
///
/// This widget provides the default link rendering implementation with extensive
/// customization options through styles and routing choices. Used as the default
/// link renderer in [GraphLinkViewBehavior], but can be replaced with custom
/// widgets if needed.
///
/// Features straight and orthogonal routing, customizable arrows and line styles,
/// and efficient rendering using [CustomPainter].
///
/// Example:
/// ```dart
/// GraphDefaultLinkRenderer(
///   link: GraphLink(
///     source: sourceNode,
///     target: targetNode,
///     direction: GraphLinkDirection.outgoing,
///   ),
///   sourceView: sourceNodeWidget,
///   targetView: targetNodeWidget,
///   routing: GraphLinkRouting.straight,
///   geometry: geometry,
///   style: const GraphDefaultLinkRendererStyle(),
/// )
/// ```
///
/// See also:
/// * [GraphLinkViewBehavior] for the core link view system
/// * [GraphConnectionGeometry] for link positioning calculations
class GraphDefaultLinkRenderer extends StatelessWidget {
  /// Creates a link renderer with the specified configuration.
  ///
  /// The [link], [sourceView], [targetView], [routing], and [geometry] parameters
  /// are required. Optional parameters control visual appearance and behavior.
  const GraphDefaultLinkRenderer({
    required this.link,
    required this.sourceView,
    required this.targetView,
    required this.routing,
    required this.geometry,
    this.child,
    this.style = const GraphDefaultLinkRendererStyle(),
    this.thickness = 20,
    this.lineWidth = 2,
    this.arrowSize = 15,
    this.color = Colors.black,
    this.lineStyle = PaintingStyle.stroke,
    this.arrowStyle = PaintingStyle.fill,
    super.key,
  });

  /// The link to render.
  final GraphLink link;

  /// The source node's rendered widget.
  final Widget sourceView;

  /// The target node's rendered widget.
  final Widget targetView;

  /// Optional child widget rendered alongside the link.
  final Widget? child;

  /// Style configuration for the link.
  final GraphDefaultLinkRendererStyle style;

  /// Interactive area thickness for hit testing.
  final double thickness;

  /// The routing strategy for the link path.
  final GraphLinkRouting routing;

  /// Geometric information for link positioning.
  final GraphConnectionGeometry geometry;

  /// Width of the link line.
  final double lineWidth;

  /// Size of the arrow head.
  final double arrowSize;

  /// Color of the link and arrow.
  final Color color;

  /// The painting style for link lines.
  final PaintingStyle lineStyle;

  /// The painting style for arrow heads.
  final PaintingStyle arrowStyle;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _createPainter(),
      ),
    );
  }

  CustomPainter _createPainter() {
    switch (routing) {
      case GraphLinkRouting.straight:
        return _StraightLinkRendererPainter(this);
      case GraphLinkRouting.orthogonal:
        return _OrthogonalLinkRendererPainter(this);
    }
  }
}

/// Link rendering base functionality.
///
/// Provides the foundation for rendering links including arrow and line styles.
/// Subclasses must implement layout-specific functionality.
abstract class _BaseLinkRendererPainter extends CustomPainter {
  const _BaseLinkRendererPainter(this.renderer);

  final GraphDefaultLinkRenderer renderer;

  @override
  void paint(Canvas canvas, Size size) {
    final geometry = renderer.geometry;
    final p = geometry.connectionPoints;

    final paint = Paint()
      ..color = renderer.color
      ..strokeWidth = renderer.lineWidth
      ..style = renderer.lineStyle;

    final (outgoing, incoming) = calculatePoints(size, p);

    // Paint path (implemented by subclasses)
    paintPath(canvas, paint, incoming, outgoing, geometry);

    // Paint arrows
    paintArrows(canvas, paint, incoming, outgoing);
  }

  (Offset outgoing, Offset incoming) calculatePoints(
    Size size,
    GraphConnectionPoints points,
  );

  void paintPath(
    Canvas canvas,
    Paint paint,
    Offset incoming,
    Offset outgoing,
    GraphConnectionGeometry geometry,
  );

  void paintArrows(
    Canvas canvas,
    Paint paint,
    Offset incoming,
    Offset outgoing,
  ) {
    switch (renderer.link.direction) {
      case GraphLinkDirection.outgoing:
        drawArrow(canvas, paint, incoming, 0);
      case GraphLinkDirection.incoming:
        drawArrow(canvas, paint, outgoing, math.pi);
      case GraphLinkDirection.bidirectional:
        drawArrow(canvas, paint, incoming, 0);
        drawArrow(canvas, paint, outgoing, math.pi);
      case GraphLinkDirection.none:
        break;
    }
  }

  void drawArrow(Canvas canvas, Paint paint, Offset tip, double baseAngle) {
    final arrowSize = renderer.arrowSize;
    const arrowAngle = 25 * math.pi / 180;

    final x1 = tip.dx - arrowSize * math.cos(baseAngle + arrowAngle);
    final y1 = tip.dy - arrowSize * math.sin(baseAngle + arrowAngle);
    final x2 = tip.dx - arrowSize * math.cos(baseAngle - arrowAngle);
    final y2 = tip.dy - arrowSize * math.sin(baseAngle - arrowAngle);

    final arrowPath = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(x1, y1)
      ..lineTo(x2, y2)
      ..close();

    canvas.drawPath(arrowPath, paint..style = renderer.arrowStyle);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Straight link renderer.
///
/// Draws links as direct lines between nodes.
class _StraightLinkRendererPainter extends _BaseLinkRendererPainter {
  const _StraightLinkRendererPainter(super.renderer);

  @override
  (Offset outgoing, Offset incoming) calculatePoints(
    Size size,
    GraphConnectionPoints points,
  ) {
    return (
      Offset(0, renderer.thickness / 2),
      Offset(points.distance, renderer.thickness / 2),
    );
  }

  @override
  void paintPath(
    Canvas canvas,
    Paint paint,
    Offset incoming,
    Offset outgoing,
    GraphConnectionGeometry geometry,
  ) {
    canvas.drawLine(outgoing, incoming, paint);
  }
}

/// Orthogonal link renderer.
///
/// Draws links as sequences of horizontal and vertical lines:
/// - Vertical line from upper node's bottom center
/// - Horizontal line at midpoint
/// - Vertical line to lower node's top center
///
/// Arrow directions align with the final line segment.
class _OrthogonalLinkRendererPainter extends _BaseLinkRendererPainter {
  const _OrthogonalLinkRendererPainter(super.renderer);

  @override
  (Offset outgoing, Offset incoming) calculatePoints(
    Size size,
    GraphConnectionPoints points,
  ) {
    final geometry = renderer.geometry;
    final source = geometry.source.bounds;
    final target = geometry.target.bounds;

    // Determine upper and lower nodes
    final isSourceUpper = source.center.dy < target.center.dy;
    final upperBounds = isSourceUpper ? source : target;
    final lowerBounds = isSourceUpper ? target : source;

    // Calculate connection points
    final upperPoint = Offset(
      upperBounds.left + upperBounds.width / 2,
      upperBounds.bottom,
    );

    final lowerPoint = Offset(
      lowerBounds.left + lowerBounds.width / 2,
      lowerBounds.top,
    );

    final points =
        isSourceUpper ? (upperPoint, lowerPoint) : (lowerPoint, upperPoint);

    // Convert to source-relative coordinates
    return (
      Offset(points.$1.dx - source.left, points.$1.dy - source.top),
      Offset(points.$2.dx - source.left, points.$2.dy - source.top),
    );
  }

  @override
  void paintArrows(
    Canvas canvas,
    Paint paint,
    Offset incoming,
    Offset outgoing,
  ) {
    final lastSegmentDirection =
        _calculateLastSegmentDirection(incoming, outgoing);

    switch (renderer.link.direction) {
      case GraphLinkDirection.outgoing:
        drawArrow(canvas, paint, incoming, lastSegmentDirection);
      case GraphLinkDirection.incoming:
        drawArrow(
          canvas,
          paint,
          outgoing,
          (lastSegmentDirection + math.pi) % (2 * math.pi),
        );
      case GraphLinkDirection.bidirectional:
        drawArrow(canvas, paint, incoming, lastSegmentDirection);
        drawArrow(
          canvas,
          paint,
          outgoing,
          (lastSegmentDirection + math.pi) % (2 * math.pi),
        );
      case GraphLinkDirection.none:
        break;
    }
  }

  double _calculateLastSegmentDirection(Offset incoming, Offset outgoing) {
    final dx = incoming.dx - outgoing.dx;

    if (incoming.dy != outgoing.dy) {
      return math.pi / 2;
    }
    return dx > 0 ? 0 : math.pi;
  }

  @override
  void paintPath(
    Canvas canvas,
    Paint paint,
    Offset incoming,
    Offset outgoing,
    GraphConnectionGeometry geometry,
  ) {
    final path = Path();
    path.moveTo(outgoing.dx, outgoing.dy);

    final midY = (outgoing.dy + incoming.dy) / 2;

    path.lineTo(outgoing.dx, midY);
    path.lineTo(incoming.dx, midY);
    path.lineTo(incoming.dx, incoming.dy);

    canvas.drawPath(path, paint);
  }
}
