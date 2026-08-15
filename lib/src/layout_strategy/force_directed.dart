import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/graph/node.dart';
import 'package:plough/src/layout_strategy/quadtree.dart';

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
    double? barnesHutTheta,
    int? stepsPerFrame,
    this.centerNodeId,
    super.seed,
    super.padding,
    super.nodePositions,
  })  : springLength = springLength ?? 200.0,
        springConstant = springConstant ?? 0.1,
        damping = damping ?? 0.8,
        coulombConstant = coulombConstant ?? 2000.0,
        maxDisplacement = maxDisplacement ?? 50.0,
        maxIterations = maxIterations ?? 500,
        tolerance = tolerance ?? 0.5,
        barnesHutTheta = barnesHutTheta ?? 0.5,
        stepsPerFrame = stepsPerFrame ?? 3;

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

  /// Barnes-Hut approximation threshold (θ).
  ///
  /// A value of 0 disables the approximation (exact O(n²) computation).
  /// Higher values trade accuracy for speed. Typical range: 0.3–0.8.
  /// Defaults to 0.5.
  final double barnesHutTheta;

  /// Number of simulation iterations to run per rendered frame.
  ///
  /// Higher values make the layout converge faster but reduce animation
  /// smoothness. Lower values produce a slower, more visible settling effect.
  /// Defaults to 3.
  final int stepsPerFrame;

  /// ID of the node to fix at the center of the layout area.
  final GraphId? centerNodeId;

  // --- Incremental layout state ---
  List<GraphNode>? _nodeList;
  double _minX = 0;
  double _maxX = 0;
  double _minY = 0;
  double _maxY = 0;
  int _iteration = 0;
  double _totalDisplacement = double.infinity;

  @override
  bool get supportsIncrementalLayout => true;

  @override
  void initIncrementalLayout(Graph graph, Size size) {
    super.performLayout(graph, size);

    final centerNode =
        centerNodeId != null ? graph.getNode(centerNodeId!) : null;
    if (centerNode != null) {
      positionNode(centerNode, size.center(Offset.zero));
    }

    final width = size.width - padding.left - padding.right;
    final height = size.height - padding.top - padding.bottom;
    for (final node in graph.nodes) {
      final nodeImpl = node as GraphNodeImpl;
      if (nodeImpl.isArranged && node.logicalPosition != Offset.zero) {
        continue;
      }
      // A caller-supplied position is a deliberate starting point; randomising
      // over it would throw away the very placement that was just requested.
      if (getNodePosition(node) != null) {
        continue;
      }
      final dx = random.nextDouble() * width + padding.left;
      final dy = random.nextDouble() * height + padding.top;
      positionNode(node, Offset(dx, dy));
    }

    _nodeList = graph.nodes.toList();
    _minX = padding.left;
    _maxX = (size.width - padding.right).clamp(_minX, double.infinity);
    _minY = padding.top;
    _maxY = (size.height - padding.bottom).clamp(_minY, double.infinity);
    _iteration = 0;
    _totalDisplacement = double.infinity;
  }

  @override
  bool stepIncrementalLayout(Graph graph) {
    final nodeList = _nodeList;
    if (nodeList == null) return false;

    // Run stepsPerFrame iterations in one frame to balance speed vs smoothness.
    for (var step = 0; step < stepsPerFrame; step++) {
      if (_iteration >= maxIterations || _totalDisplacement <= tolerance) {
        return false;
      }

      _totalDisplacement = 0.0;
      final forces = {for (final node in nodeList) node: Offset.zero};

      final bodies = nodeList
          .map(
            (n) => QuadtreeBody(
              id: n.id,
              x: n.logicalPosition.dx,
              y: n.logicalPosition.dy,
              mass: n.weight,
            ),
          )
          .toList();

      var treeLeft = double.infinity;
      var treeTop = double.infinity;
      var treeRight = double.negativeInfinity;
      var treeBottom = double.negativeInfinity;
      for (final b in bodies) {
        if (b.x < treeLeft) treeLeft = b.x;
        if (b.y < treeTop) treeTop = b.y;
        if (b.x > treeRight) treeRight = b.x;
        if (b.y > treeBottom) treeBottom = b.y;
      }
      const margin = 1.0;
      final treeBounds = Rect.fromLTRB(
        treeLeft - margin,
        treeTop - margin,
        treeRight + margin,
        treeBottom + margin,
      );
      final tree = QuadtreeNode.build(bodies, treeBounds);

      for (var i = 0; i < nodeList.length; i++) {
        final node = nodeList[i];
        final body = bodies[i];
        final repulsion =
            tree.computeRepulsion(body, coulombConstant, barnesHutTheta);
        forces[node] = forces[node]! + repulsion;
      }

      for (final link in graph.links) {
        final source = link.source;
        final target = link.target;
        final delta = target.logicalPosition - source.logicalPosition;
        final distance = delta.distance;
        if (distance == 0) continue;
        final force = springConstant * (distance - springLength);
        final directionScale = force / distance;
        forces[source] = forces[source]! +
            Offset(delta.dx * directionScale, delta.dy * directionScale);
        forces[target] = forces[target]! -
            Offset(delta.dx * directionScale, delta.dy * directionScale);
      }

      for (final node in nodeList) {
        var force = forces[node]! * damping;
        final displacement = force.distance;
        if (displacement > maxDisplacement) {
          force = Offset(
            force.dx * maxDisplacement / displacement,
            force.dy * maxDisplacement / displacement,
          );
        }
        var newPosition = node.logicalPosition + force;
        newPosition = Offset(
          newPosition.dx.clamp(_minX, _maxX),
          newPosition.dy.clamp(_minY, _maxY),
        );
        _totalDisplacement += (newPosition - node.logicalPosition).distance;
        positionNode(node, newPosition);
      }

      _iteration++;
    }

    return _iteration < maxIterations && _totalDisplacement > tolerance;
  }

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
      // A caller-supplied position is a deliberate starting point; randomising
      // over it would throw away the very placement that was just requested.
      if (getNodePosition(node) != null) {
        continue;
      }
      final dx = random.nextDouble() * width + padding.left;
      final dy = random.nextDouble() * height + padding.top;
      positionNode(node, Offset(dx, dy));
    }

    // Iterative layout calculation
    var iteration = 0;
    var totalDisplacement = double.infinity;

    final nodeList = graph.nodes.toList();

    // Clamp bounds (computed once outside the loop).
    final minX = padding.left;
    final maxX = (size.width - padding.right).clamp(minX, double.infinity);
    final minY = padding.top;
    final maxY = (size.height - padding.bottom).clamp(minY, double.infinity);

    while (iteration < maxIterations && totalDisplacement > tolerance) {
      totalDisplacement = 0.0;
      final forces = {for (final node in nodeList) node: Offset.zero};

      // Calculate Coulomb force (repulsion) using Barnes-Hut quadtree.
      // Build quadtree from current node positions.
      final bodies = nodeList
          .map(
            (n) => QuadtreeBody(
              id: n.id,
              x: n.logicalPosition.dx,
              y: n.logicalPosition.dy,
              mass: n.weight,
            ),
          )
          .toList();

      // Compute bounding box for the quadtree.
      var treeLeft = double.infinity;
      var treeTop = double.infinity;
      var treeRight = double.negativeInfinity;
      var treeBottom = double.negativeInfinity;
      for (final b in bodies) {
        if (b.x < treeLeft) treeLeft = b.x;
        if (b.y < treeTop) treeTop = b.y;
        if (b.x > treeRight) treeRight = b.x;
        if (b.y > treeBottom) treeBottom = b.y;
      }
      // Add a small margin to avoid degenerate zero-area bounds.
      const margin = 1.0;
      final treeBounds = Rect.fromLTRB(
        treeLeft - margin,
        treeTop - margin,
        treeRight + margin,
        treeBottom + margin,
      );

      final tree = QuadtreeNode.build(bodies, treeBounds);

      for (var i = 0; i < nodeList.length; i++) {
        final node = nodeList[i];
        final body = bodies[i];
        final repulsion =
            tree.computeRepulsion(body, coulombConstant, barnesHutTheta);
        forces[node] = forces[node]! + repulsion;
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
      for (final node in nodeList) {
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
        barnesHutTheta != oldStrategy.barnesHutTheta ||
        stepsPerFrame != oldStrategy.stepsPerFrame ||
        padding != oldStrategy.padding;
  }
}
