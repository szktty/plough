import 'package:flutter/material.dart';
import 'package:plough/plough.dart';
import 'dart:async';

void main() {
  runApp(const DebugApp());
}

class DebugApp extends StatelessWidget {
  const DebugApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plough Debug App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DebugHomePage(),
    );
  }
}

class DebugHomePage extends StatefulWidget {
  const DebugHomePage({super.key});

  @override
  State<DebugHomePage> createState() => _DebugHomePageState();
}

class _DebugHomePageState extends State<DebugHomePage> {
  late Graph graph;
  final List<DebugEvent> _events = [];
  final _eventStreamController = StreamController<DebugEvent>.broadcast();
  
  // Monitoring flags
  bool _monitorCallbacks = true;
  bool _monitorRebuilds = true;
  bool _monitorNotifications = true;
  
  // Stats
  int _rebuildCount = 0;
  int _callbackCount = 0;
  int _notificationCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeGraph();
  }

  void _initializeGraph() {
    graph = Graph();
    
    // Create simple test nodes
    final node1 = GraphNode(properties: {'label': 'Node 1'});
    final node2 = GraphNode(properties: {'label': 'Node 2'});
    final node3 = GraphNode(properties: {'label': 'Node 3'});
    
    graph.addNode(node1);
    graph.addNode(node2);
    graph.addNode(node3);
    
    // Add links
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
    
    // Monitor graph changes
    graph.addListener(_onGraphChanged);
  }

  void _onGraphChanged() {
    _notificationCount++;
    _logEvent(DebugEvent(
      type: EventType.notification,
      source: 'Graph',
      message: 'Graph data changed',
      timestamp: DateTime.now(),
    ));
  }

  void _logEvent(DebugEvent event) {
    // Use addPostFrameCallback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _events.insert(0, event);
          if (_events.length > 1000) {
            _events.removeRange(500, _events.length);
          }
        });
      }
    });
    _eventStreamController.add(event);
  }

  @override
  void dispose() {
    graph.removeListener(_onGraphChanged);
    _eventStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plough Debug App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Row(
        children: [
          // Graph view area
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.grey[200],
                    child: Row(
                      children: [
                        const Text('Graph View', style: TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Text('Rebuilds: $_rebuildCount'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: DebugGraphView(
                      graph: graph,
                      onEvent: _logEvent,
                      onRebuild: () {
                        _rebuildCount++;
                      },
                      monitorCallbacks: _monitorCallbacks,
                      monitorRebuilds: _monitorRebuilds,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Debug panel
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // Control panel
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey[100],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Monitoring Options', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: const Text('Callbacks'),
                        value: _monitorCallbacks,
                        onChanged: (value) => setState(() => _monitorCallbacks = value),
                        dense: true,
                      ),
                      SwitchListTile(
                        title: const Text('Rebuilds'),
                        value: _monitorRebuilds,
                        onChanged: (value) => setState(() => _monitorRebuilds = value),
                        dense: true,
                      ),
                      SwitchListTile(
                        title: const Text('Notifications'),
                        value: _monitorNotifications,
                        onChanged: (value) => setState(() => _monitorNotifications = value),
                        dense: true,
                      ),
                    ],
                  ),
                ),
                // Stats
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.blue[50],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Statistics', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Total Callbacks: $_callbackCount'),
                      Text('Total Rebuilds: $_rebuildCount'),
                      Text('Total Notifications: $_notificationCount'),
                    ],
                  ),
                ),
                // Event log
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.grey[200],
                          child: Row(
                            children: [
                              const Text('Event Log', style: TextStyle(fontWeight: FontWeight.bold)),
                              const Spacer(),
                              TextButton(
                                onPressed: () => setState(() => _events.clear()),
                                child: const Text('Clear'),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _events.length,
                            itemBuilder: (context, index) {
                              final event = _events[index];
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: index % 2 == 0 ? Colors.white : Colors.grey[50],
                                  border: Border(
                                    bottom: BorderSide(color: Colors.grey[300]!),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.only(top: 4, right: 8),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _getEventColor(event.type),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            event.message,
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                          Text(
                                            '${event.source} - ${_formatTime(event.timestamp)}',
                                            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                          ),
                                          if (event.details != null)
                                            Text(
                                              event.details!,
                                              style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Action buttons
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _addNode,
            tooltip: 'Add Node',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: _removeNode,
            tooltip: 'Remove Node',
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: _triggerAnimation,
            tooltip: 'Trigger Animation',
            child: const Icon(Icons.play_arrow),
          ),
        ],
      ),
    );
  }

  void _addNode() {
    final nodeLabel = 'Node ${graph.nodes.length + 1}';
    final node = GraphNode(properties: {'label': nodeLabel});
    graph.addNode(node);
    
    if (graph.nodes.length > 1) {
      final nodesList = graph.nodes.toList();
      final randomNode = nodesList[nodesList.length - 2];
      graph.addLink(GraphLink(
        source: node,
        target: randomNode,
        direction: GraphLinkDirection.outgoing,
      ));
    }
  }

  void _removeNode() {
    if (graph.nodes.isNotEmpty) {
      graph.removeNode(graph.nodes.last.id);
    }
  }

  void _triggerAnimation() {
    // Trigger layout recalculation
    setState(() {});
  }

  Color _getEventColor(EventType type) {
    switch (type) {
      case EventType.callback:
        return Colors.green;
      case EventType.rebuild:
        return Colors.orange;
      case EventType.notification:
        return Colors.blue;
      case EventType.gesture:
        return Colors.purple;
      case EventType.layout:
        return Colors.red;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
           '${time.minute.toString().padLeft(2, '0')}:'
           '${time.second.toString().padLeft(2, '0')}.'
           '${time.millisecond.toString().padLeft(3, '0')}';
  }
}

// Debug event types
enum EventType {
  callback,
  rebuild,
  notification,
  gesture,
  layout,
}

// Debug event model
class DebugEvent {
  final EventType type;
  final String source;
  final String message;
  final DateTime timestamp;
  final String? details;

  DebugEvent({
    required this.type,
    required this.source,
    required this.message,
    required this.timestamp,
    this.details,
  });
}

// Custom GraphView with debug instrumentation
class DebugGraphView extends StatefulWidget {
  final Graph graph;
  final Function(DebugEvent) onEvent;
  final VoidCallback onRebuild;
  final bool monitorCallbacks;
  final bool monitorRebuilds;

  const DebugGraphView({
    super.key,
    required this.graph,
    required this.onEvent,
    required this.onRebuild,
    required this.monitorCallbacks,
    required this.monitorRebuilds,
  });

  @override
  State<DebugGraphView> createState() => _DebugGraphViewState();
}

class _DebugGraphViewState extends State<DebugGraphView> {
  int _buildCount = 0;

  @override
  Widget build(BuildContext context) {
    _buildCount++;
    if (widget.monitorRebuilds) {
      // Post rebuild event after the build completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onRebuild();
        widget.onEvent(DebugEvent(
          type: EventType.rebuild,
          source: 'DebugGraphView',
          message: 'Widget rebuilt',
          timestamp: DateTime.now(),
          details: 'Build #$_buildCount',
        ));
      });
    }

    return GraphView(
      graph: widget.graph,
      layoutStrategy: GraphForceDirectedLayoutStrategy(),
      behavior: _createDebugBehavior(),
    );
  }

  GraphViewBehavior _createDebugBehavior() {
    return DebugGraphViewBehavior(
      onEvent: widget.onEvent,
      monitorCallbacks: widget.monitorCallbacks,
    );
  }
}

