import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:plough/src/viewport/controller.dart';
import 'package:plough/src/viewport/widget/viewport_scope.dart';

/// Controls how the canvas behaves when the viewport is panned.
enum GraphViewportCanvasMode {
  /// The canvas has a fixed size equal to the initial viewport size.
  ///
  /// Nodes cannot be dragged outside the canvas boundary — they snap back to
  /// their original position on drag end.  Pan is clamped so the viewport
  /// always shows canvas content (no empty areas).
  bounded,

  /// The canvas expands automatically to always contain all nodes.
  ///
  /// When a drag ends with a node outside the current canvas boundary, the
  /// canvas grows to include the new position.  Pan is clamped to the
  /// (expanded) canvas, so no empty areas are ever visible.
  infinite,
}

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
    this.canvasMode = GraphViewportCanvasMode.bounded,
    this.onTransformChanged,
    this.debugShowBorder = false,
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

  /// How the canvas behaves when panned. Defaults to [GraphViewportCanvasMode.bounded].
  ///
  /// - [GraphViewportCanvasMode.bounded]: the scene rect is fixed at the
  ///   initial viewport size; pan is clamped so the viewport never leaves it.
  /// - [GraphViewportCanvasMode.infinite]: the scene rect starts at the
  ///   viewport size and grows in whichever direction the viewport pans toward
  ///   an edge.  The scene rect lives in the controller; its origin may go
  ///   negative as it grows up/left.
  final GraphViewportCanvasMode canvasMode;

  /// Called whenever the viewport transform changes (pan or zoom).
  final VoidCallback? onTransformChanged;

  /// When true, draws a blue border around the viewport bounds for debugging.
  final bool debugShowBorder;

  @override
  State<GraphViewport> createState() => _GraphViewportState();
}

class _GraphViewportState extends State<GraphViewport> {
  GraphViewportController? _internalController;

  GraphViewportController get _controller =>
      widget.controller ?? _internalController!;

  Size _viewportSize = Size.zero;

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

  double _lastGestureScale = 1;

  // True while the current single-pointer gesture started on an entity, so its
  // pan drives a node/link drag (forwarded to the GraphView's gesture manager)
  // instead of panning the viewport.  Multi-pointer (zoom) always pans/zooms
  // the viewport.
  bool _draggingEntity = false;

