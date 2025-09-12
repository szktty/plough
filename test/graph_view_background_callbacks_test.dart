import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

class _FixedNodeSizeBehavior extends GraphViewDefaultBehavior {
  const _FixedNodeSizeBehavior({super.linkRouting});

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

  testWidgets('Background pan callbacks fire only on empty area (nodeEdgeOnly)',
      (tester) async {
    final graph = Graph();
    final a = GraphNode(properties: {'label': 'A'});
    final b = GraphNode(properties: {'label': 'B'});
    graph
      ..addNode(a)
      ..addNode(b);
    graph.addLink(GraphLink(
        source: a, target: b, direction: GraphLinkDirection.outgoing));

    // Manual fixed positions; nodes are 60x60 by behavior
    final layout = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(id: a.id, position: const Offset(60, 80)),
        GraphNodeLayoutPosition(id: b.id, position: const Offset(200, 80)),
      ],
      origin: GraphLayoutPositionOrigin.topLeft,
    );

    int panStartCount = 0;
    int panUpdateCount = 0;
    int panEndCount = 0;

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
                gestureMode: GraphGestureMode.nodeEdgeOnly,
                onBackgroundPanStart: (_) => panStartCount++,
                onBackgroundPanUpdate: (_, __) => panUpdateCount++,
                onBackgroundPanEnd: (_) => panEndCount++,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final viewTopLeft = tester.getTopLeft(find.byType(GraphView));

    // Background drag (empty area): start at (10,10) relative to GraphView
    final startBg = viewTopLeft + const Offset(10, 10);
    // Seed hover to initialize _lastPointerDetails used by pan update
    tester.binding.handlePointerEvent(PointerHoverEvent(position: startBg));
    final gestureBg = await tester.startGesture(startBg);
    await tester.pump();
    await gestureBg.moveBy(const Offset(30, 0));
    await tester.pump();
    await gestureBg.up();
    await tester.pump();
    // Let any gesture timers settle
    await tester.pump(const Duration(milliseconds: 300));

    expect(panStartCount, 1, reason: 'Background panStart should fire once');
    expect(panUpdateCount, greaterThan(0),
        reason: 'Background panUpdate should fire');
    expect(panEndCount, 1, reason: 'Background panEnd should fire once');

    // Reset counters
    panStartCount = 0;
    panUpdateCount = 0;
    panEndCount = 0;

    // Node area drag: center of node A at (60,80) with size 60x60 -> center (90,110)
    final nodeCenter = viewTopLeft + const Offset(90, 110);
    // Seed hover
    tester.binding.handlePointerEvent(PointerHoverEvent(position: nodeCenter));
    final gestureNode = await tester.startGesture(nodeCenter);
    await tester.pump();
    await gestureNode.moveBy(const Offset(20, 0));
    await tester.pump();
    await gestureNode.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // In nodeEdgeOnly mode, callbacks should NOT fire when
    // interacting with a node
    expect(panStartCount, 0);
    expect(panUpdateCount, 0);
    expect(panEndCount, 0);
  });
}
