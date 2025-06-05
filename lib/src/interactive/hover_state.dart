import 'package:flutter/gestures.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/interactive/state_manager.dart';
import 'package:plough/src/utils/logger.dart';

// Internal state for hover
class _HoverState {
  _HoverState(this.entityId);
  final GraphId entityId;
}

/// Manages hover state for graph entities.
@internal
abstract base class GraphEntityHoverStateManager<E extends GraphEntity>
    extends GraphStateManager<_HoverState> {
  GraphEntityHoverStateManager({required super.gestureManager});

  // --- Public API ---
  GraphId? get hoveredEntityId => states.firstOrNull?.entityId;

  // cancelAll() is inherited or can be added if specific logic needed
  void cancelAll() {
    final currentId = hoveredEntityId;
    if (currentId != null) {
      cancel(currentId);
    }
  }

  // --- Gesture Handling ---

  /// Called by GraphGestureManager when pointer enters or moves within an entity.
  void handleMouseHover(GraphId entityId, PointerHoverEvent event) {
    if (!hasState(entityId)) {
      clearAllStates(); // Ensure only one entity is hovered
      setState(entityId, _HoverState(entityId));
      logDebug(LogCategory.gesture, 'Hover started for $entityId');
      // Note: GraphGestureManager dispatches GraphHoverEnterEvent
    } else {
      // Already hovering this entity
      logDebug(LogCategory.gesture, 'Hover move over $entityId');
      // Note: GraphGestureManager dispatches GraphHoverMoveEvent
    }
  }

  /// Called by GraphGestureManager when pointer leaves an entity's area.
  void handleMouseExit(GraphId entityId, PointerHoverEvent event) {
    if (hasState(entityId)) {
      removeState(entityId);
      logDebug(LogCategory.gesture, 'Hover ended for $entityId');
      // Note: GraphGestureManager dispatches GraphHoverEndEvent
    }
  }

  /// Called by GraphGestureManager on pointer down to cancel hover.
  void handlePointerDown(PointerDownEvent event) {
    // Cancel hover regardless of where the pointer down occurs
    final currentId = hoveredEntityId;
    if (currentId != null) {
      cancel(currentId);
    }
  }

  /// Cancels hover state for a specific entity.
  @override
  void cancel(GraphId entityId) {
    if (hasState(entityId)) {
      removeState(entityId);
      logDebug(LogCategory.gesture, 'Hover cancelled for $entityId');
      // Note: GraphGestureManager should dispatch HoverEnd if cancelling due to external factors.
    }
  }
}

@internal
final class GraphNodeHoverStateManager
    extends GraphEntityHoverStateManager<GraphNode> {
  GraphNodeHoverStateManager({required super.gestureManager});

  @override
  GraphEntityType get entityType => GraphEntityType.node;
}

@internal
final class GraphLinkHoverStateManager
    extends GraphEntityHoverStateManager<GraphLink> {
  GraphLinkHoverStateManager({required super.gestureManager});

  @override
  GraphEntityType get entityType => GraphEntityType.link;
}
