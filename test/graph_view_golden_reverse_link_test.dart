import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GraphView golden: reverseLink before/after comparison', (
    tester,
  ) async {
    GraphNode mk(String label) => GraphNode(properties: {'label': label});

    // graphA: outgoing A->B
    final graphA = Graph();
    final a1 = mk('A');
    final b1 = mk('B');
    graphA
      ..addNode(a1)
      ..addNode(b1);
    final linkA = GraphLink(
      source: a1,
      target: b1,
      direction: GraphLinkDirection.outgoing,
    );
    graphA.addLink(linkA);

    // graphB: same but reversed via reverseLink
    final graphB = Graph();
    final a2 = mk('A');
    final b2 = mk('B');
    graphB
      ..addNode(a2)
      ..addNode(b2);
    final linkB = GraphLink(
      source: a2,
      target: b2,
      direction: GraphLinkDirection.outgoing,
    );
    graphB.addLink(linkB);
    graphB.reverseLink(linkB.id);

    final layoutA = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(id: a1.id, position: const Offset(50, 60)),
        GraphNodeLayoutPosition(id: b1.id, position: const Offset(210, 60)),
      ],
      origin: GraphLayoutPositionOrigin.topLeft,
    );
    final layoutB = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(id: a2.id, position: const Offset(50, 60)),
        GraphNodeLayoutPosition(id: b2.id, position: const Offset(210, 60)),
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
                height: 180,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 140,
                      child: GraphView(
                        graph: graphA,
                        behavior: const GraphViewDefaultBehavior(),
                        layoutStrategy: layoutA,
                        animationEnabled: false,
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      height: 140,
                      child: GraphView(
                        graph: graphB,
                        behavior: const GraphViewDefaultBehavior(),
                        layoutStrategy: layoutB,
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
      matchesGoldenFile('goldens/graph_view_reverse_link_before_after.png'),
    );
  });
}
