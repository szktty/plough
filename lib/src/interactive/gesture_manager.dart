import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:plough/src/graph/entity.dart';
import 'package:plough/src/graph/graph_base.dart';
import 'package:plough/src/graph/id.dart';
import 'package:plough/src/graph/link.dart';
import 'package:plough/src/graph/node.dart';
import 'package:plough/src/graph/order_manager.dart';
import 'package:plough/src/graph_view/behavior.dart';
import 'package:plough/src/interactive/drag_state.dart';
import 'package:plough/src/interactive/events.dart';
import 'package:plough/src/interactive/hover_state.dart';
import 'package:plough/src/interactive/tap_state.dart';
import 'package:plough/src/interactive/tooltip_state.dart';
import 'package:plough/src/tooltip/behavior.dart';

class GraphGestureManager {
  GraphGestureManager({
    required this.graph,
    required this.viewBehavior,
    required this.viewportSize,
    this.nodeTooltipTriggerMode,
    this.linkTooltipTriggerMode,
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
        '[GestureManager] _dispatchSelectionChange: newlySelected=${newlySelected.map((id) => id.value.substring(0, 4)).join(', ')}, newlyDeselected=${newlyDeselected.map((id) => id.value.substring(0, 4)).join(', ')}',
      );
      final event = GraphSelectionChangeEvent(
        selectedIds: newlySelected,
        deselectedIds: newlyDeselected,
        currentSelectionIds: graph.selectedEntityIds.toList(),
        details: details,
      );
      viewBehavior.onSelectionChange(event);
    }
  }

  void toggleSelection(GraphId entityId, {PointerEventDetails? details}) {
    debugPrint(
      '[GestureManager] toggleSelection called for: ${entityId.value.substring(0, 4)}',
    );
    final currentSelection = graph.selectedEntityIds.toSet();
    final newlySelected = <GraphId>[];
    final newlyDeselected = <GraphId>[];

    if (currentSelection.contains(entityId)) {
      deselectEntities([entityId], details: details);
    } else {
      selectEntities([entityId], details: details);
    }
  }

  void selectEntities(List<GraphId> entityIds, {PointerEventDetails? details}) {
    debugPrint(
      '[GestureManager] selectEntities called for: ${entityIds.map((id) => id.value.substring(0, 4)).join(', ')}',
    );
    final currentSelection = graph.selectedEntityIds.toSet();
    final newlySelected = <GraphId>[];
    final newlyDeselected = <GraphId>[];

    final idsToSelect =
        entityIds.where((id) => !currentSelection.contains(id)).toList();
    if (idsToSelect.isNotEmpty) {
      final othersToDeselect =
          currentSelection.where((id) => !entityIds.contains(id)).toList();
      if (othersToDeselect.isNotEmpty) {
        _deselectEntitiesInternal(othersToDeselect);
        newlyDeselected.addAll(othersToDeselect);
      }
    }

    for (final entityId in entityIds) {
      if (!currentSelection.contains(entityId)) {
        final entity = getEntity(entityId);
        if (entity is GraphNode && entity.canSelect) {
          debugPrint(
            '[GestureManager] selecting Node: ${entity.id.value.substring(0, 4)}',
          );
          graph.selectNode(entity.id);
          newlySelected.add(entity.id);
        } else if (entity is GraphLink && entity.canSelect) {
          debugPrint(
            '[GestureManager] selecting Link: ${entity.id.value.substring(0, 4)}',
          );
          graph.selectLink(entity.id);
          newlySelected.add(entity.id);
        } else {
          debugPrint(
            '[GestureManager] NOT selecting ${entity?.runtimeType ?? 'Unknown'} (${entityId.value.substring(0, 4)}): canSelect=${entity?.canSelect}',
          );
        }
      }
    }

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
      '[GestureManager] deselectEntities called for: ${entityIds.map((id) => id.value.substring(0, 4)).join(', ')}',
    );
    final currentSelection = graph.selectedEntityIds.toSet();
    final newlyDeselected = <GraphId>[];

    for (final entityId in entityIds) {
      if (currentSelection.contains(entityId)) {
        final entity = getEntity(entityId);
        if (entity is GraphNode) {
          debugPrint(
            '[GestureManager] deselecting Node: ${entity.id.value.substring(0, 4)}',
          );
          graph.deselectNode(entity.id);
          newlyDeselected.add(entity.id);
        } else if (entity is GraphLink) {
          debugPrint(
            '[GestureManager] deselecting Link: ${entity.id.value.substring(0, 4)}',
          );
          graph.deselectLink(entity.id);
          newlyDeselected.add(entity.id);
        }
      }
    }
    _dispatchSelectionChange([], newlyDeselected, details: details);
  }

  void deselectAll({PointerEventDetails? details}) {
    final currentSelection = graph.selectedEntityIds.toList();
    if (currentSelection.isNotEmpty) {
      deselectEntities(currentSelection, details: details);
    }
  }

  void handlePointerDown(PointerDownEvent event) {
    _nodeHoverManager.handlePointerDown(event);
    _linkHoverManager.handlePointerDown(event);

    final node = findNodeAt(event.localPosition);
    if (node != null) {
      _nodeTapManager.handlePointerDown(node.id, event);
      _nodeDragManager.handlePointerDown(node.id, event);
      return;
    }

    final link = findLinkAt(event.localPosition);
    if (link != null) {
      _linkTapManager.handlePointerDown(link.id, event);
      _linkDragManager.handlePointerDown(link.id, event);
    }

    deselectAll(details: _lastPointerDetails);
  }

  void handlePointerUp(PointerUpEvent event) {
    _lastPointerDetails = PointerEventDetails.fromPointerEvent(event);
    final details = _lastPointerDetails!;

    final nodeTargetId =
        _nodeTapManager.trackedEntityId ?? _nodeDragManager.lastDraggedEntityId;
    if (nodeTargetId != null) {
      final node = graph.getNode(nodeTargetId);
      if (node == null) {
        _nodeTapManager.cleanupTapState(nodeTargetId);
        _nodeDragManager.cancel(nodeTargetId);
        return;
      }

      _nodeTapManager.handlePointerUp(nodeTargetId, event);
      _nodeDragManager.handlePointerUp(nodeTargetId, event);

      final isStillDraggingAfterUp = _nodeDragManager.isDragging(nodeTargetId);
      final isTapCompletedAfterUp =
          _nodeTapManager.isTapCompleted(nodeTargetId);

      debugPrint(
        '[GestureManager] Final check (Node: ${nodeTargetId.value.substring(0, 4)}): isStillDraggingAfterUp=$isStillDraggingAfterUp, isTapCompletedAfterUp=$isTapCompletedAfterUp',
      );

      if (!isStillDraggingAfterUp && isTapCompletedAfterUp) {
        debugPrint(
          '[GestureManager] Toggling selection for Node: ${nodeTargetId.value.substring(0, 4)}',
        );
        toggleSelection(nodeTargetId, details: details);
        final tapCount = _nodeTapManager.getTapCount(nodeTargetId) ?? 1;
        final tapEvent = GraphTapEvent(
          entityIds: [nodeTargetId],
          details: details,
          tapCount: tapCount,
        );
        viewBehavior.onTap(tapEvent);
      } else {
        debugPrint(
          '[GestureManager] NOT Toggling selection for Node: ${nodeTargetId.value.substring(0, 4)} (isStillDraggingAfterUp=$isStillDraggingAfterUp, isTapCompletedAfterUp=$isTapCompletedAfterUp)',
        );
      }
      return;
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
        '[GestureManager] Final check (Link: ${linkTargetId.value.substring(0, 4)}): isStillDraggingAfterUp=$isStillDraggingAfterUp, isTapCompletedAfterUp=$isTapCompletedAfterUp',
      );

      if (!isStillDraggingAfterUp && isTapCompletedAfterUp) {
        debugPrint(
          '[GestureManager] Toggling selection for Link: ${linkTargetId.value.substring(0, 4)}',
        );
        toggleSelection(linkTargetId, details: details);
        final tapCount = _linkTapManager.getTapCount(linkTargetId) ?? 1;
        final tapEvent = GraphTapEvent(
          entityIds: [linkTargetId],
          details: details,
          tapCount: tapCount,
        );
        viewBehavior.onTap(tapEvent);
      } else {
        debugPrint(
          '[GestureManager] NOT Toggling selection for Link: ${linkTargetId.value.substring(0, 4)} (isStillDraggingAfterUp=$isStillDraggingAfterUp, isTapCompletedAfterUp=$isTapCompletedAfterUp)',
        );
      }
      return;
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
    // We might need to rely on _lastPointerDetails from PointerDownEvent if needed

    // Prefer dragging nodes over links if both are present
    final node = findNodeAt(details.localPosition);
    if (node != null && node.canDrag) {
      _nodeDragManager.handlePanStart([node.id], details);
      if (_nodeDragManager.isActive) {
        // Check if drag actually started
        // Use the details captured during PointerDown
        if (_lastPointerDetails == null) {
          // Should not happen if PointerDown was processed correctly, but add a safeguard
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
      return;
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
    }
    // If no draggable entity found, potentially start panning the viewport later
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
      return;
    }
    final link = findLinkAt(details.localPosition);
    if (link != null) {
      _linkTapManager.handlePanUpdate(link.id, details);
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
      return;
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
