import 'dart:ui';

import 'package:flutter/widgets.dart';

/// Controls pan and zoom for a GraphViewport.
///
/// Extends [ValueNotifier] so that widgets built with
/// [ValueListenableBuilder] or [AnimatedBuilder] automatically rebuild when
/// the viewport changes.
///
/// The transformation matrix encodes **scale first, then translation**:
/// screen_point = scale * scene_point + panOffset
/// This means [panOffset] is always in screen pixels regardless of [scale].
///
/// Example:
/// ```dart
/// final controller = GraphViewportController();
///
/// // Wrap GraphView:
/// GraphViewport(
///   controller: controller,
///   child: GraphView(...),
/// )
///
/// // Programmatic control:
/// controller.pan(const Offset(100, 0));
/// controller.zoomAt(1.2, focalPoint: const Offset(400, 300));
/// controller.reset();
/// ```
class GraphViewportController extends ValueNotifier<Matrix4> {
  /// Creates a controller with an identity (no pan, no zoom) transform.
  GraphViewportController({
    double minScale = 0.1,
    double maxScale = 10.0,
  })  : _minScale = minScale,
        _maxScale = maxScale,
        super(Matrix4.identity());

  final double _minScale;
  final double _maxScale;

  AnimationController? _animationController;

  /// The current zoom scale.
  double get scale => value.getMaxScaleOnAxis();

  /// The current pan offset in screen pixels.
  Offset get panOffset => Offset(value[12], value[13]);

  /// Converts a global screen position to scene (logical) coordinates.
  ///
  /// Pass this as [GraphView.globalToScene] so that node geometry calculations
  /// remain correct after pan/zoom:
  /// ```dart
  /// GraphView(
  ///   globalToScene: _viewportController.toScene,
  ///   ...
  /// )
  /// ```
  Offset toScene(Offset globalPosition) {
    final s = scale;
    final pan = panOffset;
    return Offset(
      (globalPosition.dx - pan.dx) / s,
      (globalPosition.dy - pan.dy) / s,
    );
  }

  /// Resets pan and zoom to the identity transform.
  void reset() {
    _cancelAnimation();
    value = Matrix4.identity();
  }

  /// Pans the viewport by [delta] in screen pixels.
  void pan(Offset delta) {
    _cancelAnimation();
    final m = value.clone();
    m[12] += delta.dx;
    m[13] += delta.dy;
    value = m;
  }

  /// Zooms by [scaleDelta] around [focalPoint] (screen/widget coordinates).
  ///
  /// [scaleDelta] is a multiplier: `1.2` zooms in 20 %, `0.8` zooms out 20 %.
  /// The result is clamped to [minScale, maxScale].
  void zoomAt(double scaleDelta, {required Offset focalPoint}) {
    _cancelAnimation();
    final oldScale = scale;
    final newScale = (oldScale * scaleDelta).clamp(_minScale, _maxScale);
    if (newScale == oldScale) return;

    // Zoom around focalPoint (screen space):
    // new_tx = focal.dx - (focal.dx - old_tx) * (newScale / oldScale)
    final ratio = newScale / oldScale;
    final tx = focalPoint.dx - (focalPoint.dx - value[12]) * ratio;
    final ty = focalPoint.dy - (focalPoint.dy - value[13]) * ratio;

    value = _composeMatrix(newScale, Offset(tx, ty));
  }

  /// Smoothly animates to a target scene position and/or scale.
  ///
  /// [sceneOffset] is the scene-space point to center in the viewport.
  /// [viewSize] is the visible size of the viewport, used to compute the
  /// translation that centers [sceneOffset].
  ///
  /// If [sceneOffset] is null the current pan is preserved.
  /// If [targetScale] is null the current scale is preserved.
  Future<void> animateTo({
    required TickerProvider vsync,
    required Size viewSize,
    Offset? sceneOffset,
    double? targetScale,
    Duration duration = const Duration(milliseconds: 350),
    Curve curve = Curves.easeInOut,
  }) async {
    _cancelAnimation();

    final startMatrix = value.clone();
    final endScale = (targetScale ?? scale).clamp(_minScale, _maxScale);

    final Offset endPan;
    if (sceneOffset != null) {
      // Translate so that sceneOffset appears at the viewport center.
      endPan = Offset(
        viewSize.width / 2 - sceneOffset.dx * endScale,
        viewSize.height / 2 - sceneOffset.dy * endScale,
      );
    } else {
      // Keep the current pan, just potentially update scale.
      final currentPan = panOffset;
      endPan = Offset(
        viewSize.width / 2 - (viewSize.width / 2 - currentPan.dx) * (endScale / scale),
        viewSize.height / 2 - (viewSize.height / 2 - currentPan.dy) * (endScale / scale),
      );
    }
    final endMatrix = _composeMatrix(endScale, endPan);

    final ctrl = AnimationController(vsync: vsync, duration: duration);
    _animationController = ctrl;

    ctrl
      ..addListener(() {
        final t = curve.transform(ctrl.value);
        value = _lerpMatrix(startMatrix, endMatrix, t);
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed ||
            status == AnimationStatus.dismissed) {
          ctrl.dispose();
          if (_animationController == ctrl) {
            _animationController = null;
          }
        }
      });

    await ctrl.forward();
  }

  void _cancelAnimation() {
    _animationController?.dispose();
    _animationController = null;
  }

  @override
  void dispose() {
    _cancelAnimation();
    super.dispose();
  }

  /// Builds a [Matrix4] with scale applied first, then translation.
  ///
  /// z is scaled identically to x/y so that getMaxScaleOnAxis returns the
  /// expected value regardless of which axis is queried.
  static Matrix4 _composeMatrix(double s, Offset pan) {
    final m = Matrix4.diagonal3Values(s, s, s);
    m[12] = pan.dx;
    m[13] = pan.dy;
    return m;
  }

  /// Linearly interpolates two [Matrix4] values component-wise.
  static Matrix4 _lerpMatrix(Matrix4 a, Matrix4 b, double t) {
    final result = Matrix4.zero();
    for (var i = 0; i < 16; i++) {
      result[i] = lerpDouble(a[i], b[i], t)!;
    }
    return result;
  }
}
