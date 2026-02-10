import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/graph/node.dart' show GraphNodeImpl;

void main() {
  group('nodeAnimationStartPosition', () {
    testWidgets(
      'uses explicit nodeAnimationStartPosition on initial layout',
      (tester) async {
        final graph = Graph();
        final node = GraphNode(properties: {'label': 'A'});
        graph.addNode(node);

        const startPosition = Offset(200, 150);

        final layout = GraphManualLayoutStrategy(
          nodePositions: [
            GraphNodeLayoutPosition(
              id: node.id,
              position: const Offset(100, 120),
            ),
          ],
          origin: GraphLayoutPositionOrigin.topLeft,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 400,
                child: GraphView(
                  graph: graph,
                  behavior: const GraphViewDefaultBehavior(),
                  layoutStrategy: layout,
                  animationEnabled: true,
                  nodeAnimationStartPosition: startPosition,
                ),
              ),
            ),
          ),
        );

        // Let initialize phase complete (geometry measurement)
        await tester.pumpAndSettle();

        final impl = graph.getNode(node.id)! as GraphNodeImpl;
        expect(
          impl.animationStartPosition,
          startPosition,
          reason:
              'Node should use explicit nodeAnimationStartPosition, not Offset.zero',
        );
      },
    );

    testWidgets(
      'defaults to screen center when nodeAnimationStartPosition is null',
      (tester) async {
        final graph = Graph();
        final node = GraphNode(properties: {'label': 'B'});
        graph.addNode(node);

        final layout = GraphManualLayoutStrategy(
          nodePositions: [
            GraphNodeLayoutPosition(
              id: node.id,
              position: const Offset(50, 60),
            ),
          ],
          origin: GraphLayoutPositionOrigin.topLeft,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 300,
                child: GraphView(
                  graph: graph,
                  behavior: const GraphViewDefaultBehavior(),
                  layoutStrategy: layout,
                  animationEnabled: true,
                  // nodeAnimationStartPosition is null (default)
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final impl = graph.getNode(node.id)! as GraphNodeImpl;
        // When null, should default to constraints center (200, 150)
        expect(
          impl.animationStartPosition,
          isNot(Offset.zero),
          reason:
              'Node should not animate from Offset.zero when nodeAnimationStartPosition is null',
        );
      },
    );
  });
}
