import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GraphView golden: medium graph 3x3 grid (mixed links, mixed selections)', (tester) async {
    final graph = Graph();

    GraphNode mk(String label) => GraphNode(properties: {'label': label});

    final n1 = mk('N1');
    final n2 = mk('N2');
    final n3 = mk('N3');
    final n4 = mk('N4');
    final n5 = mk('N5');
    final n6 = mk('N6');
    final n7 = mk('N7');
    final n8 = mk('N8');
    final n9 = mk('N9');

    for (final n in [n1, n2, n3, n4, n5, n6, n7, n8, n9]) {
      graph.addNode(n);
    }

    final l12 = GraphLink(source: n1, target: n2, direction: GraphLinkDirection.outgoing);
    final l23 = GraphLink(source: n2, target: n3, direction: GraphLinkDirection.bidirectional);
    final l45 = GraphLink(source: n4, target: n5, direction: GraphLinkDirection.none);
    final l78 = GraphLink(source: n7, target: n8, direction: GraphLinkDirection.incoming);
    final l14 = GraphLink(source: n1, target: n4, direction: GraphLinkDirection.outgoing);
    final l25 = GraphLink(source: n2, target: n5, direction: GraphLinkDirection.outgoing);
    final l36 = GraphLink(source: n3, target: n6, direction: GraphLinkDirection.outgoing);
    final l69 = GraphLink(source: n6, target: n9, direction: GraphLinkDirection.bidirectional);

    for (final l in [l12, l23, l45, l78, l14, l25, l36, l69]) {
      graph.addLink(l);
    }

    // Selections: nodes N2, N5 and link l23, l69
    graph.selectNode(n2.id);
    graph.selectNode(n5.id);
    graph.selectLink(l23.id);
    graph.selectLink(l69.id);

    final positions = <GraphNodeLayoutPosition>[
      GraphNodeLayoutPosition(id: n1.id, position: const Offset(60, 60)),
      GraphNodeLayoutPosition(id: n2.id, position: const Offset(240, 60)),
      GraphNodeLayoutPosition(id: n3.id, position: const Offset(420, 60)),
      GraphNodeLayoutPosition(id: n4.id, position: const Offset(60, 200)),
      GraphNodeLayoutPosition(id: n5.id, position: const Offset(240, 200)),
      GraphNodeLayoutPosition(id: n6.id, position: const Offset(420, 200)),
      GraphNodeLayoutPosition(id: n7.id, position: const Offset(60, 340)),
      GraphNodeLayoutPosition(id: n8.id, position: const Offset(240, 340)),
      GraphNodeLayoutPosition(id: n9.id, position: const Offset(420, 340)),
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
                height: 420,
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
      find.byKey(key),
      matchesGoldenFile('goldens/graph_view_medium_grid.png'),
    );
  });
}

