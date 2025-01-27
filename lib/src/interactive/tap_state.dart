import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/interactive/state_manager.dart';

part 'tap_state.freezed.dart';

@freezed
class GraphTapData with _$GraphTapData {
  /// Creates tap state data with initial selection state.
  const factory GraphTapData({
    required bool isSelectedOnStart,
  }) = _GraphTapData;
}

abstract base class GraphTapStateManager
    extends GraphStateManager<GraphTapData> {
  GraphTapStateManager({
    required super.gestureManager,
    this.timeout = defaultTimeout,
    this.tooltipTriggerMode,
  });

  static const defaultTimeout = Duration(milliseconds: 300);

  final Duration timeout;
  final GraphTooltipTriggerMode? tooltipTriggerMode;

  @override
  GraphEntityType get entityType => GraphEntityType.node;

  void handlePointerDown(GraphId entityId, PointerDownEvent event) {
    final entity = gestureManager.getEntity(entityId);
    if (entity == null) return;

    if (_tapCount == 0) {
      setState(entityId, GraphTapData(isSelectedOnStart: entity.isSelected));
    }
    _multipleTapTimer?.ignore();
    _multipleTapTimer = null;
    _lastTapUpTime = DateTime.now();

    if (tooltipTriggerMode == GraphTooltipTriggerMode.tap) {
      gestureManager.toggleTooltip(entityId);
    } else {
      gestureManager.hideTooltip(entityId);
    }
  }

  Future<Null>? _multipleTapTimer;
  int _tapCount = 0;
  DateTime? _lastTapUpTime;

  void handlePointerUp(GraphId entityId, PointerUpEvent event) {
    final entity = gestureManager.getEntity(entityId);
    final state = getState(entityId);
    if (entity == null || state == null) {
      cancel(entityId);
      return;
    }

    final currentTime = DateTime.now();
    if (_lastTapUpTime != null) {
      if (currentTime.difference(_lastTapUpTime!) < timeout) {
        _tapCount++;
      } else {
        _tapCount = 1;
      }
    } else {
      cancel(entityId);
      return;
    }
    _lastTapUpTime = currentTime;

    if (_tapCount == 1) {
      gestureManager.toggleSelection(entityId);
    }

    // 一定時間後にタップ数に変化がなければ確定
    _multipleTapTimer?.ignore();
    _multipleTapTimer = Future.delayed(timeout, () {
      final state = getState(entityId);
      if (state == null) return;

      if (_tapCount == 1) {
        onTap(targets);
      } else {
        onDoubleTap(targets);
      }
      cancel(entityId);
    });
  }

  void handlePointerCancel(GraphId entityId, PointerCancelEvent event) {
    cancel(entityId);
  }

  void handlePanUpdate(GraphId entityId, DragUpdateDetails details) {
    cancel(entityId);
  }

  @override
  void cancel(GraphId entityId) {
    _tapCount = 0;
    _lastTapUpTime = null;
    _multipleTapTimer?.ignore();
    _multipleTapTimer = null;
    clearAllStates();
  }
}

/// ノード要素のタップ状態を管理します。
///
/// ノード固有のタップ挙動を実装し、タップによる選択状態の切り替えを制御します。
base class GraphNodeTapStateManager extends GraphTapStateManager {
  /// Creates a tap state manager for node elements.
  GraphNodeTapStateManager({
    required super.gestureManager,
    super.timeout,
    super.tooltipTriggerMode,
  });

  @override
  GraphEntityType get entityType => GraphEntityType.node;
}

/// リンク要素のタップ状態を管理します。
///
/// リンク固有のタップ挙動を実装し、タップによる選択状態の切り替えを制御します。
base class GraphLinkTapStateManager extends GraphTapStateManager {
  /// Creates a tap state manager for link elements.
  GraphLinkTapStateManager({
    required super.gestureManager,
    super.timeout,
    super.tooltipTriggerMode,
  });

  @override
  GraphEntityType get entityType => GraphEntityType.link;
}
