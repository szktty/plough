import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/graph/node.dart'
    show GraphNodeImpl; // internal for position update helper

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GraphView golden: after programmatic drag (position updated)', (
    tester,
  ) async {
    final graph = Graph();
    final n = GraphNode(properties: {'label': 'Drag'});
    graph.addNode(n);

    final layout = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(id: n.id, position: const Offset(60, 60)),
      ],
      origin: GraphLayoutPositionOrigin.topLeft,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              child: SizedBox(
                width: 220,
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

    // emulate drag effect by updating logical position directly (no animation)
    final impl = graph.getNode(n.id)! as GraphNodeImpl;
    impl.logicalPosition = const Offset(140, 80);

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(GraphView),
      matchesGoldenFile('goldens/graph_view_after_drag.png'),
    );
  });
}
