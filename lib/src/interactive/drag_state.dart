import 'package:flutter/gestures.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plough/plough.dart'; // Import GraphNode etc.
// Import GraphEntity
// Import GraphId
import 'package:plough/src/graph/node.dart';
import 'package:plough/src/interactive/state_manager.dart';
import 'package:plough/src/utils/logger.dart';

// Internal state for tracking a single dragged entity
class _DragState {
  _DragState({
    required this.entityId,
    required this.initialLogicalPosition, // Node's logical position at drag start
  }) {
    currentLogicalPosition = initialLogicalPosition;
  }

  final GraphId entityId;
  final Offset initialLogicalPosition;
  late Offset currentLogicalPosition;
  // Accumulated delta from details.delta across all pan updates.
  // Using details.delta (frame-relative) avoids coordinate system mismatch
  // when GraphView is inside a transformed InteractiveViewer.
  Offset accumulatedDelta = Offset.zero;
  bool cancelled = false;
}

/// Base class for managing drag interactions for graph entities.
@internal
abstract base class GraphEntityDragStateManager<E extends GraphEntity>
    extends GraphStateManager<_DragState> {
  GraphEntityDragStateManager({required super.gestureManager});

  // --- Public API for GraphGestureManager ---

  /// IDs of the entities currently being dragged.
  List<GraphId> get draggedEntityIds => super.activeEntityIds;

  /// The ID of the last entity that was added to the drag state.
  GraphId? get lastDraggedEntityId => super.lastActiveEntityId;

  /// Checks if a specific entity is currently being dragged.
  bool isDragging(GraphId entityId) => hasState(entityId);

  /// Checks if the entity can be dragged based on its properties.
  bool canDrag(GraphId entityId) {
    return gestureManager.getEntity(entityId)?.canDrag ?? false;
  }

  /// Cancels all ongoing drag operations.

  /// Cancels all ongoing drag operations.
  void cancelAll() {
    final statesToCancel = List<_DragState>.from(states);
    for (final state in statesToCancel) {
      final dragState = state;
      cancel(dragState.entityId);
    }
    if (isActive) {
      logWarning(LogCategory.drag, 'Drag states remained after cancelAll');
      clearAllStates();
    }
  }

  // --- Gesture Handling Logic ---

  void handlePanStart(List<GraphId> entityIds, DragStartDetails details) {
    if (entityIds.isEmpty || isActive) return;
    clearAllStates();
    for (final entityId in entityIds) {
      final entity = gestureManager.getEntity(entityId);
      if (entity is GraphNode && canDrag(entityId)) {
        // Stop any ongoing animation before starting drag
        (entity as GraphNodeImpl).isAnimating = false;
        setState(
          entityId,
          _DragState(
            entityId: entityId,
            initialLogicalPosition: entity.logicalPosition,
          ),
        );
        gestureManager.onNodeDragStart?.call(entityId);
      } else {
        logWarning(
          LogCategory.drag,
          'Attempted to start drag on non-draggable entity: $entityId',
        );
      }
    }
  }

  List<GraphId> handlePanUpdate(DragUpdateDetails details) {
    if (!isActive) return [];
    final updatedIds = <GraphId>[];
    final currentStates = List<_DragState>.from(states);

    for (final state in currentStates) {
      final dragState = state;
      if (dragState.cancelled) continue;
      // Accumulate frame-relative delta, optionally transformed to the graph's
      // logical coordinate space via gestureManager.dragDeltaTransform.
      // This is needed when GraphView is inside a transformed parent such as
      // InteractiveViewer, where the raw delta is in screen space.
      final rawDelta = details.delta;
      final logicalDelta =
          gestureManager.dragDeltaTransform?.call(rawDelta) ?? rawDelta;
      dragState.accumulatedDelta += logicalDelta;
      final newLogicalPosition =
          dragState.initialLogicalPosition + dragState.accumulatedDelta;
      dragState.currentLogicalPosition = newLogicalPosition;
      final entity = gestureManager.getEntity(dragState.entityId);
      if (entity is GraphNode) {
        // Stop any ongoing animation during drag
        (entity as GraphNodeImpl).isAnimating = false;
        // The id is still reported when movement is suppressed, so the drag is
        // observable even though the node stays put.
        if (!gestureManager.suppressDragMovement) {
          setPosition(entity.id, newLogicalPosition);
        }
        updatedIds.add(dragState.entityId);
      } else {
        logWarning(
          LogCategory.drag,
          'Dragged entity ${dragState.entityId} not found or not a Node during update.',
        );
        cancel(dragState.entityId);
      }
    }
    return updatedIds;
  }

  List<GraphId> handlePanEnd(DragEndDetails details) {
    if (!isActive) return [];
    final endedDragIds = <GraphId>[];
    final statesToEnd = List<_DragState>.from(states);
    for (final state in statesToEnd) {
      final dragState = state;
      if (!dragState.cancelled) {
        endedDragIds.add(dragState.entityId);
      }
      // Remove state regardless of cancelled status at the end of the pan
      // removeState(dragState.entityId); // Do this in clearAllStates
    }
    clearAllStates(); // Ensure all states are cleared on PanEnd
    return endedDragIds;
  }

  void handlePointerMove(PointerMoveEvent event) {}
  void handlePointerDown(GraphId entityId, PointerDownEvent event) {}

  void handlePointerUp(GraphId entityId, PointerUpEvent event) {
    final state = getState(entityId);
    if (state != null) {
      // Drag state still exists on PointerUp means the pan recognizer hasn't
      // fired PanEnd yet (event ordering anomaly).  Treat this as a normal
      // drag-end so callers can react (e.g. snap-back).  Only call the
      // callback for node drags (link drags don't currently support it).
      if (!state.cancelled) {
        gestureManager.onNodeDragEnd?.call(entityId);
      }
      logWarning(
        LogCategory.drag,
        'Drag state still exists on PointerUp for $entityId. Ending drag.',
      );
      cancel(entityId);
    }
  }

  void handlePointerCancel(GraphId entityId, PointerCancelEvent event) {
    cancel(entityId);
  }

  @override
  void cancel(GraphId entityId) {
    final state = getState(entityId);
    if (state != null && !state.cancelled) {
      state.cancelled = true;
      removeState(entityId);
      logDebug(LogCategory.drag, 'Cancelled drag for $entityId');
    }
  }
}