  void _onScaleStart(ScaleStartDetails details) {
    _lastGestureScale = 1;
    final handlers = _controller.pointerHandlers;
    _draggingEntity = details.pointerCount == 1 &&
        handlers != null &&
        handlers.hitTestsEntityAt(details.localFocalPoint);
    if (_draggingEntity) {
      handlers!.onPanStart(
        DragStartDetails(
          localPosition: details.localFocalPoint,
          globalPosition: details.focalPoint,
        ),
      );
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    // An entity drag in progress: forward the pan to the gesture manager and do
    // not move the viewport.  A second pointer (zoom) cancels the entity drag.
    if (_draggingEntity) {
      if (details.pointerCount > 1) {
        _draggingEntity = false;
        _controller.pointerHandlers?.onPanEnd(DragEndDetails());
      } else {
        _controller.pointerHandlers?.onPanUpdate(
          DragUpdateDetails(
            globalPosition: details.focalPoint,
            localPosition: details.localFocalPoint,
            delta: details.focalPointDelta,
          ),
        );
        return;
      }
    }

    if (widget.enablePan) {
      _controller.pan(details.focalPointDelta);
      _clampPanToBounds();
    }

    if (widget.enableZoom && details.scale != 1.0) {
      final scaleDelta = details.scale / _lastGestureScale;
      _controller.zoomAt(scaleDelta, focalPoint: details.focalPoint);
      _lastGestureScale = details.scale;
      _clampPanToBounds();
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_draggingEntity) {
      _draggingEntity = false;
      _controller.pointerHandlers?.onPanEnd(DragEndDetails());
    }
  }

  /// Clamps pan in [GraphViewportCanvasMode.bounded] so the viewport never
  /// leaves the fixed canvas (the initial viewport size in scene units).
  ///
  /// The canvas projects to screen as `(0,0)..(canvasW,canvasH) * scale + pan`;
  /// the viewport `(0,0)..(viewW,viewH)` stays inside while:
  ///   pan.dx ∈ [viewW - canvasW*s,  0]
  ///   pan.dy ∈ [viewH - canvasH*s,  0]
  /// In [GraphViewportCanvasMode.infinite] there is no clamp — the scene is
  /// unbounded and pans freely (the transform is the only state).
  void _clampPanToBounds() {
    if (widget.canvasMode == GraphViewportCanvasMode.infinite) return;
    if (_viewportSize == Size.zero) return;

    // Bounded canvas is the initial viewport size, origin (0,0).
    final canvas = _viewportSize;
    final s = _controller.scale;
    final pan = _controller.panOffset;

    // When the scaled canvas is smaller than the viewport on an axis, min may
    // exceed max; pin the canvas top-left (no blank area, no jitter).
    var minTx = _viewportSize.width - canvas.width * s;
    var maxTx = 0.0;
    var minTy = _viewportSize.height - canvas.height * s;
    var maxTy = 0.0;
    if (minTx > maxTx) minTx = maxTx;
    if (minTy > maxTy) minTy = maxTy;

    final clampedTx = pan.dx.clamp(minTx, maxTx);
    final clampedTy = pan.dy.clamp(minTy, maxTy);

    if (clampedTx != pan.dx || clampedTy != pan.dy) {
      _controller.setPanOffset(Offset(clampedTx, clampedTy));
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = _ViewportClip(
      child: LayoutBuilder(
        builder: (context, constraints) {
          _viewportSize = constraints.biggest;
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                // The viewport transform (scale + pan) is the only state.  The
                // child lays out its nodes in scene (logical) space; nodes
                // outside the visible window are drawn via Clip.none and remain
                // interactive (see _ViewportClip).  No SizedBox(scene) resizing
                // or origin shift — scene coordinates never move.
                return Transform(
                  key: const ValueKey('GraphViewport_Transform'),
                  transform: _controller.value,
                  child: SizedBox(
                    width: _viewportSize.width,
                    height: _viewportSize.height,
                    child: GraphViewportScope(
                      controller: _controller,
                      child: widget.child,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );

    if (widget.debugShowBorder) {
      content = Stack(
        fit: StackFit.passthrough,
        children: [
          content,
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF2196F3), width: 3),
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      'Viewport',
                      style: TextStyle(
                        color: const Color(0xFF2196F3),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        background: Paint()..color = const Color(0x882196F3),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Pointer reception lives here, *outside* the Transform, so it spans the
    // whole viewport in screen space and is never clipped to the initial scene
    // rectangle.  Forwarded events reach the child GraphView's gesture manager
    // (via controller.pointerHandlers), which maps viewport-local positions to
    // scene space — keeping nodes panned outside the initial viewport
    // interactive.  No-op when no GraphView has attached.
    return Listener(
      onPointerDown: _forwardPointerDown,
      onPointerUp: _forwardPointerUp,
      onPointerMove: _forwardPointerMove,
      onPointerHover: _forwardPointerHover,
      behavior: HitTestBehavior.translucent,
      child: GestureDetector(
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        onScaleEnd: _onScaleEnd,
        behavior: HitTestBehavior.opaque,
        child: content,
      ),
    );
  }

  void _forwardPointerDown(PointerDownEvent event) {
    _controller.pointerHandlers?.onPointerDown(event);
  }

  void _forwardPointerUp(PointerUpEvent event) {
    _controller.pointerHandlers?.onPointerUp(event);
  }

  void _forwardPointerMove(PointerMoveEvent event) {
    _controller.pointerHandlers?.onPointerMove(event);
  }

  void _forwardPointerHover(PointerHoverEvent event) {
    _controller.pointerHandlers?.onPointerHover(event);
  }
}

/// Clips painting to the viewport bounds without clipping hit-testing.
///
/// Standard [ClipRect] clips both painting AND hit-testing, which prevents
/// pointer events from reaching nodes that have been panned outside the
/// visible area.  This widget clips only the canvas drawing so that nodes
/// outside the viewport are invisible but still interactive.
class _ViewportClip extends SingleChildRenderObjectWidget {
  const _ViewportClip({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderViewportClip();
}

class _RenderViewportClip extends RenderProxyBox {
  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.save();
    context.canvas.clipRect(offset & size);
    super.paint(context, offset);
    context.canvas.restore();
  }

  // Do NOT override hitTest — default RenderProxyBox passes through to
  // children regardless of visible bounds, allowing panned nodes to be tapped.
}
