import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

class _ThickOnSelectedBehavior extends GraphViewDefaultBehavior {
  const _ThickOnSelectedBehavior({super.linkRouting});

  @override
  GraphLinkViewBehavior createLinkViewBehavior() {
    return GraphLinkViewBehavior(
      builder: (context, graph, link, sourceView, targetView, routing, geometry, _) {
        return GraphDefaultLinkRenderer(
          link: link,
          sourceView: sourceView,
          targetView: targetView,
          routing: routing,
          geometry: geometry,
          thickness: 20,
          lineWidth: 3,
          arrowSize: 15,
          color: Colors.black,
        );
      },
      routing: linkRouting,
      thicknessGetter: (context, graph, link, sourceView, targetView) {
        return link.isSelected ? 40 : 20;
      },
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GraphView golden: link and node selection highlight (custom thickness)', (tester) async {
    final graph = Graph();
    final a = GraphNode(properties: {'label': 'A'});
    final b = GraphNode(properties: {'label': 'B'});
    graph.addNode(a);
    graph.addNode(b);
    final l = GraphLink(source: a, target: b, direction: GraphLinkDirection.outgoing);
    graph.addLink(l);

    // Select one node and the link
    graph.selectNode(a.id);
    graph.selectLink(l.id);

    final layout = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(id: a.id, position: const Offset(60, 70)),
        GraphNodeLayoutPosition(id: b.id, position: const Offset(200, 70)),
      ],
      origin: GraphLayoutPositionOrigin.topLeft,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              child: SizedBox(
                width: 320,
                height: 180,
                child: GraphView(
                  graph: graph,
                  behavior: const _ThickOnSelectedBehavior(),
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
      matchesGoldenFile('goldens/graph_view_link_and_node_selected.png'),
    );
  });
}

