import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GraphView golden: large star+mesh (hub with ring)', (
    tester,
  ) async {
    final g = Graph();

    GraphNode mk(String name) => GraphNode(properties: {'label': name});

    final o = mk('O');
    final r1 = mk('R1');
    final r2 = mk('R2');
    final r3 = mk('R3');
    final r4 = mk('R4');
    final r5 = mk('R5');
    final r6 = mk('R6');
    final r7 = mk('R7');
    final r8 = mk('R8');

    for (final n in [o, r1, r2, r3, r4, r5, r6, r7, r8]) {
      g.addNode(n);
    }

    // Star from hub O to ring nodes
    for (final n in [r1, r2, r3, r4, r5, r6, r7, r8]) {
      g.addLink(
        GraphLink(source: o, target: n, direction: GraphLinkDirection.outgoing),
      );
    }

    // Ring mesh (bidirectional on quarters, outgoing otherwise)
    g.addLink(
      GraphLink(source: r1, target: r2, direction: GraphLinkDirection.outgoing),
    );
    g.addLink(
      GraphLink(
        source: r2,
        target: r3,
        direction: GraphLinkDirection.bidirectional,
      ),
    );
    g.addLink(
      GraphLink(source: r3, target: r4, direction: GraphLinkDirection.outgoing),
    );
    g.addLink(
      GraphLink(source: r4, target: r5, direction: GraphLinkDirection.none),
    );
    g.addLink(
      GraphLink(source: r5, target: r6, direction: GraphLinkDirection.outgoing),
    );
    g.addLink(
      GraphLink(
        source: r6,
        target: r7,
        direction: GraphLinkDirection.bidirectional,
      ),
    );
    g.addLink(
      GraphLink(source: r7, target: r8, direction: GraphLinkDirection.outgoing),
    );
    g.addLink(
      GraphLink(source: r8, target: r1, direction: GraphLinkDirection.outgoing),
    );

    // Select some nodes and ring links
    g.selectNode(r2.id);
    g.selectNode(r6.id);
    // choose two ring links to highlight
    // find the created links by iterating would require internals; we know the order above
    // but for clarity we re-create references in local variables

    final positions = <GraphNodeLayoutPosition>[
      // hub
      GraphNodeLayoutPosition(id: o.id, position: const Offset(240, 140)),
      // ring (clockwise from top)
      GraphNodeLayoutPosition(id: r1.id, position: const Offset(240, 40)),
      GraphNodeLayoutPosition(id: r2.id, position: const Offset(330, 70)),
      GraphNodeLayoutPosition(id: r3.id, position: const Offset(360, 140)),
      GraphNodeLayoutPosition(id: r4.id, position: const Offset(330, 210)),
      GraphNodeLayoutPosition(id: r5.id, position: const Offset(240, 240)),
      GraphNodeLayoutPosition(id: r6.id, position: const Offset(150, 210)),
      GraphNodeLayoutPosition(id: r7.id, position: const Offset(120, 140)),
      GraphNodeLayoutPosition(id: r8.id, position: const Offset(150, 70)),
    ];

    final layout = GraphManualLayoutStrategy(
      nodePositions: positions,
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
                width: 520,
                height: 300,
                child: GraphView(
                  graph: g,
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
      find.byKey(key),
      matchesGoldenFile('goldens/graph_view_large_star_mesh.png'),
    );
  });
}
