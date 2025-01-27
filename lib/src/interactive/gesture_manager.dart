import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:plough/src/graph/entity.dart';
import 'package:plough/src/graph/graph_base.dart';
import 'package:plough/src/graph/id.dart';
import 'package:plough/src/graph/link.dart';
import 'package:plough/src/graph/node.dart';
import 'package:plough/src/graph/order_manager.dart';
import 'package:plough/src/graph_view/behavior.dart';
import 'package:plough/src/interactive/drag_state.dart';
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

  void toggleSelection(GraphId entityId) {
    final selected = graph.selectedEntityIds;
    if (selected.isEmpty) {
      selectEntities([entityId]);
    } else if (selected.length == 1 && selected.first == entityId) {
      deselectEntities(selected);
    } else if (selected.contains(entityId)) {
      deselectEntities(selected.where((id) => id != entityId).toList());
    } else {
      deselectEntities(selected.where((id) => id != entityId).toList());
      selectEntities([entityId]);
    }
  }

  void selectEntities(List<GraphId> entityIds) {
    final entities = entityIds.map(getEntity).toList();
    final nodes = entities.whereType<GraphNode>().toList();
    final links = entities.whereType<GraphLink>().toList();
    if (nodes.isNotEmpty) {
      for (final node in nodes) {
        graph.selectNode(node.id);
      }
      viewBehavior.onNodeSelect(nodes, isSelected: true);
    }
    if (links.isNotEmpty) {
      for (final link in links) {
        graph.selectLink(link.id);
      }
      viewBehavior.onLinkSelect(links, isSelected: true);
    }
  }

  void deselectEntities(List<GraphId> entityIds) {
    final entities = entityIds.map(getEntity).toList();
    final nodes = entities.whereType<GraphNode>().toList();
    final links = entities.whereType<GraphLink>().toList();
    if (nodes.isNotEmpty) {
      for (final node in nodes) {
        graph.deselectNode(node.id);
      }
      viewBehavior.onNodeSelect(nodes, isSelected: false);
    }
    if (links.isNotEmpty) {
      for (final link in links) {
        graph.deselectLink(link.id);
      }
      viewBehavior.onLinkSelect(links, isSelected: false);
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
  }

  void handlePointerUp(PointerUpEvent event) {
    final node = findNodeAt(event.localPosition);
    if (node != null) {
      _nodeTapManager.handlePointerUp(node.id, event);
      _nodeDragManager.handlePointerUp(node.id, event);
      return;
    }

    final link = findLinkAt(event.localPosition);
    if (link != null) {
      _linkTapManager.handlePointerUp(link.id, event);
      _linkDragManager.handlePointerUp(link.id, event);
    }
  }

  void handlePointerCancel(PointerCancelEvent event) {
    final node = findNodeAt(event.localPosition);
    if (node != null) {
      _nodeTapManager.handlePointerCancel(node.id, event);
      _nodeDragManager.handlePointerCancel(node.id, event);
      return;
    }

    final link = findLinkAt(event.localPosition);
    if (link != null) {
      _linkTapManager.handlePointerCancel(link.id, event);
      _linkDragManager.handlePointerCancel(link.id, event);
    }
  }

  void handlePanStart(DragStartDetails details) {
    final node = findNodeAt(details.localPosition);
    if (node != null) {
      _nodeDragManager.handlePanStart(node.id, details);
      return;
    }

    final link = findLinkAt(details.localPosition);
    if (link != null) {
      _linkDragManager.handlePanStart(link.id, details);
    }
  }

  void handlePanUpdate(DragUpdateDetails details) {
    final node = findNodeAt(details.localPosition);
    if (node != null) {
      _nodeTapManager.handlePanUpdate(node.id, details);
      _nodeDragManager.handlePanUpdate(node.id, details);
      return;
    }

    final link = findLinkAt(details.localPosition);
    if (link != null) {
      _linkTapManager.handlePanUpdate(link.id, details);
      _linkDragManager.handlePanUpdate(link.id, details);
    }
  }

  void handlePanEnd(DragEndDetails details) {
    final node = findNodeAt(details.localPosition);
    if (node != null) {
      _nodeDragManager.handlePanEnd(node.id, details);
      return;
    }

    final link = findLinkAt(details.localPosition);
    if (link != null) {
      _linkDragManager.handlePanEnd(link.id, details);
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
    if (isDragging) return;

    final node = findNodeAt(event.localPosition);
    final link = findLinkAt(event.localPosition);

    if (node?.id != _nodeDragManager.lastDraggedEntityId) {
      _nodeDragManager.lastDraggedEntityId = null;
    }
    if (link?.id != _linkDragManager.lastDraggedEntityId) {
      _linkDragManager.lastDraggedEntityId = null;
    }

    if (node != null) {
      _nodeHoverManager.handleMouseHover(node.id, event);
      _nodeTooltipManager.handleMouseHover(node.id, event);
      return;
    } else {
      _nodeHoverManager.handleMouseExit(event);
      _nodeTooltipManager.handleMouseExit(event);
    }

    if (link != null) {
      _linkHoverManager.handleMouseHover(link.id, event);
      _linkTooltipManager.handleMouseHover(link.id, event);
    } else {
      _linkHoverManager.handleMouseExit(event);
      _linkTooltipManager.handleMouseExit(event);
    }
  }

  void endHover(GraphId entityId) {
    final entity = getEntity(entityId);
    if (entity is GraphNode) {
      _nodeTooltipManager.cancel(entityId);
    } else if (entity is GraphLink) {
      _linkTooltipManager.cancel(entityId);
    }
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
