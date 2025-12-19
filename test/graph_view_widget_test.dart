import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/graph/node.dart' show GraphNodeImpl;

void main() {
  testWidgets('GraphView with ManualLayout applies fixed logical positions', (
    tester,
  ) async {
    final graph = Graph();
    final node = GraphNode(properties: {'label': 'n'});
    graph.addNode(node);

    final layout = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(id: node.id, position: const Offset(100, 120)),
      ],
      origin: GraphLayoutPositionOrigin.topLeft,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            height: 300,
            child: GraphView(
              graph: graph,
              behavior: const GraphViewDefaultBehavior(),
              layoutStrategy: layout,
              animationEnabled: false,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(GraphView), findsOneWidget);
    // Logical position is set by layout strategy
    final impl = graph.getNode(node.id)! as GraphNodeImpl;
    expect(impl.logicalPosition, const Offset(100, 120));
  });
}
