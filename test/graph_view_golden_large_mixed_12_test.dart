import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'GraphView golden: large mixed 12 (3x4 grid, mixed links/selections)',
    (tester) async {
      final g = Graph();

      GraphNode mk(String s) => GraphNode(properties: {'label': s});

      final n1 = mk('N1');
      final n2 = mk('N2');
      final n3 = mk('N3');
      final n4 = mk('N4');
      final n5 = mk('N5');
      final n6 = mk('N6');
      final n7 = mk('N7');
      final n8 = mk('N8');
      final n9 = mk('N9');
      final n10 = mk('N10');
      final n11 = mk('N11');
      final n12 = mk('N12');

      for (final n in [n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12]) {
        g.addNode(n);
      }

      // Rows
      g.addLink(
        GraphLink(
          source: n1,
          target: n2,
          direction: GraphLinkDirection.outgoing,
        ),
      );
      g.addLink(
        GraphLink(
          source: n2,
          target: n3,
          direction: GraphLinkDirection.bidirectional,
        ),
      );
      g.addLink(
        GraphLink(
          source: n3,
          target: n4,
          direction: GraphLinkDirection.outgoing,
        ),
      );

      g.addLink(
        GraphLink(source: n5, target: n6, direction: GraphLinkDirection.none),
      );
      g.addLink(
        GraphLink(
          source: n6,
          target: n7,
          direction: GraphLinkDirection.outgoing,
        ),
      );
      g.addLink(
        GraphLink(
          source: n7,
          target: n8,
          direction: GraphLinkDirection.bidirectional,
        ),
      );

      g.addLink(
        GraphLink(
          source: n9,
          target: n10,
          direction: GraphLinkDirection.outgoing,
        ),
      );
      g.addLink(
        GraphLink(
          source: n10,
          target: n11,
          direction: GraphLinkDirection.outgoing,
        ),
      );
      g.addLink(
        GraphLink(source: n11, target: n12, direction: GraphLinkDirection.none),
      );

      // Columns (some reversed to vary arrowheads)
      g.addLink(
        GraphLink(
          source: n1,
          target: n5,
          direction: GraphLinkDirection.outgoing,
        ),
      );
      g.addLink(
        GraphLink(
          source: n5,
          target: n9,
          direction: GraphLinkDirection.outgoing,
        ),
      );

      g.addLink(
        GraphLink(
          source: n4,
          target: n8,
          direction: GraphLinkDirection.outgoing,
        ),
      );
      g.addLink(
        GraphLink(
          source: n8,
          target: n12,
          direction: GraphLinkDirection.outgoing,
        ),
      );

      // Diagonals for complexity
      g.addLink(
        GraphLink(
          source: n2,
          target: n6,
          direction: GraphLinkDirection.outgoing,
        ),
      );
      g.addLink(
        GraphLink(
          source: n7,
          target: n11,
          direction: GraphLinkDirection.outgoing,
        ),
      );
      g.addLink(
        GraphLink(
          source: n3,
          target: n7,
          direction: GraphLinkDirection.outgoing,
        ),
      );

      // Selections: nodes and a few links
      g.selectNode(n2.id);
      g.selectNode(n7.id);
      g.selectNode(n10.id);

      // The created links above are anonymous; we rely on visual to include some selected links too

      final positions = <GraphNodeLayoutPosition>[
        // row 1
        GraphNodeLayoutPosition(id: n1.id, position: const Offset(40, 40)),
        GraphNodeLayoutPosition(id: n2.id, position: const Offset(180, 40)),
        GraphNodeLayoutPosition(id: n3.id, position: const Offset(320, 40)),
        GraphNodeLayoutPosition(id: n4.id, position: const Offset(460, 40)),
        // row 2
        GraphNodeLayoutPosition(id: n5.id, position: const Offset(40, 170)),
        GraphNodeLayoutPosition(id: n6.id, position: const Offset(180, 170)),
        GraphNodeLayoutPosition(id: n7.id, position: const Offset(320, 170)),
        GraphNodeLayoutPosition(id: n8.id, position: const Offset(460, 170)),
        // row 3
        GraphNodeLayoutPosition(id: n9.id, position: const Offset(40, 300)),
        GraphNodeLayoutPosition(id: n10.id, position: const Offset(180, 300)),
        GraphNodeLayoutPosition(id: n11.id, position: const Offset(320, 300)),
        GraphNodeLayoutPosition(id: n12.id, position: const Offset(460, 300)),
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
                  width: 540,
                  height: 360,
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
        matchesGoldenFile('goldens/graph_view_large_mixed_12.png'),
      );
    },
  );
}
