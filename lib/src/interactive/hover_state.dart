import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plough/src/graph/id.dart';
import 'package:plough/src/interactive/state_manager.dart';
import 'package:plough/src/utils/logger.dart';

part 'hover_state.freezed.dart';

/// Data object that holds the state of mouse hover interactions.
///
/// Tracks the last hover time with [lastHoverTime] and position with [lastHoverPosition].
@freezed
class GraphHoverData with _$GraphHoverData {
  /// Creates hover state data with optional time and position.
  const factory GraphHoverData({
    DateTime? lastHoverTime,
    Offset? lastHoverPosition,
  }) = _GraphHoverData;
}

/// グラフ要素のマウスホバーの状態を管理します。
///
/// マウスホバーの開始、終了、タイムアウトの処理を制御します。
/// 主要な機能：
///
/// * [handleMouseHover], マウスホバーイベントを処理
/// * [handleMouseExit], マウスホバーの終了を処理
///
/// 使用例：
/// ```dart
/// final manager = GraphNodeHoverStateManager(gestureManager: myGestureManager);
/// manager.handleMouseHover(entityId, hoverEvent);
/// ```
abstract base class GraphHoverStateManager
    extends GraphStateManager<GraphHoverData> {
  GraphHoverStateManager({
    required super.gestureManager,
    this.timeout = defaultTimeout,
  });

  static const defaultTimeout = Duration(milliseconds: 500);

  final Duration timeout;

  // 現在ホバー中のエンティティID
  GraphId? _currentHoveredId;

  // 次のフレームで処理予定のホバーID
  GraphId? _pendingHoverId;
  bool _hasPendingUpdate = false;

  void handlePointerDown(PointerDownEvent event) {
    if (_currentHoveredId != null) {
      cancel(_currentHoveredId!);
    }
  }

  void handleMouseHover(GraphId entityId, PointerHoverEvent event) {
    // 既にこのエンティティへの更新がペンディングの場合は処理しない
    if (_pendingHoverId == entityId) return;

    // 現在のホバー状態を更新
    final state = getState(entityId);
    if (state == null) return;
    setState(
      entityId,
      state.copyWith(
        lastHoverTime: DateTime.now(),
        lastHoverPosition: event.localPosition,
      ),
    );

    // 同じエンティティの場合は更新のみ
    if (_currentHoveredId == entityId) {
      onMouseHover(entityId);
      return;
    }

    // 新しいエンティティへのホバー遷移を次のフレームで処理
    _pendingHoverId = entityId;
    _hasPendingUpdate = true;

    SchedulerBinding.instance.scheduleFrame();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processPendingHover(event);
    });
  }

  void _processPendingHover(PointerHoverEvent event) {
    if (!_hasPendingUpdate || _pendingHoverId == null) return;

    final newEntityId = _pendingHoverId!;

    // 現在ホバー中のエンティティがある場合は終了処理
    if (_currentHoveredId != null) {
      _handleHoverEnd(_currentHoveredId!);
    }

    // 新しいエンティティのホバー開始
    _startHover(newEntityId, event);

    _currentHoveredId = newEntityId;
    _hasPendingUpdate = false;
    _pendingHoverId = null;
  }

  void handleMouseExit(PointerHoverEvent? event) {
    if (_currentHoveredId != null) {
      cancel(_currentHoveredId!);
    }
  }

  @override
  void cancel(GraphId entityId) {
    // 現在ホバー中のエンティティがある場合のみ処理
    if (_currentHoveredId != null) {
      _handleHoverEnd(_currentHoveredId!);
      _currentHoveredId = null;
    }

    // ペンディング状態をクリア
    _hasPendingUpdate = false;
    _pendingHoverId = null;
  }

  void _startHover(GraphId entityId, PointerHoverEvent event) {
    log.d('GraphHoverStateManager: hover start $entityId');
    setState(entityId, GraphHoverData(lastHoverTime: DateTime.now()));
    onMouseEnter(entityId);
  }

  void _handleHoverEnd(GraphId entityId) {
    log.d('GraphHoverStateManager: hover end $entityId');
    final state = getState(entityId);
    if (state == null) return;

    setState(
      entityId,
      state.copyWith(lastHoverTime: null, lastHoverPosition: null),
    );
    onMouseExit(entityId);
    onHoverEnd(entityId);
  }
}

/// ノード要素のホバー状態を管理します。
///
/// ノードに特化したホバー状態の制御を実装します。
base class GraphNodeHoverStateManager extends GraphHoverStateManager {
  /// Creates a hover state manager for node elements.
  GraphNodeHoverStateManager({
    required super.gestureManager,
    super.timeout,
  });

  @override
  GraphEntityType get entityType => GraphEntityType.node;
}

/// リンク要素のホバー状態を管理します。
///
/// リンクに特化したホバー状態の制御を実装します。
base class GraphLinkHoverStateManager extends GraphHoverStateManager {
  /// Creates a hover state manager for link elements.
  GraphLinkHoverStateManager({
    required super.gestureManager,
    super.timeout,
  });

  @override
  GraphEntityType get entityType => GraphEntityType.link;
}
