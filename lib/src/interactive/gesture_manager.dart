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
import 'package:plough/src/interactive/hover_state.dart';
import 'package:plough/src/interactive/tap_state.dart';
import 'package:plough/src/interactive/tooltip_state.dart';
import 'package:plough/src/tooltip/behavior.dart';

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
    debugPrint('[GESTURE_MODE] shouldConsumeGestureAt: mode=$gestureMode, hasEntity=${hitTestResult.hasEntity}');
    
    bool result;
    switch (gestureMode) {
      case GraphGestureMode.exclusive:
        result = true;
        debugPrint('[GESTURE_MODE] Exclusive mode: consuming gesture');
      case GraphGestureMode.nodeEdgeOnly:
        result = hitTestResult.hasEntity;
        debugPrint('[GESTURE_MODE] NodeEdgeOnly mode: ${result ? 'consuming' : 'not consuming'} (hasEntity=${hitTestResult.hasEntity})');
      case GraphGestureMode.transparent:
        result = false;
        debugPrint('[GESTURE_MODE] Transparent mode: not consuming gesture');
      case GraphGestureMode.custom:
        result = shouldConsumeGesture?.call(position, hitTestResult) ?? true;
        debugPrint('[GESTURE_MODE] Custom mode: ${result ? 'consuming' : 'not consuming'}');
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
      debugPrint(
        '[SELECTION] _dispatchSelectionChange: newlySelected=${newlySelected.map((id) => id.value.substring(0, 4)).join(', ')}, newlyDeselected=${newlyDeselected.map((id) => id.value.substring(0, 4)).join(', ')}',
      );
      final event = GraphSelectionChangeEvent(
        selectedIds: newlySelected,
        deselectedIds: newlyDeselected,
        currentSelectionIds: graph.selectedEntityIds.toList(),
        details: details,
      );
      viewBehavior.onSelectionChange(event);
    } else {
      debugPrint('[SELECTION] _dispatchSelectionChange: No actual changes, skipping event dispatch');
    }
  }

  void toggleSelection(GraphId entityId, {PointerEventDetails? details}) {
    debugPrint(
      '[SELECTION] toggleSelection called for: ${entityId.value.substring(0, 4)}',
    );
    final currentSelection = graph.selectedEntityIds.toSet();
    debugPrint(
      '[SELECTION] Current selection before toggle: '
      '[${currentSelection.map((id) => id.value.substring(0, 4)).join(', ')}]',
    );

    if (currentSelection.contains(entityId)) {
      debugPrint('[SELECTION] Entity is already selected, deselecting');
      deselectEntities([entityId], details: details);
    } else {
      debugPrint('[SELECTION] Entity not selected, selecting');
      selectEntities([entityId], details: details);
    }
  }

  void selectEntities(List<GraphId> entityIds, {PointerEventDetails? details}) {
    debugPrint(
      '[SELECTION] selectEntities called for: '
      '[${entityIds.map((id) => id.value.substring(0, 4)).join(', ')}]',
    );
    final currentSelection = graph.selectedEntityIds.toSet();
    debugPrint(
      '[SELECTION] Current selection before select: '
      '[${currentSelection.map((id) => id.value.substring(0, 4)).join(', ')}]',
    );
    final newlySelected = <GraphId>[];
    final newlyDeselected = <GraphId>[];

    final idsToSelect =
        entityIds.where((id) => !currentSelection.contains(id)).toList();
    debugPrint('[SELECTION] IDs to select: [${idsToSelect.map((id) => id.value.substring(0, 4)).join(', ')}]');
    
    if (idsToSelect.isNotEmpty) {
      final othersToDeselect =
          currentSelection.where((id) => !entityIds.contains(id)).toList();
      if (othersToDeselect.isNotEmpty) {
        debugPrint('[SELECTION] Deselecting others first: [${othersToDeselect.map((id) => id.value.substring(0, 4)).join(', ')}]');
        _deselectEntitiesInternal(othersToDeselect);
        newlyDeselected.addAll(othersToDeselect);
      }
    }

    for (final entityId in entityIds) {
      if (!currentSelection.contains(entityId)) {
        final entity = getEntity(entityId);
        if (entity is GraphNode && entity.canSelect) {
          debugPrint(
            '[SELECTION] Selecting Node: '
            '${entity.id.value.substring(0, 4)}',
          );
          graph.selectNode(entity.id);
          newlySelected.add(entity.id);
        } else if (entity is GraphLink && entity.canSelect) {
          debugPrint(
            '[SELECTION] Selecting Link: '
            '${entity.id.value.substring(0, 4)}',
          );
          graph.selectLink(entity.id);
          newlySelected.add(entity.id);
        } else {
          debugPrint(
            '[SELECTION] NOT selecting ${entity?.runtimeType ?? 'Unknown'} '
            '(${entityId.value.substring(0, 4)}): canSelect=${entity?.canSelect}',
          );
        }
      } else {
        debugPrint('[SELECTION] Entity ${entityId.value.substring(0, 4)} already selected, skipping');
      }
    }

    debugPrint('[SELECTION] About to dispatch: newlySelected=[${newlySelected.map((id) => id.value.substring(0, 4)).join(', ')}], newlyDeselected=[${newlyDeselected.map((id) => id.value.substring(0, 4)).join(', ')}]');
    _dispatchSelectionChange(newlySelected, newlyDeselected, details: details);
  }

  void _deselectEntitiesInternal(List<GraphId> entityIds) {
    for (final entityId in entityIds) {
      final entity = getEntity(entityId);
      debugPrint(
        '[GestureManager] _deselectInternal: ${entityId.value.substring(0, 4)}',
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
    debugPrint(
      '[SELECTION] deselectEntities called for: '
      '[${entityIds.map((id) => id.value.substring(0, 4)).join(', ')}]',
    );
    final currentSelection = graph.selectedEntityIds.toSet();
    debugPrint(
      '[SELECTION] Current selection before deselect: '
      '[${currentSelection.map((id) => id.value.substring(0, 4)).join(', ')}]',
    );
    final newlyDeselected = <GraphId>[];

    for (final entityId in entityIds) {
      if (currentSelection.contains(entityId)) {
        final entity = getEntity(entityId);
        if (entity is GraphNode) {
          debugPrint(
            '[SELECTION] Deselecting Node: '
            '${entity.id.value.substring(0, 4)}',
          );
          graph.deselectNode(entity.id);
          newlyDeselected.add(entity.id);
        } else if (entity is GraphLink) {
          debugPrint(
            '[SELECTION] Deselecting Link: '
            '${entity.id.value.substring(0, 4)}',
          );
          graph.deselectLink(entity.id);
          newlyDeselected.add(entity.id);
        }
      } else {
        debugPrint('[SELECTION] Entity ${entityId.value.substring(0, 4)} not selected, skipping deselect');
      }
    }
    debugPrint('[SELECTION] About to dispatch deselection: newlyDeselected=[${newlyDeselected.map((id) => id.value.substring(0, 4)).join(', ')}]');
    _dispatchSelectionChange([], newlyDeselected, details: details);
  }

  void deselectAll({PointerEventDetails? details}) {
    debugPrint('[SELECTION] deselectAll called');
    final currentSelection = graph.selectedEntityIds.toList();
    debugPrint('[SELECTION] Current selection: [${currentSelection.map((id) => id.value.substring(0, 4)).join(', ')}]');
    if (currentSelection.isNotEmpty) {
      debugPrint('[SELECTION] Deselecting all ${currentSelection.length} entities');
      deselectEntities(currentSelection, details: details);
    } else {
      debugPrint('[SELECTION] No entities selected, skipping deselect to avoid unnecessary rebuilds');
      // Don't call deselectEntities when there's nothing to deselect
      // This prevents unnecessary event dispatching and rebuilds
    }
  }

  void handlePointerDown(PointerDownEvent event) {
    debugPrint('[POINTER_DOWN] Starting handlePointerDown at ${event.localPosition}, mode: $gestureMode');
    
    _nodeHoverManager.handlePointerDown(event);
    _linkHoverManager.handlePointerDown(event);

    final node = findNodeAt(event.localPosition);
    if (node != null) {
      debugPrint('[POINTER_DOWN] Node found: ${node.id.value.substring(0, 4)}');
      _nodeTapManager.handlePointerDown(node.id, event);
      _nodeDragManager.handlePointerDown(node.id, event);
      // Return early for all modes except transparent
      if (gestureMode == GraphGestureMode.transparent) {
        debugPrint('[POINTER_DOWN] Continuing after node processing (transparent mode)');
      } else {
        debugPrint('[POINTER_DOWN] Early return for node (mode: $gestureMode)');
        return;
      }
    }

    final link = findLinkAt(event.localPosition);
    if (link != null) {
      debugPrint('[POINTER_DOWN] Link found: ${link.id.value.substring(0, 4)}');
      _linkTapManager.handlePointerDown(link.id, event);
      _linkDragManager.handlePointerDown(link.id, event);
      // Return early for all modes except transparent
      if (gestureMode == GraphGestureMode.transparent) {
        debugPrint('[POINTER_DOWN] Continuing after link processing (transparent mode)');
      } else {
        debugPrint('[POINTER_DOWN] Early return for link (mode: $gestureMode)');
        return;
      }
    }

    // Check if we should consume this gesture (after processing entities)
    final shouldConsume = shouldConsumeGestureAt(event.localPosition);
    debugPrint('[POINTER_DOWN] shouldConsumeGesture: $shouldConsume');
    
    if (!shouldConsume) {
      debugPrint('[POINTER_DOWN] Not consuming gesture, calling background callback');
      // Call background callback if available
      onBackgroundTapped?.call(event.localPosition);
      // In transparent mode, don't deselect when background is tapped
      if (gestureMode != GraphGestureMode.transparent) {
        debugPrint('[POINTER_DOWN] Calling deselectAll (non-transparent mode)');
        deselectAll(details: _lastPointerDetails);
      } else {
        debugPrint('[POINTER_DOWN] Skipping deselectAll (transparent mode)');
      }
      return;
    }

    // Background was tapped - but check if we should call callback based on mode
    debugPrint('[POINTER_DOWN] Background area, checking if should call callback');
    if (gestureMode == GraphGestureMode.nodeEdgeOnly && (node != null || link != null)) {
      debugPrint('[GESTURE] handlePointerDown: NOT calling onBackgroundTapped - entity found in nodeEdgeOnly mode');
    } else {
      debugPrint('[GESTURE] handlePointerDown: Calling onBackgroundTapped');
      onBackgroundTapped?.call(event.localPosition);
    }
    deselectAll(details: _lastPointerDetails);
  }

  void handlePointerUp(PointerUpEvent event) {
    debugPrint('[POINTER_UP] Starting handlePointerUp at ${event.localPosition}, mode: $gestureMode');
    _lastPointerDetails = PointerEventDetails.fromPointerEvent(event);
    final details = _lastPointerDetails!;
    
    // Track if we're processing an entity
    bool entityProcessed = false;

    final nodeTargetId =
        _nodeTapManager.trackedEntityId ?? _nodeDragManager.lastDraggedEntityId;
    debugPrint('[POINTER_UP] Node target ID: ${nodeTargetId?.value.substring(0, 4) ?? 'null'}');
    
    if (nodeTargetId != null) {
      final node = graph.getNode(nodeTargetId);
      if (node == null) {
        debugPrint('[POINTER_UP] Node not found, cleaning up');
        _nodeTapManager.cleanupTapState(nodeTargetId);
        _nodeDragManager.cancel(nodeTargetId);
        return;
      }

      debugPrint('[POINTER_UP] Processing node: ${node.id.value.substring(0, 4)}');
      _nodeTapManager.handlePointerUp(nodeTargetId, event);
      _nodeDragManager.handlePointerUp(nodeTargetId, event);

      final isStillDraggingAfterUp = _nodeDragManager.isDragging(nodeTargetId);
      final isTapCompletedAfterUp =
          _nodeTapManager.isTapCompleted(nodeTargetId);

      debugPrint(
        '[POINTER_UP] Final check (Node: '
        '${nodeTargetId.value.substring(0, 4)}): '
        'isStillDraggingAfterUp=$isStillDraggingAfterUp, '
        'isTapCompletedAfterUp=$isTapCompletedAfterUp',
      );

      if (!isStillDraggingAfterUp && isTapCompletedAfterUp) {
        debugPrint(
          '[POINTER_UP] Toggling selection for Node: '
          '${nodeTargetId.value.substring(0, 4)}',
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
      } else {
        debugPrint(
          '[POINTER_UP] NOT Toggling selection for Node: '
          '${nodeTargetId.value.substring(0, 4)} '
          '(isStillDraggingAfterUp=$isStillDraggingAfterUp, '
          'isTapCompletedAfterUp=$isTapCompletedAfterUp)',
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

      debugPrint(
        '[GestureManager] Final check (Link: '
        '${linkTargetId.value.substring(0, 4)}): '
        'isStillDraggingAfterUp=$isStillDraggingAfterUp, '
        'isTapCompletedAfterUp=$isTapCompletedAfterUp',
      );

      if (!isStillDraggingAfterUp && isTapCompletedAfterUp) {
        debugPrint(
          '[GestureManager] Toggling selection for Link: '
          '${linkTargetId.value.substring(0, 4)}',
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
      } else {
        debugPrint(
          '[GestureManager] NOT Toggling selection for Link: '
          '${linkTargetId.value.substring(0, 4)} '
          '(isStillDraggingAfterUp=$isStillDraggingAfterUp, '
          'isTapCompletedAfterUp=$isTapCompletedAfterUp)',
        );
      }
      entityProcessed = true;
    }
    
    // Check if we should call background callback
    if (!entityProcessed && gestureMode == GraphGestureMode.nodeEdgeOnly) {
      // No entity was processed, this is a true background tap
      debugPrint('[GESTURE] handlePointerUp: No entity processed, might be background tap');
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
          debugPrint('Error: _lastPointerDetails is null in handlePanStart');
          return;
        }
        final event = GraphDragStartEvent(
          entityIds: [node.id],
          details: _lastPointerDetails!, // Assumes not null after PointerDown
        );
        viewBehavior.onDragStart(event);
        // Cancel any pending tap on the node being dragged
        // _nodeTapManager.cancel(node.id); // Removed: Let handlePanUpdate cancel based on slop
      }
      // In nodeEdgeOnly mode, we handled the node, so don't call background callback
      if (gestureMode == GraphGestureMode.nodeEdgeOnly) {
        debugPrint('[GESTURE] handlePanStart: Skipping background callback - node handled in nodeEdgeOnly mode');
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
          debugPrint(
            'Error: _lastPointerDetails is null in handlePanStart (link)',
          );
          return;
        }
        final event = GraphDragStartEvent(
          entityIds: [link.id],
          details: _lastPointerDetails!, // Assumes not null after PointerDown
        );
        viewBehavior.onDragStart(event);
        // Cancel any pending tap on the link being dragged
        // _linkTapManager.cancel(link.id); // Removed: Let handlePanUpdate cancel based on slop
      }
      // In nodeEdgeOnly mode, we handled the link, so don't call background callback
      if (gestureMode == GraphGestureMode.nodeEdgeOnly) {
        debugPrint('[GESTURE] handlePanStart: Skipping background callback - link handled in nodeEdgeOnly mode');
        return;
      }
      // In transparent mode, don't return early so gestures can pass through
      if (gestureMode != GraphGestureMode.transparent) {
        return;
      }
    }

    // Check if we should consume this gesture (after processing entities)
    if (!shouldConsumeGestureAt(details.localPosition)) {
      onBackgroundPanStart?.call(details.localPosition);
      return;
    }

    // Background pan start - only call if we haven't handled an entity in nodeEdgeOnly mode
    if (gestureMode != GraphGestureMode.nodeEdgeOnly || (node == null && link == null)) {
      debugPrint('[GESTURE] handlePanStart: Calling background callback');
      onBackgroundPanStart?.call(details.localPosition);
    } else {
      debugPrint('[GESTURE] handlePanStart: NOT calling background callback (nodeEdgeOnly with entity)');
    }
  }

  void handlePanUpdate(DragUpdateDetails details) {
    // DO NOT create a new PointerEventDetails from DragUpdateDetails
    // Use the last known details
    if (_lastPointerDetails == null) {
      debugPrint('Error: _lastPointerDetails is null in handlePanUpdate');
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
        debugPrint('[GESTURE] handlePanUpdate: Skipping background callback - node handled in nodeEdgeOnly mode');
        return;
      }
    }
    final link = findLinkAt(details.localPosition);
    if (link != null) {
      _linkTapManager.handlePanUpdate(link.id, details);
      // In nodeEdgeOnly mode, we're handling a link, so don't call background callback
      if (gestureMode == GraphGestureMode.nodeEdgeOnly) {
        debugPrint('[GESTURE] handlePanUpdate: Skipping background callback - link handled in nodeEdgeOnly mode');
        return;
      }
    }

    // Check if this is a background pan update
    if (!shouldConsumeGestureAt(details.localPosition)) {
      onBackgroundPanUpdate?.call(details.localPosition, details.delta);
      return;
    }

    // Background pan update - only call if we haven't handled an entity in nodeEdgeOnly mode
    if (gestureMode != GraphGestureMode.nodeEdgeOnly || (node == null && link == null)) {
      debugPrint('[GESTURE] handlePanUpdate: Calling background callback');
      onBackgroundPanUpdate?.call(details.localPosition, details.delta);
    } else {
      debugPrint('[GESTURE] handlePanUpdate: NOT calling background callback (nodeEdgeOnly with entity)');
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
          debugPrint('Error: _lastPointerDetails is null in handlePanEnd');
        } else {
          final event = GraphDragEndEvent(
            entityIds: endedDragIds,
            details: endPointerDetails, // Use last known details
          );
          viewBehavior.onDragEnd(event);
        }
      }
      // In nodeEdgeOnly mode, we handled a node drag, so don't call background callback
      if (gestureMode == GraphGestureMode.nodeEdgeOnly) {
        debugPrint('[GESTURE] handlePanEnd: Skipping background callback - node drag handled in nodeEdgeOnly mode');
        return;
      }
      return;
    }

    // Link drag end (if supported)
    if (_linkDragManager.isActive) {
      final endedDragIds = _linkDragManager.handlePanEnd(details);
      if (endedDragIds.isNotEmpty) {
        if (endPointerDetails == null) {
          debugPrint(
            'Error: _lastPointerDetails is null in handlePanEnd (link)',
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
        debugPrint('[GESTURE] handlePanEnd: Skipping background callback - link drag handled in nodeEdgeOnly mode');
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
          debugPrint('[GESTURE] handlePanEnd: Calling background callback (no entity at position)');
          onBackgroundPanEnd?.call(endPointerDetails.localPosition);
        } else {
          debugPrint('[GESTURE] handlePanEnd: NOT calling background callback (entity found at position)');
        }
      } else {
        debugPrint('[GESTURE] handlePanEnd: Calling background callback (not nodeEdgeOnly mode)');
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
