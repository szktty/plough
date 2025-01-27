import 'package:example/sample_data/base.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plough/plough.dart';

SampleData treeSample() {
  return SampleData(
    name: 'Tree layout',
    graph: _createGraph(),
    layoutStrategy: GraphTreeLayoutStrategy(
      direction: GraphTreeLayoutDirection.topToBottom,
    ),
    //layoutStrategy: GraphForceDirectedLayoutStrategy(),
    nodeRendererBuilder: _createNodeRenderer,
    linkRouting: GraphLinkRouting.orthogonal,
  );
}

Graph _createGraph() {
  final graph = Graph();

  // Create root node
  final rootNode = GraphNode(
    properties: {'label': 'project-root/', 'description': 'project-root/'},
  );

  // Create directory nodes
  final srcNode =
      GraphNode(properties: {'label': 'src/', 'description': 'src/'});
  final modelsNode =
      GraphNode(properties: {'label': 'models/', 'description': 'models/'});
  final utilsNode =
      GraphNode(properties: {'label': 'utils/', 'description': 'utils/'});
  final testsNode =
      GraphNode(properties: {'label': 'tests/', 'description': 'tests/'});
  final testModelsNode =
      GraphNode(properties: {'label': 'models/', 'description': 'models/'});
  final testUtilsNode =
      GraphNode(properties: {'label': 'utils/', 'description': 'utils/'});
  final docsNode =
      GraphNode(properties: {'label': 'docs/', 'description': 'docs/'});

  // Create file nodes
  final mainFile =
      GraphNode(properties: {'label': 'main.dart', 'description': 'main.dart'});
  final userFile =
      GraphNode(properties: {'label': 'user.dart', 'description': 'user.dart'});
  final settingsFile = GraphNode(
    properties: {'label': 'settings.dart', 'description': 'settings.dart'},
  );
  final helperFile = GraphNode(
    properties: {'label': 'helper.dart', 'description': 'helper.dart'},
  );
  final userTestFile = GraphNode(
    properties: {'label': 'user_test.dart', 'description': 'user_test.dart'},
  );
  final helperTestFile = GraphNode(
    properties: {
      'label': 'helper_test.dart',
      'description': 'helper_test.dart',
    },
  );
  final apiDoc =
      GraphNode(properties: {'label': 'API.md', 'description': 'API.md'});
  final setupDoc =
      GraphNode(properties: {'label': 'SETUP.md', 'description': 'SETUP.md'});
  final readmeFile =
      GraphNode(properties: {'label': 'README.md', 'description': 'README.md'});
  final licenseFile =
      GraphNode(properties: {'label': 'LICENSE', 'description': 'LICENSE'});
  final pubspecFile = GraphNode(
    properties: {'label': 'pubspec.yaml', 'description': 'pubspec.yaml'},
  );

  // Add all nodes to the graph
  final nodes = [
    rootNode,
    srcNode,
    modelsNode,
    utilsNode,
    testsNode,
    testModelsNode,
    testUtilsNode,
    docsNode,
    mainFile,
    userFile,
    settingsFile,
    helperFile,
    userTestFile,
    helperTestFile,
    apiDoc,
    setupDoc,
    readmeFile,
    licenseFile,
    pubspecFile,
  ];

  for (final node in nodes) {
    graph.addNode(node);
  }

  // Create directory structure links
  final directoryLinks = [
    GraphLink(
      source: rootNode,
      target: srcNode,
      direction: GraphLinkDirection.outgoing,
    ),
    GraphLink(
      source: srcNode,
      target: modelsNode,
      direction: GraphLinkDirection.outgoing,
    ),
    GraphLink(
      source: srcNode,
      target: utilsNode,
      direction: GraphLinkDirection.outgoing,
    ),
    GraphLink(
      source: rootNode,
      target: testsNode,
      direction: GraphLinkDirection.outgoing,
    ),
    GraphLink(
      source: testsNode,
      target: testModelsNode,
      direction: GraphLinkDirection.outgoing,
    ),
    GraphLink(
      source: testsNode,
      target: testUtilsNode,
      direction: GraphLinkDirection.outgoing,
    ),
    GraphLink(
      source: rootNode,
      target: docsNode,
      direction: GraphLinkDirection.outgoing,
    ),
  ];

  // Create file links
  final fileLinks = [
    GraphLink(
      source: srcNode,
      target: mainFile,
      direction: GraphLinkDirection.outgoing,
    ),
    GraphLink(
      source: modelsNode,
      target: userFile,
      direction: GraphLinkDirection.outgoing,
    ),
    GraphLink(
      source: modelsNode,
      target: settingsFile,
      direction: GraphLinkDirection.outgoing,
    ),
    GraphLink(
      source: utilsNode,
      target: helperFile,
      direction: GraphLinkDirection.outgoing,
    ),
    GraphLink(
      source: testModelsNode,
      target: userTestFile,
      direction: GraphLinkDirection.outgoing,
    ),
    GraphLink(
      source: testUtilsNode,
      target: helperTestFile,
      direction: GraphLinkDirection.outgoing,
    ),
    GraphLink(
      source: docsNode,
      target: apiDoc,
      direction: GraphLinkDirection.outgoing,
    ),
    GraphLink(
      source: docsNode,
      target: setupDoc,
      direction: GraphLinkDirection.outgoing,
    ),
    GraphLink(
      source: rootNode,
      target: readmeFile,
      direction: GraphLinkDirection.outgoing,
    ),
    GraphLink(
      source: rootNode,
      target: licenseFile,
      direction: GraphLinkDirection.outgoing,
    ),
    GraphLink(
      source: rootNode,
      target: pubspecFile,
      direction: GraphLinkDirection.outgoing,
    ),
  ];

  // Add all links to the graph
  for (final link in [...directoryLinks, ...fileLinks]) {
    //for (final link in directoryLinks) {
    graph.addLink(link);
  }

  return graph;
}

GraphDefaultNodeRenderer _createNodeRenderer(
  BuildContext context,
  GraphNode node,
  Widget? child,
) {
  final label = node['label']! as String;
  return GraphDefaultNodeRenderer(
    node: node,
    style: const GraphDefaultNodeRendererStyle(
      shape: GraphDefaultNodeRendererShape.rectangle,
    ),
    child: Center(
      child: Text(
        label,
        style: GoogleFonts.robotoMono(
          fontSize: 14,
        ),
      ),
    ),
  );
}
