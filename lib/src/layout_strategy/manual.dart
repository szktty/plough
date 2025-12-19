import 'dart:math' as math;
import 'dart:ui';

import 'package:plough/src/graph/graph_base.dart';
import 'package:plough/src/graph/node.dart';
import 'package:plough/src/layout_strategy/base.dart';

/// Defines the reference point for manual node positioning.
///
/// The origin point determines how node positions are calculated relative to
/// the container boundaries.
enum GraphLayoutPositionOrigin {
  /// Positions are relative to the top-left corner
  topLeft,

  /// Positions are relative to the top-center point
  topCenter,

  /// Positions are relative to the top-right corner
  topRight,

  /// Positions are relative to the middle-left point
  centerLeft,

  /// Positions are relative to the center point
  center,

  /// Positions are relative to the middle-right point
  centerRight,

  /// Positions are relative to the bottom-left corner
  bottomLeft,

  /// Positions are relative to the bottom-center point
  bottomCenter,

  /// Positions are relative to the bottom-right corner
  bottomRight,

  /// Positions are relative to the center of all nodes' bounding box
  alignCenter,
}

/// A layout strategy for manual node positioning.
///
/// Provides precise control over node placement through:
///
/// * Individual node positions via [nodePositions]
/// * Reference point selection with [origin]
/// * Fine position adjustment using [originOffset]
///
/// Example usage:
/// ```dart
/// final positions = [
///   GraphNodeLayoutPosition(
///     id: node1.id,
///     position: const Offset(100, 100),
///   ),
///   GraphNodeLayoutPosition(
///     id: node2.id,
///     position: const Offset(200, 200),
///   ),
/// ];
///
/// final layout = GraphManualLayoutStrategy(
///   nodePositions: positions,
///   origin: GraphLayoutPositionOrigin.center,
///   originOffset: const Offset(0, -50),
/// );
///
/// return GraphView(
///   graph: graph,
///   layoutStrategy: layout,
/// );
/// ```
///
/// See also:
///
/// * [GraphLayoutPositionOrigin] for available reference points
/// * [GraphLayoutStrategy] for the base layout functionality
base class GraphManualLayoutStrategy extends GraphLayoutStrategy {
  /// Creates a manual layout strategy with required node positions and optional configuration.
  GraphManualLayoutStrategy({
    required super.nodePositions,
    this.origin = GraphLayoutPositionOrigin.alignCenter,
    this.originOffset = Offset.zero,
  });

  /// The reference point for node positioning.
  ///
  /// Determines how the coordinate system is aligned within the container.
  final GraphLayoutPositionOrigin origin;

  /// Additional offset from the origin point.
  ///
  /// Applied after origin calculations for fine position adjustment.
  final Offset originOffset;

  Offset _calculateNodesCenter(Graph graph) {
    if (graph.nodes.isEmpty) return Offset.zero;

    var minX = double.infinity;
    var maxX = double.negativeInfinity;
    var minY = double.infinity;
    var maxY = double.negativeInfinity;

    for (final nodePosition in nodePositions) {
      final node = graph.getNode(nodePosition.id);
      if (node == null) continue;

      final bounds = (node as GraphNodeImpl).geometry?.bounds;
      if (bounds == null) {
        minX = math.min(minX, nodePosition.position.dx);
        maxX = math.max(maxX, nodePosition.position.dx);
        minY = math.min(minY, nodePosition.position.dy);
        maxY = math.max(maxY, nodePosition.position.dy);
      } else {
        minX = math.min(minX, nodePosition.position.dx);
        maxX = math.max(maxX, nodePosition.position.dx + bounds.width);
        minY = math.min(minY, nodePosition.position.dy);
        maxY = math.max(maxY, nodePosition.position.dy + bounds.height);
      }
    }

    return Offset((maxX + minX) / 2, (maxY + minY) / 2);
  }

  Offset _calculateAbsolutePosition(
    Offset relativePosition,
    Size containerSize, {
    Offset? centerOffset,
    Offset? screenCenter,
  }) {
    if (origin == GraphLayoutPositionOrigin.alignCenter) {
      if (centerOffset == null || screenCenter == null) {
        throw StateError(
          'centerOffset and screenCenter must be provided for alignCenter',
        );
      }
      return (relativePosition - centerOffset) + screenCenter + originOffset;
    }
    final basePoint = switch (origin) {
      GraphLayoutPositionOrigin.topLeft => Offset.zero,
      GraphLayoutPositionOrigin.topCenter => Offset(containerSize.width / 2, 0),
      GraphLayoutPositionOrigin.topRight => Offset(containerSize.width, 0),
      GraphLayoutPositionOrigin.centerLeft => Offset(
          0,
          containerSize.height / 2,
        ),
      GraphLayoutPositionOrigin.center => containerSize.center(Offset.zero),
      GraphLayoutPositionOrigin.centerRight => Offset(
          containerSize.width,
          containerSize.height / 2,
        ),
      GraphLayoutPositionOrigin.bottomLeft => Offset(0, containerSize.height),
      GraphLayoutPositionOrigin.bottomCenter => Offset(
          containerSize.width / 2,
          containerSize.height,
        ),
      GraphLayoutPositionOrigin.bottomRight => Offset(
          containerSize.width,
          containerSize.height,
        ),
      GraphLayoutPositionOrigin.alignCenter => throw StateError('unreachable'),
    };

    return basePoint + originOffset + relativePosition;
  }

  @override
  void performLayout(Graph graph, Size size) {
    super.performLayout(graph, size);

    final centerOffset = origin == GraphLayoutPositionOrigin.alignCenter
        ? _calculateNodesCenter(graph)
        : null;
    final screenCenter = origin == GraphLayoutPositionOrigin.alignCenter
        ? size.center(Offset.zero)
        : null;

    for (final nodePosition in nodePositions) {
      final node = graph.getNode(nodePosition.id);
      if (node != null) {
        final absolutePosition = _calculateAbsolutePosition(
          nodePosition.position,
          size,
          centerOffset: centerOffset,
          screenCenter: screenCenter,
        );
        positionNode(node, absolutePosition);
      }
    }
  }

  @override
  bool shouldRelayout(covariant GraphManualLayoutStrategy oldStrategy) {
    return !baseEquals(oldStrategy) ||
        origin != oldStrategy.origin ||
        originOffset != oldStrategy.originOffset;
  }
}
