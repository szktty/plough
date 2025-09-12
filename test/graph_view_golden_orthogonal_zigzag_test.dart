import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GraphView golden: orthogonal zigzag path', (tester) async {
    final graph = Graph();

    final a = GraphNode(properties: {'label': 'A'});
    final b = GraphNode(properties: {'label': 'B'});
    final c = GraphNode(properties: {'label': 'C'});
    final d = GraphNode(properties: {'label': 'D'});

    graph..addNode(a)..addNode(b)..addNode(c)..addNode(d);

    graph.addLink(GraphLink(source: a, target: b, direction: GraphLinkDirection.outgoing));
    graph.addLink(GraphLink(source: b, target: c, direction: GraphLinkDirection.outgoing));
    graph.addLink(GraphLink(source: c, target: d, direction: GraphLinkDirection.outgoing));

    final layout = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(id: a.id, position: const Offset(40, 40)),
        GraphNodeLayoutPosition(id: b.id, position: const Offset(160, 120)),
        GraphNodeLayoutPosition(id: c.id, position: const Offset(280, 40)),
        GraphNodeLayoutPosition(id: d.id, position: const Offset(400, 120)),
      ],
      origin: GraphLayoutPositionOrigin.topLeft,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              child: SizedBox(
                width: 460,
                height: 180,
                child: GraphView(
                  graph: graph,
                  behavior: const GraphViewDefaultBehavior(linkRouting: GraphLinkRouting.orthogonal),
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
      matchesGoldenFile('goldens/graph_view_orthogonal_zigzag.png'),
    );
  });
}

