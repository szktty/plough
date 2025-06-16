import 'dart:async';

import 'package:flutter/foundation.dart'; // Add this import
import 'package:flutter/gestures.dart';
// Remove unused import
// import 'package:flutter/widgets.dart';
// import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/interactive/state_manager.dart';
import 'package:plough/src/utils/logger.dart';

// Remove freezed part file
// part 'tap_state.freezed.dart';

// Remove freezed data class
/*
@freezed
class GraphTapData with _$GraphTapData {
  const factory GraphTapData({
    required bool isSelectedOnStart,
  }) = _GraphTapData;
}
*/

// Internal state for tap gesture recognition
class _TapState {
  _TapState({
    required this.entityId,
    required this.downPosition,
    required this.downTime,
  });

  final GraphId entityId;
  final Offset downPosition;
  final DateTime downTime; // Keep as final
  int tapCount = 1;
  bool cancelled = false;
  bool completed = false; // Flag set when a valid tap-up occurs
  Timer? doubleTapTimer; // Timer to detect if it's a single or double tap
}

/// Manages tap (single and double) detection for graph entities.
abstract base class GraphEntityTapStateManager<E extends GraphEntity>
    extends GraphStateManager<_TapState> {
  // Use _TapState
  GraphEntityTapStateManager({
    required super.gestureManager,
    required this.tooltipTriggerMode,
    // ダブルタップタイムアウトを大幅に短縮してドラッグ時の点滅を防ぐ
    this.doubleTapTimeout = const Duration(milliseconds: 100), // 300ms -> 100ms
    this.touchSlop = kTouchSlop *
        4, // Increase touch slop significantly for more forgiving taps
    this.doubleTapSlop = kDoubleTapSlop,
  });

  final GraphTooltipTriggerMode? tooltipTriggerMode;
  final Duration doubleTapTimeout;
  final double touchSlop;
  final double doubleTapSlop;

  // --- Public API ---

  /// ID of the entity currently being tracked for a potential tap.
  GraphId? get trackedEntityId => states.firstOrNull?.entityId;

  /// Checks if the tap sequence for the given entity has successfully completed.
  bool isTapCompleted(GraphId entityId) =>
      getState(entityId)?.completed ?? false;

  /// Gets the number of taps detected (1 or 2) if completed, otherwise null.
  int? getTapCount(GraphId entityId) => getState(entityId)?.tapCount;

  /// Cleans up the tap state for an entity after the gesture is fully resolved.
  void cleanupTapState(GraphId entityId) {
    // Timer completion or cancellation already removes the state.
    // This might be redundant if logic in handlePointerUp/cancel is correct.
    if (hasState(entityId) && getState(entityId)?.doubleTapTimer == null) {
      // Only remove if no timer is pending (i.e., it was a confirmed double tap or cancelled)
      // log.d('Cleaning up residual tap state for $entityId');
      // removeState(entityId);
    }
  }

  /// Cancels all ongoing tap recognitions.
  void cancelAll() {
    final statesToCancel = List.from(states);
    for (final state in statesToCancel) {
      final tapState = state as _TapState;
      cancel(tapState.entityId);
    }
  }

  // --- Gesture Handling Logic ---

  void handlePointerDown(GraphId entityId, PointerDownEvent event) {
    // Allow tap start even if !canSelect, selection check happens on up?
    // if (!canSelect(entityId)) return;

    final existingState = getState(entityId);
    final now = DateTime.now();

    // Check for double tap
    if (existingState != null &&
        !existingState.cancelled &&
        now.difference(existingState.downTime) < doubleTapTimeout &&
        _isWithinDoubleTapSlop(
          existingState.downPosition,
          event.localPosition,
        )) {
      existingState.doubleTapTimer?.cancel(); // Cancel the single tap timer
      existingState.tapCount = 2;
      existingState.completed =
          false; // Reset completion for the second tap down
      logDebug(LogCategory.tap, 'Potential double tap detected for $entityId');
    } else {
      // Start a new single tap recognition
      cancelAll(); // Cancel any previous tap attempts on *other* entities
      setState(
        entityId,
        _TapState(
          entityId: entityId,
          downPosition: event.localPosition,
          downTime: now,
        ),
      );
      logDebug(LogCategory.tap, 'Tap sequence started for $entityId');
    }
  }

  void handlePointerUp(GraphId entityId, PointerUpEvent event) {
    final state = getState(entityId);
    if (state == null || state.cancelled || state.completed) {
      return; // Ignore if cancelled or already completed
    }

    final isWithinSlop =
        _isWithinTapSlop(state.downPosition, event.localPosition);
    logDebug(
      LogCategory.tap,
      'handlePointerUp ($entityId): isWithinSlop = $isWithinSlop',
    );

    if (isWithinSlop) {
      logDebug(LogCategory.tap,
          'Tap up within slop for $entityId (Tap Count: ${state.tapCount})');
      state.completed = true; // Mark as completed
      logDebug(
        LogCategory.tap,
        'handlePointerUp ($entityId): state.completed set to true',
      );

      // Trigger tooltip if mode is tap
      if (tooltipTriggerMode == GraphTooltipTriggerMode.tap) {
        gestureManager.toggleTooltip(entityId);
      }

      // Start timer to confirm single tap or wait for double tap end
      if (state.tapCount == 1) {
        state.doubleTapTimer = Timer(doubleTapTimeout, () {
          // Timer expired, it was just a single tap.
          // Event dispatch happens in GraphGestureManager based on isTapCompleted and getTapCount.
          logDebug(
            LogCategory.tap,
            'Double tap timer expired for $entityId, confirming single tap.',
          );
          logDebug(
            LogCategory.tap,
            'Double tap timer expired for $entityId, removing state.',
          );

          // 静かに状態を削除して再描画を防ぐ
          removeStateSilently(entityId);
        });
        // Don't remove state immediately for single taps - let the timer handle it
      } else {
        // Double tap up detected.
        // Event dispatch happens in GraphGestureManager.
        logDebug(LogCategory.tap, 'Double tap confirmed for $entityId on up.');
        logDebug(
          LogCategory.tap,
          'Double tap confirmed for $entityId, removing state.',
        );
        // Don't remove state immediately - let GraphGestureManager check completion first
        // Schedule removal for next frame to allow gesture manager to process
        Timer(Duration.zero, () {
          removeStateSilently(entityId);
        });
      }
    } else {
      // Moved too far, cancel tap
      logDebug(LogCategory.tap, 'Tap cancelled for $entityId due to movement.');
      logDebug(
        LogCategory.tap,
        'handlePointerUp ($entityId): Cancelling due to movement beyond slop.',
      );
      cancel(entityId);
    }
  }

  /// Called when dragging starts or pointer moves too far during a tap sequence.
  void handlePanUpdate(GraphId entityId, DragUpdateDetails details) {
    final state = getState(entityId);
    // Cancel tap if pointer moves beyond slop while tap is active (not completed/cancelled)
    if (state != null &&
        !state.cancelled &&
        !state.completed &&
        !_isWithinTapSlop(state.downPosition, details.localPosition)) {
      logDebug(LogCategory.tap,
          'Tap cancelled for $entityId due to pan update movement.');
      logDebug(
        LogCategory.tap,
        'handlePanUpdate ($entityId): Cancelling due to movement beyond slop during pan.',
      );
      cancel(entityId);
    }
  }

  void handlePointerCancel(GraphId entityId, PointerCancelEvent event) {
    logDebug(
      LogCategory.tap,
      'handlePointerCancel ($entityId): Cancelling due to pointer cancel event.',
    );
    cancel(entityId);
  }

  /// Cancels the tap recognition for a specific entity.
  @override
  void cancel(GraphId entityId) {
    final state = getState(entityId);
    if (state != null && !state.cancelled) {
      logDebug(LogCategory.tap, 'Cancelling tap state for $entityId');
      logDebug(
        LogCategory.tap,
        'cancel ($entityId): Setting cancelled=true, removing state.',
      );
      state.cancelled = true;

      // タイマーをキャンセルして、不要な状態変更通知を防ぐ
      if (state.doubleTapTimer != null) {
        state.doubleTapTimer!.cancel();
        state.doubleTapTimer = null;
      }

      // 状態を静かに削除して、再描画を防ぐ
      removeStateSilently(entityId);
      // Hide tooltip if it was shown by a tap that got cancelled
      if (tooltipTriggerMode == GraphTooltipTriggerMode.tap &&
          state.completed) {
        // This condition seems unlikely if cancelled before completed? Check logic.
        // Maybe check if tooltip *is* showing for this ID instead?
        // Consider adding: gestureManager.isTooltipVisible(entityId) ?
        gestureManager.hideTooltip(entityId);
      }
    }
  }

  bool _isWithinTapSlop(Offset p1, Offset p2) {
    final distanceSquared = (p1 - p2).distanceSquared;
    final result = distanceSquared < touchSlop * touchSlop;
    logDebug(
      LogCategory.tap,
      '_isWithinTapSlop: distanceSquared=$distanceSquared, touchSlopSquared=${touchSlop * touchSlop}, result=$result',
    );
    return result;
  }

  bool _isWithinDoubleTapSlop(Offset p1, Offset p2) {
    return (p1 - p2).distanceSquared < doubleTapSlop * doubleTapSlop;
  }
}

final class GraphNodeTapStateManager
    extends GraphEntityTapStateManager<GraphNode> {
  GraphNodeTapStateManager({
    required super.gestureManager,
    required super.tooltipTriggerMode,
    super.doubleTapTimeout,
    super.touchSlop,
    super.doubleTapSlop,
  });

  @override
  GraphEntityType get entityType => GraphEntityType.node;
}

final class GraphLinkTapStateManager
    extends GraphEntityTapStateManager<GraphLink> {
  GraphLinkTapStateManager({
    required super.gestureManager,
    required super.tooltipTriggerMode,
    super.doubleTapTimeout,
    super.touchSlop,
    super.doubleTapSlop,
  });

  @override
  GraphEntityType get entityType => GraphEntityType.link;
}