// Custom behavior for debugging
class DebugGraphViewBehavior extends GraphViewDefaultBehavior {
  final Function(DebugEvent) onEvent;
  final bool monitorCallbacks;

  DebugGraphViewBehavior({
    required this.onEvent,
    required this.monitorCallbacks,
  });

  @override
  void onTap(GraphTapEvent event) {
    super.onTap(event);
    if (monitorCallbacks) {
      final hasEntities = event.entityIds.isNotEmpty;
      final details = hasEntities
          ? 'Entities: ${event.entityIds.length}, Tap count: ${event.tapCount}, Position: ${event.details.localPosition}'
          : 'Background tap at ${event.details.localPosition}';
      onEvent(DebugEvent(
        type: EventType.callback,
        source: 'DebugGraphViewBehavior',
        message: 'onTap fired',
        timestamp: DateTime.now(),
        details: details,
      ));
    }
  }

  @override
  void onSelectionChange(GraphSelectionChangeEvent event) {
    super.onSelectionChange(event);
    if (monitorCallbacks) {
      final selectedCount = event.selectedIds.length;
      final deselectedCount = event.deselectedIds.length;
      final currentCount = event.currentSelectionIds.length;
      onEvent(DebugEvent(
        type: EventType.callback,
        source: 'DebugGraphViewBehavior',
        message: 'onSelectionChange fired',
        timestamp: DateTime.now(),
        details: 'Selected: $selectedCount, Deselected: $deselectedCount, Current: $currentCount',
      ));
    }
  }

