import 'dart:math';

import 'package:example/sample_data/base.dart';
import 'package:flutter/material.dart';
import 'package:plough/plough.dart';

/// Large graph samples for performance testing.
/// These samples generate graphs with many nodes and links to stress-test
/// rendering, layout, and interaction performance.

SampleData largeGraphSparse() {
  return SampleData(
    name: 'Large graph (200 nodes, sparse)',
    graph: _createSparseGraph(nodeCount: 200, avgDegree: 3),
    layoutStrategy: GraphForceDirectedLayoutStrategy(
      maxIterations: 300,
    ),
    nodeRendererBuilder: _compactNodeRenderer,
  );
}

SampleData largeGraphDense() {
  return SampleData(
    name: 'Large graph (200 nodes, dense)',
    graph: _createRandomGraph(nodeCount: 200, linkCount: 600),
    layoutStrategy: GraphForceDirectedLayoutStrategy(
      maxIterations: 300,
    ),
    nodeRendererBuilder: _compactNodeRenderer,
  );
}

SampleData largeGraphHubs() {
  return SampleData(
    name: 'Large graph (300 nodes, hub-and-spoke)',
    graph: _createHubGraph(hubCount: 6, spokeCount: 44),
    layoutStrategy: GraphForceDirectedLayoutStrategy(
      maxIterations: 400,
    ),
    nodeRendererBuilder: _compactNodeRenderer,
  );
}

SampleData largeGraphScaleTest() {
  return SampleData(
    name: 'Large graph (500 nodes, scale test)',
    graph: _createRandomGraph(nodeCount: 500, linkCount: 1000),
    layoutStrategy: GraphForceDirectedLayoutStrategy(
      maxIterations: 200,
    ),
    nodeRendererBuilder: _dotNodeRenderer,
  );
}

// ---------------------------------------------------------------------------
// Node renderers
// ---------------------------------------------------------------------------

GraphDefaultNodeRenderer _compactNodeRenderer(
  BuildContext context,
  GraphNode node,
  Widget? child,
) {
  final label = node['label'] as String? ?? '';
  final isHub = node['hub'] == true;

  return GraphDefaultNodeRenderer(
    node: node,
    child: Container(
      width: isHub ? 48 : 32,
      height: isHub ? 48 : 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isHub ? Colors.indigo : Colors.blueGrey.shade200,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: isHub ? 10 : 8,
            color: Colors.white,
            fontWeight: isHub ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    ),
  );
}

GraphDefaultNodeRenderer _dotNodeRenderer(
  BuildContext context,
  GraphNode node,
  Widget? child,
) {
  return GraphDefaultNodeRenderer(
    node: node,
    child: Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blueGrey,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Graph generators
// ---------------------------------------------------------------------------

/// Sparse random graph: each node connects to ~avgDegree neighbours.
Graph _createSparseGraph({required int nodeCount, required int avgDegree}) {
  final random = Random(42);
  final graph = Graph();
  final nodes = <GraphNode>[];

  for (var i = 0; i < nodeCount; i++) {
    final node = GraphNode(properties: {'label': '$i'});
    nodes.add(node);
    graph.addNode(node);
  }

  // Ensure connectivity: chain all nodes first
  for (var i = 0; i < nodeCount - 1; i++) {
    graph.addLink(GraphLink(
      source: nodes[i],
      target: nodes[i + 1],
      direction: GraphLinkDirection.outgoing,
    ));
  }

  // Add random extra edges up to avgDegree
  final extraEdges = (nodeCount * avgDegree / 2).round() - (nodeCount - 1);
  for (var i = 0; i < extraEdges; i++) {
    final src = random.nextInt(nodeCount);
    final dst = random.nextInt(nodeCount);
    if (src != dst) {
      graph.addLink(GraphLink(
        source: nodes[src],
        target: nodes[dst],
        direction: GraphLinkDirection.outgoing,
      ));
    }
  }

  return graph;
}

/// Fully random graph with a fixed number of links.
Graph _createRandomGraph({required int nodeCount, required int linkCount}) {
  final random = Random(42);
  final graph = Graph();
  final nodes = <GraphNode>[];

  for (var i = 0; i < nodeCount; i++) {
    final node = GraphNode(properties: {'label': '$i'});
    nodes.add(node);
    graph.addNode(node);
  }

  // Spanning tree to ensure connectivity
  final shuffled = List<int>.generate(nodeCount, (i) => i)..shuffle(random);
  for (var i = 0; i < nodeCount - 1; i++) {
    graph.addLink(GraphLink(
      source: nodes[shuffled[i]],
      target: nodes[shuffled[i + 1]],
      direction: GraphLinkDirection.outgoing,
    ));
  }

  // Remaining random links
  final remaining = linkCount - (nodeCount - 1);
  for (var i = 0; i < remaining; i++) {
    final src = random.nextInt(nodeCount);
    final dst = random.nextInt(nodeCount);
    if (src != dst) {
      graph.addLink(GraphLink(
        source: nodes[src],
        target: nodes[dst],
        direction: GraphLinkDirection.outgoing,
      ));
    }
  }

  return graph;
}

/// Hub-and-spoke graph: hubCount central hubs, each connected to spokeCount
/// leaf nodes, with inter-hub connections.
Graph _createHubGraph({required int hubCount, required int spokeCount}) {
  final graph = Graph();
  final hubs = <GraphNode>[];

  // Create hubs
  for (var h = 0; h < hubCount; h++) {
    final hub = GraphNode(properties: {'label': 'H$h', 'hub': true});
    hubs.add(hub);
    graph.addNode(hub);
  }

  // Connect hubs in a ring
  for (var h = 0; h < hubCount; h++) {
    graph.addLink(GraphLink(
      source: hubs[h],
      target: hubs[(h + 1) % hubCount],
      direction: GraphLinkDirection.bidirectional,
    ));
  }

  // Add cross-hub connection
  if (hubCount > 2) {
    graph.addLink(GraphLink(
      source: hubs[0],
      target: hubs[hubCount ~/ 2],
      direction: GraphLinkDirection.outgoing,
    ));
  }

  // Create spokes for each hub
  var nodeIndex = 0;
  for (var h = 0; h < hubCount; h++) {
    for (var s = 0; s < spokeCount; s++) {
      final spoke = GraphNode(properties: {'label': '$nodeIndex'});
      nodeIndex++;
      graph.addNode(spoke);
      graph.addLink(GraphLink(
        source: hubs[h],
        target: spoke,
        direction: GraphLinkDirection.outgoing,
      ));
    }
  }

  return graph;
}
