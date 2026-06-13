import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

// F1: removing nodes/links should not leak cached views/keys, and re-adding an
// entity after removal must not blow up (e.g. duplicate GlobalKey). We can't
// read the private caches from a widget test, so we exercise the add/remove/
// re-add cycle and assert the rendered output stays correct and stable.

Widget _host(Graph graph, GraphLayoutStrategy layout) => MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 400,
          child: GraphView(
            graph: graph,
            behavior: const GraphViewDefaultBehavior(),
            layoutStrategy: layout,
            animationEnabled: false,
          ),
        ),
      ),
    );

void main() {
  testWidgets('removed node disappears and re-adding does not crash', (
    tester,
  ) async {
    final graph = Graph();
    final a = GraphNode(properties: {'label': 'A'});
    final b = GraphNode(properties: {'label': 'B'});
    graph
      ..addNode(a)
      ..addNode(b);

    final layout = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(id: a.id, position: const Offset(80, 80)),
        GraphNodeLayoutPosition(id: b.id, position: const Offset(200, 200)),
      ],
      origin: GraphLayoutPositionOrigin.topLeft,
    );

    await tester.pumpWidget(_host(graph, layout));
    await tester.pumpAndSettle();

    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);

    // Remove B and rebuild.
    graph.removeNode(b.id);
    await tester.pumpAndSettle();

    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsNothing);

    // Re-add a node with the same id as the removed one. If the GlobalKey for
    // the old node had leaked, this rebuild would throw a duplicate-key error.
    final b2 = GraphNode(id: b.id, properties: {'label': 'B2'});
    graph.addNode(b2);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B2'), findsOneWidget);
  });

  testWidgets('repeated add/remove cycles stay stable', (tester) async {
    final graph = Graph();
    final keep = GraphNode(properties: {'label': 'KEEP'});
    graph.addNode(keep);

    final layout = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(id: keep.id, position: const Offset(50, 50)),
      ],
      origin: GraphLayoutPositionOrigin.topLeft,
    );

    await tester.pumpWidget(_host(graph, layout));
    await tester.pumpAndSettle();

    for (var i = 0; i < 5; i++) {
      final tmp = GraphNode(properties: {'label': 'TMP$i'});
      graph.addNode(tmp);
      await tester.pumpAndSettle();
      expect(find.text('TMP$i'), findsOneWidget);

      graph.removeNode(tmp.id);
      await tester.pumpAndSettle();
      expect(find.text('TMP$i'), findsNothing);
    }

    expect(tester.takeException(), isNull);
    expect(find.text('KEEP'), findsOneWidget);
  });

  testWidgets('cached entity count does not grow across add/remove cycles', (
    tester,
  ) async {
    final graph = Graph();
    final a = GraphNode(properties: {'label': 'A'});
    final b = GraphNode(properties: {'label': 'B'});
    graph
      ..addNode(a)
      ..addNode(b);
    final ab = GraphLink(
      source: a,
      target: b,
      direction: GraphLinkDirection.outgoing,
    );
    graph.addLink(ab);

    final layout = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(id: a.id, position: const Offset(60, 60)),
        GraphNodeLayoutPosition(id: b.id, position: const Offset(220, 220)),
      ],
      origin: GraphLayoutPositionOrigin.topLeft,
    );

    await tester.pumpWidget(_host(graph, layout));
    await tester.pumpAndSettle();

    final state = tester.state<GraphViewState>(find.byType(GraphView));
    final baseline = state.debugCachedEntityCount;

    // Add and remove a transient node+link many times. Without pruning, the
    // node/link key caches would grow by one entry per iteration.
    for (var i = 0; i < 10; i++) {
      final tmp = GraphNode(properties: {'label': 'T$i'});
      graph.addNode(tmp);
      final tmpLink = GraphLink(
        source: a,
        target: tmp,
        direction: GraphLinkDirection.outgoing,
      );
      graph.addLink(tmpLink);
      await tester.pumpAndSettle();

      graph
        ..removeLink(tmpLink.id)
        ..removeNode(tmp.id);
      await tester.pumpAndSettle();
    }

    // Caches must return to the baseline (the original a, b, ab), not grow.
    expect(state.debugCachedEntityCount, baseline);
  });
}
