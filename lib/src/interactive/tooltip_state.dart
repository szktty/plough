import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/interactive/state_manager.dart';
import 'package:plough/src/utils/logger.dart';

// Internal state for tooltip
class _TooltipState {
  _TooltipState(this.entityId);
  final GraphId entityId;
  Timer? showTimer;
  Timer? hideTimer;
  bool isVisible = false;
}

/// Manages tooltip display state for graph elements.
///
/// Controls tooltip show/hide and transition timing.
/// Main features:
///
/// * [handleMouseHover], processes display by mouse hover
/// * [handleMouseExit], processes end of mouse hover
/// * [show], displays tooltip
/// * [toggle], toggles tooltip show/hide
///
/// Usage example:
/// ```dart
/// final manager = GraphNodeTooltipStateManager(
///   gestureManager: myGestureManager,
///   triggerMode: GraphTooltipTriggerMode.hover,
/// );
/// ```
@internal
abstract base class GraphEntityTooltipStateManager<E extends GraphEntity>
    extends GraphStateManager<_TooltipState> {
  GraphEntityTooltipStateManager({
    required super.gestureManager,
    this.triggerMode,
    this.showDelay = const Duration(milliseconds: 500),
    this.hideDelay = const Duration(milliseconds: 200),
  });

  final GraphTooltipTriggerMode? triggerMode;
  final Duration showDelay;
  final Duration hideDelay;

  bool get isShowing => _currentShowId != null;

  GraphId? _currentShowId;
  GraphId? _pendingShowId;

  bool get _hasPendingShow => _pendingShowId != null;

  Offset? _lastPointerPosition;

  // --- Public API ---
  bool isTooltipVisible(GraphId entityId) =>
      getState(entityId)?.isVisible ?? false;

  void cancelAll() {
    final statesToCancel = List.from(states);
    for (final state in statesToCancel) {
      final tooltipState = state as _TooltipState;
      cancel(tooltipState.entityId);
    }
  }

  // --- Internal Logic & Handlers ---

  void show(GraphId entityId) {
    if (triggerMode == null) return;
    final state = getState(entityId) ?? _createState(entityId);
    state.hideTimer?.cancel();
    if (!state.isVisible && state.showTimer == null) {
      if (showDelay == Duration.zero) {
        _showNow(entityId, state);
      } else {
        state.showTimer = Timer(showDelay, () => _showNow(entityId, state));
      }
    }
  }

  void _showNow(GraphId entityId, _TooltipState state) {
    state.showTimer = null;
    if (!state.isVisible) {
      state.isVisible = true;
      final details = gestureManager.lastPointerDetails ??
          PointerEventDetails.fromLastKnownPosition(
            Offset.zero,
            Offset.zero,
            PointerDeviceKind.unknown,
          );
      final currentTriggerMode = triggerMode ?? GraphTooltipTriggerMode.hover;
      gestureManager.viewBehavior.onTooltipShow(
        GraphTooltipShowEvent(
          entityId: entityId,
          details: details,
          triggerMode: currentTriggerMode,
        ),
      );
      logDebug(LogCategory.gesture, 'Tooltip shown for $entityId');
    }
  }

  @override
  void cancel(GraphId entityId) {
    final state = getState(entityId);
    if (state != null) {
      state.showTimer?.cancel();
      state.showTimer = null;
      state.hideTimer?.cancel();
      state.hideTimer = null;
      if (state.isVisible) {
        state.isVisible = false;
        final details = gestureManager.lastPointerDetails;
        gestureManager.viewBehavior.onTooltipHide(
          GraphTooltipHideEvent(entityId: entityId, details: details),
        );
        logDebug(LogCategory.gesture, 'Tooltip hidden for $entityId');
      }
      removeState(entityId);
    }
  }

  void handleMouseHover(GraphId entityId, PointerHoverEvent event) {
    if (triggerMode == GraphTooltipTriggerMode.hover ||
        triggerMode == GraphTooltipTriggerMode.hoverStay) {
      show(entityId);
    }
  }

  void handleMouseExit(GraphId entityId, PointerHoverEvent event) {
    final state = getState(entityId);
    if (state != null) {
      state.showTimer?.cancel();
      state.showTimer = null;
      if (state.isVisible &&
          triggerMode != GraphTooltipTriggerMode.hoverStay &&
          state.hideTimer == null) {
        if (hideDelay == Duration.zero) {
          cancel(entityId);
        } else {
          state.hideTimer = Timer(hideDelay, () => cancel(entityId));
        }
      } else if (!state.isVisible) {
        removeState(entityId);
      }
    }
  }

  void handleTap(GraphId entityId) {
    if (triggerMode == GraphTooltipTriggerMode.tap ||
        triggerMode == GraphTooltipTriggerMode.longPress ||
        triggerMode == GraphTooltipTriggerMode.doubleTap) {
      toggle(entityId);
    } else if (triggerMode == GraphTooltipTriggerMode.hoverStay) {
      cancel(entityId);
    }
  }

  _TooltipState _createState(GraphId entityId) {
    final newState = _TooltipState(entityId);
    setState(entityId, newState);
    return newState;
  }

  void toggle(GraphId entityId) {
    final state = getState(entityId);
    if (state?.isVisible ?? false) {
      cancel(entityId);
    } else {
      final newState = getState(entityId) ?? _createState(entityId);
      _showNow(entityId, newState);
    }
  }
}

/// Manages tooltip state for node elements.
///
/// Controls node-specific tooltip display behavior.
@internal
final class GraphNodeTooltipStateManager
    extends GraphEntityTooltipStateManager<GraphNode> {
  /// Creates a tooltip state manager for node elements.
  GraphNodeTooltipStateManager({
    required super.gestureManager,
    required super.triggerMode,
    super.showDelay,
    super.hideDelay,
  });

  @override
  GraphEntityType get entityType => GraphEntityType.node;
}

/// Manages tooltip state for link elements.
///
/// Controls link-specific tooltip display behavior.
@internal
final class GraphLinkTooltipStateManager
    extends GraphEntityTooltipStateManager<GraphLink> {
  /// Creates a tooltip state manager for link elements.
  GraphLinkTooltipStateManager({
    required super.gestureManager,
    required super.triggerMode,
    super.showDelay,
    super.hideDelay,
  });

  @override
  GraphEntityType get entityType => GraphEntityType.link;
}
