import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:plough/src/graph/entity.dart';
import 'package:plough/src/graph/link.dart';
import 'package:plough/src/graph/node.dart';

/// Configuration for viewport culling behavior.
class ViewportCullingConfig {
  const ViewportCullingConfig({
    this.enabled = true,
    this.nodeMargin = 50.0,
    this.linkMargin = 10.0,
    this.debugVisualization = false,
  });

  /// Whether viewport culling is enabled.
  final bool enabled;

  /// Additional margin around nodes for culling calculations.
  /// Nodes within this margin of the viewport will still be rendered.
  final double nodeMargin;

  /// Additional margin around links for culling calculations.
  final double linkMargin;

  /// Whether to show debug visualization of culling bounds.
  final bool debugVisualization;
}

/// Handles viewport-based culling of graph entities to optimize rendering.
class ViewportCuller {
  ViewportCuller({
    required this.config,
  });

  final ViewportCullingConfig config;

  /// Determines if a node should be rendered based on viewport bounds.
  bool shouldRenderNode(
    GraphNode node,
    Rect viewport, {
    Size? nodeSize,
  }) {
    if (!config.enabled) return true;

    final position = node.logicalPosition;
    final size = nodeSize ?? const Size(40, 40); // Default node size
    
    // Create node bounds with margin
    final nodeBounds = Rect.fromCenter(
      center: position,
      width: size.width + config.nodeMargin,
      height: size.height + config.nodeMargin,
    );

    // Check if node bounds intersect with viewport
    return viewport.overlaps(nodeBounds);
  }

  /// Determines if a link should be rendered based on viewport bounds.
  bool shouldRenderLink(
    GraphLink link,
    Rect viewport, {
    bool sourceVisible = true,
    bool targetVisible = true,
  }) {
    if (!config.enabled) return true;

    // If both endpoints are invisible, don't render
    if (!sourceVisible && !targetVisible) return false;

    // If at least one endpoint is visible, we might need to render
    if (sourceVisible || targetVisible) {
      // Create link bounds
      final sourcePos = link.source.logicalPosition;
      final targetPos = link.target.logicalPosition;
      
      final linkBounds = Rect.fromPoints(sourcePos, targetPos).inflate(
        config.linkMargin,
      );

      return viewport.overlaps(linkBounds);
    }

    return false;
  }

  /// Calculates the optimal viewport bounds for culling.
  /// 
  /// This can be used with transforms (zoom/pan) to determine
  /// what's actually visible on screen.
  Rect calculateCullingViewport(
    Size screenSize, {
    Matrix4? transform,
    double marginMultiplier = 1.5,
  }) {
    if (transform == null) {
      // No transform, viewport is the screen with margin
      return Rect.fromLTWH(
        -screenSize.width * (marginMultiplier - 1) / 2,
        -screenSize.height * (marginMultiplier - 1) / 2,
        screenSize.width * marginMultiplier,
        screenSize.height * marginMultiplier,
      );
    }

    // Calculate inverse transform to map screen coordinates to graph coordinates
    final inverseTransform = Matrix4.inverted(transform);
    
    // Transform screen corners to graph coordinates
    final corners = [
      Offset.zero,
      Offset(screenSize.width, 0),
      Offset(screenSize.width, screenSize.height),
      Offset(0, screenSize.height),
    ];

    final transformedCorners = corners.map((corner) {
      final transformed = inverseTransform.transform3(
        Vector3(corner.dx, corner.dy, 0),
      );
      return Offset(transformed.x, transformed.y);
    }).toList();

    // Find bounds of transformed corners
    var minX = transformedCorners.first.dx;
    var maxX = transformedCorners.first.dx;
    var minY = transformedCorners.first.dy;
    var maxY = transformedCorners.first.dy;

    for (final corner in transformedCorners.skip(1)) {
      minX = math.min(minX, corner.dx);
      maxX = math.max(maxX, corner.dx);
      minY = math.min(minY, corner.dy);
      maxY = math.max(maxY, corner.dy);
    }

    // Add margin
    final width = maxX - minX;
    final height = maxY - minY;
    final marginX = width * (marginMultiplier - 1) / 2;
    final marginY = height * (marginMultiplier - 1) / 2;

    return Rect.fromLTRB(
      minX - marginX,
      minY - marginY,
      maxX + marginX,
      maxY + marginY,
    );
  }

  /// Filters a list of nodes to only include those within the viewport.
  List<GraphNode> cullNodes(
    List<GraphNode> nodes,
    Rect viewport, {
    Map<String, Size>? nodeSizes,
  }) {
    if (!config.enabled) return nodes;

    return nodes.where((node) {
      final nodeSize = nodeSizes?[node.id.value];
      return shouldRenderNode(node, viewport, nodeSize: nodeSize);
    }).toList();
  }

  /// Filters a list of links to only include those within the viewport.
  List<GraphLink> cullLinks(
    List<GraphLink> links,
    Rect viewport,
    Set<String> visibleNodeIds,
  ) {
    if (!config.enabled) return links;

    return links.where((link) {
      final sourceVisible = visibleNodeIds.contains(link.source.id.value);
      final targetVisible = visibleNodeIds.contains(link.target.id.value);
      
      return shouldRenderLink(
        link,
        viewport,
        sourceVisible: sourceVisible,
        targetVisible: targetVisible,
      );
    }).toList();
  }

  /// Returns culling statistics for debugging.
  CullingStats calculateStats(
    List<GraphNode> allNodes,
    List<GraphLink> allLinks,
    List<GraphNode> visibleNodes,
    List<GraphLink> visibleLinks,
  ) {
    return CullingStats(
      totalNodes: allNodes.length,
      visibleNodes: visibleNodes.length,
      culledNodes: allNodes.length - visibleNodes.length,
      totalLinks: allLinks.length,
      visibleLinks: visibleLinks.length,
      culledLinks: allLinks.length - visibleLinks.length,
      nodeReduction: allNodes.isNotEmpty 
          ? (allNodes.length - visibleNodes.length) / allNodes.length
          : 0.0,
      linkReduction: allLinks.isNotEmpty
          ? (allLinks.length - visibleLinks.length) / allLinks.length
          : 0.0,
    );
  }
}

/// Statistics about culling performance.
class CullingStats {
  const CullingStats({
    required this.totalNodes,
    required this.visibleNodes,
    required this.culledNodes,
    required this.totalLinks,
    required this.visibleLinks,
    required this.culledLinks,
    required this.nodeReduction,
    required this.linkReduction,
  });

  final int totalNodes;
  final int visibleNodes;
  final int culledNodes;
  final int totalLinks;
  final int visibleLinks;
  final int culledLinks;
  final double nodeReduction;
  final double linkReduction;

  @override
  String toString() {
    return 'CullingStats('
        'nodes: $visibleNodes/$totalNodes '
        '(${(nodeReduction * 100).toStringAsFixed(1)}% culled), '
        'links: $visibleLinks/$totalLinks '
        '(${(linkReduction * 100).toStringAsFixed(1)}% culled) '
        ')';
  }
}

/// 3D Vector for transform calculations
class Vector3 {
  Vector3(this.x, this.y, this.z);
  
  final double x;
  final double y;
  final double z;
}