  @override
  void onDragStart(GraphDragStartEvent event) {
    super.onDragStart(event);
    if (monitorCallbacks) {
      final hasEntities = event.entityIds.isNotEmpty;
      final details = hasEntities
          ? 'Entities: ${event.entityIds.length}, Position: ${event.details.localPosition}'
          : 'Background drag start at ${event.details.localPosition}';
      onEvent(DebugEvent(
        type: EventType.gesture,
        source: 'DebugGraphViewBehavior',
        message: 'onDragStart fired',
        timestamp: DateTime.now(),
        details: details,
      ));
    }
  }

  @override
  void onDragUpdate(GraphDragUpdateEvent event) {
    super.onDragUpdate(event);
    if (monitorCallbacks) {
      final hasEntities = event.entityIds.isNotEmpty;
      final details = hasEntities
          ? 'Entities: ${event.entityIds.length}, Delta: ${event.delta}'
          : 'Background drag, Delta: ${event.delta}';
      onEvent(DebugEvent(
        type: EventType.gesture,
        source: 'DebugGraphViewBehavior',
        message: 'onDragUpdate fired',
        timestamp: DateTime.now(),
        details: details,
      ));
    }
  }

  @override
  void onDragEnd(GraphDragEndEvent event) {
    super.onDragEnd(event);
    if (monitorCallbacks) {
      final hasEntities = event.entityIds.isNotEmpty;
      final details = hasEntities
          ? 'Entities: ${event.entityIds.length}, Position: ${event.details.localPosition}'
          : 'Background drag end at ${event.details.localPosition}';
      onEvent(DebugEvent(
        type: EventType.gesture,
        source: 'DebugGraphViewBehavior',
        message: 'onDragEnd fired',
        timestamp: DateTime.now(),
        details: details,
      ));
    }
  }

  @override
  void onHoverEnter(GraphHoverEvent event) {
    super.onHoverEnter(event);
    if (monitorCallbacks) {
      onEvent(DebugEvent(
        type: EventType.callback,
        source: 'DebugGraphViewBehavior',
        message: 'onHoverEnter fired',
        timestamp: DateTime.now(),
        details: 'Entity ID: ${event.entityId}, Position: ${event.details.localPosition}',
      ));
    }
  }

  @override
  void onHoverMove(GraphHoverEvent event) {
    super.onHoverMove(event);
    if (monitorCallbacks) {
      onEvent(DebugEvent(
        type: EventType.callback,
        source: 'DebugGraphViewBehavior',
        message: 'onHoverMove fired',
        timestamp: DateTime.now(),
        details: 'Entity ID: ${event.entityId}, Position: ${event.details.localPosition}',
      ));
    }
  }

  @override
  void onHoverEnd(GraphHoverEndEvent event) {
    super.onHoverEnd(event);
    if (monitorCallbacks) {
      onEvent(DebugEvent(
        type: EventType.callback,
        source: 'DebugGraphViewBehavior',
        message: 'onHoverEnd fired',
        timestamp: DateTime.now(),
        details: 'Position: ${event.details.localPosition}',
      ));
    }
  }

  @override
  void onTooltipShow(GraphTooltipShowEvent event) {
    super.onTooltipShow(event);
    if (monitorCallbacks) {
      onEvent(DebugEvent(
        type: EventType.callback,
        source: 'DebugGraphViewBehavior',
        message: 'onTooltipShow fired',
        timestamp: DateTime.now(),
        details: 'Entity ID: ${event.entityId}',
      ));
    }
  }

  @override
  void onTooltipHide(GraphTooltipHideEvent event) {
    super.onTooltipHide(event);
    if (monitorCallbacks) {
      onEvent(DebugEvent(
        type: EventType.callback,
        source: 'DebugGraphViewBehavior',
        message: 'onTooltipHide fired',
        timestamp: DateTime.now(),
        details: 'Entity ID: ${event.entityId}',
      ));
    }
  }
}