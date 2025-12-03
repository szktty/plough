import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GraphView golden: orthogonal steps with crossing',
      (tester) async {
    final g = Graph();

    final a = GraphNode(properties: {'label': 'A'});
    final b = GraphNode(properties: {'label': 'B'});
    final c = GraphNode(properties: {'label': 'C'});
    final d = GraphNode(properties: {'label': 'D'});

    final e = GraphNode(properties: {'label': 'E'});
    final f = GraphNode(properties: {'label': 'F'});
    final h = GraphNode(properties: {'label': 'H'});
    final i = GraphNode(properties: {'label': 'I'});

    g
      ..addNode(a)
      ..addNode(b)
      ..addNode(c)
      ..addNode(d)
      ..addNode(e)
      ..addNode(f)
      ..addNode(h)
      ..addNode(i);

    // Top row A-B-C-D, bottom row E-F-H-I (offset creating steps)
    g.addLink(GraphLink(
        source: a, target: b, direction: GraphLinkDirection.outgoing));
    g.addLink(GraphLink(
        source: b, target: c, direction: GraphLinkDirection.outgoing));
    g.addLink(GraphLink(
        source: c, target: d, direction: GraphLinkDirection.outgoing));

    g.addLink(GraphLink(
        source: e, target: f, direction: GraphLinkDirection.outgoing));
    g.addLink(GraphLink(
        source: f, target: h, direction: GraphLinkDirection.outgoing));
    g.addLink(GraphLink(
        source: h, target: i, direction: GraphLinkDirection.outgoing));

    // Vertical connections with crossings B->F and C->H
    g.addLink(GraphLink(
        source: b, target: f, direction: GraphLinkDirection.outgoing));
    g.addLink(GraphLink(
        source: c, target: h, direction: GraphLinkDirection.outgoing));

    final layout = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(id: a.id, position: const Offset(40, 60)),
        GraphNodeLayoutPosition(
            id: b.id, position: const Offset(180, 40)), // slightly up for step
        GraphNodeLayoutPosition(
            id: c.id,
            position: const Offset(320, 80)), // slightly down for step
        GraphNodeLayoutPosition(id: d.id, position: const Offset(460, 60)),

        GraphNodeLayoutPosition(id: e.id, position: const Offset(40, 220)),
        GraphNodeLayoutPosition(id: f.id, position: const Offset(180, 200)),
        GraphNodeLayoutPosition(id: h.id, position: const Offset(320, 240)),
        GraphNodeLayoutPosition(id: i.id, position: const Offset(460, 220)),
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
                width: 540,
                height: 320,
                child: GraphView(
                  graph: g,
                  behavior: const GraphViewDefaultBehavior(
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
      find.byKey(key),
      matchesGoldenFile('goldens/graph_view_orthogonal_steps_cross.png'),
    );
  });
}
