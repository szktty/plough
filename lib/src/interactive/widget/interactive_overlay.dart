import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/graph/graph_base.dart';
import 'package:plough/src/interactive/gesture_manager.dart';
import 'package:plough/src/viewport/controller.dart';
import 'package:plough/src/viewport/widget/viewport_scope.dart';

/// Overlay widget that handles interactive operations for the graph.
///
/// Detects mouse/touch operations and forwards them to the appropriate gesture manager.
/// Main features:
///
/// * Mouse hover detection and processing
/// * Touch/click operation detection and processing
/// * Drag operation detection and processing
///
/// Usage example:
/// ```dart
/// GraphInteractiveOverlay(
///   graph: myGraph,
///   behavior: myBehavior,
///   viewportSize: Size(800, 600),
///   nodeTooltipTriggerMode: GraphTooltipTriggerMode.hover,
///   onTooltipShow: (entity) => print('Tooltip show: ${entity.id}'),
/// )
/// ```
class GraphInteractiveOverlay extends StatefulWidget {
  const GraphInteractiveOverlay({
    required this.graph,
    required this.behavior,
    required this.viewportSize,
    this.nodeTooltipTriggerMode,
    this.linkTooltipTriggerMode,
    this.gestureMode = GraphGestureMode.exclusive,
    this.shouldConsumeGesture,
    this.onBackgroundTapped,
    this.onBackgroundPanStart,
    this.onBackgroundPanUpdate,
    this.onBackgroundPanEnd,
    this.onTooltipShow,
    this.onTooltipHide,
    this.dragDeltaTransform,
    this.globalToScene,
    this.onNodeDragStart,
    this.onNodeDragEnd,
    super.key,
  });

  final Graph graph;
  final GraphViewBehavior behavior;
  final Size viewportSize;
  final GraphTooltipTriggerMode? nodeTooltipTriggerMode;
  final GraphTooltipTriggerMode? linkTooltipTriggerMode;
  final GraphGestureMode gestureMode;
  final GraphGestureConsumptionCallback? shouldConsumeGesture;
  final GraphBackgroundGestureCallback? onBackgroundTapped;
  final GraphBackgroundGestureCallback? onBackgroundPanStart;
  final GraphBackgroundPanCallback? onBackgroundPanUpdate;
  final GraphBackgroundGestureCallback? onBackgroundPanEnd;
  final void Function(GraphEntity)? onTooltipShow;
  final void Function(GraphEntity)? onTooltipHide;
  final Offset Function(Offset delta)? dragDeltaTransform;
  final Offset Function(Offset globalPosition)? globalToScene;
  final void Function(GraphId nodeId)? onNodeDragStart;
  final void Function(GraphId nodeId)? onNodeDragEnd;

  @override
  State<GraphInteractiveOverlay> createState() =>
      _GraphInteractiveOverlayState();
}

class _GraphInteractiveOverlayState extends State<GraphInteractiveOverlay> {
  late final GraphGestureManager _gestureManager;

  /// The enclosing viewport's controller, if any.  When present, the viewport
  /// owns pointer reception (it sits outside the Transform, free of the box-size
  /// limit that clips off-screen nodes) and drives our gesture manager via the
  /// handlers we publish; this overlay then stops receiving pointers itself to
  /// avoid double handling.  Null when the GraphView is used standalone.
  GraphViewportController? _viewportController;

