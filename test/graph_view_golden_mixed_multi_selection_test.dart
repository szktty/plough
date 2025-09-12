import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/graph/graph_base.dart'
    show GraphImpl; // internal for GraphImpl cast

class _MixedHighlightBehavior extends GraphViewDefaultBehavior {
  const _MixedHighlightBehavior({super.linkRouting});
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
          thickness: 14,
          lineWidth: 3,
          arrowSize: 12,
          color: Colors.black,
        );
      },
      routing: linkRouting,
      thicknessGetter: (context, graph, link, sourceView, targetView) {
        return link.isSelected ? 30 : 14;
      },
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GraphView golden: mixed multi-selection (nodes+links)',
      (tester) async {
    final graph = Graph();

    final a = GraphNode(properties: {'label': 'A'});
    final b = GraphNode(properties: {'label': 'B'});
    final c = GraphNode(properties: {'label': 'C'});
    final d = GraphNode(properties: {'label': 'D'});
    final e = GraphNode(properties: {'label': 'E'});

    graph
      ..addNode(a)
      ..addNode(b)
      ..addNode(c)
      ..addNode(d)
      ..addNode(e);

    final l1 =
        GraphLink(source: a, target: b, direction: GraphLinkDirection.outgoing);
    final l2 = GraphLink(
        source: b, target: c, direction: GraphLinkDirection.bidirectional);
    final l3 =
        GraphLink(source: c, target: d, direction: GraphLinkDirection.outgoing);
    final l4 =
        GraphLink(source: b, target: e, direction: GraphLinkDirection.none);

    graph
      ..addLink(l1)
      ..addLink(l2)
      ..addLink(l3)
      ..addLink(l4);

    // enable multi-selection (internal)
    final impl = graph as GraphImpl;
    impl.setState(impl.state.value.copyWith(allowMultiSelection: true));

    // select two nodes and two links
    graph.selectNode(b.id);
    graph.selectNode(d.id);
    graph.selectLink(l2.id);
    graph.selectLink(l4.id);

    final layout = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(id: a.id, position: const Offset(40, 100)),
        GraphNodeLayoutPosition(id: b.id, position: const Offset(160, 60)),
        GraphNodeLayoutPosition(id: c.id, position: const Offset(280, 60)),
        GraphNodeLayoutPosition(id: d.id, position: const Offset(400, 60)),
        GraphNodeLayoutPosition(id: e.id, position: const Offset(160, 160)),
      ],
      origin: GraphLayoutPositionOrigin.topLeft,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              child: SizedBox(
                width: 460,
                height: 220,
                child: GraphView(
                  graph: graph,
                  behavior: const _MixedHighlightBehavior(
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
      find.byType(GraphView),
      matchesGoldenFile('goldens/graph_view_mixed_multi_selection.png'),
    );
  });
}
