import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

class _FixedNodeSizeBehavior extends GraphViewDefaultBehavior {
  const _FixedNodeSizeBehavior();

  @override
  GraphNodeViewBehavior createNodeViewBehavior() {
    return GraphNodeViewBehavior.defaultBehavior(
      tooltipTriggerMode: GraphTooltipTriggerMode.tap,
      nodeRendererStyle: const GraphDefaultNodeRendererStyle(
        shape: GraphDefaultNodeRendererShape.rectangle,
        width: 60,
        height: 60,
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpGraph(
    WidgetTester tester, {
    required GraphGestureMode gestureMode,
    required void Function() onBackgroundTap,
  }) async {
    final graph = Graph();
    final a = GraphNode(properties: {'label': 'A'});
    final b = GraphNode(properties: {'label': 'B'});
    graph
      ..addNode(a)
      ..addNode(b);
    graph.addLink(GraphLink(
        source: a, target: b, direction: GraphLinkDirection.outgoing));

    final layout = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(id: a.id, position: const Offset(60, 80)),
        GraphNodeLayoutPosition(id: b.id, position: const Offset(200, 80)),
      ],
      origin: GraphLayoutPositionOrigin.topLeft,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              height: 240,
              child: GraphView(
                graph: graph,
                behavior: const _FixedNodeSizeBehavior(),
                layoutStrategy: layout,
                animationEnabled: false,
                gestureMode: gestureMode,
                onBackgroundTapped: (_) => onBackgroundTap(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> flushTimers(WidgetTester tester) async {
    // Flush timers used by tap/double-tap detection
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('onBackgroundTapped fires only on empty area (exclusive)',
      (tester) async {
    var bgTap = 0;
    await pumpGraph(
      tester,
      gestureMode: GraphGestureMode.exclusive,
      onBackgroundTap: () => bgTap++,
    );

    final viewTopLeft = tester.getTopLeft(find.byType(GraphView));

    // Background tap
    await tester.tapAt(viewTopLeft + const Offset(10, 10));
    await tester.pump();
    await flushTimers(tester);
    expect(bgTap, 1);

    // Node tap (node A center at 90,110)
    await tester.tapAt(viewTopLeft + const Offset(90, 110));
    await tester.pump();
    await flushTimers(tester);
    expect(bgTap, 1, reason: 'Should not increase on node tap');
  });

  testWidgets('onBackgroundTapped fires only on empty area (transparent)',
      (tester) async {
    var bgTap = 0;
    await pumpGraph(
      tester,
      gestureMode: GraphGestureMode.transparent,
      onBackgroundTap: () => bgTap++,
    );

    final viewTopLeft = tester.getTopLeft(find.byType(GraphView));

    // Background tap
    await tester.tapAt(viewTopLeft + const Offset(10, 10));
    await tester.pump();
    await flushTimers(tester);
    expect(bgTap, 1);

    // Node tap should not count as background
    await tester.tapAt(viewTopLeft + const Offset(90, 110));
    await tester.pump();
    await flushTimers(tester);
    expect(bgTap, 1);
  });
}
