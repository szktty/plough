import 'package:flutter/material.dart';
import 'package:plough/plough.dart';
import 'models.dart';

// Layout strategies
const List<String> layoutStrategies = [
  'Force Directed',
  'Tree',
  'Manual',
  'Random',
  'Custom',
];

// Data presets
const List<String> dataPresets = [
  'Default',
  'Small Network',
  'Large Network',
  'Tree Structure',
  'Complex Graph',
];

// Internal debug state default values
Map<String, dynamic> createDefaultDebugState() {
  return {
    'nodeTargetId': 'null',
    'state_exists': false,
    'state_completed': false,
    'state_cancelled': false,
    'tap_count': 0,
    'tracked_entity_id': 'null',
    'is_still_dragging_after_up': false,
    'is_tap_completed_after_up': false,
    'touch_slop': 144.0,
    'k_touch_slop': 18.0,
    'phase': 'none',
    'node_can_select': false,
    'node_can_drag': false,
    'node_is_selected': false,
    'gesture_mode': 'unknown',
    'pointer_position': {'x': 0.0, 'y': 0.0},
    'node_position': {'x': 0.0, 'y': 0.0},
    'node_at_position': 'null',
    'tap_manager_states_count': 0,
    'drag_state_exists': false,
    'drag_manager_is_dragging': false,
    'will_toggle_selection': false,
    'tap_debug_info': null,
    'distance': 0.0,
    'isWithinSlop': false,
  };
}

// Default timeline filters
Set<EventType> createDefaultTimelineFilters() {
  return {
    EventType.gesture,
    EventType.rebuild,
    EventType.notification,
    EventType.layout,
  };
}

// Helper to get event type label
String getEventTypeLabel(EventType type) {
  switch (type) {
    case EventType.callback:
      return 'Callbacks';
    case EventType.rebuild:
      return 'Rebuilds';
    case EventType.notification:
      return 'Notifications';
    case EventType.gesture:
      return 'Gestures';
    case EventType.layout:
      return 'Layout';
  }
}

// Helper to get event color
Color getEventColor(EventType type) {
  switch (type) {
    case EventType.gesture:
      return Colors.red;
    case EventType.callback:
      return Colors.brown;
    case EventType.layout:
      return Colors.pink;
    case EventType.rebuild:
      return Colors.orange;
    case EventType.notification:
      return Colors.teal;
  }
}

// Helper to shorten ID
String shortenId(String id) {
  if (id == 'null' || id == 'N/A') return id;
  return id.length > 6 ? id.substring(id.length - 6) : id;
}

// Initialize graph with sample data
Graph initializeGraph() {
  final graph = Graph();

  // Add sample nodes using the correct API from the original
  final node1 = GraphNode(properties: {'label': 'Node 1'});
  final node2 = GraphNode(properties: {'label': 'Node 2'});
  final node3 = GraphNode(properties: {'label': 'Node 3'});
  final node4 = GraphNode(properties: {'label': 'Node 4'});

  graph.addNode(node1);
  graph.addNode(node2);
  graph.addNode(node3);
  graph.addNode(node4);

  // Add links using the correct API
  graph.addLink(GraphLink(
    source: node1,
    target: node2,
    direction: GraphLinkDirection.outgoing,
  ));
  graph.addLink(GraphLink(
    source: node2,
    target: node3,
    direction: GraphLinkDirection.outgoing,
  ));
  graph.addLink(GraphLink(
    source: node3,
    target: node4,
    direction: GraphLinkDirection.outgoing,
  ));
  graph.addLink(GraphLink(
    source: node4,
    target: node1,
    direction: GraphLinkDirection.outgoing,
  ));

  return graph;
}