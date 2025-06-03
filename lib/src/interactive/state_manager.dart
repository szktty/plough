import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/graph/link.dart';
import 'package:plough/src/graph/node.dart';
import 'package:plough/src/interactive/gesture_manager.dart';

@internal
enum GraphEntityType {
  node,
  link;

  bool get isNode => this == GraphEntityType.node;

  bool get isLink => this == GraphEntityType.link;
}

@internal
abstract base class GraphStateManager<T> with Diagnosticable {
  GraphStateManager({
    required this.gestureManager,
  });

  final GraphGestureManager gestureManager;

  GraphViewBehavior get behavior => gestureManager.viewBehavior;

  final Map<GraphId, T> _states = <GraphId, T>{};

  GraphId? _lastActiveEntityId;

  List<T> get states => _states.values.toList();

  GraphEntityType get entityType;

  /// IDs of the entities currently being managed by this state manager.
  List<GraphId> get activeEntityIds => _states.keys.toList();

  /// The ID of the last entity for which state was set.
  GraphId? get lastActiveEntityId => _lastActiveEntityId;

  static const double defaultDragThreshold = 8;

  double get dragThreshold => defaultDragThreshold;

  bool hasState(GraphId entityId) => _states.containsKey(entityId);

  GraphNode? getNode(GraphId entityId) =>
      gestureManager.graph.getNode(entityId);

  List<GraphNode> getNodes(List<GraphId> entityIds) =>
      entityIds.map((id) => getNode(id)!).toList();

  GraphLink? getLink(GraphId entityId) =>
      gestureManager.graph.getLink(entityId);

  List<GraphLink> getLinks(List<GraphId> entityIds) =>
      entityIds.map((id) => getLink(id)!).toList();

  GraphId? firstWhere(bool Function(T) callback) =>
      _states.entries.firstWhereOrNull((e) => callback(e.value))?.key;

  Iterable<GraphId> where(bool Function(T) callback) =>
      _states.entries.where((e) => callback(e.value)).map((e) => e.key);

  // TODO: Maybe no need to override in subclasses?
  List<GraphId> get targets => _states.keys.toList();

  int get activeCount => _states.values.length;

  bool get isActive => activeCount > 0;

  T? getState(GraphId entityId) => _states[entityId];

  void setState(GraphId entityId, T state) {
    _states[entityId] = state;
    _lastActiveEntityId = entityId; // Update last active ID
  }

  void removeState(GraphId entityId) {
    _states.remove(entityId);
    // Optionally, clear _lastActiveEntityId if it matches entityId
    if (_lastActiveEntityId == entityId) {
      // Set to null or find the new last? Setting to null is simpler.
      _lastActiveEntityId = null;
    }
  }

  void clearAllStates() {
    _states.clear();
    _lastActiveEntityId = null; // Clear last active ID
  }

  void cancel(GraphId entityId);

  void select(GraphId entityId) {
    switch (entityType) {
      case GraphEntityType.node:
        gestureManager.graph.selectNode(entityId);
      case GraphEntityType.link:
        gestureManager.graph.selectLink(entityId);
    }
  }

  void deselect(GraphId entityId) {
    switch (entityType) {
      case GraphEntityType.node:
        gestureManager.graph.deselectNode(entityId);
      case GraphEntityType.link:
        gestureManager.graph.deselectLink(entityId);
    }
  }

  bool isSelected(GraphId entityId) {
    switch (entityType) {
      case GraphEntityType.node:
        return gestureManager.graph.getNode(entityId)?.isSelected ?? false;
      case GraphEntityType.link:
        return gestureManager.graph.getLink(entityId)?.isSelected ?? false;
    }
  }

  bool canSelect(GraphId entityId) {
    switch (entityType) {
      case GraphEntityType.node:
        return gestureManager.graph.getNode(entityId)?.canSelect ?? false;
      case GraphEntityType.link:
        return gestureManager.graph.getLink(entityId)?.canSelect ?? false;
    }
  }

  Offset? getPosition(GraphId entityId) {
    switch (entityType) {
      case GraphEntityType.node:
        return gestureManager.graph.getNode(entityId)?.logicalPosition;
      case GraphEntityType.link:
        final link = gestureManager.graph.getLink(entityId) as GraphLinkImpl?;
        return link?.sourceImpl.logicalPosition;
    }
  }

  void setPosition(GraphId entityId, Offset position) {
    switch (entityType) {
      case GraphEntityType.node:
        final node = gestureManager.graph.getNode(entityId) as GraphNodeImpl?;
        if (node != null) {
          // Use force update during drag to ensure immediate UI updates
          node.setState(
            node.state.value.copyWith(logicalPosition: position),
            force: true,
          );

          // Update node geometry during drag
          // (deferred to avoid setState during build)
          if (node.geometry != null) {
            final currentGeometry = node.geometry!;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (node.geometry != null) {
                node.geometry = GraphNodeViewGeometry(
                  bounds: Rect.fromLTWH(
                    position.dx,
                    position.dy,
                    currentGeometry.bounds.width,
                    currentGeometry.bounds.height,
                  ),
                );
              }
            });
          }
        }
      case GraphEntityType.link:
        // not supported
        break;
    }
  }

  // Methods previously calling GraphViewBehavior callbacks are now obsolete.
  // Event dispatching is handled by GraphGestureManager.
  /*
  void onTap(List<GraphId> entityIds) {
    switch (entityType) {
      case GraphEntityType.node:
        behavior.onNodeTap(getNodes(entityIds));
      case GraphEntityType.link:
        behavior.onLinkTap(getLinks(entityIds));
    }
  }

  void onDoubleTap(List<GraphId> entityIds) {
    switch (entityType) {
      case GraphEntityType.node:
        behavior.onNodeDoubleTap(getNodes(entityIds));
      case GraphEntityType.link:
        behavior.onLinkDoubleTap(getLinks(entityIds));
    }
  }

  void onDragStart(List<GraphId> entityIds) {
    switch (entityType) {
      case GraphEntityType.node:
        behavior.onNodeDragStart(getNodes(entityIds));
      case GraphEntityType.link:
        behavior.onLinkDragStart(getLinks(entityIds));
    }
  }

  void onDragUpdate(List<GraphId> entityIds) {
    switch (entityType) {
      case GraphEntityType.node:
        behavior.onNodeDragUpdate(getNodes(entityIds));
      case GraphEntityType.link:
        behavior.onLinkDragUpdate(getLinks(entityIds));
    }
  }

  void onDragEnd(List<GraphId> entityIds) {
    switch (entityType) {
      case GraphEntityType.node:
        behavior.onNodeDragEnd(getNodes(entityIds));
      case GraphEntityType.link:
        behavior.onLinkDragEnd(getLinks(entityIds));
    }
  }

  void onDragMove(List<GraphId> entityIds) {
    switch (entityType) {
      case GraphEntityType.node:
        behavior.onNodeDragMove(getNodes(entityIds));
      case GraphEntityType.link:
        behavior.onLinkDragMove(getLinks(entityIds));
    }
  }

  void onMouseEnter(GraphId entityId) {
    switch (entityType) {
      case GraphEntityType.node:
        behavior.onNodeMouseEnter(getNode(entityId)!);
      case GraphEntityType.link:
        behavior.onLinkMouseEnter(getLink(entityId)!);
    }
  }

  void onMouseExit(GraphId entityId) {
    switch (entityType) {
      case GraphEntityType.node:
        behavior.onNodeMouseExit(getNode(entityId)!);
      case GraphEntityType.link:
        behavior.onLinkMouseExit(getLink(entityId)!);
    }
  }

  void onMouseHover(GraphId entityId) {
    switch (entityType) {
      case GraphEntityType.node:
        behavior.onNodeMouseHover(getNode(entityId)!);
      case GraphEntityType.link:
        behavior.onLinkMouseHover(getLink(entityId)!);
    }
  }

  void onHoverEnd(GraphId entityId) {
    // gestureManager.endHover(entityId); // This logic might be needed in GestureManager
    switch (entityType) {
      case GraphEntityType.node:
        behavior.onNodeHoverEnd(getNode(entityId)!);
      case GraphEntityType.link:
        behavior.onLinkHoverEnd(getLink(entityId)!);
    }
  }

  void onTooltipShow(GraphId entityId) {
    switch (entityType) {
      case GraphEntityType.node:
        final node = getNode(entityId)!;
        behavior.onNodeTooltipShow(node);
        gestureManager.onTooltipShow?.call(node);
      case GraphEntityType.link:
        final link = getLink(entityId)!;
        behavior.onLinkTooltipShow(link);
        gestureManager.onTooltipShow?.call(link);
    }
  }

  void onTooltipHide(GraphId entityId) {
    switch (entityType) {
      case GraphEntityType.node:
        final node = getNode(entityId)!;
        behavior.onNodeTooltipHide(node);
        gestureManager.onTooltipHide?.call(node);
      case GraphEntityType.link:
        final link = getLink(entityId)!;
        behavior.onLinkTooltipHide(link);
        gestureManager.onTooltipHide?.call(link);
    }
  }
  */
}
