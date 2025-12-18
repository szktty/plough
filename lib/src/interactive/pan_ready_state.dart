import 'package:flutter/gestures.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/interactive/state_manager.dart';

/// Class that manages Pan Ready state
/// An intermediate state where pan start has occurred but actual dragging has not yet begun
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

/// Base class for managing Pan Ready state
abstract base class GraphEntityPanReadyStateManager<E extends GraphEntity>
    extends GraphStateManager<_PanReadyState> {
  GraphEntityPanReadyStateManager({
    required super.gestureManager,
    this.dragStartThreshold =
        8.0, // Threshold distance for considering drag start
    this.maxReadyDuration = const Duration(
      milliseconds: 200,
    ), // Maximum duration for Ready state
  });

  final double dragStartThreshold;
  final Duration maxReadyDuration;

  /// List of entities in Pan Ready state
  List<GraphId> get readyEntityIds => states
      .where((state) => !state.dragStarted && !state.cancelled)
      .map((state) => state.entityId)
      .toList();

  /// Whether entity is in Pan Ready state
  bool isPanReady(GraphId entityId) {
    final state = getState(entityId);
    return state != null && !state.dragStarted && !state.cancelled;
  }

  /// Process pan start (set to Ready state)
  void handlePanStart(GraphId entityId, DragStartDetails details) {
    logGestureDebug(
      GestureDebugEventType.stateCreate,
      'PanReadyStateManager',
      'PAN_READY_STATE_CREATED',
      data: {
        'entityId': entityId.value.substring(0, 8),
        'position': {
          'x': details.localPosition.dx,
          'y': details.localPosition.dy,
        },
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

    // Auto-cancel after maximum duration
    Future.delayed(maxReadyDuration, () {
      _timeoutPanReady(entityId);
    });
  }

  /// Process pan update (start drag when threshold exceeded)
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
          'y': state.startPosition.dy,
        },
        'current_position': {
          'x': details.localPosition.dx,
          'y': details.localPosition.dy,
        },
      },
    );

    if (distance >= dragStartThreshold) {
      // Threshold exceeded, start actual drag
      _startActualDrag(entityId, state, details);
    }
  }

  /// Start actual drag
  void _startActualDrag(
    GraphId entityId,
    _PanReadyState readyState,
    DragUpdateDetails updateDetails,
  ) {
    readyState.dragStarted = true;

    logGestureDebug(
      GestureDebugEventType.dragStart,
      'PanReadyStateManager',
      'ACTUAL_DRAG_STARTED',
      data: {
        'entityId': entityId.value.substring(0, 8),
        'ready_duration_ms':
            DateTime.now().difference(readyState.startTime).inMilliseconds,
        'trigger_distance':
            (updateDetails.localPosition - readyState.startPosition).distance,
        'threshold': dragStartThreshold,
      },
    );

    // Delegate to appropriate drag manager
    _delegateActualDragStart(entityId, readyState.startDetails, updateDetails);

    // Clean up Ready state
    removeStateSilently(entityId);
  }

  /// Ready state timeout processing
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

      // Timed out, so release Ready state
      // Leave possibility of being treated as a tap
      removeStateSilently(entityId);
    }
  }

  /// Cancel Ready state
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

  /// Cancel all Ready states
  void cancelAllPanReady() {
    final activeStates = List<_PanReadyState>.from(states);
    for (final state in activeStates) {
      if (!state.dragStarted) {
        cancelPanReady(state.entityId);
      }
    }
  }

  /// Delegate actual drag start to appropriate manager (implemented in subclasses)
  void _delegateActualDragStart(
    GraphId entityId,
    DragStartDetails startDetails,
    DragUpdateDetails updateDetails,
  );

  @override
  void cancel(GraphId entityId) {
    cancelPanReady(entityId);
  }
}

/// Pan Ready state manager for nodes
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
  void _delegateActualDragStart(
    GraphId entityId,
    DragStartDetails startDetails,
    DragUpdateDetails updateDetails,
  ) {
    // Delegate to node drag manager
    gestureManager.nodeDragManager.handlePanStart([entityId], startDetails);
    gestureManager.nodeDragManager.handlePanUpdate(updateDetails);

    // Cancel tap state (drag confirmed)
    gestureManager.nodeTapManager.cancel(entityId);
  }
}

/// Pan Ready state manager for links
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
  void _delegateActualDragStart(
    GraphId entityId,
    DragStartDetails startDetails,
    DragUpdateDetails updateDetails,
  ) {
    // Delegate to link drag manager
    gestureManager.linkDragManager.handlePanStart([entityId], startDetails);
    gestureManager.linkDragManager.handlePanUpdate(updateDetails);

    // Cancel tap state (drag confirmed)
    gestureManager.linkTapManager.cancel(entityId);
  }
}
