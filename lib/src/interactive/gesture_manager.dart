import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plough/src/graph/entity.dart';
import 'package:plough/src/graph/graph_base.dart';
import 'package:plough/src/graph/id.dart';
import 'package:plough/src/graph/link.dart';
import 'package:plough/src/graph/node.dart';
import 'package:plough/src/graph/order_manager.dart';
import 'package:plough/src/graph_view/behavior.dart';
import 'package:plough/src/graph_view/hit_test.dart';
import 'package:plough/src/interactive/drag_state.dart';
import 'package:plough/src/interactive/events.dart';
import 'package:plough/src/interactive/gesture_debug.dart';
import 'package:plough/src/interactive/hover_state.dart';
import 'package:plough/src/interactive/tap_state.dart';
import 'package:plough/src/interactive/tooltip_state.dart';
import 'package:plough/src/tooltip/behavior.dart';
import 'package:plough/src/utils/logger.dart';
import 'package:plough/src/debug/external_debug_client.dart';

@internal
class GraphGestureManager {
  GraphGestureManager({
    required this.graph,
    required this.viewBehavior,
    required this.viewportSize,
    this.nodeTooltipTriggerMode,
    this.linkTooltipTriggerMode,
    this.gestureMode = GraphGestureMode.exclusive,
    this.shouldConsumeGesture,
    this.onBackgroundTapped,
    this.onBackgroundPanStart,
    this.onBackgroundPanUpdate,
    this.onBackgroundPanEnd,
    this.onTooltipShow,
    this.onTooltipHide,
  }) {
    _orderManager = graph.getOrderManagerSync();
  }

  final Graph graph;
  final GraphViewBehavior viewBehavior;
  final Size viewportSize;
  final GraphTooltipTriggerMode? nodeTooltipTriggerMode;
  final GraphTooltipTriggerMode? linkTooltipTriggerMode;
  final GraphGestureMode gestureMode;
  final GraphGestureConsumptionCallback? shouldConsumeGesture;
  final GraphBackgroundGestureCallback? onBackgroundTapped;
  final GraphBackgroundGestureCallback? onBackgroundPanStart;
  final GraphBackgroundPanCallback? onBackgroundPanUpdate;
  final GraphBackgroundGestureCallback? onBackgroundPanEnd;
  final void Function(GraphEntity)? onTooltipShow;
  final void Function(GraphEntity)? onTooltipHide;

  late final GraphNodeTapStateManager _nodeTapManager =
      GraphNodeTapStateManager(
    gestureManager: this,
    tooltipTriggerMode: nodeTooltipTriggerMode,
  );
  late final GraphLinkTapStateManager _linkTapManager =
      GraphLinkTapStateManager(
    gestureManager: this,
    tooltipTriggerMode: linkTooltipTriggerMode,
  );
  late final GraphNodeDragStateManager _nodeDragManager =
      GraphNodeDragStateManager(gestureManager: this);
  late final GraphLinkDragStateManager _linkDragManager =
      GraphLinkDragStateManager(gestureManager: this);
  late final GraphNodeHoverStateManager _nodeHoverManager =
      GraphNodeHoverStateManager(gestureManager: this);
  late final GraphLinkHoverStateManager _linkHoverManager =
      GraphLinkHoverStateManager(gestureManager: this);
  late final GraphNodeTooltipStateManager _nodeTooltipManager =
      GraphNodeTooltipStateManager(
    gestureManager: this,
    triggerMode: nodeTooltipTriggerMode,
  );
  late final GraphLinkTooltipStateManager _linkTooltipManager =
      GraphLinkTooltipStateManager(
    gestureManager: this,
    triggerMode: linkTooltipTriggerMode,
  );

  late final GraphOrderManager _orderManager;

  PointerEventDetails? _lastPointerDetails;
  PointerEventDetails? get lastPointerDetails => _lastPointerDetails;

  // Debug accessors for internal state
  GraphNodeTapStateManager get nodeTapManager => _nodeTapManager;
  GraphNodeDragStateManager get nodeDragManager => _nodeDragManager;
  GraphLinkTapStateManager get linkTapManager => _linkTapManager;
  GraphLinkDragStateManager get linkDragManager => _linkDragManager;

  GraphEntity? getEntity(GraphId entityId) =>
      graph.getNode(entityId) ?? graph.getLink(entityId);

  bool get isDragging => _nodeDragManager.isActive || _linkDragManager.isActive;

  GraphId? get lastDraggedEntityId =>
      _nodeDragManager.lastDraggedEntityId ??
      _linkDragManager.lastDraggedEntityId;

  /// Creates a hit test result for the given position.
  GraphHitTestResult createHitTestResult(Offset position) {
    final node = findNodeAt(position);
    final link = node == null ? findLinkAt(position) : null;

    return GraphHitTestResult(
      localPosition: position,
      node: node,
      link: link,
    );
  }

  /// Determines if a gesture should be consumed based on the current mode.
  bool shouldConsumeGestureAt(Offset position) {
    final hitTestResult = createHitTestResult(position);
    logDebug(LogCategory.gesture,
        'shouldConsumeGestureAt: mode=$gestureMode, hasEntity=${hitTestResult.hasEntity}');

    bool result;
    switch (gestureMode) {
      case GraphGestureMode.exclusive:
        result = true;
        logDebug(LogCategory.gesture, 'Exclusive mode: consuming gesture');
      case GraphGestureMode.nodeEdgeOnly:
        result = hitTestResult.hasEntity;
        logDebug(LogCategory.gesture,
            'NodeEdgeOnly mode: ${result ? 'consuming' : 'not consuming'} (hasEntity=${hitTestResult.hasEntity})');
      case GraphGestureMode.transparent:
        result = false;
        logDebug(
            LogCategory.gesture, 'Transparent mode: not consuming gesture');
      case GraphGestureMode.custom:
        result = shouldConsumeGesture?.call(position, hitTestResult) ?? true;
        logDebug(LogCategory.gesture,
            'Custom mode: ${result ? 'consuming' : 'not consuming'}');
    }

    return result;
  }

  GraphNode? findNodeAt(Offset position) {
    return _orderManager.frontmostWhereOrNull((entity) {
      if (entity is GraphNode) {
        return viewBehavior.hitTestNode(entity, position);
      } else {
        return false;
      }
    }) as GraphNode?;
  }

