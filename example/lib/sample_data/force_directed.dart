import 'package:example/sample_data/base.dart';
import 'package:plough/plough.dart';

SampleData forceDirectedSample() {
  return SampleData(
    name: 'Force-directed layout',
    graph: _createGraph(),
    layoutStrategy: GraphForceDirectedLayoutStrategy(),
  );
}

Graph _createGraph() {
  final graph = Graph();

  // Create character nodes
  final alice = GraphNode(
    properties: {'label': 'Alice', 'description': 'Primary message sender'},
  );
  final bob = GraphNode(
    properties: {'label': 'Bob', 'description': 'Primary message receiver'},
  );
  final carol = GraphNode(
    properties: {
      'label': 'Carol',
      'description': 'Trusted third party / Potential MITM attacker',
    },
  );
  final dave = GraphNode(
    properties: {'label': 'Dave', 'description': 'Fourth party participant'},
  );
  final ellen = GraphNode(
    properties: {'label': 'Ellen', 'description': 'Fifth party participant'},
  );
  final frank = GraphNode(
    properties: {'label': 'Frank', 'description': 'Sixth party participant'},
  );
  final eve = GraphNode(
    properties: {
      'label': 'Eve',
      'description': 'Passive attacker / Eavesdropper',
    },
  );

  // Trusted third party scenario links
  final aliceToCarol = GraphLink(
    source: alice,
    target: carol,
    direction: GraphLinkDirection.outgoing,
    properties: {
      'label': 'Auth',
      'description': 'Certificate request / Key registration',
    },
  );

  final carolToBob = GraphLink(
    source: carol,
    target: bob,
    direction: GraphLinkDirection.outgoing,
    properties: {
      'label': 'Auth',
      'description': 'Certificate validation / Key distribution',
    },
  );

  // MITM scenario links
  final aliceToCarolMITM = GraphLink(
    source: alice,
    target: carol,
    direction: GraphLinkDirection.outgoing,
    properties: {
      'label': 'Intercept',
      'description': 'Intercepted message (Alice thinks sending to Bob)',
    },
  );

  final carolToBobMITM = GraphLink(
    source: carol,
    target: bob,
    direction: GraphLinkDirection.outgoing,
    properties: {
      'label': 'Forge',
      'description': 'Forged message (Bob thinks from Alice)',
    },
  );

  // Regular third party communications
  final carolToDave = GraphLink(
    source: carol,
    target: dave,
    direction: GraphLinkDirection.outgoing,
    properties: {'label': 'Link', 'description': 'Regular communication'},
  );

  final daveToEllen = GraphLink(
    source: dave,
    target: ellen,
    direction: GraphLinkDirection.outgoing,
    properties: {'label': 'Link', 'description': 'Regular communication'},
  );

  final ellenToFrank = GraphLink(
    source: ellen,
    target: frank,
    direction: GraphLinkDirection.outgoing,
    properties: {'label': 'Link', 'description': 'Regular communication'},
  );

  // Eve's eavesdropping links
  final eveToAlice = GraphLink(
    source: eve,
    target: alice,
    direction: GraphLinkDirection.outgoing,
    properties: {'label': 'Monitor', 'description': 'Eavesdropping channel'},
  );

  final eveToBob = GraphLink(
    source: eve,
    target: bob,
    direction: GraphLinkDirection.outgoing,
    properties: {'label': 'Monitor', 'description': 'Eavesdropping channel'},
  );

  // Add nodes
  graph
    ..addNode(alice)
    ..addNode(bob)
    ..addNode(carol)
    ..addNode(dave)
    ..addNode(ellen)
    ..addNode(frank)
    ..addNode(eve);

  // Add links
  graph
    ..addLink(aliceToCarol)
    ..addLink(carolToBob)
    ..addLink(aliceToCarolMITM)
    ..addLink(carolToBobMITM)
    ..addLink(carolToDave)
    ..addLink(daveToEllen)
    ..addLink(ellenToFrank)
    ..addLink(eveToAlice)
    ..addLink(eveToBob);

  return graph;
}
