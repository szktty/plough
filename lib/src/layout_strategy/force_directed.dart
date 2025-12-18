import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/graph/node.dart';

/// A physics-based layout strategy using a force-directed algorithm.
///
/// Uses spring forces between linked nodes and Coulomb forces for repulsion,
/// resulting in naturally spaced layouts. Positions can be adjusted through
/// spring length, stiffness, damping, and other physics parameters.
///
/// Example:
/// ```dart
/// final layout = GraphForceDirectedLayoutStrategy(
///   springLength: 150,
///   springConstant: 0.2,
///   damping: 0.9,
///   centerNodeId: rootId,
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
/// * [GraphTreeLayoutStrategy] for hierarchical layouts
/// * [GraphManualLayoutStrategy] for precise control
base class GraphForceDirectedLayoutStrategy extends GraphLayoutStrategy {
  /// Creates a force-directed layout with physics-based node positioning.
  ///
  /// The [centerNodeId] can be specified to anchor a node at the center
  /// of the layout area. Other parameters control the physics simulation
  /// for layout calculation.
  GraphForceDirectedLayoutStrategy({
    double? springLength,
    double? springConstant,
    double? damping,
    double? coulombConstant,
    double? maxDisplacement,
    int? maxIterations,
    double? tolerance,
    this.centerNodeId,
    super.seed,
    super.padding,
  })  : springLength = springLength ?? 200.0,
        springConstant = springConstant ?? 0.1,
        damping = damping ?? 0.8,
        coulombConstant = coulombConstant ?? 2000.0,
        maxDisplacement = maxDisplacement ?? 50.0,
        maxIterations = maxIterations ?? 500,
        tolerance = tolerance ?? 0.5;

  /// Natural length of springs between linked nodes.
  final double springLength;

  /// Spring stiffness coefficient.
  final double springConstant;

  /// Velocity reduction factor for node movement.
  final double damping;

  /// Coulomb force coefficient for node repulsion.
  final double coulombConstant;

  /// Maximum allowed node movement per iteration.
  final double maxDisplacement;

  /// Maximum number of simulation iterations.
  final int maxIterations;

  /// Convergence threshold for total node movement.
  final double tolerance;

  /// ID of the node to fix at the center of the layout area.
  final GraphId? centerNodeId;

  @override
  void performLayout(Graph graph, Size size) {
    super.performLayout(graph, size);

    // Get center node position
    final centerNode =
        centerNodeId != null ? graph.getNode(centerNodeId!) : null;
    if (centerNode != null) {
      positionNode(centerNode, size.center(Offset.zero));
    }

    // Initial node placement (skip already positioned nodes)
    final width = size.width - padding.left - padding.right;
    final height = size.height - padding.top - padding.bottom;
    for (final node in graph.nodes) {
      // Skip initial placement for already positioned nodes
      final nodeImpl = node as GraphNodeImpl;
      if (nodeImpl.isArranged && node.logicalPosition != Offset.zero) {
        continue;
      }
      final dx = random.nextDouble() * width + padding.left;
      final dy = random.nextDouble() * height + padding.top;
      positionNode(node, Offset(dx, dy));
    }

    // Iterative layout calculation
    var iteration = 0;
    var totalDisplacement = double.infinity;

    while (iteration < maxIterations && totalDisplacement > tolerance) {
      totalDisplacement = 0.0;
      final forces = {for (final node in graph.nodes) node: Offset.zero};

      // Calculate Coulomb force (repulsion)
      for (final node1 in graph.nodes) {
        for (final node2 in graph.nodes) {
          if (node1 == node2) continue;

          final delta = node2.logicalPosition - node1.logicalPosition;
          final distance = delta.distance;
          if (distance == 0) continue;

          // Calculate repulsion force (based on Coulomb's law)
          final force = coulombConstant / (distance * distance);
          final directionScale = force / distance;
          forces[node1] = forces[node1]! -
              Offset(delta.dx * directionScale, delta.dy * directionScale);
          forces[node2] = forces[node2]! +
              Offset(delta.dx * directionScale, delta.dy * directionScale);
        }
      }

      // Calculate spring force (attraction)
      for (final link in graph.links) {
        final source = link.source;
        final target = link.target;
        final delta = target.logicalPosition - source.logicalPosition;
        final distance = delta.distance;
        if (distance == 0) continue;

        // Calculate spring force (based on Hooke's law)
        final force = springConstant * (distance - springLength);
        final directionScale = force / distance;
        forces[source] = forces[source]! +
            Offset(delta.dx * directionScale, delta.dy * directionScale);
        forces[target] = forces[target]! -
            Offset(delta.dx * directionScale, delta.dy * directionScale);
      }

      // Update node positions
      for (final node in graph.nodes) {
        var force = forces[node]! * damping;

        // Limit maximum displacement
        final displacement = force.distance;
        if (displacement > maxDisplacement) {
          force = Offset(
            force.dx * maxDisplacement / displacement,
            force.dy * maxDisplacement / displacement,
          );
        }

        // Calculate new position and boundary check
        var newPosition = node.logicalPosition + force;

        // Ensure clamp bounds are valid (min <= max)
        final minX = padding.left;
        final maxX = (size.width - padding.right).clamp(minX, double.infinity);
        final minY = padding.top;
        final maxY = (size.height - padding.bottom).clamp(
          minY,
          double.infinity,
        );

        newPosition = Offset(
          newPosition.dx.clamp(minX, maxX),
          newPosition.dy.clamp(minY, maxY),
        );

        totalDisplacement += (newPosition - node.logicalPosition).distance;
        positionNode(node, newPosition);
      }

      iteration++;
    }
  }

  @override
  bool shouldRelayout(covariant GraphForceDirectedLayoutStrategy oldStrategy) {
    return !baseEquals(oldStrategy) ||
        springLength != oldStrategy.springLength ||
        springConstant != oldStrategy.springConstant ||
        damping != oldStrategy.damping ||
        coulombConstant != oldStrategy.coulombConstant ||
        maxDisplacement != oldStrategy.maxDisplacement ||
        maxIterations != oldStrategy.maxIterations ||
        tolerance != oldStrategy.tolerance ||
        padding != oldStrategy.padding;
  }
}
