import 'package:flutter/gestures.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/interactive/state_manager.dart';

/// Pan Ready状態を管理するクラス
/// pan startが発生したが、まだ実際のドラッグは開始されていない中間状態
class _PanReadyState {
  _PanReadyState({
    required this.entityId,
    required this.startPosition,
    required this.startTime,
    required this.startDetails,
  });

  final GraphId entityId;
  final Offset startPosition;
  final DateTime startTime;
  final DragStartDetails startDetails;
  
  bool dragStarted = false;
  bool cancelled = false;
}

/// Pan Ready状態を管理するベースクラス
abstract base class GraphEntityPanReadyStateManager<E extends GraphEntity>
    extends GraphStateManager<_PanReadyState> {
  GraphEntityPanReadyStateManager({
    required super.gestureManager,
    this.dragStartThreshold = 8.0, // ドラッグ開始とみなす移動距離の閾値
    this.maxReadyDuration = const Duration(milliseconds: 200), // Ready状態の最大持続時間
  });

  final double dragStartThreshold;
  final Duration maxReadyDuration;

  /// Pan Ready状態のエンティティリスト
  List<GraphId> get readyEntityIds => 
      states.where((state) => !state.dragStarted && !state.cancelled)
          .map((state) => state.entityId)
          .toList();

  /// エンティティがPan Ready状態かどうか
  bool isPanReady(GraphId entityId) {
    final state = getState(entityId);
    return state != null && !state.dragStarted && !state.cancelled;
  }

  /// Pan開始を処理（Ready状態にする）
  void handlePanStart(GraphId entityId, DragStartDetails details) {
    logGestureDebug(
      GestureDebugEventType.stateCreate,
      'PanReadyStateManager',
      'PAN_READY_STATE_CREATED',
      data: {
        'entityId': entityId.value.substring(0, 8),
        'position': {'x': details.localPosition.dx, 'y': details.localPosition.dy},
        'threshold': dragStartThreshold,
        'maxDuration': maxReadyDuration.inMilliseconds,
      },
    );

    final state = _PanReadyState(
      entityId: entityId,
      startPosition: details.localPosition,
      startTime: DateTime.now(),
      startDetails: details,
    );

    setState(entityId, state);
    
    // 最大持続時間後に自動キャンセル
    Future.delayed(maxReadyDuration, () {
      _timeoutPanReady(entityId);
    });
  }

  /// Pan更新を処理（閾値を超えた場合にドラッグ開始）
  void handlePanUpdate(GraphId entityId, DragUpdateDetails details) {
    final state = getState(entityId);
    if (state == null || state.dragStarted || state.cancelled) {
      return;
    }

    final distance = (details.localPosition - state.startPosition).distance;
    
    logGestureDebug(
      GestureDebugEventType.conditionCheck,
      'PanReadyStateManager',
      'PAN_UPDATE_DISTANCE_CHECK',
      data: {
        'entityId': entityId.value.substring(0, 8),
        'distance': distance,
        'threshold': dragStartThreshold,
        'exceeds_threshold': distance >= dragStartThreshold,
        'start_position': {
          'x': state.startPosition.dx, 
          'y': state.startPosition.dy
        },
        'current_position': {
          'x': details.localPosition.dx, 
          'y': details.localPosition.dy
        },
      },
    );

    if (distance >= dragStartThreshold) {
      // 閾値を超えたため、実際のドラッグ開始
      _startActualDrag(entityId, state, details);
    }
  }

  /// 実際のドラッグを開始
  void _startActualDrag(GraphId entityId, _PanReadyState readyState, DragUpdateDetails updateDetails) {
    readyState.dragStarted = true;
    
    logGestureDebug(
      GestureDebugEventType.dragStart,
      'PanReadyStateManager',
      'ACTUAL_DRAG_STARTED',
      data: {
        'entityId': entityId.value.substring(0, 8),
        'ready_duration_ms': DateTime.now().difference(readyState.startTime).inMilliseconds,
        'trigger_distance': (updateDetails.localPosition - readyState.startPosition).distance,
        'threshold': dragStartThreshold,
      },
    );

    // 適切なドラッグマネージャーに委譲
    _delegateActualDragStart(entityId, readyState.startDetails, updateDetails);
    
    // Ready状態をクリーンアップ
    removeStateSilently(entityId);
  }

  /// Ready状態のタイムアウト処理
  void _timeoutPanReady(GraphId entityId) {
    final state = getState(entityId);
    if (state != null && !state.dragStarted && !state.cancelled) {
      logGestureDebug(
        GestureDebugEventType.timerExpire,
        'PanReadyStateManager',
        'PAN_READY_TIMEOUT',
        data: {
          'entityId': entityId.value.substring(0, 8),
          'duration_ms': maxReadyDuration.inMilliseconds,
        },
      );
      
      // タイムアウトしたのでReady状態を解除
      // タップとして扱われる可能性を残す
      removeStateSilently(entityId);
    }
  }

  /// Ready状態をキャンセル
  void cancelPanReady(GraphId entityId) {
    final state = getState(entityId);
    if (state != null && !state.dragStarted) {
      state.cancelled = true;
      
      logGestureDebug(
        GestureDebugEventType.stateDestroy,
        'PanReadyStateManager',
        'PAN_READY_CANCELLED',
        data: {
          'entityId': entityId.value.substring(0, 8),
          'reason': 'manual_cancellation',
        },
      );
      
      removeStateSilently(entityId);
    }
  }

  /// すべてのReady状態をキャンセル
  void cancelAllPanReady() {
    final activeStates = List<_PanReadyState>.from(states);
    for (final state in activeStates) {
      if (!state.dragStarted) {
        cancelPanReady(state.entityId);
      }
    }
  }

  /// 実際のドラッグ開始を適切なマネージャーに委譲（サブクラスで実装）
  void _delegateActualDragStart(GraphId entityId, DragStartDetails startDetails, DragUpdateDetails updateDetails);

  @override
  void cancel(GraphId entityId) {
    cancelPanReady(entityId);
  }
}

