import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GraphView golden: undirected (none) link', (tester) async {
    final graph = Graph();
    final n1 = GraphNode(properties: {'label': 'X'});
    final n2 = GraphNode(properties: {'label': 'Y'});
    graph.addNode(n1);
    graph.addNode(n2);
    graph.addLink(GraphLink(
      source: n1,
      target: n2,
      direction: GraphLinkDirection.none,
    ));

    final layout = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(id: n1.id, position: const Offset(40, 80)),
        GraphNodeLayoutPosition(id: n2.id, position: const Offset(180, 80)),
      ],
      origin: GraphLayoutPositionOrigin.topLeft,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              child: SizedBox(
                width: 300,
                height: 160,
                child: GraphView(
                  graph: graph,
                  behavior: const GraphViewDefaultBehavior(),
                  layoutStrategy: layout,
                  animationEnabled: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(GraphView),
      matchesGoldenFile('goldens/graph_view_none_link.png'),
    );
  });
}
