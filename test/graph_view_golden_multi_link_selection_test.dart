import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

class _ThickSelectedLinksBehavior extends GraphViewDefaultBehavior {
  const _ThickSelectedLinksBehavior();
  @override
  GraphLinkViewBehavior createLinkViewBehavior() {
    return GraphLinkViewBehavior(
      builder:
          (context, graph, link, sourceView, targetView, routing, geometry, _) {
        return GraphDefaultLinkRenderer(
          link: link,
          sourceView: sourceView,
          targetView: targetView,
          routing: routing,
          geometry: geometry,
          thickness: 16,
          lineWidth: 3,
          arrowSize: 14,
        );
      },
      routing: linkRouting,
      thicknessGetter: (context, graph, link, sourceView, targetView) {
        return link.isSelected ? 34 : 16;
      },
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'GraphView golden: multiple link selections highlighted (thicker)',
    (tester) async {
      final graph = Graph();

      final a = GraphNode(properties: {'label': 'A'});
      final b = GraphNode(properties: {'label': 'B'});
      final c = GraphNode(properties: {'label': 'C'});
      final d = GraphNode(properties: {'label': 'D'});
      graph
        ..addNode(a)
        ..addNode(b)
        ..addNode(c)
        ..addNode(d);

      final l1 = GraphLink(
        source: a,
        target: b,
        direction: GraphLinkDirection.outgoing,
      );
      final l2 = GraphLink(
        source: b,
        target: c,
        direction: GraphLinkDirection.outgoing,
      );
      final l3 = GraphLink(
        source: c,
        target: d,
        direction: GraphLinkDirection.outgoing,
      );
      graph
        ..addLink(l1)
        ..addLink(l2)
        ..addLink(l3);

      // select two links (non-adjacent to make thickness contrast clear)
      graph.selectLink(l1.id);
      graph.selectLink(l3.id);

      final layout = GraphManualLayoutStrategy(
        nodePositions: [
          GraphNodeLayoutPosition(id: a.id, position: const Offset(40, 80)),
          GraphNodeLayoutPosition(id: b.id, position: const Offset(140, 80)),
          GraphNodeLayoutPosition(id: c.id, position: const Offset(240, 80)),
          GraphNodeLayoutPosition(id: d.id, position: const Offset(340, 80)),
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
                  height: 160,
                  child: GraphView(
                    graph: graph,
                    behavior: const _ThickSelectedLinksBehavior(),
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
        matchesGoldenFile('goldens/graph_view_multi_link_selected.png'),
      );
    },
  );
}
