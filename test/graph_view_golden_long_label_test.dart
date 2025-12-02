import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GraphView golden: long labels wrap and render stably', (tester) async {
    final graph = Graph();
    final n1 = GraphNode(properties: {
      'label': 'This is a very very long label for node A that should wrap over multiple lines to test text layout.'
    });
    final n2 = GraphNode(properties: {
      'label': 'Another extremely long label for node B to verify consistent wrapping and ellipsis if any.'
    });
    graph.addNode(n1);
    graph.addNode(n2);

    final layout = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(id: n1.id, position: const Offset(30, 40)),
        GraphNodeLayoutPosition(id: n2.id, position: const Offset(30, 120)),
      ],
      origin: GraphLayoutPositionOrigin.topLeft,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              child: SizedBox(
                width: 360,
                height: 240,
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
      matchesGoldenFile('goldens/graph_view_long_labels.png'),
    );
  });
}

