import 'package:flutter/gestures.dart';
import 'package:plough/plough.dart'; // For Graph, GraphNode, GraphLink, GraphId, GraphTooltipTriggerMode etc.

/// Base class for all graph interaction events.
abstract class GraphEvent {
  const GraphEvent();
}

/// Contains details about the pointer event that triggered a graph event.
class PointerEventDetails {
  const PointerEventDetails({
    required this.localPosition,
    required this.globalPosition,
    required this.kind,
    this.buttons,
  }); // For mouse events

  factory PointerEventDetails.fromPointerEvent(PointerEvent event) {
    return PointerEventDetails(
      localPosition: event.localPosition,
      globalPosition: event.position, // Use event.position for global
      kind: event.kind,
      buttons: event is PointerDownEvent ||
              event is PointerUpEvent ||
              event is PointerMoveEvent
          ? event.buttons
          : null,
    );
  }

  factory PointerEventDetails.fromDragStartDetails(DragStartDetails details) {
    return PointerEventDetails(
      localPosition: details.localPosition,
      globalPosition: details.globalPosition,
      kind:
          PointerDeviceKind.touch, // Or determine based on context if possible
    );
  }

  factory PointerEventDetails.fromDragUpdateDetails(DragUpdateDetails details) {
    return PointerEventDetails(
      localPosition: details.localPosition,
      globalPosition: details.globalPosition,
      kind:
          PointerDeviceKind.touch, // Or determine based on context if possible
    );
  }

  // DragEndDetails doesn't directly provide position, might need to capture last known position
  factory PointerEventDetails.fromLastKnownPosition(
    Offset local,
    Offset global,
    PointerDeviceKind kind,
  ) {
    return PointerEventDetails(
      localPosition: local,
      globalPosition: global,
      kind: kind,
    );
  }
  final Offset localPosition;
  final Offset globalPosition;
  final PointerDeviceKind kind;
  final int? buttons;
}

/// Base class for events related to one or more graph entities.
abstract class GraphEntityEvent extends GraphEvent {
  const GraphEntityEvent(this.entityIds);
  final List<GraphId> entityIds;

  /// Helper to get the nodes involved in this event from the graph.
  Iterable<GraphNode> getNodes(Graph graph) =>
      entityIds.map((id) => graph.getNode(id)).whereType<GraphNode>();

  /// Helper to get the links involved in this event from the graph.
  Iterable<GraphLink> getLinks(Graph graph) =>
      entityIds.map((id) => graph.getLink(id)).whereType<GraphLink>();
}

/// Event fired when one or more entities are tapped (single or double).
class GraphTapEvent extends GraphEntityEvent {
  const GraphTapEvent({
    required List<GraphId> entityIds,
    required this.details,
    required this.tapCount,
  }) : super(entityIds);

  final PointerEventDetails details;

  /// The number of taps (1 for single tap, 2 for double tap).
  final int tapCount;

  bool get isSingleTap => tapCount == 1;
  bool get isDoubleTap => tapCount == 2;
}

/// Event fired when the selection state of entities changes.
class GraphSelectionChangeEvent extends GraphEvent {
  const GraphSelectionChangeEvent({
    required this.selectedIds,
    required this.deselectedIds,
    required this.currentSelectionIds,
    this.details, // Optional details about the interaction causing the change
  });

  /// IDs of entities that were newly selected in this change.
  final List<GraphId> selectedIds;

  /// IDs of entities that were deselected in this change.
  final List<GraphId> deselectedIds;

  /// All entity IDs currently selected *after* this change.
  final List<GraphId> currentSelectionIds;

  /// Optional details about the pointer event that triggered the selection change.
  final PointerEventDetails? details;

  /// Checks if a specific entity was newly selected in this event.
  bool didSelect(GraphId id) => selectedIds.contains(id);

  /// Checks if a specific entity was deselected in this event.
  bool didDeselect(GraphId id) => deselectedIds.contains(id);
}

/// Event fired when a drag operation starts on one or more entities.
class GraphDragStartEvent extends GraphEntityEvent {
  const GraphDragStartEvent({
    required List<GraphId> entityIds,
    required this.details,
  }) : super(entityIds);
  final PointerEventDetails details;
}

/// Event fired during a drag operation on one or more entities.
class GraphDragUpdateEvent extends GraphEntityEvent {
  const GraphDragUpdateEvent({
    required List<GraphId> entityIds,
    required this.details,
    required this.delta,
  }) : super(entityIds);

  final PointerEventDetails details;

  /// The change in position since the last update.
  final Offset delta;
}

/// Event fired when a drag operation on one or more entities ends.
class GraphDragEndEvent extends GraphEntityEvent {
  const GraphDragEndEvent({
    required List<GraphId> entityIds,
    required this.details,
    // required this.velocity, // from DragEndDetails
  }) : super(entityIds);

  final PointerEventDetails details;
  // final Velocity velocity;
}

/// Event fired when the mouse pointer enters the area of an entity.
class GraphHoverEvent extends GraphEvent {
  const GraphHoverEvent({
    required this.entityId,
    required this.details,
  });
  final GraphId entityId;
  final PointerEventDetails details;

  /// Helper to get the node involved (if it's a node).
  GraphNode? getNode(Graph graph) => graph.getNode(entityId);

  /// Helper to get the link involved (if it's a link).
  GraphLink? getLink(Graph graph) => graph.getLink(entityId);
}

/// Event fired when the mouse pointer leaves the area of an entity.
class GraphHoverEndEvent extends GraphEvent {
  const GraphHoverEndEvent({
    required this.entityId,
    required this.details,
  });
  final GraphId entityId;
  final PointerEventDetails details;

  /// Helper to get the node involved (if it's a node).
  GraphNode? getNode(Graph graph) => graph.getNode(entityId);

  /// Helper to get the link involved (if it's a link).
  GraphLink? getLink(Graph graph) => graph.getLink(entityId);
}

/// Event fired when an entity's tooltip is shown.
class GraphTooltipShowEvent extends GraphEvent {
  const GraphTooltipShowEvent({
    required this.entityId,
    required this.details, // Details of the event that triggered the tooltip (e.g., hover or tap)
    required this.triggerMode,
  });
  final GraphId entityId;
  final PointerEventDetails details;
  final GraphTooltipTriggerMode triggerMode;

  /// Helper to get the node involved (if it's a node).
  GraphNode? getNode(Graph graph) => graph.getNode(entityId);

  /// Helper to get the link involved (if it's a link).
  GraphLink? getLink(Graph graph) => graph.getLink(entityId);
}

/// Event fired when an entity's tooltip is hidden.
class GraphTooltipHideEvent extends GraphEvent {
  const GraphTooltipHideEvent({
    required this.entityId,
    this.details, // Optional details if hiding was triggered by a specific event
  });
  final GraphId entityId;
  final PointerEventDetails? details;

  /// Helper to get the node involved (if it's a node).
  GraphNode? getNode(Graph graph) => graph.getNode(entityId);

  /// Helper to get the link involved (if it's a link).
  GraphLink? getLink(Graph graph) => graph.getLink(entityId);
}
