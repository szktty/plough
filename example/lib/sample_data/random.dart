import 'package:example/sample_data/base.dart';
import 'package:plough/plough.dart';

SampleData randomSample() {
  return SampleData(
    name: 'Random layout',
    graph: _createGraph(),
    layoutStrategy: GraphRandomLayoutStrategy(),
  );
}

Graph _createGraph() {
  final graph = Graph();

  // Create 7 nodes
  final node1 = GraphNode(properties: {'label': '1', 'description': 'Node 1'});
  final node2 = GraphNode(properties: {'label': '2', 'description': 'Node 2'});
  final node3 = GraphNode(properties: {'label': '3', 'description': 'Node 3'});
  final node4 = GraphNode(properties: {'label': '4', 'description': 'Node 4'});
  final node5 = GraphNode(properties: {'label': '5', 'description': 'Node 5'});
  final node6 = GraphNode(properties: {'label': '6', 'description': 'Node 6'});
  final node7 = GraphNode(properties: {'label': '7', 'description': 'Node 7'});

  // Create links between nodes
  final links = [
    GraphLink(
      source: node1,
      target: node2,
      direction: GraphLinkDirection.outgoing,
    ),
    GraphLink(
      source: node2,
      target: node3,
      direction: GraphLinkDirection.outgoing,
    ),
    GraphLink(
      source: node3,
      target: node4,
      direction: GraphLinkDirection.outgoing,
    ),
    GraphLink(
      source: node4,
      target: node5,
      direction: GraphLinkDirection.bidirectional,
    ),
    GraphLink(
      source: node5,
      target: node6,
      direction: GraphLinkDirection.incoming,
    ),
    GraphLink(
      source: node6,
      target: node7,
      direction: GraphLinkDirection.outgoing,
    ),
    GraphLink(
      source: node1,
      target: node7,
      direction: GraphLinkDirection.bidirectional,
    ),
    GraphLink(
      source: node2,
      target: node5,
      direction: GraphLinkDirection.outgoing,
    ),
    GraphLink(
      source: node3,
      target: node6,
      direction: GraphLinkDirection.incoming,
    ),
  ];

  // Add all nodes to the graph
  graph
    ..addNode(node1)
    ..addNode(node2)
    ..addNode(node3)
    ..addNode(node4)
    ..addNode(node5)
    ..addNode(node6)
    ..addNode(node7);

  // Add all links to the graph
  for (final link in links) {
    graph.addLink(link);
  }

  return graph;
}
