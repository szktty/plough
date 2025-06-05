import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/interactive/gesture_manager.dart';

/// グラフのインタラクティブな操作を受け付けるオーバーレイウィジェットです。
///
/// マウス/タッチ操作を検出し、適切なジェスチャーマネージャーに転送します。
/// 主要な機能：
///
/// * マウスホバーの検出と処理
/// * タッチ/クリック操作の検出と処理
/// * ドラッグ操作の検出と処理
///
/// 使用例：
/// ```dart
/// GraphInteractiveOverlay(
///   graph: myGraph,
///   behavior: myBehavior,
///   viewportSize: Size(800, 600),
///   nodeTooltipTriggerMode: GraphTooltipTriggerMode.hover,
///   onTooltipShow: (entity) => print('ツールチップ表示: ${entity.id}'),
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

  @override
  State<GraphInteractiveOverlay> createState() =>
      _GraphInteractiveOverlayState();
}

class _GraphInteractiveOverlayState extends State<GraphInteractiveOverlay> {
  late final GraphGestureManager _gestureManager;

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
    );
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
        child: RawGestureDetector(
          gestures: _buildGestureRecognizers(),
          child: const SizedBox(child: ColoredBox(color: Colors.transparent)),
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
        _TransparentPanGestureRecognizer.new,
        (recognizer) {
          recognizer
            ..onStart = _handlePanStartConditional
            ..onUpdate = _handlePanUpdateConditional
            ..onEnd = _handlePanEndConditional;
        },
      );
    } else {
      // For other modes, use standard PanGestureRecognizer
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

  bool _shouldConsumeGestureAt(Offset position) {
    return _gestureManager.shouldConsumeGestureAt(position);
  }
}

/// Custom pan gesture recognizer that can selectively accept gestures.
class _CustomPanGestureRecognizer extends PanGestureRecognizer {
  _CustomPanGestureRecognizer({
    required this.shouldAcceptGesture,
  });

  final bool Function(Offset) shouldAcceptGesture;

  @override
  void addPointer(PointerDownEvent event) {
    // Only accept the gesture if shouldAcceptGesture returns true
    if (shouldAcceptGesture(event.localPosition)) {
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
    // Always accept the gesture but allow it to pass through
    super.addPointer(event);
  }
}
