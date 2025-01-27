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
    this.onTooltipShow,
    this.onTooltipHide,
    super.key,
  });

  final Graph graph;
  final GraphViewBehavior behavior;
  final Size viewportSize;
  final GraphTooltipTriggerMode? nodeTooltipTriggerMode;
  final GraphTooltipTriggerMode? linkTooltipTriggerMode;
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

  void _handlePanStart(DragStartDetails details) {
    _gestureManager.handlePanStart(details);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    _gestureManager.handlePanUpdate(details);
  }

  void _handlePanEnd(DragEndDetails details) {
    _gestureManager.handlePanEnd(details);
  }

  void _handleMouseHover(PointerHoverEvent event) {
    _gestureManager.handleMouseHover(event);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: _handleMouseHover,
      child: Listener(
        onPointerUp: _handlePointerUp,
        onPointerDown: _handlePointerDown,
        onPointerMove: _handlePointerMove,
        child: GestureDetector(
          onPanStart: _handlePanStart,
          onPanUpdate: _handlePanUpdate,
          onPanEnd: _handlePanEnd,
          child: const SizedBox(child: ColoredBox(color: Colors.transparent)),
        ),
      ),
    );
  }
}
