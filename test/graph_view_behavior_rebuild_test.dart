import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

class _CountingBehavior extends GraphViewDefaultBehavior {
  const _CountingBehavior({super.linkRouting});
  static int nodeCreateCount = 0;
  static int linkCreateCount = 0;

  static void reset() {
    nodeCreateCount = 0;
    linkCreateCount = 0;
  }

  @override
  GraphNodeViewBehavior createNodeViewBehavior() {
    nodeCreateCount += 1;
    return super.createNodeViewBehavior();
  }

  @override
  GraphLinkViewBehavior createLinkViewBehavior() {
    linkCreateCount += 1;
    return super.createLinkViewBehavior();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'GraphView: equivalent behavior skips reinit; different triggers reinit',
    (tester) async {
      final graph = Graph();
      final a = GraphNode(properties: {'label': 'A'});
      final b = GraphNode(properties: {'label': 'B'});
      graph
        ..addNode(a)
        ..addNode(b);
      graph.addLink(
        GraphLink(source: a, target: b, direction: GraphLinkDirection.outgoing),
      );

      final layout = GraphManualLayoutStrategy(
        nodePositions: [
          GraphNodeLayoutPosition(id: a.id, position: const Offset(40, 60)),
          GraphNodeLayoutPosition(id: b.id, position: const Offset(180, 60)),
        ],
        origin: GraphLayoutPositionOrigin.topLeft,
      );

      _CountingBehavior.reset();

      const behavior1 = _CountingBehavior();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 260,
                height: 160,
                child: GraphView(
                  graph: graph,
                  behavior: behavior1,
                  layoutStrategy: layout,
                  animationEnabled: false,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // After initial mount, create*Behavior should have been called exactly once each.
      expect(_CountingBehavior.nodeCreateCount, 1);
      expect(_CountingBehavior.linkCreateCount, 1);

      // Pump with equivalent behavior (new instance, same params)
      const behavior2 = _CountingBehavior();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 260,
                height: 160,
                child: GraphView(
                  graph: graph,
                  behavior: behavior2,
                  layoutStrategy: layout,
                  animationEnabled: false,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Equivalent behavior: no reinit, counters unchanged
      expect(_CountingBehavior.nodeCreateCount, 1);
      expect(_CountingBehavior.linkCreateCount, 1);

      // Pump with different behavior (orthogonal) to trigger reinit
      const behavior3 = _CountingBehavior(
        linkRouting: GraphLinkRouting.orthogonal,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 260,
                height: 160,
                child: GraphView(
                  graph: graph,
                  behavior: behavior3,
                  layoutStrategy: layout,
                  animationEnabled: false,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Different behavior: reinit, counters incremented
      expect(_CountingBehavior.nodeCreateCount, 2);
      expect(_CountingBehavior.linkCreateCount, 2);
    },
  );
}
