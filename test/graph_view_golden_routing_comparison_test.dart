import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GraphView golden: routing comparison (straight vs orthogonal)',
      (tester) async {
    final graph1 = Graph();
    final graph2 = Graph();

    GraphNode mkNode(String label) => GraphNode(properties: {'label': label});

    final a1 = mkNode('A');
    final b1 = mkNode('B');
    graph1
      ..addNode(a1)
      ..addNode(b1)
      ..addLink(GraphLink(
          source: a1, target: b1, direction: GraphLinkDirection.outgoing));

    final a2 = mkNode('A');
    final b2 = mkNode('B');
    graph2
      ..addNode(a2)
      ..addNode(b2)
      ..addLink(GraphLink(
          source: a2, target: b2, direction: GraphLinkDirection.outgoing));

    final layout1 = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(id: a1.id, position: const Offset(50, 60)),
        GraphNodeLayoutPosition(id: b1.id, position: const Offset(210, 120)),
      ],
      origin: GraphLayoutPositionOrigin.topLeft,
    );
    final layout2 = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(id: a2.id, position: const Offset(50, 60)),
        GraphNodeLayoutPosition(id: b2.id, position: const Offset(210, 120)),
      ],
      origin: GraphLayoutPositionOrigin.topLeft,
    );

    const straight =
        GraphViewDefaultBehavior(linkRouting: GraphLinkRouting.straight);
    const ortho =
        GraphViewDefaultBehavior(linkRouting: GraphLinkRouting.orthogonal);

    final key = UniqueKey();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              key: key,
              child: SizedBox(
                width: 400,
                height: 240,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 180,
                      height: 200,
                      child: GraphView(
                        graph: graph1,
                        behavior: straight,
                        layoutStrategy: layout1,
                        animationEnabled: false,
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      height: 200,
                      child: GraphView(
                        graph: graph2,
                        behavior: ortho,
                        layoutStrategy: layout2,
                        animationEnabled: false,
                      ),
                    ),
                  ],
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
      matchesGoldenFile('goldens/graph_view_routing_comparison.png'),
    );
  });
}