  bool get _drivenByViewport => _viewportController != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = GraphViewportScope.maybeOf(context);
    if (controller != _viewportController) {
      _viewportController?.pointerHandlers = null;
      _viewportController = controller;
      _viewportController?.pointerHandlers = GraphViewportPointerHandlers(
        onPointerDown: _handlePointerDown,
        onPointerUp: _handlePointerUp,
        onPointerMove: _handlePointerMove,
        onPointerHover: _handleMouseHover,
        onPanStart: _handlePanStartConditional,
        onPanUpdate: _handlePanUpdateConditional,
        onPanEnd: _handlePanEndConditional,
        hitTestsEntityAt: _shouldConsumeGestureAt,
      );
      // Forwarded events carry viewport-local positions; convert them to scene
      // space through the controller's inverse transform.
      _gestureManager.screenToScene = controller?.screenToScene;
    }
  }

  void _onLayoutChange() {
    // Rebuild spatial index after layout or node movement settles.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _gestureManager.rebuildSpatialIndex();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _gestureManager = GraphGestureManager(
      graph: widget.graph,
      viewBehavior: widget.behavior,
      viewportSize: widget.viewportSize,
      nodeTooltipTriggerMode: widget.nodeTooltipTriggerMode,
      linkTooltipTriggerMode: widget.linkTooltipTriggerMode,
      gestureMode: widget.gestureMode,
      shouldConsumeGesture: widget.shouldConsumeGesture,
      onBackgroundTapped: widget.onBackgroundTapped,
      onBackgroundPanStart: widget.onBackgroundPanStart,
      onBackgroundPanUpdate: widget.onBackgroundPanUpdate,
      onBackgroundPanEnd: widget.onBackgroundPanEnd,
      onTooltipShow: widget.onTooltipShow,
      onTooltipHide: widget.onTooltipHide,
      dragDeltaTransform: widget.dragDeltaTransform,
      globalToScene: widget.globalToScene,
      onNodeDragStart: widget.onNodeDragStart,
      onNodeDragEnd: widget.onNodeDragEnd,
    );
    (widget.graph as GraphImpl)
        .layoutChangeListenable
        .addListener(_onLayoutChange);
  }

  @override
  void didUpdateWidget(GraphInteractiveOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _gestureManager.globalToScene = widget.globalToScene;
    _gestureManager.dragDeltaTransform = widget.dragDeltaTransform;
    _gestureManager.onNodeDragStart = widget.onNodeDragStart;
    _gestureManager.onNodeDragEnd = widget.onNodeDragEnd;
  }

  @override
  void dispose() {
    _viewportController?.pointerHandlers = null;
    (widget.graph as GraphImpl)
        .layoutChangeListenable
        .removeListener(_onLayoutChange);
    super.dispose();
  }

  void _handlePointerUp(PointerUpEvent event) {
    _gestureManager.handlePointerUp(event);
  }

  void _handlePointerDown(PointerDownEvent event) {
    _gestureManager.handlePointerDown(event);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    _gestureManager.handlePointerMove(event);
  }

  void _handleMouseHover(PointerHoverEvent event) {
    _gestureManager.handleMouseHover(event);
  }

  @override
  Widget build(BuildContext context) {
    // When driven by a viewport, the viewport (outside the Transform) owns all
    // pointer and pan reception and calls our handlers via
    // controller.pointerHandlers.  We attach nothing here — our own
    // Listener/RawGestureDetector would be clipped to the initial viewport box
    // and could not reach off-screen nodes.
    if (_drivenByViewport) {
      return const SizedBox.expand();
    }

    // In transparent mode, allow all interactions but with translucent behavior
    if (widget.gestureMode == GraphGestureMode.transparent) {
      return MouseRegion(
        onHover: _handleMouseHover,
        child: Listener(
          onPointerUp: _handlePointerUp,
          onPointerDown: _handlePointerDown,
          onPointerMove: _handlePointerMove,
          behavior: HitTestBehavior.translucent,
          child: RawGestureDetector(
            gestures: _buildGestureRecognizers(),
            behavior: HitTestBehavior.translucent,
            child: const SizedBox(child: ColoredBox(color: Colors.transparent)),
          ),
        ),
      );
    }

    // For other modes, use RawGestureDetector for more control
    return MouseRegion(
      onHover: _handleMouseHover,
      child: Listener(
        onPointerUp: _handlePointerUp,
        onPointerDown: _handlePointerDown,
        onPointerMove: _handlePointerMove,
        // translucent: receive pointer events across the full overlay area
        // while still allowing events to reach widgets below when not consumed.
        behavior: HitTestBehavior.translucent,
        child: RawGestureDetector(
          gestures: _buildGestureRecognizers(),
          behavior: HitTestBehavior.translucent,
          child: const SizedBox.expand(),
        ),
      ),
    );
  }

  Map<Type, GestureRecognizerFactory> _buildGestureRecognizers() {
    // Build gesture recognizers based on gesture mode
    final recognizers = <Type, GestureRecognizerFactory>{};

    // For custom mode, we need a special gesture recognizer
    if (widget.gestureMode == GraphGestureMode.custom) {
      recognizers[_CustomPanGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<_CustomPanGestureRecognizer>(
        () => _CustomPanGestureRecognizer(
          shouldAcceptGesture: _shouldConsumeGestureAt,
        ),
        (recognizer) {
          recognizer
            ..onStart = _handlePanStartConditional
            ..onUpdate = _handlePanUpdateConditional
            ..onEnd = _handlePanEndConditional;
        },
      );
    } else if (widget.gestureMode == GraphGestureMode.transparent) {
      // For transparent mode, use custom recognizer that allows pass-through
      recognizers[_TransparentPanGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<
                  _TransparentPanGestureRecognizer>(
              _TransparentPanGestureRecognizer.new, (recognizer) {
        recognizer
          ..onStart = _handlePanStartConditional
          ..onUpdate = _handlePanUpdateConditional
          ..onEnd = _handlePanEndConditional;
      });
    } else if (widget.gestureMode == GraphGestureMode.nodeEdgeOnly &&
        widget.onBackgroundPanStart == null &&
        widget.onBackgroundPanUpdate == null &&
        widget.onBackgroundPanEnd == null) {
      // In nodeEdgeOnly mode without background pan callbacks, only accept
      // gestures on entities so that background drags fall through to a parent
      // viewport widget (e.g. GraphViewport).
      recognizers[_CustomPanGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<_CustomPanGestureRecognizer>(
        () => _CustomPanGestureRecognizer(
          shouldAcceptGesture: _shouldConsumeGestureAt,
        ),
        (recognizer) {
          recognizer
            ..onStart = _handlePanStartConditional
            ..onUpdate = _handlePanUpdateConditional
            ..onEnd = _handlePanEndConditional;
        },
      );
    } else {
      // For exclusive mode, use standard PanGestureRecognizer.
      recognizers[PanGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(
        PanGestureRecognizer.new,
        (recognizer) {
          recognizer
            ..onStart = _handlePanStartConditional
            ..onUpdate = _handlePanUpdateConditional
            ..onEnd = _handlePanEndConditional;
        },
      );
    }

    return recognizers;
  }

  void _handlePanStartConditional(DragStartDetails details) {
    // Always delegate to gesture manager for proper handling
    _gestureManager.handlePanStart(details);
  }

  void _handlePanUpdateConditional(DragUpdateDetails details) {
    // Always delegate to gesture manager for proper handling
    _gestureManager.handlePanUpdate(details);
  }

  void _handlePanEndConditional(DragEndDetails details) {
    _gestureManager.handlePanEnd(details);
  }

  bool _shouldConsumeGestureAt(Offset localPosition, [Offset? globalPosition]) {
    final scenePos = _gestureManager.toScene(
      localPosition,
      globalPosition ?? localPosition,
    );
    return _gestureManager.shouldConsumeGestureAt(scenePos);
  }
}

/// Custom pan gesture recognizer that can selectively accept gestures.
class _CustomPanGestureRecognizer extends PanGestureRecognizer {
  _CustomPanGestureRecognizer({required this.shouldAcceptGesture});

  final bool Function(Offset localPosition, Offset globalPosition)
      shouldAcceptGesture;

  @override
  void addPointer(PointerDownEvent event) {
    // Only accept the gesture if shouldAcceptGesture returns true
    if (shouldAcceptGesture(event.localPosition, event.position)) {
      super.addPointer(event);
    } else {
      // Reject this pointer to let it pass through
      stopTrackingPointer(event.pointer);
    }
  }
}

/// Transparent pan gesture recognizer that allows pass-through.
class _TransparentPanGestureRecognizer extends PanGestureRecognizer {
  @override
  void addPointer(PointerDownEvent event) {
    // In transparent mode, we want to reject all gestures so they pass through
    // to the underlying InteractiveViewer
    // Don't start tracking - just ignore the pointer completely
  }
}
