import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

void main() {
  group('GraphViewportController', () {
    test('initial value is identity matrix', () {
      final c = GraphViewportController();
      expect(c.value, Matrix4.identity());
      expect(c.scale, closeTo(1.0, 1e-6));
      expect(c.panOffset, Offset.zero);
      c.dispose();
    });

    group('reset()', () {
      test('returns to identity after pan', () {
        final c = GraphViewportController();
        c.pan(const Offset(50, 100));
        c.reset();
        expect(c.value, Matrix4.identity());
        expect(c.panOffset, Offset.zero);
        expect(c.scale, closeTo(1.0, 1e-6));
        c.dispose();
      });

      test('returns to identity after zoom', () {
        final c = GraphViewportController();
        c.zoomAt(2.0, focalPoint: const Offset(200, 150));
        c.reset();
        expect(c.scale, closeTo(1.0, 1e-6));
        c.dispose();
      });
    });

    group('pan()', () {
      test('updates panOffset by delta', () {
        final c = GraphViewportController();
        c.pan(const Offset(30, -20));
        expect(c.panOffset.dx, closeTo(30, 1e-6));
        expect(c.panOffset.dy, closeTo(-20, 1e-6));
        c.dispose();
      });

      test('accumulates multiple pan calls', () {
        final c = GraphViewportController();
        c.pan(const Offset(10, 0));
        c.pan(const Offset(5, 15));
        expect(c.panOffset.dx, closeTo(15, 1e-6));
        expect(c.panOffset.dy, closeTo(15, 1e-6));
        c.dispose();
      });

      test('does not change scale', () {
        final c = GraphViewportController();
        c.pan(const Offset(100, 200));
        expect(c.scale, closeTo(1.0, 1e-6));
        c.dispose();
      });
    });

    group('zoomAt()', () {
      test('doubles scale with scaleDelta 2.0', () {
        final c = GraphViewportController();
        c.zoomAt(2.0, focalPoint: Offset.zero);
        expect(c.scale, closeTo(2.0, 1e-6));
        c.dispose();
      });

      test('halves scale with scaleDelta 0.5', () {
        final c = GraphViewportController();
        c.zoomAt(0.5, focalPoint: Offset.zero);
        expect(c.scale, closeTo(0.5, 1e-6));
        c.dispose();
      });

      test('focal point at origin leaves panOffset unchanged', () {
        final c = GraphViewportController();
        c.zoomAt(2.0, focalPoint: Offset.zero);
        expect(c.panOffset.dx, closeTo(0, 1e-6));
        expect(c.panOffset.dy, closeTo(0, 1e-6));
        c.dispose();
      });

      test('focal point not at origin adjusts panOffset correctly', () {
        // Zoom 2× around focal (100, 100):
        // new_tx = 100 - (100 - 0) * 2 = -100
        // new_ty = 100 - (100 - 0) * 2 = -100
        final c = GraphViewportController();
        c.zoomAt(2.0, focalPoint: const Offset(100, 100));
        expect(c.panOffset.dx, closeTo(-100, 1e-6));
        expect(c.panOffset.dy, closeTo(-100, 1e-6));
        c.dispose();
      });

      test('clamps to minScale', () {
        final c = GraphViewportController(minScale: 0.5);
        c.zoomAt(0.1, focalPoint: Offset.zero);
        expect(c.scale, closeTo(0.5, 1e-6));
        c.dispose();
      });

      test('clamps to maxScale', () {
        final c = GraphViewportController(maxScale: 3.0);
        c.zoomAt(10.0, focalPoint: Offset.zero);
        expect(c.scale, closeTo(3.0, 1e-6));
        c.dispose();
      });

      test('no-op when already at minScale and zooming out', () {
        final c = GraphViewportController(minScale: 0.5);
        c.zoomAt(0.5, focalPoint: Offset.zero); // hits minScale
        final before = c.value.clone();
        c.zoomAt(0.5, focalPoint: Offset.zero); // no-op
        expect(c.value, before);
        c.dispose();
      });
    });

    group('notifies listeners', () {
      test('pan() triggers notification', () {
        final c = GraphViewportController();
        var notified = false;
        c.addListener(() => notified = true);
        c.pan(const Offset(1, 1));
        expect(notified, isTrue);
        c.dispose();
      });

      test('zoomAt() triggers notification', () {
        final c = GraphViewportController();
        var notified = false;
        c.addListener(() => notified = true);
        c.zoomAt(1.5, focalPoint: Offset.zero);
        expect(notified, isTrue);
        c.dispose();
      });

      test('reset() triggers notification', () {
        final c = GraphViewportController();
        c.pan(const Offset(10, 10)); // move away from identity
        var notified = false;
        c.addListener(() => notified = true);
        c.reset();
        expect(notified, isTrue);
        c.dispose();
      });
    });

    group('screenToScene / sceneToScreen', () {
      test('identity transform maps a point to itself', () {
        final c = GraphViewportController();
        const p = Offset(42, 17);
        expect(c.screenToScene(p), p);
        expect(c.sceneToScreen(p), p);
        c.dispose();
      });

      test('screenToScene inverts pan + zoom (known value)', () {
        final c = GraphViewportController();
        // scale 2, pan (100, 50): screen = scene * 2 + pan.
        c.zoomAt(2.0, focalPoint: Offset.zero);
        c.setPanOffset(const Offset(100, 50));
        // A node at scene (30, 40) draws at screen (160, 130).
        final screen = c.sceneToScreen(const Offset(30, 40));
        expect(screen.dx, closeTo(160, 1e-6));
        expect(screen.dy, closeTo(130, 1e-6));
        // And the inverse recovers the scene point.
        final scene = c.screenToScene(screen);
        expect(scene.dx, closeTo(30, 1e-6));
        expect(scene.dy, closeTo(40, 1e-6));
        c.dispose();
      });

      test('round-trips for arbitrary pan and zoom', () {
        final c = GraphViewportController();
        c.zoomAt(1.7, focalPoint: const Offset(200, 150));
        c.pan(const Offset(-37, 88));
        const original = Offset(123, -45);
        final back = c.screenToScene(c.sceneToScreen(original));
        expect(back.dx, closeTo(original.dx, 1e-6));
        expect(back.dy, closeTo(original.dy, 1e-6));
        c.dispose();
      });

      test('toScene delegates to screenToScene', () {
        final c = GraphViewportController();
        c.zoomAt(1.3, focalPoint: const Offset(10, 10));
        c.pan(const Offset(5, 5));
        const p = Offset(60, 70);
        expect(c.toScene(p), c.screenToScene(p));
        c.dispose();
      });
    });
  });
}