  GraphLink? findLinkAt(Offset position) {
    return _orderManager.frontmostWhereOrNull((entity) {
      if (entity is GraphLink) {
        return viewBehavior.hitTestLink(entity, position);
      } else {
        return false;
      }
    }) as GraphLink?;
  }

  void _dispatchSelectionChange(
    List<GraphId> newlySelected,
    List<GraphId> newlyDeselected, {
    PointerEventDetails? details,
  }) {
    if (newlySelected.isNotEmpty || newlyDeselected.isNotEmpty) {
      logDebug(
        LogCategory.selection,
        '_dispatchSelectionChange: newlySelected=${newlySelected.map((id) => id.value.substring(0, 4)).join(', ')}, newlyDeselected=${newlyDeselected.map((id) => id.value.substring(0, 4)).join(', ')}',
      );
      final event = GraphSelectionChangeEvent(
        selectedIds: newlySelected,
        deselectedIds: newlyDeselected,
        currentSelectionIds: graph.selectedEntityIds.toList(),
        details: details,
      );
      viewBehavior.onSelectionChange(event);
    } else {
      logDebug(LogCategory.selection,
          '_dispatchSelectionChange: No actual changes, skipping event dispatch');
    }
  }

  void toggleSelection(GraphId entityId, {PointerEventDetails? details}) {
    logDebug(
      LogCategory.selection,
      'toggleSelection called for: ${entityId.value.substring(0, 4)}',
    );
    final currentSelection = graph.selectedEntityIds.toSet();
    logDebug(
      LogCategory.selection,
      'Current selection before toggle: [${currentSelection.map((id) => id.value.substring(0, 4)).join(', ')}]',
    );

    if (currentSelection.contains(entityId)) {
      logDebug(
          LogCategory.selection, 'Entity is already selected, deselecting');
      deselectEntities([entityId], details: details);
    } else {
      logDebug(LogCategory.selection, 'Entity not selected, selecting');
      selectEntities([entityId], details: details);
    }
  }

  void selectEntities(List<GraphId> entityIds, {PointerEventDetails? details}) {
    logDebug(
      LogCategory.selection,
      'selectEntities called for: [${entityIds.map((id) => id.value.substring(0, 4)).join(', ')}]',
    );
    final currentSelection = graph.selectedEntityIds.toSet();
    logDebug(
      LogCategory.selection,
      'Current selection before select: [${currentSelection.map((id) => id.value.substring(0, 4)).join(', ')}]',
    );
    final newlySelected = <GraphId>[];
    final newlyDeselected = <GraphId>[];

    final idsToSelect =
        entityIds.where((id) => !currentSelection.contains(id)).toList();
    logDebug(LogCategory.selection,
        'IDs to select: [${idsToSelect.map((id) => id.value.substring(0, 4)).join(', ')}]');

    if (idsToSelect.isNotEmpty) {
      final othersToDeselect =
          currentSelection.where((id) => !entityIds.contains(id)).toList();
      if (othersToDeselect.isNotEmpty) {
        logDebug(LogCategory.selection,
            'Deselecting others first: [${othersToDeselect.map((id) => id.value.substring(0, 4)).join(', ')}]');
        _deselectEntitiesInternal(othersToDeselect);
        newlyDeselected.addAll(othersToDeselect);
      }
    }

    for (final entityId in entityIds) {
      if (!currentSelection.contains(entityId)) {
        final entity = getEntity(entityId);
        if (entity is GraphNode && entity.canSelect) {
          logDebug(
            LogCategory.selection,
            'Selecting Node: ${entity.id.value.substring(0, 4)}',
          );
          graph.selectNode(entity.id);
          newlySelected.add(entity.id);
        } else if (entity is GraphLink && entity.canSelect) {
          logDebug(
            LogCategory.selection,
            'Selecting Link: ${entity.id.value.substring(0, 4)}',
          );
          graph.selectLink(entity.id);
          newlySelected.add(entity.id);
        } else {
          logDebug(
            LogCategory.selection,
            'NOT selecting ${entity?.runtimeType ?? 'Unknown'} (${entityId.value.substring(0, 4)}): canSelect=${entity?.canSelect}',
          );
        }
      } else {
        logDebug(LogCategory.selection,
            'Entity ${entityId.value.substring(0, 4)} already selected, skipping');
      }
    }

    logDebug(LogCategory.selection,
        'About to dispatch: newlySelected=[${newlySelected.map((id) => id.value.substring(0, 4)).join(', ')}], newlyDeselected=[${newlyDeselected.map((id) => id.value.substring(0, 4)).join(', ')}]');
    _dispatchSelectionChange(newlySelected, newlyDeselected, details: details);
  }

  void _deselectEntitiesInternal(List<GraphId> entityIds) {
    for (final entityId in entityIds) {
      final entity = getEntity(entityId);
      logDebug(
        LogCategory.selection,
        '_deselectInternal: ${entityId.value.substring(0, 4)}',
      );
      if (entity is GraphNode) {
        graph.deselectNode(entity.id);
      } else if (entity is GraphLink) {
        graph.deselectLink(entity.id);
      }
    }
  }

  void deselectEntities(
    List<GraphId> entityIds, {
    PointerEventDetails? details,
  }) {
    logDebug(
      LogCategory.selection,
      'deselectEntities called for: [${entityIds.map((id) => id.value.substring(0, 4)).join(', ')}]',
    );
    final currentSelection = graph.selectedEntityIds.toSet();
    logDebug(
      LogCategory.selection,
      'Current selection before deselect: [${currentSelection.map((id) => id.value.substring(0, 4)).join(', ')}]',
    );
    final newlyDeselected = <GraphId>[];

    for (final entityId in entityIds) {
      if (currentSelection.contains(entityId)) {
        final entity = getEntity(entityId);
        if (entity is GraphNode) {
          logDebug(
            LogCategory.selection,
            'Deselecting Node: ${entity.id.value.substring(0, 4)}',
          );
          graph.deselectNode(entity.id);
          newlyDeselected.add(entity.id);
        } else if (entity is GraphLink) {
          logDebug(
            LogCategory.selection,
            'Deselecting Link: ${entity.id.value.substring(0, 4)}',
          );
          graph.deselectLink(entity.id);
          newlyDeselected.add(entity.id);
        }
      } else {
        logDebug(LogCategory.selection,
            'Entity ${entityId.value.substring(0, 4)} not selected, skipping deselect');
      }
    }
    logDebug(LogCategory.selection,
        'About to dispatch deselection: newlyDeselected=[${newlyDeselected.map((id) => id.value.substring(0, 4)).join(', ')}]');
    _dispatchSelectionChange([], newlyDeselected, details: details);
  }

