import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

// A minimal child widget used in place of GraphView to keep tests fast and
// free of layout complexity.
class _Box extends StatelessWidget {
  const _Box();

  @override
  Widget build(BuildContext context) => const ColoredBox(
      color: Colors.blue, child: SizedBox(width: 400, height: 400));
}

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(
        body: SizedBox(width: 600, height: 600, child: child),
      ),
    );

void main() {
  group('GraphViewport', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const GraphViewport(child: _Box()),
        ),
      );
      expect(find.byType(GraphViewport), findsOneWidget);
      expect(find.byType(_Box), findsOneWidget);
    });

    testWidgets('uses provided controller', (tester) async {
      final ctrl = GraphViewportController();
      addTearDown(ctrl.dispose);

      await tester.pumpWidget(
        _wrap(GraphViewport(controller: ctrl, child: const _Box())),
      );

      expect(ctrl.scale, closeTo(1.0, 1e-6));
      expect(ctrl.panOffset, Offset.zero);
    });

    testWidgets('programmatic pan() updates Transform', (tester) async {
      final ctrl = GraphViewportController();
      addTearDown(ctrl.dispose);

      await tester.pumpWidget(
        _wrap(GraphViewport(controller: ctrl, child: const _Box())),
      );

      ctrl.pan(const Offset(50, 30));
      await tester.pump();

      expect(ctrl.panOffset.dx, closeTo(50, 1e-6));
      expect(ctrl.panOffset.dy, closeTo(30, 1e-6));

      final transform = tester.widget<Transform>(
        find.byKey(const ValueKey('GraphViewport_Transform')),
      );
      expect(transform.transform[12], closeTo(50, 1e-6));
      expect(transform.transform[13], closeTo(30, 1e-6));
    });

    testWidgets('programmatic zoomAt() updates Transform scale',
        (tester) async {
      final ctrl = GraphViewportController();
      addTearDown(ctrl.dispose);

      await tester.pumpWidget(
        _wrap(GraphViewport(controller: ctrl, child: const _Box())),
      );

      ctrl.zoomAt(2.0, focalPoint: Offset.zero);
      await tester.pump();

      expect(ctrl.scale, closeTo(2.0, 1e-6));

      final transform = tester.widget<Transform>(
        find.byKey(const ValueKey('GraphViewport_Transform')),
      );
      expect(transform.transform.getMaxScaleOnAxis(), closeTo(2.0, 1e-6));
    });

    testWidgets('reset() restores identity transform', (tester) async {
      final ctrl = GraphViewportController();
      addTearDown(ctrl.dispose);

      await tester.pumpWidget(
        _wrap(GraphViewport(controller: ctrl, child: const _Box())),
      );

      ctrl.pan(const Offset(100, 200));
      ctrl.zoomAt(3.0, focalPoint: Offset.zero);
      ctrl.reset();
      await tester.pump();

      final transform = tester.widget<Transform>(
        find.byKey(const ValueKey('GraphViewport_Transform')),
      );
      expect(transform.transform, Matrix4.identity());
    });

    testWidgets('infinite canvas: pan gesture updates controller panOffset',
        (tester) async {
      final ctrl = GraphViewportController();
      addTearDown(ctrl.dispose);

      await tester.pumpWidget(
        _wrap(
          GraphViewport(
            controller: ctrl,
            canvasMode: GraphViewportCanvasMode.infinite,
            child: const _Box(),
          ),
        ),
      );

      // Simulate a drag (pan) gesture on the viewport.
      final center = tester.getCenter(find.byType(GraphViewport));
      await tester.dragFrom(center, const Offset(80, 60));
      await tester.pump();

      // Infinite canvas pans freely (no clamp), so dragging right/down by
      // (80, 60) moves the pan offset by the same amount.
      expect(ctrl.panOffset.dx, greaterThan(0));
      expect(ctrl.panOffset.dy, greaterThan(0));
    });

    testWidgets('bounded canvas: pan gesture is clamped to zero',
        (tester) async {
      final ctrl = GraphViewportController();
      addTearDown(ctrl.dispose);

      await tester.pumpWidget(
        _wrap(
          GraphViewport(
            controller: ctrl,
            // bounded is the default; the canvas equals the initial viewport
            // size, so at scale 1 the valid pan range collapses to [0, 0].
            child: const _Box(),
          ),
        ),
      );

      // Dragging right/down would move the pan into positive territory, but the
      // bounded canvas clamps it back to zero (no blank area can appear).
      final center = tester.getCenter(find.byType(GraphViewport));
      await tester.dragFrom(center, const Offset(80, 60));
      await tester.pump();

      expect(ctrl.panOffset.dx, closeTo(0, 1e-6));
      expect(ctrl.panOffset.dy, closeTo(0, 1e-6));
    });

    testWidgets('enablePan:false suppresses pan gesture', (tester) async {
      final ctrl = GraphViewportController();
      addTearDown(ctrl.dispose);

      await tester.pumpWidget(
        _wrap(
          GraphViewport(
            controller: ctrl,
            enablePan: false,
            child: const _Box(),
          ),
        ),
      );

      final center = tester.getCenter(find.byType(GraphViewport));
      await tester.dragFrom(center, const Offset(80, 60));
      await tester.pump();

      expect(ctrl.panOffset, Offset.zero);
    });

    testWidgets('internal controller is created when none provided',
        (tester) async {
      // Should not throw — internal controller is allocated.
      await tester.pumpWidget(
        _wrap(const GraphViewport(child: _Box())),
      );
      expect(find.byType(GraphViewport), findsOneWidget);
    });

    testWidgets('minScale and maxScale are passed to internal controller',
        (tester) async {
      final ctrl = GraphViewportController(minScale: 0.5, maxScale: 2.0);
      addTearDown(ctrl.dispose);

      ctrl.zoomAt(0.01, focalPoint: Offset.zero); // try to zoom way out
      expect(ctrl.scale, closeTo(0.5, 1e-6));

      ctrl.reset();
      ctrl.zoomAt(100.0, focalPoint: Offset.zero); // try to zoom way in
      expect(ctrl.scale, closeTo(2.0, 1e-6));
    });
  });
}
