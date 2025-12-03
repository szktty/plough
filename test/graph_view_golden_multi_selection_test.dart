import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/graph/graph_base.dart'
    show GraphImpl; // internal to enable multi selection

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GraphView golden: multi node selection highlight',
      (tester) async {
    final graph = Graph();
    final a = GraphNode(properties: {'label': 'A'});
    final b = GraphNode(properties: {'label': 'B'});
    final c = GraphNode(properties: {'label': 'C'});
    graph.addNode(a);
    graph.addNode(b);
    graph.addNode(c);

    // Enable multi selection via internal GraphImpl state
    final impl = graph as GraphImpl;
    impl.setState(impl.state.value.copyWith(allowMultiSelection: true));

    // Select A and C
    graph.selectNode(a.id);
    graph.selectNode(c.id);

    final layout = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(id: a.id, position: const Offset(50, 50)),
        GraphNodeLayoutPosition(id: b.id, position: const Offset(130, 80)),
        GraphNodeLayoutPosition(id: c.id, position: const Offset(210, 50)),
      ],
      origin: GraphLayoutPositionOrigin.topLeft,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              child: SizedBox(
                width: 300,
                height: 160,
                child: GraphView(
                  graph: graph,
                  behavior: const GraphViewDefaultBehavior(),
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
      matchesGoldenFile('goldens/graph_view_multi_selection.png'),
    );
  });
}
