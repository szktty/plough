import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GraphView golden: crossing links (straight routing)', (
    tester,
  ) async {
    final graph = Graph();
    final n1 = GraphNode(properties: {'label': 'N1'});
    final n2 = GraphNode(properties: {'label': 'N2'});
    final n3 = GraphNode(properties: {'label': 'N3'});
    final n4 = GraphNode(properties: {'label': 'N4'});
    graph
      ..addNode(n1)
      ..addNode(n2)
      ..addNode(n3)
      ..addNode(n4);

    graph.addLink(
      GraphLink(source: n1, target: n3, direction: GraphLinkDirection.outgoing),
    );
    graph.addLink(
      GraphLink(source: n2, target: n4, direction: GraphLinkDirection.outgoing),
    );

    final layout = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(id: n1.id, position: const Offset(40, 40)),
        GraphNodeLayoutPosition(id: n2.id, position: const Offset(260, 40)),
        GraphNodeLayoutPosition(id: n3.id, position: const Offset(260, 160)),
        GraphNodeLayoutPosition(id: n4.id, position: const Offset(40, 160)),
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
      matchesGoldenFile('goldens/graph_view_crossing_links.png'),
    );
  });
}
