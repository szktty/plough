import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:plough/src/graph/link.dart';
import 'package:plough/src/graph_view/data.dart';
import 'package:plough/src/graph_view/geometry.dart';
import 'package:plough/src/graph_view/graph_view.dart';
import 'package:plough/src/utils/logger.dart';
import 'package:plough/src/utils/widget/position_plotter.dart';

/// A widget that renders connections between graph nodes.
///
/// Handles:
/// - Link geometry and position calculation
/// - Rotation and placement
/// - Connection point management
///
/// This widget should not be used directly - use [GraphView] instead.
///
/// See also:
/// * [GraphView], which manages the complete graph visualization
/// * [GraphLinkViewBehavior], for customizing link appearance
class GraphLinkView extends StatefulWidget {
  const GraphLinkView({
    required super.key,
    required this.link,
    required this.sourceView,
    required this.targetView,
    required this.behavior,
  });

  /// The link to be rendered.
  final GraphLink link;

  /// The widget representing the source node.
  final Widget sourceView;

  /// The widget representing the target node.
  final Widget targetView;

  /// Configuration for link appearance and behavior.
  final GraphLinkViewBehavior behavior;

  @override
  State<GraphLinkView> createState() => _GraphLinkViewState();
}

/// State class for [GraphLinkView].
///
/// Responsibilities:
/// - Updating link geometry
/// - Calculating position and rotation
/// - Updating connection points
///
/// See also:
/// * [GraphLinkView], the stateful widget using this state
/// * [GraphLinkViewGeometry], which defines the link's spatial properties
class _GraphLinkViewState extends State<GraphLinkView> {
  GraphLinkImpl get link => widget.link as GraphLinkImpl;

  GraphLinkViewBehavior get behavior => widget.behavior;

  @override
  void dispose() {
    log.d('GraphLinkView: dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log.d('GraphLinkView: ${link.id}: build');
    final graphViewData = GraphViewData.of(context);
    final graphViewBehavior = graphViewData.behavior;
    log.d(
      'GraphLinkView: ${link.id}: watch nodes ${link.source.id} -> ${link.target.id}',
    );

    // Listen to both source and target node changes to update link position
    return AnimatedBuilder(
      animation: Listenable.merge([link.source, link.target]),
      builder: (context, _) {
        final sourceGeometry = link.source.geometry;
        final targetGeometry = link.target.geometry;

        if (sourceGeometry == null || targetGeometry == null) {
          log.d('GraphLinkView: waiting to get node geometries...');
          return const SizedBox();
        }

        final connPoints = graphViewBehavior.getConnectionPoints(
          link.source,
          link.target,
          widget.sourceView,
          widget.targetView,
        );
        if (connPoints == null) {
          log.d('GraphLinkView: waiting to calculate connection points...');
          return const SizedBox();
        }

        if (!connPoints.incoming.isFinite || !connPoints.outgoing.isFinite) {
          log.e(
            'GraphLinkView: ${link.id}: connection points must be infinite',
          );
          return const SizedBox();
        }

        final geometry = GraphConnectionGeometry(
          source: sourceGeometry,
          target: targetGeometry,
          connectionPoints: connPoints,
        );

        return _buildPositioned(
          geometry: geometry,
          thickness: behavior.thicknessGetter?.call(
                context,
                graphViewData.graph,
                link,
                widget.sourceView,
                widget.targetView,
              ) ??
              behavior.thickness,
          child: GraphPositionPlotter.wrapOr(
            child: behavior.builder(
              context,
              graphViewData.graph,
              link,
              widget.sourceView,
              widget.targetView,
              behavior.routing,
              geometry,
              behavior.child,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPositioned({
    required GraphConnectionGeometry geometry,
    required double thickness,
    required Widget child,
  }) {
    final p = geometry.connectionPoints;
    switch (behavior.routing) {
      case GraphLinkRouting.straight:
        final angle = math.atan2(
          p.incoming.dy - p.outgoing.dy,
          p.incoming.dx - p.outgoing.dx,
        );
        final viewGeometry = GraphLinkViewGeometry(
          bounds: Rect.fromPoints(p.outgoing, p.incoming),
          connection: geometry,
          thickness: thickness,
          angle: angle,
        );
        // Defer geometry update to avoid setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          link.geometry = viewGeometry;
        });

        final dx = p.outgoing.dx + (thickness / 2) * math.sin(angle);
        final dy = p.outgoing.dy - (thickness / 2) * math.cos(angle);
        return Positioned(
          left: dx,
          top: dy,
          child: Transform.rotate(
            alignment: Alignment.topLeft,
            angle: p.angle,
            child: Container(
              padding: EdgeInsets.zero,
              width: p.distance,
              height: thickness,
              child: child,
            ),
          ),
        );
      case GraphLinkRouting.orthogonal:
        final bounds = Rect.fromLTRB(
          math.min(geometry.source.bounds.left, geometry.target.bounds.left),
          math.min(geometry.source.bounds.top, geometry.target.bounds.top),
          math.max(geometry.source.bounds.right, geometry.target.bounds.right),
          math.max(
            geometry.source.bounds.bottom,
            geometry.target.bounds.bottom,
          ),
        );

        final viewGeometry = GraphLinkViewGeometry(
          bounds: bounds,
          connection: geometry,
          thickness: thickness,
          angle: 0,
        );

        // Defer geometry update to avoid setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          link.geometry = viewGeometry;
        });

        return Positioned(
          left: bounds.left,
          top: bounds.top,
          child: Container(
            padding: EdgeInsets.zero,
            width: bounds.width,
            height: bounds.height,
            child: child,
          ),
        );
    }
  }
}
