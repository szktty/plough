import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GraphView golden: orthogonal complex (steps + crossings)', (
    tester,
  ) async {
    final g = Graph();

    final a = GraphNode(properties: {'label': 'A'});
    final b = GraphNode(properties: {'label': 'B'});
    final c = GraphNode(properties: {'label': 'C'});
    final d = GraphNode(properties: {'label': 'D'});
    final e = GraphNode(properties: {'label': 'E'});
    final f = GraphNode(properties: {'label': 'F'});

    g
      ..addNode(a)
      ..addNode(b)
      ..addNode(c)
      ..addNode(d)
      ..addNode(e)
      ..addNode(f);

    // Horizontal chain top row A->B->C
    g.addLink(
      GraphLink(source: a, target: b, direction: GraphLinkDirection.outgoing),
    );
    g.addLink(
      GraphLink(source: b, target: c, direction: GraphLinkDirection.outgoing),
    );

    // Horizontal chain bottom row D<-E<-F (reverse direction to show arrowheads)
    g.addLink(
      GraphLink(source: f, target: e, direction: GraphLinkDirection.outgoing),
    );
    g.addLink(
      GraphLink(source: e, target: d, direction: GraphLinkDirection.outgoing),
    );

    // Verticals A->D and C->F to create crossings with bottom chain
    g.addLink(
      GraphLink(source: a, target: d, direction: GraphLinkDirection.outgoing),
    );
    g.addLink(
      GraphLink(source: c, target: f, direction: GraphLinkDirection.outgoing),
    );

    // Diagonal-like via orthogonal (B->E)
    g.addLink(
      GraphLink(source: b, target: e, direction: GraphLinkDirection.outgoing),
    );

    final layout = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(id: a.id, position: const Offset(60, 60)),
        GraphNodeLayoutPosition(id: b.id, position: const Offset(240, 60)),
        GraphNodeLayoutPosition(id: c.id, position: const Offset(420, 60)),
        GraphNodeLayoutPosition(id: d.id, position: const Offset(60, 220)),
        GraphNodeLayoutPosition(id: e.id, position: const Offset(240, 220)),
        GraphNodeLayoutPosition(id: f.id, position: const Offset(420, 220)),
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
                width: 520,
                height: 300,
                child: GraphView(
                  graph: g,
                  behavior: const GraphViewDefaultBehavior(
                    linkRouting: GraphLinkRouting.orthogonal,
                  ),
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
      matchesGoldenFile('goldens/graph_view_orthogonal_complex.png'),
    );
  });
}
