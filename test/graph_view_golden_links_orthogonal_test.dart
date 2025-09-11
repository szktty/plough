import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GraphView golden: orthogonal routing', (tester) async {
    final graph = Graph();
    final a = GraphNode(properties: {'label': 'A'});
    final b = GraphNode(properties: {'label': 'B'});
    graph.addNode(a);
    graph.addNode(b);
    graph.addLink(GraphLink(
      source: a,
      target: b,
      direction: GraphLinkDirection.outgoing,
    ));

    final layout = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(id: a.id, position: const Offset(40, 40)),
        GraphNodeLayoutPosition(id: b.id, position: const Offset(200, 120)),
      ],
      origin: GraphLayoutPositionOrigin.topLeft,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              child: SizedBox(
                width: 320,
                height: 200,
                child: GraphView(
                  graph: graph,
                  behavior: const GraphViewDefaultBehavior(
                    linkRouting: GraphLinkRouting.orthogonal,
                  ),
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
      matchesGoldenFile('goldens/graph_view_orthogonal_link.png'),
    );
  });
}

