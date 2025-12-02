import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GraphView golden: node selection highlight', (tester) async {
    final graph = Graph();
    final n1 = GraphNode(properties: {'label': 'Sel'});
    final n2 = GraphNode(properties: {'label': 'N'});
    graph.addNode(n1);
    graph.addNode(n2);

    // Select first node so default behavior highlights it
    graph.selectNode(n1.id);

    final layout = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(id: n1.id, position: const Offset(60, 60)),
        GraphNodeLayoutPosition(id: n2.id, position: const Offset(140, 60)),
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
                height: 140,
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
      matchesGoldenFile('goldens/graph_view_selection.png'),
    );
  });
}
