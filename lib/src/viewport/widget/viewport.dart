import 'package:flutter/widgets.dart';
import 'package:plough/src/viewport/controller.dart';

/// A widget that provides pan and zoom for its child, typically a GraphView.
///
/// [GraphViewport] owns a transformation matrix (scale + pan offset) and
/// handles pan and pinch-to-zoom gestures internally.  Because the transform
/// is applied *inside* plough — between the gesture recognizer and the
/// positioned nodes — all existing coordinate logic in GraphView, including
/// hit-testing and node dragging, works correctly at any pan/zoom level.
///
/// Basic usage:
/// ```dart
/// GraphViewport(
///   child: GraphView(
///     graph: graph,
///     behavior: behavior,
///     layoutStrategy: layoutStrategy,
///     gestureMode: GraphGestureMode.nodeEdgeOnly,
///   ),
/// )
/// ```
///
/// With a [GraphViewportController] for programmatic control:
/// ```dart
/// final _controller = GraphViewportController();
///
/// GraphViewport(
///   controller: _controller,
///   minScale: 0.3,
///   maxScale: 4.0,
///   child: GraphView(...),
/// )
///
/// // Later:
/// _controller.reset();
/// await _controller.animateTo(
///   vsync: this,
///   viewSize: context.size!,
///   sceneOffset: node.logicalPosition,
///   targetScale: 1.5,
/// );
/// ```
class GraphViewport extends StatefulWidget {
  /// Creates a viewport that wraps [child] with pan and zoom support.
  const GraphViewport({
    required this.child,
    this.controller,
    this.minScale = 0.1,
    this.maxScale = 10.0,
    this.enablePan = true,
    this.enableZoom = true,
    this.onTransformChanged,
    super.key,
  });

  /// The widget to display inside the viewport, typically a GraphView.
  final Widget child;

  /// Optional controller for reading and programmatically setting the
  /// viewport transform.  If null, an internal controller is created.
  final GraphViewportController? controller;

  /// Minimum allowed zoom scale. Defaults to `0.1`.
  final double minScale;

  /// Maximum allowed zoom scale. Defaults to `10.0`.
  final double maxScale;

  /// Whether pan gestures are enabled. Defaults to `true`.
  final bool enablePan;

  /// Whether pinch-to-zoom and scroll-wheel gestures are enabled. Defaults to `true`.
  final bool enableZoom;

  /// Called whenever the viewport transform changes (pan or zoom).
  ///
  /// Use this to refresh node geometry after a viewport change:
  /// ```dart
  /// GraphViewport(
  ///   onTransformChanged: () => graphViewState.refreshAllNodeGeometry(),
  ///   child: GraphView(...),
  /// )
  /// ```
  final VoidCallback? onTransformChanged;

  @override
  State<GraphViewport> createState() => _GraphViewportState();
}

class _GraphViewportState extends State<GraphViewport> {
  GraphViewportController? _internalController;

  GraphViewportController get _controller =>
      widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = GraphViewportController(
        minScale: widget.minScale,
        maxScale: widget.maxScale,
      );
    }
    _controller.addListener(_onTransformChanged);
  }

  @override
  void didUpdateWidget(GraphViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_onTransformChanged);
      _controller.addListener(_onTransformChanged);
    }
  }

  void _onTransformChanged() {
    widget.onTransformChanged?.call();
  }

  @override
  void dispose() {
    _controller.removeListener(_onTransformChanged);
    _internalController?.dispose();
    super.dispose();
  }

  // --- Gesture handling ---

  // Previous cumulative scale, tracked across scale gesture updates.
  double _lastGestureScale = 1;

  void _onScaleStart(ScaleStartDetails details) {
    _lastGestureScale = 1;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    // Pan: focalPointDelta is in screen pixels.
    if (widget.enablePan) {
      _controller.pan(details.focalPointDelta);
    }

    // Zoom: details.scale is cumulative; derive per-frame delta.
    if (widget.enableZoom && details.scale != 1.0) {
      final scaleDelta = details.scale / _lastGestureScale;
      _controller.zoomAt(scaleDelta, focalPoint: details.focalPoint);
      _lastGestureScale = details.scale;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      // Ensure the detector covers the full area even where the child is
      // transparent.
      behavior: HitTestBehavior.opaque,
      child: ClipRect(
        child: ValueListenableBuilder<Matrix4>(
          valueListenable: _controller,
          builder: (context, matrix, _) {
            return Transform(
              key: const ValueKey('GraphViewport_Transform'),
              transform: matrix,
              child: widget.child,
            );
          },
        ),
      ),
    );
  }
}
