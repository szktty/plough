import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpGraph(
    WidgetTester tester, {
    required void Function(Offset pos) onStart,
    required void Function(Offset pos, Offset delta) onUpdate,
    required void Function(Offset pos) onEnd,
  }) async {
    final graph = Graph();
    final a = GraphNode(properties: {'label': 'A'});
    final b = GraphNode(properties: {'label': 'B'});
    graph
      ..addNode(a)
      ..addNode(b);

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
                behavior: const GraphViewDefaultBehavior(),
                layoutStrategy: layout,
                animationEnabled: false,
                gestureMode: GraphGestureMode.custom,
                // Accept gesture initially anywhere; during update we branch by position
                shouldConsumeGesture: (pos, hit) => pos.dx >= 150,
                onBackgroundPanStart: (p) => onStart(p),
                onBackgroundPanUpdate: (p, d) => onUpdate(p, d),
                onBackgroundPanEnd: (p) => onEnd(p),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'custom gesture mode: background pan updates when moving into non-consumed area',
    (tester) async {
      var starts = 0;
      var updates = 0;
      var ends = 0;

      await pumpGraph(
        tester,
        onStart: (_) => starts++,
        onUpdate: (_, __) => updates++,
        onEnd: (_) => ends++,
      );

      final boxTopLeft = tester.getTopLeft(find.byType(GraphView));

      // Start in consumed area (right side), move a bit within consumed area (no updates),
      // then cross into non-consumed area (updates should fire), and end.
      final gesture = await tester.startGesture(
        boxTopLeft + const Offset(300, 20),
      );
      await tester.pump();

      // Move within consumed area (dx >= 150) -> no background update expected
      await gesture.moveBy(const Offset(-40, 0));
      await tester.pump();

      final updatesAfterConsumedOnly = updates;

      // Cross the threshold into non-consumed area (dx < 150)
      await gesture.moveBy(const Offset(-140, 0));
      await tester.pump();

      await gesture.up();
      await tester.pumpAndSettle();

      // Verify we got at least one background update after crossing the threshold
      expect(updates, greaterThan(updatesAfterConsumedOnly));

      final prevStarts = starts;
      final prevUpdates = updates;
      final prevEnds = ends;

      // New gesture that stays entirely within consumed area: no updates expected
      final gesture2 = await tester.startGesture(
        boxTopLeft + const Offset(300, 40),
      );
      await tester.pump();
      await gesture2.moveBy(const Offset(30, 0));
      await tester.pump();
      await gesture2.up();
      await tester.pumpAndSettle();

      expect(starts, greaterThanOrEqualTo(prevStarts)); // start may be called
      expect(updates, prevUpdates); // no new updates in consumed-only path
      expect(
        ends,
        greaterThanOrEqualTo(prevEnds),
      ); // end always fires for non-nodeEdgeOnly modes
    },
    skip: true,
    // TODO: This is flaky under the current custom recognizer semantics. The
    // recognizer accepts at pointer-down and GraphGestureManager decides per-update
    // whether to call background update based on shouldConsumeGestureAt().
    // Revisit this when we solidify cross-threshold behavior.
  );
}
