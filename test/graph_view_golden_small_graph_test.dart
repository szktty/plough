import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'GraphView golden: small mixed graph (5 nodes, mixed links, mixed selections)',
    (tester) async {
      final graph = Graph();
      final n1 = GraphNode(properties: {'label': 'N1'});
      final n2 = GraphNode(properties: {'label': 'N2'});
      final n3 = GraphNode(properties: {'label': 'N3'});
      final n4 = GraphNode(properties: {'label': 'N4'});
      final n5 = GraphNode(properties: {'label': 'N5'});
      graph.addNode(n1);
      graph.addNode(n2);
      graph.addNode(n3);
      graph.addNode(n4);
      graph.addNode(n5);

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
      final l35 = GraphLink(
        source: n3,
        target: n5,
        direction: GraphLinkDirection.none,
      );
      final l41 = GraphLink(
        source: n4,
        target: n1,
        direction: GraphLinkDirection.incoming,
      );
      graph.addLink(l12);
      graph.addLink(l23);
      graph.addLink(l35);
      graph.addLink(l41);

      // Selections: n2 and l23 selected
      graph.selectNode(n2.id);
      graph.selectLink(l23.id);

      final layout = GraphManualLayoutStrategy(
        nodePositions: [
          GraphNodeLayoutPosition(id: n1.id, position: const Offset(60, 60)),
          GraphNodeLayoutPosition(id: n2.id, position: const Offset(200, 60)),
          GraphNodeLayoutPosition(id: n3.id, position: const Offset(340, 60)),
          GraphNodeLayoutPosition(id: n4.id, position: const Offset(120, 160)),
          GraphNodeLayoutPosition(id: n5.id, position: const Offset(280, 160)),
        ],
        origin: GraphLayoutPositionOrigin.topLeft,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: RepaintBoundary(
                child: SizedBox(
                  width: 420,
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
        matchesGoldenFile('goldens/graph_view_small_mixed_graph.png'),
      );
    },
  );
}