@internal
final class GraphNodeDragStateManager
    extends GraphEntityDragStateManager<GraphNode> {
  GraphNodeDragStateManager({required super.gestureManager});
  @override
  GraphEntityType get entityType => GraphEntityType.node;
}

@internal
final class GraphLinkDragStateManager
    extends GraphEntityDragStateManager<GraphLink> {
  GraphLinkDragStateManager({required super.gestureManager});
  @override
  GraphEntityType get entityType => GraphEntityType.link;
  @override
  bool canDrag(GraphId entityId) => false;
  @override
  void handlePanStart(List<GraphId> entityIds, DragStartDetails details) {
    logWarning(
      LogCategory.drag,
      'Attempted to drag links: $entityIds. Link dragging not supported.',
    );
  }

  @override
  List<GraphId> handlePanUpdate(DragUpdateDetails details) => [];
  @override
  List<GraphId> handlePanEnd(DragEndDetails details) => [];
  @override
  void handlePointerDown(GraphId entityId, PointerDownEvent event) {}
  @override
  void handlePointerUp(GraphId entityId, PointerUpEvent event) {}
  @override
  void handlePointerCancel(GraphId entityId, PointerCancelEvent event) {}
  @override
  void cancel(GraphId entityId) {
    removeState(entityId);
  }

  @override
  void cancelAll() {
    clearAllStates();
  }
}