/// ノード用のPan Ready状態マネージャー
final class GraphNodePanReadyStateManager 
    extends GraphEntityPanReadyStateManager<GraphNode> {
  GraphNodePanReadyStateManager({
    required super.gestureManager,
    super.dragStartThreshold,
    super.maxReadyDuration,
  });

  @override
  GraphEntityType get entityType => GraphEntityType.node;

  @override
  void _delegateActualDragStart(GraphId entityId, DragStartDetails startDetails, DragUpdateDetails updateDetails) {
    // ノードドラッグマネージャーに委譲
    gestureManager.nodeDragManager.handlePanStart([entityId], startDetails);
    gestureManager.nodeDragManager.handlePanUpdate(updateDetails);
    
    // タップ状態をキャンセル（ドラッグが確定したため）
    gestureManager.nodeTapManager.cancel(entityId);
  }
}

/// リンク用のPan Ready状態マネージャー
final class GraphLinkPanReadyStateManager 
    extends GraphEntityPanReadyStateManager<GraphLink> {
  GraphLinkPanReadyStateManager({
    required super.gestureManager,
    super.dragStartThreshold,
    super.maxReadyDuration,
  });

  @override
  GraphEntityType get entityType => GraphEntityType.link;

  @override
  void _delegateActualDragStart(GraphId entityId, DragStartDetails startDetails, DragUpdateDetails updateDetails) {
    // リンクドラッグマネージャーに委譲
    gestureManager.linkDragManager.handlePanStart([entityId], startDetails);
    gestureManager.linkDragManager.handlePanUpdate(updateDetails);
    
    // タップ状態をキャンセル（ドラッグが確定したため）
    gestureManager.linkTapManager.cancel(entityId);
  }
}
