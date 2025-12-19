import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'GraphView golden: medium dense graph (2x5 grid, mixed links, mixed selections)',
    (tester) async {
      final g = Graph();

      GraphNode mk(String name) => GraphNode(properties: {'label': name});

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

      for (final n in [n1, n2, n3, n4, n5, n6, n7, n8, n9, n10]) {
        g.addNode(n);
      }

      // Row links
      final l12 = GraphLink(
        source: n1,
        target: n2,
        direction: GraphLinkDirection.outgoing,
      );
      final l23 = GraphLink(
        source: n2,
        target: n3,
        direction: GraphLinkDirection.bidirectional,
      );
      final l34 = GraphLink(
        source: n3,
        target: n4,
        direction: GraphLinkDirection.outgoing,
      );
      final l45 = GraphLink(
        source: n4,
        target: n5,
        direction: GraphLinkDirection.none,
      );

      final l67 = GraphLink(
        source: n6,
        target: n7,
        direction: GraphLinkDirection.outgoing,
      );
      final l78 = GraphLink(
        source: n7,
        target: n8,
        direction: GraphLinkDirection.outgoing,
      );
      final l89 = GraphLink(
        source: n8,
        target: n9,
        direction: GraphLinkDirection.bidirectional,
      );
      final l9a = GraphLink(
        source: n9,
        target: n10,
        direction: GraphLinkDirection.outgoing,
      );

      // Cross links
      final l16 = GraphLink(
        source: n1,
        target: n6,
        direction: GraphLinkDirection.outgoing,
      );
      final l27 = GraphLink(
        source: n2,
        target: n7,
        direction: GraphLinkDirection.outgoing,
      );
      final l38 = GraphLink(
        source: n3,
        target: n8,
        direction: GraphLinkDirection.outgoing,
      );
      final l49 = GraphLink(
        source: n4,
        target: n9,
        direction: GraphLinkDirection.outgoing,
      );
      final l5a = GraphLink(
        source: n5,
        target: n10,
        direction: GraphLinkDirection.outgoing,
      );

      for (final l in [
        l12,
        l23,
        l34,
        l45,
        l67,
        l78,
        l89,
        l9a,
        l16,
        l27,
        l38,
        l49,
        l5a,
      ]) {
        g.addLink(l);
      }

      // Selections: nodes N2, N9 and links l23, l89
      g.selectNode(n2.id);
      g.selectNode(n9.id);
      g.selectLink(l23.id);
      g.selectLink(l89.id);

      final positions = <GraphNodeLayoutPosition>[
        // top row
        GraphNodeLayoutPosition(id: n1.id, position: const Offset(40, 50)),
        GraphNodeLayoutPosition(id: n2.id, position: const Offset(160, 50)),
        GraphNodeLayoutPosition(id: n3.id, position: const Offset(280, 50)),
        GraphNodeLayoutPosition(id: n4.id, position: const Offset(400, 50)),
        GraphNodeLayoutPosition(id: n5.id, position: const Offset(520, 50)),
        // bottom row
        GraphNodeLayoutPosition(id: n6.id, position: const Offset(40, 190)),
        GraphNodeLayoutPosition(id: n7.id, position: const Offset(160, 190)),
        GraphNodeLayoutPosition(id: n8.id, position: const Offset(280, 190)),
        GraphNodeLayoutPosition(id: n9.id, position: const Offset(400, 190)),
        GraphNodeLayoutPosition(id: n10.id, position: const Offset(520, 190)),
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
                  width: 600,
                  height: 260,
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
        matchesGoldenFile('goldens/graph_view_medium_dense.png'),
      );
    },
  );
}
