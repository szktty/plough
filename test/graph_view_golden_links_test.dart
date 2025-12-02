import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GraphView golden: two nodes with a link', (tester) async {
    final graph = Graph();
    final n1 = GraphNode(properties: {'label': 'A'});
    final n2 = GraphNode(properties: {'label': 'B'});
    graph.addNode(n1);
    graph.addNode(n2);
    graph.addLink(GraphLink(
        source: n1, target: n2, direction: GraphLinkDirection.outgoing));

    final layout = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(id: n1.id, position: const Offset(40, 60)),
        GraphNodeLayoutPosition(id: n2.id, position: const Offset(160, 120)),
      ],
      origin: GraphLayoutPositionOrigin.topLeft,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              child: SizedBox(
                width: 240,
                height: 180,
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
      matchesGoldenFile('goldens/graph_view_two_nodes_link.png'),
    );
  });
}
