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
  return loadGraphTemplate('Default');
}

// Load graph template by name
Graph loadGraphTemplate(String templateName) {
  switch (templateName) {
    case 'Default':
      return _createDefaultGraph();
    case 'Small Network':
      return _createSmallNetworkGraph();
    case 'Large Network':
      return _createLargeNetworkGraph();
    case 'Tree Structure':
      return _createTreeStructureGraph();
    case 'Complex Graph':
      return _createComplexGraph();
    default:
      return _createDefaultGraph();
  }
}

Graph _createDefaultGraph() {
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

Graph _createSmallNetworkGraph() {
  final graph = Graph();

  // Create 6 nodes
  final nodes = <GraphNode>[];
  for (int i = 1; i <= 6; i++) {
    nodes.add(GraphNode(properties: {'label': 'Node $i'}));
    graph.addNode(nodes.last);
  }

  // Create interconnections
  graph.addLink(GraphLink(source: nodes[0], target: nodes[1], direction: GraphLinkDirection.outgoing));
  graph.addLink(GraphLink(source: nodes[0], target: nodes[2], direction: GraphLinkDirection.outgoing));
  graph.addLink(GraphLink(source: nodes[1], target: nodes[3], direction: GraphLinkDirection.outgoing));
  graph.addLink(GraphLink(source: nodes[2], target: nodes[4], direction: GraphLinkDirection.outgoing));
  graph.addLink(GraphLink(source: nodes[3], target: nodes[5], direction: GraphLinkDirection.outgoing));
  graph.addLink(GraphLink(source: nodes[4], target: nodes[5], direction: GraphLinkDirection.outgoing));
  graph.addLink(GraphLink(source: nodes[1], target: nodes[4], direction: GraphLinkDirection.outgoing));

  return graph;
}

Graph _createLargeNetworkGraph() {
  final graph = Graph();

  // Create 25 nodes
  final nodes = <GraphNode>[];
  for (int i = 1; i <= 25; i++) {
    nodes.add(GraphNode(properties: {'label': 'Node $i'}));
    graph.addNode(nodes.last);
  }

  // Create more complex interconnections
  for (int i = 0; i < nodes.length; i++) {
    // Connect each node to 2-4 other nodes
    final connectionCount = 2 + (i % 3);
    for (int j = 1; j <= connectionCount; j++) {
      final targetIndex = (i + j * 3) % nodes.length;
      if (targetIndex != i) {
        graph.addLink(GraphLink(
          source: nodes[i],
          target: nodes[targetIndex],
          direction: GraphLinkDirection.outgoing,
        ));
      }
    }
  }

  return graph;
}

Graph _createTreeStructureGraph() {
  final graph = Graph();

  // Create root node
  final root = GraphNode(properties: {'label': 'Root'});
  graph.addNode(root);

  // Create level 1 nodes
  final level1Nodes = <GraphNode>[];
  for (int i = 1; i <= 3; i++) {
    final node = GraphNode(properties: {'label': 'L1-$i'});
    level1Nodes.add(node);
    graph.addNode(node);
    graph.addLink(GraphLink(
      source: root,
      target: node,
      direction: GraphLinkDirection.outgoing,
    ));
  }

  // Create level 2 nodes
  for (int i = 0; i < level1Nodes.length; i++) {
    final childCount = i == 0 ? 3 : 2; // First branch has 3 children, others have 2
    for (int j = 1; j <= childCount; j++) {
      final node = GraphNode(properties: {'label': 'L2-${i + 1}-$j'});
      graph.addNode(node);
      graph.addLink(GraphLink(
        source: level1Nodes[i],
        target: node,
        direction: GraphLinkDirection.outgoing,
      ));
    }
  }

  return graph;
}

Graph _createComplexGraph() {
  final graph = Graph();

  // Create central hub nodes
  final hubs = <GraphNode>[];
  for (int i = 1; i <= 4; i++) {
    final hub = GraphNode(properties: {'label': 'Hub $i'});
    hubs.add(hub);
    graph.addNode(hub);
  }

  // Connect hubs in a circle
  for (int i = 0; i < hubs.length; i++) {
    final nextIndex = (i + 1) % hubs.length;
    graph.addLink(GraphLink(
      source: hubs[i],
      target: hubs[nextIndex],
      direction: GraphLinkDirection.outgoing,
    ));
  }

  // Add satellite nodes around each hub
  for (int i = 0; i < hubs.length; i++) {
    final satelliteCount = 3 + (i % 2); // 3 or 4 satellites per hub
    for (int j = 1; j <= satelliteCount; j++) {
      final satellite = GraphNode(properties: {'label': 'S${i + 1}-$j'});
      graph.addNode(satellite);
      graph.addLink(GraphLink(
        source: hubs[i],
        target: satellite,
        direction: GraphLinkDirection.outgoing,
      ));
      
      // Some satellites connect to other hubs
      if (j == 1 && i < hubs.length - 1) {
        graph.addLink(GraphLink(
          source: satellite,
          target: hubs[i + 1],
          direction: GraphLinkDirection.outgoing,
        ));
      }
    }
  }

  return graph;
}