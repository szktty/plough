import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GraphView golden: link selection highlight', (tester) async {
    final graph = Graph();
    final n1 = GraphNode(properties: {'label': 'S'});
    final n2 = GraphNode(properties: {'label': 'T'});
    graph.addNode(n1);
    graph.addNode(n2);
    final link = GraphLink(
      source: n1,
      target: n2,
      direction: GraphLinkDirection.outgoing,
    );
    graph.addLink(link);

    // select the link to highlight it
    graph.selectLink(link.id);

    final layout = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(id: n1.id, position: const Offset(50, 50)),
        GraphNodeLayoutPosition(id: n2.id, position: const Offset(170, 110)),
      ],
      origin: GraphLayoutPositionOrigin.topLeft,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              child: SizedBox(
                width: 280,
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
      matchesGoldenFile('goldens/graph_view_link_selected.png'),
    );
  });
}
