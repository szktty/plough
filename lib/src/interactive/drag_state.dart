import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plough/src/graph/id.dart';
import 'package:plough/src/interactive/state_manager.dart';

part 'drag_state.freezed.dart';

/// Data object that holds the state of drag operations.
///
/// Tracks drag initiation information with [dragStartDetails] and [dragStartPosition],
/// and maintains drag updates with [dragUpdateDetails].
@freezed
class GraphDragData with _$GraphDragData {
  /// Creates drag state data with optional drag details and positions.
  const factory GraphDragData({
    DragStartDetails? dragStartDetails,
    Offset? dragStartPosition,
    DragUpdateDetails? dragUpdateDetails,
  }) = _GraphDragData;
}

/// グラフ要素のドラッグ操作の状態を管理します。
///
/// ドラッグ操作の開始、更新、終了を処理し、複数の要素の同時ドラッグをサポートします。
/// 以下の主要な機能を提供します：
///
/// * [handlePanStart], ドラッグ操作の開始を処理
/// * [handlePanUpdate], ドラッグ中の位置更新を処理
/// * [handlePanEnd], ドラッグ操作の終了を処理
/// * [handlePointerDown], タッチ/マウスの押下を処理
/// * [handlePointerMove], ポインターの移動を処理
///
/// 使用例：
/// ```dart
/// final manager = GraphNodeDragStateManager(gestureManager: myGestureManager);
/// manager.handlePointerDown(entityId, pointerEvent);
/// ```
abstract base class GraphDragStateManager
    extends GraphStateManager<GraphDragData> {
  GraphDragStateManager({
    required super.gestureManager,
  });

  late Offset? _lastPointerPosition;

  GraphId? lastDraggedEntityId;

  void handlePanStart(GraphId entityId, DragStartDetails details) {
    for (final targetId in targets) {
      final position = getPosition(entityId);
      if (position == null) {
        continue;
      }
      setState(
        targetId,
        GraphDragData(
          dragStartDetails: details,
          dragStartPosition: position,
        ),
      );
    }
  }

  void handlePanUpdate(GraphId entityId, DragUpdateDetails details) {
    onDragUpdate(targets.toList());
  }

  void handlePanEnd(GraphId entityId, DragEndDetails details) {
    final targetIds = targets;
    clearAllStates();
    lastDraggedEntityId = entityId;
    onDragEnd(targetIds);
  }

  void handlePointerDown(GraphId entityId, PointerDownEvent event) {
    // ドラッグ対象のエンティティを決定する
    final targetIds = [
      entityId,
      ...gestureManager.graph.nodes.where((e) => e.isSelected).map((e) => e.id),
    ];
    for (final targetId in targetIds) {
      setState(targetId, GraphDragData(dragStartPosition: event.position));
    }
    _lastPointerPosition = event.position;
  }

  void handlePointerMove(PointerMoveEvent event) {
    final targetIds = targets;
    if (targetIds.isEmpty) return;

    for (final entityId in targetIds) {
      final position = getPosition(entityId);
      if (position == null) {
        continue;
      }
      final newPosition = position + event.position - _lastPointerPosition!;
      _lastPointerPosition = event.position;
      setPosition(entityId, newPosition);
    }

    onDragMove(targetIds);
  }

  void handlePointerUp(GraphId entityId, PointerUpEvent event) {
    cancel(entityId);
  }

  void handlePointerCancel(GraphId entityId, PointerCancelEvent event) {
    cancel(entityId);
  }

  @override
  void cancel(GraphId entityId) {
    clearAllStates();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IntProperty('active drag states', activeCount))
      ..add(
        IterableProperty(
          'dragging entities',
          targets,
        ),
      );
  }
}

/// ノード要素のドラッグ状態を管理します。
///
/// ノード固有のドラッグ挙動を実装し、親クラスの機能を継承します。
base class GraphNodeDragStateManager extends GraphDragStateManager {
  /// Creates a drag state manager for node elements.
  GraphNodeDragStateManager({
    required super.gestureManager,
  });

  @override
  GraphEntityType get entityType => GraphEntityType.node;
}

/// リンク要素のドラッグ状態を管理します。
///
/// リンク固有のドラッグ挙動を実装し、親クラスの機能を継承します。
base class GraphLinkDragStateManager extends GraphDragStateManager {
  /// Creates a drag state manager for link elements.
  GraphLinkDragStateManager({
    required super.gestureManager,
  });

  @override
  GraphEntityType get entityType => GraphEntityType.link;
}
