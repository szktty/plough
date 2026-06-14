import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plough/src/debug/debug_sink.dart';
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
import 'package:plough/src/interactive/pan_ready_state.dart';
import 'package:plough/src/interactive/tap_state.dart';
import 'package:plough/src/interactive/tooltip_state.dart';
import 'package:plough/src/tooltip/behavior.dart';
import 'package:plough/src/utils/logger.dart';

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
    this.dragDeltaTransform,
    this.globalToScene,
    this.onNodeDragStart,
    this.onNodeDragEnd,
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

  /// Optional transform applied to drag delta before updating node positions.
  /// Use this when GraphView is inside a transformed parent (e.g. InteractiveViewer).
  Offset Function(Offset delta)? dragDeltaTransform;

  /// Called when a node drag starts. Receives the dragged node's [GraphId].
  void Function(GraphId nodeId)? onNodeDragStart;

  /// Called when a node drag ends. Receives the dragged node's [GraphId].
  void Function(GraphId nodeId)? onNodeDragEnd;

  /// Optional transform that converts a global screen position to the graph's
  /// logical (scene) coordinate space.
  ///
  /// Use this when [GraphView] is inside a transformed parent such as
  /// [InteractiveViewer].  Without this, hit-testing and pointer handling use
  /// [PointerEvent.localPosition] which is in the gesture detector's local
  /// frame — identical to scene space only when no parent transform is applied.
  ///
  /// Typically set to `transformationController.toScene`.
  Offset Function(Offset globalPosition)? globalToScene;

  /// Converts a viewport-local (screen) position to scene coordinates.
  ///
  /// Set when an enclosing [GraphViewport] drives this manager from outside its
  /// [Transform]: the events it forwards carry viewport-local positions, which
  /// this maps to scene space via the controller's inverse transform.  Takes
  /// precedence over [globalToScene] in [toScene].
  Offset Function(Offset localPosition)? screenToScene;

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

  // Pan Ready state manager (for deferred drag detection)
  late final GraphNodePanReadyStateManager _nodePanReadyManager =
      GraphNodePanReadyStateManager(gestureManager: this);
  late final GraphLinkPanReadyStateManager _linkPanReadyManager =
      GraphLinkPanReadyStateManager(gestureManager: this);

  late final GraphOrderManager _orderManager;

  /// Spatial grid for fast node hit-testing.
  final _NodeSpatialGrid _nodeGrid = _NodeSpatialGrid(cellSize: 80);

  PointerEventDetails? _lastPointerDetails;
  PointerEventDetails? get lastPointerDetails => _lastPointerDetails;

  /// Local position of a pointer-down that landed on empty background while a
  /// selection existed.  Deselection is deferred to pointer-up so that a
  /// background *pan* (e.g. panning a [GraphViewport]) does not clear the
  /// selection — only a background *tap* (released within touch slop) does.
  /// Null when the current gesture did not start on the background.
  Offset? _pendingBackgroundDeselectAt;

  /// Rebuild the spatial grid from current node geometries.
  void rebuildSpatialIndex() {
    _nodeGrid.rebuild(graph.nodes);
  }

  // Debug accessors for internal state
  GraphNodeTapStateManager get nodeTapManager => _nodeTapManager;
  GraphNodeDragStateManager get nodeDragManager => _nodeDragManager;
  GraphLinkTapStateManager get linkTapManager => _linkTapManager;
  GraphLinkDragStateManager get linkDragManager => _linkDragManager;
  GraphNodePanReadyStateManager get nodePanReadyManager => _nodePanReadyManager;
  GraphLinkPanReadyStateManager get linkPanReadyManager => _linkPanReadyManager;

  GraphEntity? getEntity(GraphId entityId) =>
      graph.getNode(entityId) ?? graph.getLink(entityId);

  bool get isDragging => _nodeDragManager.isActive || _linkDragManager.isActive;

  /// Converts a local (gesture detector) position to graph scene (logical)
  /// coordinates.  When [globalToScene] is provided (e.g. via
  /// [TransformationController.toScene]), it is applied to the event's global
  /// position.  Otherwise the local position is returned as-is.
  Offset toScene(Offset localPosition, Offset globalPosition) {
    if (screenToScene != null) {
      return screenToScene!.call(localPosition);
    }
    if (globalToScene != null) {
      return globalToScene!.call(globalPosition);
    }
    return localPosition;
  }

  GraphId? get lastDraggedEntityId =>
      _nodeDragManager.lastDraggedEntityId ??
      _linkDragManager.lastDraggedEntityId;

  /// Creates a hit test result for the given position.
  GraphHitTestResult createHitTestResult(Offset position) {
    final node = findNodeAt(position);
    final link = node == null ? findLinkAt(position) : null;

    return GraphHitTestResult(localPosition: position, node: node, link: link);
  }

  /// Determines if a gesture should be consumed based on the current mode.
  bool shouldConsumeGestureAt(Offset position) {
    final hitTestResult = createHitTestResult(position);
    logDebug(
      LogCategory.gesture,
      'shouldConsumeGestureAt: mode=$gestureMode, hasEntity=${hitTestResult.hasEntity}',
    );

    bool result;
    switch (gestureMode) {
      case GraphGestureMode.exclusive:
        result = true;
        logDebug(LogCategory.gesture, 'Exclusive mode: consuming gesture');
      case GraphGestureMode.nodeEdgeOnly:
        result = hitTestResult.hasEntity;
        logDebug(
          LogCategory.gesture,
          'NodeEdgeOnly mode: ${result ? 'consuming' : 'not consuming'} (hasEntity=${hitTestResult.hasEntity})',
        );
      case GraphGestureMode.transparent:
        result = false;
        logDebug(
          LogCategory.gesture,
          'Transparent mode: not consuming gesture',
        );
      case GraphGestureMode.custom:
        result = shouldConsumeGesture?.call(position, hitTestResult) ?? true;
        logDebug(
          LogCategory.gesture,
          'Custom mode: ${result ? 'consuming' : 'not consuming'}',
        );
    }

    return result;
  }

  GraphNode? findNodeAt(Offset position) {
    // Use spatial grid candidates when available; fall back to full scan.
    final candidates = _nodeGrid.candidatesAt(position);
    if (candidates.isNotEmpty) {
      // Check candidates in frontmost-first order.
      GraphNode? best;
      for (final node in candidates) {
        if (viewBehavior.hitTestNode(node, position)) {
          if (best == null || node.stackOrder > best.stackOrder) {
            best = node;
          }
        }
      }
      if (best != null) return best;
    }
    // Fall back to linear scan (catches nodes not yet in the grid).
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
      logDebug(
        LogCategory.selection,
        '_dispatchSelectionChange: No actual changes, skipping event dispatch',
      );
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
        LogCategory.selection,
        'Entity is already selected, deselecting',
      );
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
    logDebug(
      LogCategory.selection,
      'IDs to select: [${idsToSelect.map((id) => id.value.substring(0, 4)).join(', ')}]',
    );

    if (idsToSelect.isNotEmpty) {
      final othersToDeselect =
          currentSelection.where((id) => !entityIds.contains(id)).toList();
      if (othersToDeselect.isNotEmpty) {
        logDebug(
          LogCategory.selection,
          'Deselecting others first: [${othersToDeselect.map((id) => id.value.substring(0, 4)).join(', ')}]',
        );
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
        logDebug(
          LogCategory.selection,
          'Entity ${entityId.value.substring(0, 4)} already selected, skipping',
        );
      }
    }

    logDebug(
      LogCategory.selection,
      'About to dispatch: newlySelected=[${newlySelected.map((id) => id.value.substring(0, 4)).join(', ')}], newlyDeselected=[${newlyDeselected.map((id) => id.value.substring(0, 4)).join(', ')}]',
    );
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
        logDebug(
          LogCategory.selection,
          'Entity ${entityId.value.substring(0, 4)} not selected, skipping deselect',
        );
      }
    }
    logDebug(
      LogCategory.selection,
      'About to dispatch deselection: newlyDeselected=[${newlyDeselected.map((id) => id.value.substring(0, 4)).join(', ')}]',
    );
    _dispatchSelectionChange([], newlyDeselected, details: details);
  }

  void deselectAll({PointerEventDetails? details}) {
    logDebug(LogCategory.selection, 'deselectAll called');
    final currentSelection = graph.selectedEntityIds.toList();
    logDebug(
      LogCategory.selection,
      'Current selection: [${currentSelection.map((id) => id.value.substring(0, 4)).join(', ')}]',
    );
    if (currentSelection.isNotEmpty) {
      logDebug(
        LogCategory.selection,
        'Deselecting all ${currentSelection.length} entities',
      );
      deselectEntities(currentSelection, details: details);
    } else {
      logDebug(
        LogCategory.selection,
        'No entities selected, skipping deselect to avoid unnecessary rebuilds',
      );
      // Don't call deselectEntities when there's nothing to deselect
      // This prevents unnecessary event dispatching and rebuilds
    }
  }

  void handlePointerDown(PointerDownEvent event) {
    final scenePos = toScene(event.localPosition, event.position);
    logDebug(
      LogCategory.gesture,
      'Starting handlePointerDown at ${event.localPosition} (scene: $scenePos), mode: $gestureMode',
    );

    // Send structured gesture event to debug server. Guard so the metadata map
    // (and DateTime.now()) is not built on every pointer-down when disabled.
    if (debugSink.enabled) {
      debugSink.sendLog(
        category: LogCategory.gesture,
        level: 'DEBUG',
        message: 'Pointer down event',
        metadata: {
          'event_type': 'pointerDown',
          'position': {
            'x': event.localPosition.dx,
            'y': event.localPosition.dy,
          },
          'gesture_mode': gestureMode.name,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    }

    _nodeHoverManager.handlePointerDown(event);
    _linkHoverManager.handlePointerDown(event);

    final node = findNodeAt(scenePos);
    if (node != null) {
      logDebug(
        LogCategory.gesture,
        'Node found: ${node.id.value.substring(0, 4)}',
      );

      // Send structured node event to debug server (guarded: skip map build
      // when disabled).
      if (debugSink.enabled) {
        debugSink.sendLog(
          category: LogCategory.gesture,
          level: 'DEBUG',
          message: 'Node found at pointer down',
          metadata: {
            'event_type': 'nodeFound',
            'nodeId': node.id.value,
            'node_id': node.id.value, // backward compatibility
            'position': {
              'x': event.localPosition.dx,
              'y': event.localPosition.dy,
            },
            'node_position': {
              'x': node.logicalPosition.dx,
              'y': node.logicalPosition.dy,
            },
            'can_select': node.canSelect,
            'can_drag': node.canDrag,
            'is_selected': graph.selectedEntityIds.contains(node.id),
            'gesture_mode': gestureMode.name,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      }

      logDebug(
        LogCategory.tap,
        'TAP DEBUG DOWN: node.id=${node.id.value.substring(0, 8)}',
      );
      logDebug(
        LogCategory.tap,
        'TAP DEBUG DOWN: Before handlePointerDown - trackedEntityId=${_nodeTapManager.trackedEntityId?.value.substring(0, 8) ?? 'null'}',
      );
      _nodeTapManager.handlePointerDown(node.id, event);
      _nodeDragManager.handlePointerDown(node.id, event);
      logDebug(
        LogCategory.tap,
        'TAP DEBUG DOWN: trackedEntityId after handlePointerDown=${_nodeTapManager.trackedEntityId?.value.substring(0, 8) ?? 'null'}',
      );

      // Send TAP_DEBUG_STATE after pointer down. Guard so the debug-state reads
      // (getState/getTapStateDebugInfo, both side-effect-free) and the data map
      // are skipped on every pointer-down when gesture debugging is off.
      if (isGestureDebugEnabled) {
        final tapState = _nodeTapManager.getState(node.id);
        final tapDebugInfo = _nodeTapManager.getTapStateDebugInfo(node.id);
        logGestureDebug(
          GestureDebugEventType.tapDebugState,
          'GraphGestureManager',
          'TAP_STATE_DOWN',
          data: {
            'event_type': 'tap_debug_state',
            'phase': 'down',
            'nodeTargetId': node.id.value,
            'state_exists': tapState != null,
            'state_completed': tapState?.completed ?? false,
            'state_cancelled': tapState?.cancelled ?? false,
            'tap_count': tapState?.tapCount ?? 0,
            'tracked_entity_id':
                _nodeTapManager.trackedEntityId?.value ?? 'null',
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
              'y': event.localPosition.dy,
            },
            'node_position': {
              'x': node.logicalPosition.dx,
              'y': node.logicalPosition.dy,
            },
            'tap_manager_states_count': _nodeTapManager.states.length,
            'drag_manager_is_dragging': _nodeDragManager.isDragging(node.id),
          },
        );
      }
      // Return early for all modes except transparent
      if (gestureMode == GraphGestureMode.transparent) {
        logDebug(
          LogCategory.gesture,
          'Continuing after node processing (transparent mode)',
        );
      } else {
        logDebug(
          LogCategory.gesture,
          'Early return for node (mode: $gestureMode)',
        );
        return;
      }
    }

    final link = findLinkAt(scenePos);
    if (link != null) {
      logDebug(
        LogCategory.gesture,
        'Link found: ${link.id.value.substring(0, 4)}',
      );

      // Send structured link event to debug server (guarded).
      if (debugSink.enabled) {
        debugSink.sendLog(
          category: LogCategory.gesture,
          level: 'DEBUG',
          message: 'Link found at pointer down',
          metadata: {
            'event_type': 'linkFound',
            'linkId': link.id.value,
            'link_id': link.id.value, // backward compatibility
            'position': {
              'x': event.localPosition.dx,
              'y': event.localPosition.dy,
            },
            'source_node_id': link.source.id.value,
            'target_node_id': link.target.id.value,
            'can_select': link.canSelect,
            'is_selected': graph.selectedEntityIds.contains(link.id),
            'gesture_mode': gestureMode.name,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      }

      _linkTapManager.handlePointerDown(link.id, event);
      _linkDragManager.handlePointerDown(link.id, event);
      // Return early for all modes except transparent
      if (gestureMode == GraphGestureMode.transparent) {
        logDebug(
          LogCategory.gesture,
          'Continuing after link processing (transparent mode)',
        );
      } else {
        logDebug(
          LogCategory.gesture,
          'Early return for link (mode: $gestureMode)',
        );
        return;
      }
    }

    // Only call background callback if no entity was found
    // Double-check to prevent race conditions
    final reCheckNode = findNodeAt(scenePos);
    final reCheckLink = findLinkAt(scenePos);

    if (node == null &&
        link == null &&
        reCheckNode == null &&
        reCheckLink == null) {
      logDebug(
        LogCategory.gesture,
        'True background area (double-checked), calling background callback',
      );
      onBackgroundTapped?.call(scenePos);
      // Defer deselection to pointer-up: only a background *tap* should clear
      // the selection.  A background *pan* (released far from the down point)
      // must keep it.  Resolved in handlePointerUp.
      _pendingBackgroundDeselectAt = event.localPosition;
    } else {
      logDebug(
        LogCategory.gesture,
        'Entity found (or re-found), not calling background callback',
      );
    }
  }

  void handlePointerUp(PointerUpEvent event) {
    final scenePos = toScene(event.localPosition, event.position);
    logDebug(
      LogCategory.gesture,
      'Starting handlePointerUp at ${event.localPosition} (scene: $scenePos), mode: $gestureMode',
    );
    _lastPointerDetails = PointerEventDetails.fromPointerEvent(event);
    final details = _lastPointerDetails!;

    // Resolve a deferred background deselect (see handlePointerDown): clear the
    // selection only if the pointer was released within touch slop of where it
    // went down on the background — i.e. a tap, not a pan.
    final pendingDeselectAt = _pendingBackgroundDeselectAt;
    final gestureStartedOnBackground = pendingDeselectAt != null;
    _pendingBackgroundDeselectAt = null;
    if (pendingDeselectAt != null) {
      final moved = (event.localPosition - pendingDeselectAt).distance;
      if (moved <= kTouchSlop) {
        deselectAll(details: details);
      } else {
        logDebug(
          LogCategory.selection,
          'Skipping background deselect: pointer moved $moved px (pan, not tap)',
        );
      }
    }

    // Send structured gesture event to debug server (guarded).
    if (debugSink.enabled) {
      debugSink.sendLog(
        category: LogCategory.gesture,
        level: 'DEBUG',
        message: 'Pointer up event',
        metadata: {
          'event_type': 'pointerUp',
          'position': {
            'x': event.localPosition.dx,
            'y': event.localPosition.dy,
          },
          'gesture_mode': gestureMode.name,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    }

    // Track if we're processing an entity
    var entityProcessed = false;

    // First try to get the node at the pointer up location
    final nodeAtPosition = findNodeAt(scenePos);

    // CRITICAL DEBUG: Check all tap states before determining nodeTargetId
    logDebug(
      LogCategory.tap,
      'TAP DEBUG UP: All tap states before nodeTargetId determination:',
    );
    for (final state in _nodeTapManager.states) {
      final tapState = state as dynamic;
      logDebug(
        LogCategory.tap,
        '  - entityId=${tapState.entityId.value.substring(0, 8)}, cancelled=${tapState.cancelled}, completed=${tapState.completed}',
      );
    }

    // When this gesture started on empty background, a lingering tracked/last-
    // dragged entity belongs to a *previous* gesture and must not be revived:
    // otherwise a background pan would toggle (and deselect) that old node on
    // release.  Only attribute to an entity actually under the pointer here.
    final nodeTargetId = gestureStartedOnBackground
        ? nodeAtPosition?.id
        : (nodeAtPosition?.id ??
            _nodeTapManager.trackedEntityId ??
            _nodeDragManager.lastDraggedEntityId);
    logDebug(
      LogCategory.tap,
      'TAP DEBUG: nodeAtPosition=${nodeAtPosition?.id.value.substring(0, 8) ?? 'null'}',
    );
    logDebug(
      LogCategory.tap,
      'TAP DEBUG: trackedEntityId=${_nodeTapManager.trackedEntityId?.value.substring(0, 8) ?? 'null'}',
    );
    logDebug(
      LogCategory.tap,
      'TAP DEBUG: lastDraggedEntityId=${_nodeDragManager.lastDraggedEntityId?.value.substring(0, 8) ?? 'null'}',
    );
    logDebug(
      LogCategory.tap,
      'TAP DEBUG: final nodeTargetId=${nodeTargetId?.value.substring(0, 8) ?? 'null'}',
    );

    logDebug(
      LogCategory.gesture,
      'Node target ID: ${nodeTargetId?.value.substring(0, 4) ?? 'null'} '
      '(trackedEntityId: ${_nodeTapManager.trackedEntityId?.value.substring(0, 4) ?? 'null'}, '
      'lastDraggedEntityId: ${_nodeDragManager.lastDraggedEntityId?.value.substring(0, 4) ?? 'null'})',
    );

    // Send structured node target info to debug server (guarded).
    if (debugSink.enabled) {
      debugSink.sendLog(
        category: LogCategory.gesture,
        level: 'DEBUG',
        message: 'Node target tracking',
        metadata: {
          'event_type': 'nodeTargetTracking',
          'nodeId': nodeTargetId?.value,
          'node_id': nodeTargetId?.value, // backward compatibility
          'tracked_by_tap_manager': _nodeTapManager.trackedEntityId?.value,
          'tracked_by_drag_manager':
              _nodeDragManager.lastDraggedEntityId?.value,
          'position': {
            'x': event.localPosition.dx,
            'y': event.localPosition.dy,
          },
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    }

    if (nodeTargetId != null) {
      final node = graph.getNode(nodeTargetId);
      if (node == null) {
        logDebug(LogCategory.gesture, 'Node not found, cleaning up');

        // Send structured cleanup event to debug server (guarded).
        if (debugSink.enabled) {
          debugSink.sendLog(
            category: LogCategory.gesture,
            level: 'WARNING',
            message: 'Node not found during cleanup',
            metadata: {
              'event_type': 'nodeNotFoundCleanup',
              'nodeId': nodeTargetId.value,
              'node_id': nodeTargetId.value, // backward compatibility
              'position': {
                'x': event.localPosition.dx,
                'y': event.localPosition.dy,
              },
              'timestamp': DateTime.now().toIso8601String(),
            },
          );
        }

        _nodeTapManager.cleanupTapState(nodeTargetId);
        _nodeDragManager.cancel(nodeTargetId);
        return;
      }

      logDebug(
        LogCategory.gesture,
        'Processing node: ${node.id.value.substring(0, 4)}',
      );

      // Send structured node processing event to debug server (guarded).
      if (debugSink.enabled) {
        debugSink.sendLog(
          category: LogCategory.gesture,
          level: 'DEBUG',
          message: 'Processing node at pointer up',
          metadata: {
            'event_type': 'nodeProcessing',
            'nodeId': node.id.value,
            'node_id': node.id.value, // backward compatibility
            'position': {
              'x': event.localPosition.dx,
              'y': event.localPosition.dy,
            },
            'node_position': {
              'x': node.logicalPosition.dx,
              'y': node.logicalPosition.dy,
            },
            'can_select': node.canSelect,
            'can_drag': node.canDrag,
            'is_selected': graph.selectedEntityIds.contains(node.id),
            'was_being_dragged': _nodeDragManager.isDragging(nodeTargetId),
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      }

      _nodeTapManager.handlePointerUp(nodeTargetId, event);
      _nodeDragManager.handlePointerUp(nodeTargetId, event);

      final isStillDraggingAfterUp = _nodeDragManager.isDragging(nodeTargetId);
      final isTapCompletedAfterUp = _nodeTapManager.isTapCompleted(
        nodeTargetId,
      );

      // Additional debugging
      final tapState = _nodeTapManager.getState(nodeTargetId);

      // Send detailed debug info to workbench via gesture debug stream.
      // Guard so the workbench-only reads and the data map are skipped on every
      // pointer-up when gesture debugging is off (reads are side-effect-free).
      if (isGestureDebugEnabled) {
        final tapDebugInfo = _nodeTapManager.getTapStateDebugInfo(nodeTargetId);
        final dragState = _nodeDragManager.getState(nodeTargetId);
        logGestureDebug(
          GestureDebugEventType.tapDebugState,
          'GraphGestureManager',
          'TAP_STATE_UP',
          data: {
            'event_type': 'tap_debug_state',
            'phase': 'up',
            'nodeTargetId': nodeTargetId.value,
            'state_exists': tapState != null,
            'state_completed': tapState?.completed ?? false,
            'state_cancelled': tapState?.cancelled ?? false,
            'tap_count': tapState?.tapCount ?? 0,
            'tracked_entity_id':
                _nodeTapManager.trackedEntityId?.value ?? 'null',
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
              'y': event.localPosition.dy,
            },
            'node_position': {
              'x': node.logicalPosition.dx,
              'y': node.logicalPosition.dy,
            },
            'node_at_position': nodeAtPosition?.id.value,
            'tap_manager_states_count': _nodeTapManager.states.length,
            'drag_state_exists': dragState != null,
            'drag_manager_is_dragging':
                _nodeDragManager.isDragging(nodeTargetId),
            'will_toggle_selection':
                !isStillDraggingAfterUp && isTapCompletedAfterUp,
          },
        );
      }

      // Also send to external debug client if available (guarded).
      if (debugSink.enabled) {
        debugSink.sendLog(
          category: LogCategory.gesture,
          level: 'DEBUG',
          message: 'TAP_STATE',
          metadata: {
            'event_type': 'tap_debug_state',
            'nodeTargetId': nodeTargetId.value,
            'state_exists': tapState != null,
            'state_completed': tapState?.completed ?? false,
            'state_cancelled': tapState?.cancelled ?? false,
            'tap_count': tapState?.tapCount ?? 0,
            'tracked_entity_id':
                _nodeTapManager.trackedEntityId?.value ?? 'null',
            'is_still_dragging_after_up': isStillDraggingAfterUp,
            'is_tap_completed_after_up': isTapCompletedAfterUp,
            'touch_slop': kTouchSlop * 8,
            'k_touch_slop': kTouchSlop,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      }

      logDebug(
        LogCategory.tap,
        'TAP DEBUG: nodeTargetId=${nodeTargetId.value.substring(0, 8)}',
      );
      logDebug(LogCategory.tap, 'TAP DEBUG: state exists=${tapState != null}');
      logDebug(LogCategory.tap, 'TAP DEBUG: completed=${tapState?.completed}');
      logDebug(LogCategory.tap, 'TAP DEBUG: cancelled=${tapState?.cancelled}');
      logDebug(LogCategory.tap, 'TAP DEBUG: tapCount=${tapState?.tapCount}');
      logDebug(
        LogCategory.tap,
        'TAP DEBUG: trackedEntityId=${_nodeTapManager.trackedEntityId?.value.substring(0, 8) ?? 'null'}',
      );

      logDebug(
        LogCategory.tap,
        'TAP DEBUG: Final check - isStillDraggingAfterUp=$isStillDraggingAfterUp, isTapCompletedAfterUp=$isTapCompletedAfterUp',
      );

      logDebug(
        LogCategory.tap,
        'isStillDraggingAfterUp: $isStillDraggingAfterUp, isTapCompletedAfterUp: $isTapCompletedAfterUp',
      );
      if (!isStillDraggingAfterUp && isTapCompletedAfterUp) {
        logDebug(LogCategory.tap, 'tap!');

        final tapCount = _nodeTapManager.getTapCount(nodeTargetId) ?? 1;
        logDebug(
          LogCategory.tap,
          'Node tap count detected: $tapCount for ${nodeTargetId.value.substring(0, 8)}',
        );

        logDebug(
          LogCategory.gesture,
          'Toggling selection for Node: ${nodeTargetId.value.substring(0, 4)}',
        );
        toggleSelection(nodeTargetId, details: details);

        final tapEvent = GraphTapEvent(
          entityIds: [nodeTargetId],
          details: details,
          tapCount: tapCount,
        );
        viewBehavior.onTap(tapEvent);
        if (tapCount == 2) {
          logDebug(
            LogCategory.tap,
            'Double tap detected for node: ${nodeTargetId.value.substring(0, 8)}',
          );
          viewBehavior.onDoubleTap(tapEvent);
          // Clean up immediately for double tap
          _nodeTapManager.cleanupTapState(nodeTargetId);
        }
        // For single tap, the timer will clean up the state
        entityProcessed = true;
      } else {
        logDebug(
          LogCategory.gesture,
          'NOT Toggling selection for Node: ${nodeTargetId.value.substring(0, 4)} (isStillDraggingAfterUp=$isStillDraggingAfterUp, isTapCompletedAfterUp=$isTapCompletedAfterUp)',
        );

        // Log detailed failure reason for tap recognition
        if (isGestureDebugEnabled) {
          var failureReason = '';
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
            data: {
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
      final isTapCompletedAfterUp = _linkTapManager.isTapCompleted(
        linkTargetId,
      );

      logDebug(
        LogCategory.gesture,
        'Final check (Link: ${linkTargetId.value.substring(0, 4)}): isStillDraggingAfterUp=$isStillDraggingAfterUp, isTapCompletedAfterUp=$isTapCompletedAfterUp',
      );

      if (!isStillDraggingAfterUp && isTapCompletedAfterUp) {
        final tapCount = _linkTapManager.getTapCount(linkTargetId) ?? 1;
        logDebug(
          LogCategory.tap,
          'Link tap count detected: $tapCount for ${linkTargetId.value.substring(0, 8)}',
        );

        logDebug(
          LogCategory.gesture,
          'Toggling selection for Link: ${linkTargetId.value.substring(0, 4)}',
        );
        toggleSelection(linkTargetId, details: details);

        final tapEvent = GraphTapEvent(
          entityIds: [linkTargetId],
          details: details,
          tapCount: tapCount,
        );
        viewBehavior.onTap(tapEvent);
        if (tapCount == 2) {
          logDebug(
            LogCategory.tap,
            'Double tap detected for link: ${linkTargetId.value.substring(0, 8)}',
          );
          viewBehavior.onDoubleTap(tapEvent);
          // Clean up immediately for double tap
          _linkTapManager.cleanupTapState(linkTargetId);
        }
        // For single tap, the timer will clean up the state
        entityProcessed = true;
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
      logDebug(
        LogCategory.gesture,
        'handlePointerUp: No entity processed, might be background tap',
      );
    }
  }

  void handlePointerCancel(PointerCancelEvent event) {
    // A cancelled gesture is neither a tap nor a deliberate release; drop any
    // pending background deselect so it can't fire on the next pointer-up.
    _pendingBackgroundDeselectAt = null;
    _lastPointerDetails = PointerEventDetails.fromPointerEvent(
      event,
    ); // Update details on cancel
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
    final scenePos = toScene(details.localPosition, details.globalPosition);
    // Seed the last pointer details from the drag start so handlePanUpdate has
    // a reference even when no prior pointer-down/hover set it (e.g. a touch
    // drag, or a viewport-driven drag where the gesture arrives as pan details
    // rather than raw pointer events).
    _lastPointerDetails ??= PointerEventDetails.fromDragStartDetails(details);
    logGestureDebug(
      GestureDebugEventType.gestureDecision,
      'GestureManager',
      'PAN_START_RECEIVED',
      data: {
        'position': {
          'x': details.localPosition.dx,
          'y': details.localPosition.dy,
        },
        'improved_algorithm': true,
      },
    );

    // New approach: Do not start dragging immediately on pan start, set to Pan Ready state
    // Prefer nodes over links if both are present
    final node = findNodeAt(scenePos);
    if (node != null && node.canDrag) {
      // Set node to Pan Ready state (drag not started yet)
      _nodePanReadyManager.handlePanStart(node.id, details);

      logGestureDebug(
        GestureDebugEventType.stateCreate,
        'GestureManager',
        'NODE_PAN_READY_CREATED',
        data: {
          'nodeId': node.id.value.substring(0, 8),
          'position': {
            'x': details.localPosition.dx,
            'y': details.localPosition.dy,
          },
        },
      );

      // In nodeEdgeOnly mode, we handled the node, so don't call background callback
      if (gestureMode == GraphGestureMode.nodeEdgeOnly) {
        logDebug(
          LogCategory.gesture,
          'handlePanStart: Node set to ready state - skipping background callback in nodeEdgeOnly mode',
        );
        return;
      }
      // In transparent mode, don't return early so gestures can pass through
      if (gestureMode != GraphGestureMode.transparent) {
        return;
      }
    }

    final link = findLinkAt(scenePos);
    if (link != null && link.canDrag) {
      // Set link to Pan Ready state (drag not started yet)
      _linkPanReadyManager.handlePanStart(link.id, details);

      logGestureDebug(
        GestureDebugEventType.stateCreate,
        'GestureManager',
        'LINK_PAN_READY_CREATED',
        data: {
          'linkId': link.id.value.substring(0, 8),
          'position': {
            'x': details.localPosition.dx,
            'y': details.localPosition.dy,
          },
        },
      );

      // In nodeEdgeOnly mode, we handled the link, so don't call background callback
      if (gestureMode == GraphGestureMode.nodeEdgeOnly) {
        logDebug(
          LogCategory.gesture,
          'handlePanStart: Link set to ready state - skipping background callback in nodeEdgeOnly mode',
        );
        return;
      }
      // In transparent mode, don't return early so gestures can pass through
      if (gestureMode != GraphGestureMode.transparent) {
        return;
      }
    }

    // Only call background callback if no entity was found
    // Double-check to prevent race conditions
    final reCheckNode = findNodeAt(scenePos);
    final reCheckLink = findLinkAt(scenePos);

    if (node == null &&
        link == null &&
        reCheckNode == null &&
        reCheckLink == null) {
      logDebug(
        LogCategory.gesture,
        'handlePanStart: True background pan (double-checked), calling callback',
      );
      onBackgroundPanStart?.call(scenePos);
    } else {
      logDebug(
        LogCategory.gesture,
        'handlePanStart: Entity found (or re-found), not calling background callback',
      );
    }
  }

  void handlePanUpdate(DragUpdateDetails details) {
    final scenePos = toScene(details.localPosition, details.globalPosition);
    // DO NOT create a new PointerEventDetails from DragUpdateDetails
    // Use the last known details
    if (_lastPointerDetails == null) {
      logError(
        LogCategory.gesture,
        '_lastPointerDetails is null in handlePanUpdate',
      );
      // Cannot proceed without details, maybe cancel drag?
      // For now, just return to avoid crash
      return;
    }

    // Priority 1: Check Pan Ready states first - this is where we transition to actual dragging
    // Check if any nodes are in Pan Ready state and should start dragging
    final readyNodeIds = _nodePanReadyManager.readyEntityIds;
    var startedDragThisUpdate = false;
    for (final nodeId in readyNodeIds) {
      _nodePanReadyManager.handlePanUpdate(nodeId, details);
      // A ready→drag transition already applied this update's delta to the
      // node drag manager (see _delegateActualDragStart).  Remember it so we
      // don't apply the same delta again in Priority 2 below.
      if (!_nodePanReadyManager.isPanReady(nodeId)) {
        startedDragThisUpdate = true;
      }
    }

    // Check if any links are in Pan Ready state and should start dragging
    final readyLinkIds = _linkPanReadyManager.readyEntityIds;
    for (final linkId in readyLinkIds) {
      _linkPanReadyManager.handlePanUpdate(linkId, details);
      if (!_linkPanReadyManager.isPanReady(linkId)) {
        startedDragThisUpdate = true;
      }
    }

    // If a drag was just started this update, its delta has already been
    // applied during the ready→drag transition.  Skip the priority handlers so
    // the same frame's delta is not counted twice (node jumping ahead of the
    // pointer).  Subsequent updates flow through Priority 2/3 normally.
    if (startedDragThisUpdate) {
      final draggedNodeId = _nodeDragManager.lastDraggedEntityId;
      if (draggedNodeId != null) {
        final event = GraphDragUpdateEvent(
          entityIds: [draggedNodeId],
          details: _lastPointerDetails!,
          delta: details.delta,
        );
        viewBehavior.onDragUpdate(event);
        _nodeTapManager.handlePanUpdate(draggedNodeId, details);
      }
      return;
    }

    // Priority 2: If dragging a node, always update the node drag manager
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

    // Priority 3: If dragging a link (currently not supported but for completeness)
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

    // Priority 4: If not currently dragging and no ready states, check if movement cancels a pending tap
    final node = findNodeAt(scenePos);
    if (node != null) {
      _nodeTapManager.handlePanUpdate(node.id, details);
      // In nodeEdgeOnly mode, we're handling a node, so don't call background callback
      if (gestureMode == GraphGestureMode.nodeEdgeOnly) {
        logDebug(
          LogCategory.gesture,
          'handlePanUpdate: Skipping background callback - node handled in nodeEdgeOnly mode',
        );
        return;
      }
    }
    final link = findLinkAt(scenePos);
    if (link != null) {
      _linkTapManager.handlePanUpdate(link.id, details);
      // In nodeEdgeOnly mode, we're handling a link, so don't call background callback
      if (gestureMode == GraphGestureMode.nodeEdgeOnly) {
        logDebug(
          LogCategory.gesture,
          'handlePanUpdate: Skipping background callback - link handled in nodeEdgeOnly mode',
        );
        return;
      }
    }

    // Check if this is a background pan update
    if (!shouldConsumeGestureAt(scenePos)) {
      onBackgroundPanUpdate?.call(scenePos, details.delta);
      return;
    }

    // Only call background callback if no entity was found
    // Double-check to prevent race conditions
    final reCheckNode = findNodeAt(scenePos);
    final reCheckLink = findLinkAt(scenePos);

    if (node == null &&
        link == null &&
        reCheckNode == null &&
        reCheckLink == null) {
      logDebug(
        LogCategory.gesture,
        'handlePanUpdate: True background pan (double-checked), calling callback',
      );
      onBackgroundPanUpdate?.call(scenePos, details.delta);
    } else {
      logDebug(
        LogCategory.gesture,
        'handlePanUpdate: Entity found (or re-found), not calling background callback',
      );
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
          logError(
            LogCategory.gesture,
            '_lastPointerDetails is null in handlePanEnd',
          );
        } else {
          final event = GraphDragEndEvent(
            entityIds: endedDragIds,
            details: endPointerDetails, // Use last known details
          );
          viewBehavior.onDragEnd(event);

          // Silently clean up remaining tap states when drag ends
          for (final nodeId in endedDragIds) {
            if (_nodeTapManager.hasState(nodeId)) {
              logDebug(
                LogCategory.gesture,
                'Cleaning up tap state after drag end: ${nodeId.value.substring(0, 4)}',
              );
              _nodeTapManager.removeStateSilently(nodeId);
            }
            onNodeDragEnd?.call(nodeId);
          }
        }
      }
      // In nodeEdgeOnly mode, we handled a node drag, so don't call background callback
      if (gestureMode == GraphGestureMode.nodeEdgeOnly) {
        logDebug(
          LogCategory.gesture,
          'handlePanEnd: Skipping background callback - node drag handled in nodeEdgeOnly mode',
        );
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
        logDebug(
          LogCategory.gesture,
          'handlePanEnd: Skipping background callback - link drag handled in nodeEdgeOnly mode',
        );
        return;
      }
      return;
    }

    // Background pan end - only call if appropriate for the gesture mode
    if (endPointerDetails != null) {
      final endScenePos = toScene(
        endPointerDetails.localPosition,
        endPointerDetails.globalPosition,
      );
      // In nodeEdgeOnly mode, only call if we're not over an entity
      if (gestureMode == GraphGestureMode.nodeEdgeOnly) {
        final node = findNodeAt(endScenePos);
        final link = findLinkAt(endScenePos);
        if (node == null && link == null) {
          logDebug(
            LogCategory.gesture,
            'handlePanEnd: Calling background callback (no entity at position)',
          );
          onBackgroundPanEnd?.call(endScenePos);
        } else {
          logDebug(
            LogCategory.gesture,
            'handlePanEnd: NOT calling background callback (entity found at position)',
          );
        }
      } else {
        logDebug(
          LogCategory.gesture,
          'handlePanEnd: Calling background callback (not nodeEdgeOnly mode)',
        );
        onBackgroundPanEnd?.call(endScenePos);
      }
    }
  }

  void handlePointerMove(PointerMoveEvent event) {
    final scenePos = toScene(event.localPosition, event.position);
    if (_nodeDragManager.isActive || findNodeAt(scenePos) != null) {
      _nodeDragManager.handlePointerMove(event);

      // Send real-time TAP_DEBUG_STATE during drag operations.
      // Guard on isGestureDebugEnabled first: this runs every frame during a
      // drag and the data map below (plus getTapStateDebugInfo / DateTime.now)
      // would otherwise be built on every move even when debugging is off.
      final draggedEntityId = _nodeDragManager.lastDraggedEntityId;
      if (isGestureDebugEnabled && draggedEntityId != null) {
        final node = getEntity(draggedEntityId) as GraphNode?;
        if (node != null) {
          final tapState = _nodeTapManager.getState(draggedEntityId);
          final tapDebugInfo = _nodeTapManager.getTapStateDebugInfo(
            draggedEntityId,
          );
          final dragState = _nodeDragManager.getState(draggedEntityId);

          logGestureDebug(
            GestureDebugEventType.tapDebugState,
            'GraphGestureManager',
            'TAP_STATE_MOVE',
            data: {
              'event_type': 'tap_debug_state',
              'phase': 'move',
              'nodeTargetId': draggedEntityId.value,
              'state_exists': tapState != null,
              'state_completed': tapState?.completed ?? false,
              'state_cancelled': tapState?.cancelled ?? false,
              'tap_count': tapState?.tapCount ?? 0,
              'tracked_entity_id':
                  _nodeTapManager.trackedEntityId?.value ?? 'null',
              'is_still_dragging_after_up': false, // Always false during move
              'is_tap_completed_after_up': false, // Always false during move
              'touch_slop': kTouchSlop * 8,
              'k_touch_slop': kTouchSlop,
              'timestamp': DateTime.now().toIso8601String(),
              'tap_debug_info': tapDebugInfo,
              'node_can_select': node.canSelect,
              'node_can_drag': node.canDrag,
              'node_is_selected': graph.selectedEntityIds.contains(node.id),
              'gesture_mode': gestureMode.name,
              'pointer_position': {
                'x': event.localPosition.dx,
                'y': event.localPosition.dy,
              },
              'node_position': {
                'x': node.logicalPosition.dx,
                'y': node.logicalPosition.dy,
              },
              'tap_manager_states_count': _nodeTapManager.states.length,
              'drag_state_exists': dragState != null,
              'drag_manager_is_dragging': _nodeDragManager.isDragging(
                draggedEntityId,
              ),
              'distance': _calculateDistance(
                event.localPosition,
                tapDebugInfo?['downPosition'] as Map<String, dynamic>?,
              ),
              'isWithinSlop': _isWithinTouchSlop(
                event.localPosition,
                tapDebugInfo?['downPosition'] as Map<String, dynamic>?,
              ),
            },
          );
        }
      }
      return;
    }

    if (_linkDragManager.isActive || findLinkAt(scenePos) != null) {
      _linkDragManager.handlePointerMove(event);
    }
  }

  void handleMouseHover(PointerHoverEvent event) {
    final scenePos = toScene(event.localPosition, event.position);
    _lastPointerDetails = PointerEventDetails.fromPointerEvent(event);
    final hoverDetails = _lastPointerDetails!;

    if (isDragging) return;

    final node = findNodeAt(scenePos);
    final link = findLinkAt(scenePos);

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

  /// Calculate distance between current position and down position
  double _calculateDistance(
    Offset currentPosition,
    Map<String, dynamic>? downPosition,
  ) {
    if (downPosition == null) return 0;

    final downX = downPosition['x'] as double? ?? 0;
    final downY = downPosition['y'] as double? ?? 0;
    final dx = currentPosition.dx - downX;
    final dy = currentPosition.dy - downY;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// Check if current position is within touch slop of down position
  bool _isWithinTouchSlop(
    Offset currentPosition,
    Map<String, dynamic>? downPosition,
  ) {
    if (downPosition == null) return true;

    final distance = _calculateDistance(currentPosition, downPosition);
    // Use the same touch slop as tap state manager
    return distance <= kTouchSlop * 4;
  }
}

// ---------------------------------------------------------------------------
// Spatial grid for fast node hit-testing
// ---------------------------------------------------------------------------

/// A uniform spatial grid that maps screen cells to overlapping nodes.
///
/// Rebuilt whenever node positions change significantly (e.g., after layout or
/// drag end). During a query, only nodes in the cell(s) near [position] are
/// checked, reducing average hit-test complexity from O(n) to O(k) where k is
/// the number of nodes per cell (typically < 5).
class _NodeSpatialGrid {
  _NodeSpatialGrid({required this.cellSize});

  final double cellSize;

  final Map<(int, int), List<GraphNode>> _cells = {};

  (int, int) _cellKey(double x, double y) {
    return (x ~/ cellSize, y ~/ cellSize);
  }

  /// Rebuild the grid from current node geometries.
  void rebuild(Iterable<GraphNode> nodes) {
    _cells.clear();
    for (final node in nodes) {
      final geometry = node.geometry;
      if (geometry == null) continue;
      final bounds = geometry.bounds;
      // A node may span multiple cells; cover all overlapping cells.
      final left = bounds.left ~/ cellSize;
      final top = bounds.top ~/ cellSize;
      final right = bounds.right ~/ cellSize;
      final bottom = bounds.bottom ~/ cellSize;
      for (var cx = left; cx <= right; cx++) {
        for (var cy = top; cy <= bottom; cy++) {
          _cells.putIfAbsent((cx, cy), () => []).add(node);
        }
      }
    }
  }

  /// Returns nodes whose cells overlap [position].
  List<GraphNode> candidatesAt(Offset position) {
    final key = _cellKey(position.dx, position.dy);
    return _cells[key] ?? const [];
  }
}
