import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Current behavior documentation: self-loop is not rendered (no connection points)
  testWidgets('GraphView golden: self-loop (current behavior: not rendered)', (
    tester,
  ) async {
    final graph = Graph();
    final a = GraphNode(properties: {'label': 'A'});
    graph.addNode(a);

    // Add a self-loop link. As of current implementation, this results in no
    // connection points and thus nothing is drawn for the link.
    graph.addLink(
      GraphLink(source: a, target: a, direction: GraphLinkDirection.outgoing),
    );

    final layout = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(id: a.id, position: const Offset(80, 80)),
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
                height: 200,
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
      matchesGoldenFile('goldens/graph_view_self_loop_current.png'),
    );
  });
}
