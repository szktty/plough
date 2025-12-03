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
    required this.startPosition, // Global position where drag gesture started
    required this.initialLogicalPosition, // Node's logical position at drag start
  }) {
    currentLogicalPosition = initialLogicalPosition;
  }

  final GraphId entityId;
  final Offset startPosition;
  final Offset initialLogicalPosition;
  late Offset currentLogicalPosition;
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
    final statesToCancel = List.from(states);
    for (final state in statesToCancel) {
      // Cast state to _DragState to access entityId safely
      final dragState = state as _DragState;
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
        // Use canDrag check
        setState(
          entityId,
          _DragState(
            entityId: entityId,
            startPosition: details.globalPosition,
            initialLogicalPosition: entity.logicalPosition,
          ),
        );
      } else {
        logWarning(LogCategory.drag,
            'Attempted to start drag on non-draggable entity: $entityId');
      }
    }
  }

  List<GraphId> handlePanUpdate(DragUpdateDetails details) {
    if (!isActive) return [];
    final updatedIds = <GraphId>[];
    final startState = states.firstOrNull;
    if (startState == null) return [];
    final dragGlobalStart = startState.startPosition;
    final delta = details.globalPosition - dragGlobalStart;
    final currentStates = List.from(states);

    for (final state in currentStates) {
      final dragState = state as _DragState;
      if (dragState.cancelled) continue;
      final newLogicalPosition = dragState.initialLogicalPosition + delta;
      dragState.currentLogicalPosition = newLogicalPosition;
      final entity = gestureManager.getEntity(dragState.entityId);
      if (entity is GraphNode) {
        // Stop any ongoing animation during drag
        (entity as GraphNodeImpl).isAnimating = false;
        setPosition(entity.id, newLogicalPosition);
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
    final statesToEnd = List.from(states);
    for (final state in statesToEnd) {
      final dragState = state as _DragState;
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
      // Check if state exists before warning/cancelling
      logWarning(
        LogCategory.drag,
        'Drag state still exists on PointerUp for $entityId. Cancelling.',
      );
      cancel(entityId); // cancel will call removeState
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
    logWarning(LogCategory.drag,
        'Attempted to drag links: $entityIds. Link dragging not supported.');
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