  void deselectAll({PointerEventDetails? details}) {
    logDebug(LogCategory.selection, 'deselectAll called');
    final currentSelection = graph.selectedEntityIds.toList();
    logDebug(LogCategory.selection,
        'Current selection: [${currentSelection.map((id) => id.value.substring(0, 4)).join(', ')}]');
    if (currentSelection.isNotEmpty) {
      logDebug(LogCategory.selection,
          'Deselecting all ${currentSelection.length} entities');
      deselectEntities(currentSelection, details: details);
    } else {
      logDebug(LogCategory.selection,
          'No entities selected, skipping deselect to avoid unnecessary rebuilds');
      // Don't call deselectEntities when there's nothing to deselect
      // This prevents unnecessary event dispatching and rebuilds
    }
  }

  void handlePointerDown(PointerDownEvent event) {
    logDebug(LogCategory.gesture,
        'Starting handlePointerDown at ${event.localPosition}, mode: $gestureMode');

    // Send structured gesture event to debug server
    externalDebugClient.sendLog(
      category: LogCategory.gesture,
      level: 'DEBUG',
      message: 'Pointer down event',
      metadata: {
        'event_type': 'pointerDown',
        'position': {'x': event.localPosition.dx, 'y': event.localPosition.dy},
        'gesture_mode': gestureMode.name,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    _nodeHoverManager.handlePointerDown(event);
    _linkHoverManager.handlePointerDown(event);

    final node = findNodeAt(event.localPosition);
    if (node != null) {
      logDebug(
          LogCategory.gesture, 'Node found: ${node.id.value.substring(0, 4)}');

      // Send structured node event to debug server
      externalDebugClient.sendLog(
        category: LogCategory.gesture,
        level: 'DEBUG',
        message: 'Node found at pointer down',
        metadata: {
          'event_type': 'nodeFound',
          'nodeId': node.id.value,
          'node_id': node.id.value, // backward compatibility
          'position': {
            'x': event.localPosition.dx,
            'y': event.localPosition.dy
          },
          'node_position': {
            'x': node.logicalPosition.dx,
            'y': node.logicalPosition.dy
          },
          'can_select': node.canSelect,
          'can_drag': node.canDrag,
          'is_selected': graph.selectedEntityIds.contains(node.id),
          'gesture_mode': gestureMode.name,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      debugPrint('TAP DEBUG DOWN: node.id=${node.id.value.substring(0, 8)}');
      debugPrint('TAP DEBUG DOWN: Before handlePointerDown - trackedEntityId=${_nodeTapManager.trackedEntityId?.value.substring(0, 8) ?? 'null'}');
      _nodeTapManager.handlePointerDown(node.id, event);
      _nodeDragManager.handlePointerDown(node.id, event);
      debugPrint(
          'TAP DEBUG DOWN: trackedEntityId after handlePointerDown=${_nodeTapManager.trackedEntityId?.value.substring(0, 8) ?? 'null'}');

      // Send TAP_DEBUG_STATE after pointer down
      final tapState = _nodeTapManager.getState(node.id);
      final tapDebugInfo = _nodeTapManager.getTapStateDebugInfo(node.id);
      logGestureDebug(
        GestureDebugEventType.tapDebugState,
        'GraphGestureManager',
        'TAP_DEBUG_STATE_DOWN',
        {
          'event_type': 'tap_debug_state',
          'phase': 'down',
          'nodeTargetId': node.id.value,
          'state_exists': tapState != null,
          'state_completed': tapState?.completed ?? false,
          'state_cancelled': tapState?.cancelled ?? false,
          'tap_count': tapState?.tapCount ?? 0,
          'tracked_entity_id': _nodeTapManager.trackedEntityId?.value ?? 'null',
          'is_still_dragging_after_up': false,
          'is_tap_completed_after_up': false,
          'touch_slop': kTouchSlop * 8,
          'k_touch_slop': kTouchSlop,
          'timestamp': DateTime.now().toIso8601String(),
          // Additional debug info
          'tap_debug_info': tapDebugInfo,
          'node_can_select': node.canSelect,
          'node_can_drag': node.canDrag,
          'node_is_selected': graph.selectedEntityIds.contains(node.id),
          'gesture_mode': gestureMode.name,
          'pointer_position': {
            'x': event.localPosition.dx,
            'y': event.localPosition.dy
          },
          'node_position': {
            'x': node.logicalPosition.dx,
            'y': node.logicalPosition.dy
          },
          'tap_manager_states_count': _nodeTapManager.states.length,
          'drag_manager_is_dragging': _nodeDragManager.isDragging(node.id),
        },
      );
      // Return early for all modes except transparent
      if (gestureMode == GraphGestureMode.transparent) {
        logDebug(LogCategory.gesture,
            'Continuing after node processing (transparent mode)');
      } else {
        logDebug(
            LogCategory.gesture, 'Early return for node (mode: $gestureMode)');
        return;
      }
    }

    final link = findLinkAt(event.localPosition);
    if (link != null) {
      logDebug(
          LogCategory.gesture, 'Link found: ${link.id.value.substring(0, 4)}');

      // Send structured link event to debug server
      externalDebugClient.sendLog(
        category: LogCategory.gesture,
        level: 'DEBUG',
        message: 'Link found at pointer down',
        metadata: {
          'event_type': 'linkFound',
          'linkId': link.id.value,
          'link_id': link.id.value, // backward compatibility
          'position': {
            'x': event.localPosition.dx,
            'y': event.localPosition.dy
          },
          'source_node_id': link.source.id.value,
          'target_node_id': link.target.id.value,
          'can_select': link.canSelect,
          'is_selected': graph.selectedEntityIds.contains(link.id),
          'gesture_mode': gestureMode.name,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      _linkTapManager.handlePointerDown(link.id, event);
      _linkDragManager.handlePointerDown(link.id, event);
      // Return early for all modes except transparent
      if (gestureMode == GraphGestureMode.transparent) {
        logDebug(LogCategory.gesture,
            'Continuing after link processing (transparent mode)');
      } else {
        logDebug(
            LogCategory.gesture, 'Early return for link (mode: $gestureMode)');
        return;
      }
    }

    // Only call background callback if no entity was found
    // Double-check to prevent race conditions
    final reCheckNode = findNodeAt(event.localPosition);
    final reCheckLink = findLinkAt(event.localPosition);

    if (node == null &&
        link == null &&
        reCheckNode == null &&
        reCheckLink == null) {
      logDebug(LogCategory.gesture,
          'True background area (double-checked), calling background callback');
      onBackgroundTapped?.call(event.localPosition);
      deselectAll(details: _lastPointerDetails);
    } else {
      logDebug(LogCategory.gesture,
          'Entity found (or re-found), not calling background callback');
    }
  }

  void handlePointerUp(PointerUpEvent event) {
    logDebug(LogCategory.gesture,
        'Starting handlePointerUp at ${event.localPosition}, mode: $gestureMode');
    _lastPointerDetails = PointerEventDetails.fromPointerEvent(event);
    final details = _lastPointerDetails!;

    // Send structured gesture event to debug server
    externalDebugClient.sendLog(
      category: LogCategory.gesture,
      level: 'DEBUG',
      message: 'Pointer up event',
      metadata: {
        'event_type': 'pointerUp',
        'position': {'x': event.localPosition.dx, 'y': event.localPosition.dy},
        'gesture_mode': gestureMode.name,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    // Track if we're processing an entity
    bool entityProcessed = false;

    // First try to get the node at the pointer up location
    final nodeAtPosition = findNodeAt(event.localPosition);
    
    // CRITICAL DEBUG: Check all tap states before determining nodeTargetId
    debugPrint('TAP DEBUG UP: All tap states before nodeTargetId determination:');
    for (final state in _nodeTapManager.states) {
      final tapState = state as dynamic;
      debugPrint('  - entityId=${tapState.entityId.value.substring(0, 8)}, cancelled=${tapState.cancelled}, completed=${tapState.completed}');
    }
    
    final nodeTargetId = nodeAtPosition?.id ??
        _nodeTapManager.trackedEntityId ??
        _nodeDragManager.lastDraggedEntityId;
    debugPrint(
        'TAP DEBUG: nodeAtPosition=${nodeAtPosition?.id.value.substring(0, 8) ?? 'null'}');
    debugPrint(
        'TAP DEBUG: trackedEntityId=${_nodeTapManager.trackedEntityId?.value.substring(0, 8) ?? 'null'}');
    debugPrint(
        'TAP DEBUG: lastDraggedEntityId=${_nodeDragManager.lastDraggedEntityId?.value.substring(0, 8) ?? 'null'}');
    debugPrint(
        'TAP DEBUG: final nodeTargetId=${nodeTargetId?.value.substring(0, 8) ?? 'null'}');

    logDebug(
        LogCategory.gesture,
        'Node target ID: ${nodeTargetId?.value.substring(0, 4) ?? 'null'} '
        '(trackedEntityId: ${_nodeTapManager.trackedEntityId?.value.substring(0, 4) ?? 'null'}, '
        'lastDraggedEntityId: ${_nodeDragManager.lastDraggedEntityId?.value.substring(0, 4) ?? 'null'})');

    // Send structured node target info to debug server
    externalDebugClient.sendLog(
      category: LogCategory.gesture,
      level: 'DEBUG',
      message: 'Node target tracking',
      metadata: {
        'event_type': 'nodeTargetTracking',
        'nodeId': nodeTargetId?.value,
        'node_id': nodeTargetId?.value, // backward compatibility
        'tracked_by_tap_manager': _nodeTapManager.trackedEntityId?.value,
        'tracked_by_drag_manager': _nodeDragManager.lastDraggedEntityId?.value,
        'position': {'x': event.localPosition.dx, 'y': event.localPosition.dy},
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    if (nodeTargetId != null) {
      final node = graph.getNode(nodeTargetId);
      if (node == null) {
        logDebug(LogCategory.gesture, 'Node not found, cleaning up');

        // Send structured cleanup event to debug server
        externalDebugClient.sendLog(
          category: LogCategory.gesture,
          level: 'WARNING',
          message: 'Node not found during cleanup',
          metadata: {
            'event_type': 'nodeNotFoundCleanup',
            'nodeId': nodeTargetId.value,
            'node_id': nodeTargetId.value, // backward compatibility
            'position': {
              'x': event.localPosition.dx,
              'y': event.localPosition.dy
            },
            'timestamp': DateTime.now().toIso8601String(),
          },
        );

        _nodeTapManager.cleanupTapState(nodeTargetId);
        _nodeDragManager.cancel(nodeTargetId);
        return;
      }

      logDebug(LogCategory.gesture,
          'Processing node: ${node.id.value.substring(0, 4)}');

      // Send structured node processing event to debug server
      externalDebugClient.sendLog(
        category: LogCategory.gesture,
        level: 'DEBUG',
        message: 'Processing node at pointer up',
        metadata: {
          'event_type': 'nodeProcessing',
          'nodeId': node.id.value,
          'node_id': node.id.value, // backward compatibility
          'position': {
            'x': event.localPosition.dx,
            'y': event.localPosition.dy
          },
          'node_position': {
            'x': node.logicalPosition.dx,
            'y': node.logicalPosition.dy
          },
          'can_select': node.canSelect,
          'can_drag': node.canDrag,
          'is_selected': graph.selectedEntityIds.contains(node.id),
          'was_being_dragged': _nodeDragManager.isDragging(nodeTargetId),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      _nodeTapManager.handlePointerUp(nodeTargetId, event);
      _nodeDragManager.handlePointerUp(nodeTargetId, event);

      final isStillDraggingAfterUp = _nodeDragManager.isDragging(nodeTargetId);
      final isTapCompletedAfterUp =
          _nodeTapManager.isTapCompleted(nodeTargetId);

      // Additional debugging
      final tapState = _nodeTapManager.getState(nodeTargetId);

      // Send detailed debug info to workbench via gesture debug stream
      final tapDebugInfo = _nodeTapManager.getTapStateDebugInfo(nodeTargetId);
      final dragState = _nodeDragManager.getState(nodeTargetId);
      logGestureDebug(
        GestureDebugEventType.tapDebugState,
        'GraphGestureManager',
        'TAP_DEBUG_STATE_UP',
        {
          'event_type': 'tap_debug_state',
          'phase': 'up',
          'nodeTargetId': nodeTargetId?.value ?? 'null',
          'state_exists': tapState != null,
          'state_completed': tapState?.completed ?? false,
          'state_cancelled': tapState?.cancelled ?? false,
          'tap_count': tapState?.tapCount ?? 0,
          'tracked_entity_id': _nodeTapManager.trackedEntityId?.value ?? 'null',
          'is_still_dragging_after_up': isStillDraggingAfterUp,
          'is_tap_completed_after_up': isTapCompletedAfterUp,
          'touch_slop': kTouchSlop * 8,
          'k_touch_slop': kTouchSlop,
          'timestamp': DateTime.now().toIso8601String(),
          // Additional debug info
          'tap_debug_info': tapDebugInfo,
          'node_can_select': node.canSelect,
          'node_can_drag': node.canDrag,
          'node_is_selected': graph.selectedEntityIds.contains(node.id),
          'gesture_mode': gestureMode.name,
          'pointer_position': {
            'x': event.localPosition.dx,
            'y': event.localPosition.dy
          },
          'node_position': {
            'x': node.logicalPosition.dx,
            'y': node.logicalPosition.dy
          },
          'node_at_position': nodeAtPosition?.id.value,
          'tap_manager_states_count': _nodeTapManager.states.length,
          'drag_state_exists': dragState != null,
          'drag_manager_is_dragging': _nodeDragManager.isDragging(nodeTargetId),
          'will_toggle_selection':
              !isStillDraggingAfterUp && isTapCompletedAfterUp,
        },
      );

      // Also send to external debug client if available
      externalDebugClient.sendLog(
        category: LogCategory.gesture,
        level: 'DEBUG',
        message: 'TAP_DEBUG_STATE',
        metadata: {
          'event_type': 'tap_debug_state',
          'nodeTargetId': nodeTargetId?.value ?? 'null',
          'state_exists': tapState != null,
          'state_completed': tapState?.completed ?? false,
          'state_cancelled': tapState?.cancelled ?? false,
          'tap_count': tapState?.tapCount ?? 0,
          'tracked_entity_id': _nodeTapManager.trackedEntityId?.value ?? 'null',
          'is_still_dragging_after_up': isStillDraggingAfterUp,
          'is_tap_completed_after_up': isTapCompletedAfterUp,
          'touch_slop': kTouchSlop * 8,
          'k_touch_slop': kTouchSlop,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      debugPrint(
          'TAP DEBUG: nodeTargetId=${nodeTargetId?.value.substring(0, 8) ?? 'null'}');
      debugPrint('TAP DEBUG: state exists=${tapState != null}');
      debugPrint('TAP DEBUG: completed=${tapState?.completed}');
      debugPrint('TAP DEBUG: cancelled=${tapState?.cancelled}');
      debugPrint('TAP DEBUG: tapCount=${tapState?.tapCount}');
      debugPrint(
          'TAP DEBUG: trackedEntityId=${_nodeTapManager.trackedEntityId?.value.substring(0, 8) ?? 'null'}');

      debugPrint(
          'TAP DEBUG: Final check - isStillDraggingAfterUp=$isStillDraggingAfterUp, isTapCompletedAfterUp=$isTapCompletedAfterUp');

      debugPrint(
          'isStillDraggingAfterUp: $isStillDraggingAfterUp, isTapCompletedAfterUp: $isTapCompletedAfterUp');
      if (!isStillDraggingAfterUp && isTapCompletedAfterUp) {
        debugPrint('tap!');
        logDebug(
          LogCategory.gesture,
          'Toggling selection for Node: ${nodeTargetId.value.substring(0, 4)}',
        );
        toggleSelection(nodeTargetId, details: details);
        final tapCount = _nodeTapManager.getTapCount(nodeTargetId) ?? 1;
        final tapEvent = GraphTapEvent(
          entityIds: [nodeTargetId],
          details: details,
          tapCount: tapCount,
        );
        viewBehavior.onTap(tapEvent);
        entityProcessed = true;

        // Clean up tap state after successful tap processing
        _nodeTapManager.cleanupTapState(nodeTargetId);
      } else {
        logDebug(
          LogCategory.gesture,
          'NOT Toggling selection for Node: ${nodeTargetId.value.substring(0, 4)} (isStillDraggingAfterUp=$isStillDraggingAfterUp, isTapCompletedAfterUp=$isTapCompletedAfterUp)',
        );

        // Log detailed failure reason for tap recognition
        String failureReason = '';
        if (isStillDraggingAfterUp && !isTapCompletedAfterUp) {
          failureReason = 'still_dragging_and_tap_not_completed';
        } else if (isStillDraggingAfterUp) {
          failureReason = 'still_dragging';
        } else if (!isTapCompletedAfterUp) {
          failureReason = 'tap_not_completed';
        } else {
          failureReason = 'unknown';
        }

        logGestureDebug(
          GestureDebugEventType.tapDebugState,
          'GraphGestureManager',
          'TAP_RECOGNITION_FAILED',
          {
            'event_type': 'tap_recognition_failed',
            'nodeTargetId': nodeTargetId.value,
            'failure_reason': failureReason,
            'is_still_dragging_after_up': isStillDraggingAfterUp,
            'is_tap_completed_after_up': isTapCompletedAfterUp,
            'tap_state_exists': tapState != null,
            'tap_state_completed': tapState?.completed ?? false,
            'tap_state_cancelled': tapState?.cancelled ?? false,
            'tap_count': tapState?.tapCount ?? 0,
            'tracked_entity_id':
                _nodeTapManager.trackedEntityId?.value ?? 'null',
          },
        );
      }
      entityProcessed = true;
    }

    final linkTargetId =
        _linkTapManager.trackedEntityId ?? _linkDragManager.lastDraggedEntityId;
    if (linkTargetId != null) {
      final link = graph.getLink(linkTargetId);
      if (link == null) {
        _linkTapManager.cleanupTapState(linkTargetId);
        _linkDragManager.cancel(linkTargetId);
        return;
      }

      _linkTapManager.handlePointerUp(linkTargetId, event);
      _linkDragManager.handlePointerUp(linkTargetId, event);

      final isStillDraggingAfterUp = _linkDragManager.isDragging(linkTargetId);
      final isTapCompletedAfterUp =
          _linkTapManager.isTapCompleted(linkTargetId);

      logDebug(
        LogCategory.gesture,
        'Final check (Link: ${linkTargetId.value.substring(0, 4)}): isStillDraggingAfterUp=$isStillDraggingAfterUp, isTapCompletedAfterUp=$isTapCompletedAfterUp',
      );

      if (!isStillDraggingAfterUp && isTapCompletedAfterUp) {
        logDebug(
          LogCategory.gesture,
          'Toggling selection for Link: ${linkTargetId.value.substring(0, 4)}',
        );
        toggleSelection(linkTargetId, details: details);
        final tapCount = _linkTapManager.getTapCount(linkTargetId) ?? 1;
        final tapEvent = GraphTapEvent(
          entityIds: [linkTargetId],
          details: details,
          tapCount: tapCount,
        );
        viewBehavior.onTap(tapEvent);
        entityProcessed = true;

        // Clean up tap state after successful tap processing
        _linkTapManager.cleanupTapState(linkTargetId);
      } else {
        logDebug(
          LogCategory.gesture,
          'NOT Toggling selection for Link: ${linkTargetId.value.substring(0, 4)} (isStillDraggingAfterUp=$isStillDraggingAfterUp, isTapCompletedAfterUp=$isTapCompletedAfterUp)',
        );
      }
      entityProcessed = true;
    }

    // Check if we should call background callback
    if (!entityProcessed && gestureMode == GraphGestureMode.nodeEdgeOnly) {
      // No entity was processed, this is a true background tap
      logDebug(LogCategory.gesture,
          'handlePointerUp: No entity processed, might be background tap');
    }
  }

  void handlePointerCancel(PointerCancelEvent event) {
    _lastPointerDetails =
        PointerEventDetails.fromPointerEvent(event); // Update details on cancel
    // Cancel any active tap or drag associated with this pointer
    final nodeTargetId =
        _nodeTapManager.trackedEntityId ?? _nodeDragManager.lastDraggedEntityId;
    if (nodeTargetId != null) {
      _nodeTapManager.handlePointerCancel(nodeTargetId, event);
      _nodeDragManager.handlePointerCancel(nodeTargetId, event);
      return;
    }

    final linkTargetId =
        _linkTapManager.trackedEntityId ?? _linkDragManager.lastDraggedEntityId;
    if (linkTargetId != null) {
      _linkTapManager.handlePointerCancel(linkTargetId, event);
      _linkDragManager.handlePointerCancel(linkTargetId, event);
      return;
    }
  }

  void handlePanStart(DragStartDetails details) {
    // Store details, can be useful for events
    // Note: DragStartDetails doesn't directly map to PointerEventDetails easily
    // We might need to rely on _lastPointerDetails from PointerDownEvent

    // Prefer dragging nodes over links if both are present
    final node = findNodeAt(details.localPosition);
    if (node != null && node.canDrag) {
      _nodeDragManager.handlePanStart([node.id], details);
      if (_nodeDragManager.isActive) {
        // Check if drag actually started
        // Use the details captured during PointerDown
        if (_lastPointerDetails == null) {
          // Should not happen if PointerDown was processed correctly
          logError(LogCategory.gesture,
              '_lastPointerDetails is null in handlePanStart');
          return;
        }
        final event = GraphDragStartEvent(
          entityIds: [node.id],
          details: _lastPointerDetails!, // Assumes not null after PointerDown
        );
        viewBehavior.onDragStart(event);
        // ドラッグ開始時にタップタイマーをキャンセル（少し遅延を加える）
        Future.delayed(const Duration(milliseconds: 50), () {
          _nodeTapManager.cancel(node.id);
        });
        logDebug(LogCategory.gesture,
            'Cancelled tap timer for dragged node: ${node.id.value.substring(0, 4)}');
      }
      // In nodeEdgeOnly mode, we handled the node, so don't call background callback
      if (gestureMode == GraphGestureMode.nodeEdgeOnly) {
        logDebug(LogCategory.gesture,
            'handlePanStart: Skipping background callback - node handled in nodeEdgeOnly mode');
        return;
      }
      // In transparent mode, don't return early so gestures can pass through
      if (gestureMode != GraphGestureMode.transparent) {
        return;
      }
    }

    final link = findLinkAt(details.localPosition);
    if (link != null && link.canDrag) {
      _linkDragManager.handlePanStart([link.id], details);
      if (_linkDragManager.isActive) {
        if (_lastPointerDetails == null) {
          logError(
            LogCategory.gesture,
            '_lastPointerDetails is null in handlePanStart (link)',
          );
          return;
        }
        final event = GraphDragStartEvent(
          entityIds: [link.id],
          details: _lastPointerDetails!, // Assumes not null after PointerDown
        );
        viewBehavior.onDragStart(event);
        // ドラッグ開始時にタップタイマーを即座にキャンセルして再描画を防ぐ
        _linkTapManager.cancel(link.id);
        logDebug(LogCategory.gesture,
            'Cancelled tap timer for dragged link: ${link.id.value.substring(0, 4)}');
      }
      // In nodeEdgeOnly mode, we handled the link, so don't call background callback
      if (gestureMode == GraphGestureMode.nodeEdgeOnly) {
        logDebug(LogCategory.gesture,
            'handlePanStart: Skipping background callback - link handled in nodeEdgeOnly mode');
        return;
      }
      // In transparent mode, don't return early so gestures can pass through
      if (gestureMode != GraphGestureMode.transparent) {
        return;
      }
    }

    // Only call background callback if no entity was found
    // Double-check to prevent race conditions
    final reCheckNode = findNodeAt(details.localPosition);
    final reCheckLink = findLinkAt(details.localPosition);

    if (node == null &&
        link == null &&
        reCheckNode == null &&
        reCheckLink == null) {
      logDebug(LogCategory.gesture,
          'handlePanStart: True background pan (double-checked), calling callback');
      onBackgroundPanStart?.call(details.localPosition);
    } else {
      logDebug(LogCategory.gesture,
          'handlePanStart: Entity found (or re-found), not calling background callback');
    }
  }

  void handlePanUpdate(DragUpdateDetails details) {
    // DO NOT create a new PointerEventDetails from DragUpdateDetails
    // Use the last known details
    if (_lastPointerDetails == null) {
      logError(LogCategory.gesture,
          '_lastPointerDetails is null in handlePanUpdate');
      // Cannot proceed without details, maybe cancel drag?
      // For now, just return to avoid crash
      return;
    }

    // If dragging a node, always update the node drag manager
    if (_nodeDragManager.isActive) {
      final updatedIds = _nodeDragManager.handlePanUpdate(details);
      // Dispatch drag update event if nodes were actually moved
      if (updatedIds.isNotEmpty) {
        final event = GraphDragUpdateEvent(
          entityIds: updatedIds,
          details: _lastPointerDetails!, // Use last known details
          delta: details.delta, // Include delta in the event
        );
        viewBehavior.onDragUpdate(event);
      }
      // Also check if the tap should be cancelled due to movement
      final draggedNodeId = _nodeDragManager.lastDraggedEntityId;
      if (draggedNodeId != null) {
        _nodeTapManager.handlePanUpdate(draggedNodeId, details);
      }
      return; // Don't check for links if already dragging a node
    }

    // If dragging a link (currently not supported but for completeness)
    if (_linkDragManager.isActive) {
      final updatedIds = _linkDragManager.handlePanUpdate(details);
      // Dispatch drag update event if links were actually moved (if supported)
      if (updatedIds.isNotEmpty) {
        final event = GraphDragUpdateEvent(
          entityIds: updatedIds,
          details: _lastPointerDetails!, // Use last known details
          delta: details.delta, // Include delta in the event
        );
        viewBehavior.onDragUpdate(event);
      }
      final draggedLinkId = _linkDragManager.lastDraggedEntityId;
      if (draggedLinkId != null) {
        _linkTapManager.handlePanUpdate(draggedLinkId, details);
      }
      return;
    }

    // If not currently dragging, check if movement cancels a pending tap
    final node = findNodeAt(details.localPosition);
    if (node != null) {
      _nodeTapManager.handlePanUpdate(node.id, details);
      // In nodeEdgeOnly mode, we're handling a node, so don't call background callback
      if (gestureMode == GraphGestureMode.nodeEdgeOnly) {
        logDebug(LogCategory.gesture,
            'handlePanUpdate: Skipping background callback - node handled in nodeEdgeOnly mode');
        return;
      }
    }
    final link = findLinkAt(details.localPosition);
    if (link != null) {
      _linkTapManager.handlePanUpdate(link.id, details);
      // In nodeEdgeOnly mode, we're handling a link, so don't call background callback
      if (gestureMode == GraphGestureMode.nodeEdgeOnly) {
        logDebug(LogCategory.gesture,
            'handlePanUpdate: Skipping background callback - link handled in nodeEdgeOnly mode');
        return;
      }
    }

    // Check if this is a background pan update
    if (!shouldConsumeGestureAt(details.localPosition)) {
      onBackgroundPanUpdate?.call(details.localPosition, details.delta);
      return;
    }

    // Only call background callback if no entity was found
    // Double-check to prevent race conditions
    final reCheckNode = findNodeAt(details.localPosition);
    final reCheckLink = findLinkAt(details.localPosition);

    if (node == null &&
        link == null &&
        reCheckNode == null &&
        reCheckLink == null) {
      logDebug(LogCategory.gesture,
          'handlePanUpdate: True background pan (double-checked), calling callback');
      onBackgroundPanUpdate?.call(details.localPosition, details.delta);
    } else {
      logDebug(LogCategory.gesture,
          'handlePanUpdate: Entity found (or re-found), not calling background callback');
    }
  }

  void handlePanEnd(DragEndDetails details) {
    // Use the last known pointer details for the end event
    final endPointerDetails = _lastPointerDetails;

    // Node drag end
    if (_nodeDragManager.isActive) {
      final endedDragIds = _nodeDragManager.handlePanEnd(details);
      if (endedDragIds.isNotEmpty) {
        if (endPointerDetails == null) {
          logError(LogCategory.gesture,
              '_lastPointerDetails is null in handlePanEnd');
        } else {
          final event = GraphDragEndEvent(
            entityIds: endedDragIds,
            details: endPointerDetails, // Use last known details
          );
          viewBehavior.onDragEnd(event);

          // ドラッグ終了時に残っているタップ状態を静かにクリーンアップ
          for (final nodeId in endedDragIds) {
            if (_nodeTapManager.hasState(nodeId)) {
              logDebug(LogCategory.gesture,
                  'Cleaning up tap state after drag end: ${nodeId.value.substring(0, 4)}');
              _nodeTapManager.removeStateSilently(nodeId);
            }
          }
        }
      }
      // In nodeEdgeOnly mode, we handled a node drag, so don't call background callback
      if (gestureMode == GraphGestureMode.nodeEdgeOnly) {
        logDebug(LogCategory.gesture,
            'handlePanEnd: Skipping background callback - node drag handled in nodeEdgeOnly mode');
        return;
      }
      return;
    }

    // Link drag end (if supported)
    if (_linkDragManager.isActive) {
      final endedDragIds = _linkDragManager.handlePanEnd(details);
      if (endedDragIds.isNotEmpty) {
        if (endPointerDetails == null) {
          logError(
            LogCategory.gesture,
            '_lastPointerDetails is null in handlePanEnd (link)',
          );
        } else {
          final event = GraphDragEndEvent(
            entityIds: endedDragIds,
            details: endPointerDetails, // Use last known details
          );
          viewBehavior.onDragEnd(event);
        }
      }
      // In nodeEdgeOnly mode, we handled a link drag, so don't call background callback
      if (gestureMode == GraphGestureMode.nodeEdgeOnly) {
        logDebug(LogCategory.gesture,
            'handlePanEnd: Skipping background callback - link drag handled in nodeEdgeOnly mode');
        return;
      }
      return;
    }

    // Background pan end - only call if appropriate for the gesture mode
    if (endPointerDetails != null) {
      // In nodeEdgeOnly mode, only call if we're not over an entity
      if (gestureMode == GraphGestureMode.nodeEdgeOnly) {
        final node = findNodeAt(endPointerDetails.localPosition);
        final link = findLinkAt(endPointerDetails.localPosition);
        if (node == null && link == null) {
          logDebug(LogCategory.gesture,
              'handlePanEnd: Calling background callback (no entity at position)');
          onBackgroundPanEnd?.call(endPointerDetails.localPosition);
        } else {
          logDebug(LogCategory.gesture,
              'handlePanEnd: NOT calling background callback (entity found at position)');
        }
      } else {
        logDebug(LogCategory.gesture,
            'handlePanEnd: Calling background callback (not nodeEdgeOnly mode)');
        onBackgroundPanEnd?.call(endPointerDetails.localPosition);
      }
    }
  }

  void handlePointerMove(PointerMoveEvent event) {
    if (_nodeDragManager.isActive || findNodeAt(event.localPosition) != null) {
      _nodeDragManager.handlePointerMove(event);
      return;
    }

    if (_linkDragManager.isActive || findLinkAt(event.localPosition) != null) {
      _linkDragManager.handlePointerMove(event);
    }
  }

  void handleMouseHover(PointerHoverEvent event) {
    _lastPointerDetails = PointerEventDetails.fromPointerEvent(event);
    final hoverDetails = _lastPointerDetails!;

    if (isDragging) return;

    final node = findNodeAt(event.localPosition);
    final link = findLinkAt(event.localPosition);

    final currentHoveredNodeId = _nodeHoverManager.hoveredEntityId;
    if (node != null) {
      if (currentHoveredNodeId != node.id) {
        if (currentHoveredNodeId != null) {
          _nodeHoverManager.handleMouseExit(currentHoveredNodeId, event);
          _nodeTooltipManager.handleMouseExit(currentHoveredNodeId, event);
          viewBehavior.onHoverEnd(
            GraphHoverEndEvent(
              entityId: currentHoveredNodeId,
              details: hoverDetails,
            ),
          );
        }
        _nodeHoverManager.handleMouseHover(node.id, event);
        _nodeTooltipManager.handleMouseHover(node.id, event);
        viewBehavior.onHoverEnter(
          GraphHoverEvent(entityId: node.id, details: hoverDetails),
        );
      } else {
        _nodeTooltipManager.handleMouseHover(node.id, event);
        viewBehavior.onHoverMove(
          GraphHoverEvent(entityId: node.id, details: hoverDetails),
        );
      }
    } else if (currentHoveredNodeId != null) {
      _nodeHoverManager.handleMouseExit(currentHoveredNodeId, event);
      _nodeTooltipManager.handleMouseExit(currentHoveredNodeId, event);
      viewBehavior.onHoverEnd(
        GraphHoverEndEvent(
          entityId: currentHoveredNodeId,
          details: hoverDetails,
        ),
      );
    }

    final currentHoveredLinkId = _linkHoverManager.hoveredEntityId;
    if (node == null) {
      if (link != null) {
        if (currentHoveredLinkId != link.id) {
          if (currentHoveredLinkId != null) {
            _linkHoverManager.handleMouseExit(currentHoveredLinkId, event);
            _linkTooltipManager.handleMouseExit(currentHoveredLinkId, event);
            viewBehavior.onHoverEnd(
              GraphHoverEndEvent(
                entityId: currentHoveredLinkId,
                details: hoverDetails,
              ),
            );
          }
          _linkHoverManager.handleMouseHover(link.id, event);
          _linkTooltipManager.handleMouseHover(link.id, event);
          viewBehavior.onHoverEnter(
            GraphHoverEvent(entityId: link.id, details: hoverDetails),
          );
        } else {
          _linkTooltipManager.handleMouseHover(link.id, event);
          viewBehavior.onHoverMove(
            GraphHoverEvent(entityId: link.id, details: hoverDetails),
          );
        }
      } else if (currentHoveredLinkId != null) {
        _linkHoverManager.handleMouseExit(currentHoveredLinkId, event);
        _linkTooltipManager.handleMouseExit(currentHoveredLinkId, event);
        viewBehavior.onHoverEnd(
          GraphHoverEndEvent(
            entityId: currentHoveredLinkId,
            details: hoverDetails,
          ),
        );
      }
    } else if (currentHoveredLinkId != null) {
      _linkHoverManager.handleMouseExit(currentHoveredLinkId, event);
      _linkTooltipManager.handleMouseExit(currentHoveredLinkId, event);
      viewBehavior.onHoverEnd(
        GraphHoverEndEvent(
          entityId: currentHoveredLinkId,
          details: hoverDetails,
        ),
      );
    }
  }

  void endHover(GraphId entityId) {
    // This might be needed if hover state needs explicit ending
    // Currently handled by hover managers and handleMouseHover exit logic
    // final entity = getEntity(entityId);
    // if (entity is GraphNode) { ... } else if (entity is GraphLink) { ... }
  }

  void showTooltip(GraphId entityId) {
    final entity = getEntity(entityId);
    if (entity is GraphNode) {
      _nodeTooltipManager.show(entityId);
    } else if (entity is GraphLink) {
      _linkTooltipManager.show(entityId);
    }
  }

  void hideTooltip(GraphId entityId) {
    final entity = getEntity(entityId);
    if (entity is GraphNode) {
      _nodeTooltipManager.cancel(entityId);
    } else if (entity is GraphLink) {
      _linkTooltipManager.cancel(entityId);
    }
  }

  void toggleTooltip(GraphId entityId) {
    final entity = getEntity(entityId);
    if (entity is GraphNode) {
      _nodeTooltipManager.toggle(entityId);
    } else if (entity is GraphLink) {
      _linkTooltipManager.toggle(entityId);
    }
  }
}
