import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

// A5: the GraphView subtree is keyed on the graph id (not hashCode). Swapping
// the graph passed to GraphView must rebuild cleanly and render the new graph.

GraphManualLayoutStrategy _layoutFor(List<GraphNode> nodes) =>
    GraphManualLayoutStrategy(
      nodePositions: [
        for (var i = 0; i < nodes.length; i++)
          GraphNodeLayoutPosition(
            id: nodes[i].id,
            position: Offset(60.0 + i * 120, 60.0 + i * 80),
          ),
      ],
      origin: GraphLayoutPositionOrigin.topLeft,
    );

Widget _host(Graph graph, GraphLayoutStrategy layout) => MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 400,
          child: GraphView(
            graph: graph,
            behavior: const GraphViewDefaultBehavior(),
            layoutStrategy: layout,
            animationEnabled: false,
          ),
        ),
      ),
    );

void main() {
  testWidgets('swapping the graph rebuilds and renders the new graph', (
    tester,
  ) async {
    final graph1 = Graph();
    final a = GraphNode(properties: {'label': 'A'});
    graph1.addNode(a);

    await tester.pumpWidget(_host(graph1, _layoutFor([a])));
    await tester.pumpAndSettle();

    expect(find.text('A'), findsOneWidget);

    // Swap to a different graph instance with different content.
    final graph2 = Graph();
    final x = GraphNode(properties: {'label': 'X'});
    graph2.addNode(x);

    await tester.pumpWidget(_host(graph2, _layoutFor([x])));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('A'), findsNothing);
    expect(find.text('X'), findsOneWidget);
  });
}
