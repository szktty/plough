import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plough/src/graph/id.dart';
import 'package:plough/src/interactive/state_manager.dart';
import 'package:plough/src/tooltip/behavior.dart';

part 'tooltip_state.freezed.dart';

/// Data object that holds the state of tooltip visibility.
///
/// Tracks time of show requests with [showRequestTime] and
/// time of hide requests with [hideRequestTime].
@freezed
class GraphTooltipData with _$GraphTooltipData {
  /// Creates tooltip state data with optional show/hide request times.
  const factory GraphTooltipData({
    DateTime? showRequestTime,
    DateTime? hideRequestTime,
  }) = _GraphTooltipData;
}

/// グラフ要素のツールチップ表示状態を管理します。
///
/// ツールチップの表示/非表示、遷移のタイミングを制御します。
/// 主要な機能：
///
/// * [handleMouseHover], マウスホバーによる表示を処理
/// * [handleMouseExit], マウスホバーの終了を処理
/// * [show], ツールチップを表示
/// * [toggle], ツールチップの表示/非表示を切り替え
///
/// 使用例：
/// ```dart
/// final manager = GraphNodeTooltipStateManager(
///   gestureManager: myGestureManager,
///   triggerMode: GraphTooltipTriggerMode.hover,
/// );
/// ```
abstract base class GraphTooltipStateManager
    extends GraphStateManager<GraphTooltipData> {
  GraphTooltipStateManager({
    required super.gestureManager,
    this.triggerMode,
    // TODO: Should be configurable in GraphView
    this.showDelay = const Duration(milliseconds: 500),
    this.hideDelay = const Duration(milliseconds: 200),
  });

  final Duration showDelay;
  final Duration hideDelay;

  final GraphTooltipTriggerMode? triggerMode;

  bool get isShowing => _currentShowId != null;

  GraphId? _currentShowId;
  GraphId? _pendingShowId;

  bool get _hasPendingShow => _pendingShowId != null;

  Offset? _lastPointerPosition;

  void handleMouseHover(GraphId entityId, PointerHoverEvent event) {
    if (gestureManager.isDragging ||
        gestureManager.lastDraggedEntityId == entityId ||
        getState(entityId) != null ||
        triggerMode != GraphTooltipTriggerMode.hover ||
        (_hasPendingShow && _pendingShowId == entityId)) {
      return;
    }

    _lastPointerPosition = event.localPosition;
    final state = GraphTooltipData(showRequestTime: DateTime.now());
    setState(entityId, state);

    _pendingShowId = entityId;

    SchedulerBinding.instance.scheduleFrame();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processPendingShow(entityId);
    });
  }

  void _processPendingShow(GraphId entityId) {
    if (!_hasPendingShow || _pendingShowId != entityId) return;

    final state = getState(entityId);
    if (state == null) return;

    final now = DateTime.now();
    final requestTime = state.showRequestTime;
    if (requestTime == null) return;

    final elapsed = now.difference(requestTime);
    if (elapsed < showDelay) {
      // まだ表示までの時間が経過していない場合は再スケジュール
      SchedulerBinding.instance.scheduleFrame();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _processPendingShow(entityId);
      });
      return;
    }

    // ホバー開始時のエンティティと現在のポインター位置にあるエンティティが異なる場合
    if (_lastPointerPosition != null) {
      final current = gestureManager.findNodeAt(_lastPointerPosition!) ??
          gestureManager.findLinkAt(_lastPointerPosition!);
      if (current?.id != entityId) {
        _clearPendingShow();
        return;
      }
    }

    show(entityId);
  }

  void show(GraphId entityId) {
    final state = getState(entityId);
    if (state == null) return;

    setState(
      entityId,
      state.copyWith(showRequestTime: null, hideRequestTime: null),
    );
    onTooltipShow(entityId);

    _currentShowId = entityId;
    _clearPendingShow();
  }

  void _clearPendingShow() {
    _pendingShowId = null;
  }

  void handleMouseExit(PointerHoverEvent event) {
    _lastPointerPosition = event.localPosition;
    if (_currentShowId == null) return;

    final entityId = _currentShowId!;
    final state = getState(entityId);
    if (state == null) return;

    setState(
      entityId,
      state.copyWith(
        hideRequestTime: DateTime.now(),
      ),
    );

    SchedulerBinding.instance.scheduleFrame();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processHide(entityId);
    });
  }

  void _processHide(GraphId entityId) {
    final state = getState(entityId);
    if (state == null) return;

    final now = DateTime.now();
    final requestTime = state.hideRequestTime;
    if (requestTime == null) return;

    final elapsed = now.difference(requestTime);
    if (elapsed < hideDelay) {
      // まだ非表示までの時間が経過していない場合は再スケジュール
      SchedulerBinding.instance.scheduleFrame();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _processHide(entityId);
      });
      return;
    }

    cancel(entityId);
  }

  void handleTap(GraphId entityId) {
    switch (triggerMode) {
      case GraphTooltipTriggerMode.hover:
        removeState(entityId);
      case GraphTooltipTriggerMode.tap:
        toggle(entityId);
      default:
    }
  }

  void toggle(GraphId entityId) {
    final state = getState(entityId);
    if (state == null) {
      setState(entityId, const GraphTooltipData());
      onTooltipShow(entityId);
    } else {
      cancel(entityId);
    }
  }

  @override
  void cancel(GraphId entityId) {
    _currentShowId = null;
    _clearPendingShow();
    clearAllStates();
    onTooltipHide(entityId);
  }
}

/// ノード要素のツールチップ状態を管理します。
///
/// ノード固有のツールチップの表示動作を制御します。
base class GraphNodeTooltipStateManager extends GraphTooltipStateManager {
  /// Creates a tooltip state manager for node elements.
  GraphNodeTooltipStateManager({
    required super.gestureManager,
    super.triggerMode,
    super.showDelay,
    super.hideDelay,
  });

  @override
  GraphEntityType get entityType => GraphEntityType.node;
}

/// リンク要素のツールチップ状態を管理します。
///
/// リンク固有のツールチップの表示動作を制御します。
base class GraphLinkTooltipStateManager extends GraphTooltipStateManager {
  /// Creates a tooltip state manager for link elements.
  GraphLinkTooltipStateManager({
    required super.gestureManager,
    super.triggerMode,
    super.showDelay,
    super.hideDelay,
  });

  @override
  GraphEntityType get entityType => GraphEntityType.link;
}
