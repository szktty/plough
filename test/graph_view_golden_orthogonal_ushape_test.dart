import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GraphView golden: orthogonal U-shape (two links via bottom)',
      (tester) async {
    final graph = Graph();

    final a = GraphNode(properties: {'label': 'A'});
    final b = GraphNode(properties: {'label': 'B'});
    final c = GraphNode(properties: {'label': 'C'});

    graph
      ..addNode(a)
      ..addNode(b)
      ..addNode(c);

    // A -> C -> B to form a "U" shape with orthogonal routing
    final l1 =
        GraphLink(source: a, target: c, direction: GraphLinkDirection.outgoing);
    final l2 =
        GraphLink(source: c, target: b, direction: GraphLinkDirection.outgoing);
    graph
      ..addLink(l1)
      ..addLink(l2);

    final layout = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(
            id: a.id, position: const Offset(60, 50)), // left-top
        GraphNodeLayoutPosition(
            id: b.id, position: const Offset(360, 50)), // right-top
        GraphNodeLayoutPosition(
            id: c.id, position: const Offset(210, 170)), // bottom-center
      ],
      origin: GraphLayoutPositionOrigin.topLeft,
    );

    final key = UniqueKey();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              key: key,
              child: SizedBox(
                width: 440,
                height: 240,
                child: GraphView(
                  graph: graph,
                  behavior: const GraphViewDefaultBehavior(
                      linkRouting: GraphLinkRouting.orthogonal),
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
      find.byKey(key),
      matchesGoldenFile('goldens/graph_view_orthogonal_ushape.png'),
    );
  });
}
