import 'package:flutter/material.dart';
import 'package:plough/plough.dart';
import 'dart:async';

void main() {
  runApp(const WorkbenchApp());
}

class WorkbenchApp extends StatelessWidget {
  const WorkbenchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plough Workbench',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
      home: const WorkbenchHomePage(),
    );
  }
}

class WorkbenchHomePage extends StatefulWidget {
  const WorkbenchHomePage({super.key});

  @override
  State<WorkbenchHomePage> createState() => _WorkbenchHomePageState();
}

class _WorkbenchHomePageState extends State<WorkbenchHomePage> {
  late Graph graph;
  final List<DebugEvent> _events = [];
  final _eventStreamController = StreamController<DebugEvent>.broadcast();
  
  // Monitoring flags
  final bool _monitorCallbacks = true;
  final bool _monitorRebuilds = true;
  final bool _monitorGestureStates = true;
  
  // Stats
  int _rebuildCount = 0;
  
  // Gesture state tracking
  bool _isDragging = false;
  bool _isHovering = false;
  bool _isTapTracking = false;
  String? _lastDraggedEntityId;
  String? _hoveredEntityId;
  String? _trackedTapEntityId;
  int _currentTapCount = 0;
  int? _doubleTapTimeRemaining;
  int _totalGestureEvents = 0;
  Timer? _gestureStateUpdateTimer;
  
  // Layout and data management
  String _currentLayoutStrategy = 'ForceDirected';
  String _currentDataPreset = 'Default';
  bool _animationEnabled = false;
  
  final List<String> _layoutStrategies = [
    'ForceDirected',
    'Tree',
    'Manual',
    'Random',
  ];
  
  final List<String> _dataPresets = [
    'Default',
    'Small Network',
    'Large Network',
    'Tree Structure',
    'Complex Graph',
  ];

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
    _gestureStateUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Layout strategy dropdown
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _currentLayoutStrategy,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _currentLayoutStrategy = newValue;
                                });
                                _applyLayoutStrategy();
                              }
                            },
                            items: _layoutStrategies.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: const TextStyle(fontSize: 12)),
                              );
                            }).toList(),
                            isDense: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _resetLayout,
                          tooltip: 'Reset Layout',
                          icon: const Icon(Icons.restart_alt),
                          iconSize: 20,
                        ),
                        const SizedBox(width: 8),
                        // Data preset dropdown
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _currentDataPreset,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _currentDataPreset = newValue;
                                });
                                _loadDataPreset();
                              }
                            },
                            items: _dataPresets.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: const TextStyle(fontSize: 12)),
                              );
                            }).toList(),
                            isDense: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _reloadGraphData,
                          tooltip: 'Reload Graph Data',
                          icon: const Icon(Icons.download),
                          iconSize: 20,
                        ),
                        const SizedBox(width: 8),
                        // Node management buttons
                        IconButton(
                          onPressed: _addNode,
                          tooltip: 'Add Node',
                          icon: const Icon(Icons.add_circle_outline),
                          iconSize: 20,
                        ),
                        IconButton(
                          onPressed: _removeNode,
                          tooltip: 'Remove Node',
                          icon: const Icon(Icons.remove_circle_outline),
                          iconSize: 20,
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _forceRebuild,
                          tooltip: 'Force Rebuild',
                          icon: const Icon(Icons.refresh),
                          iconSize: 20,
                        ),
                        const SizedBox(width: 16),
                        // Animation toggle
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: _animationEnabled,
                              onChanged: (bool? value) {
                                setState(() {
                                  _animationEnabled = value ?? false;
                                });
                              },
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              splashRadius: 0,
                              visualDensity: VisualDensity.compact,
                            ),
                            const Text('Animation', style: TextStyle(fontSize: 12)),
                          ],
                        ),
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
                      animationEnabled: _animationEnabled,
                      updateGestureState: _updateGestureState,
                    ),
                  ),
                  // Status bar
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.grey[300],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Nodes: ${graph.nodes.length}', style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 16),
                        Text('Links: ${graph.links.length}', style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 16),
                        Text('Rebuilds: $_rebuildCount', style: const TextStyle(fontSize: 12)),
                      ],
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
                // Gesture State Panel
                Container(
                  color: Colors.purple[50],
                  child: ExpansionTile(
                    title: const Text('Gesture State', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    initiallyExpanded: true,
                    tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                    childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    backgroundColor: Colors.purple[50],
                    collapsedBackgroundColor: Colors.purple[50],
                    iconColor: Colors.purple[700],
                    collapsedIconColor: Colors.purple[700],
                    shape: const Border(),
                    collapsedShape: const Border(),
                    controlAffinity: ListTileControlAffinity.leading,
                    children: [
                      _buildGestureStateDisplay(),
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
                                style: TextButton.styleFrom(
                                  splashFactory: NoSplash.splashFactory,
                                  overlayColor: Colors.transparent,
                                ),
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

  void _applyLayoutStrategy() {
    // Apply the selected layout strategy
    setState(() {
      _rebuildCount = 0; // Reset rebuild count on layout change
    });
    _logEvent(DebugEvent(
      type: EventType.layout,
      source: 'WorkbenchHomePage',
      message: 'Layout strategy changed',
      timestamp: DateTime.now(),
      details: 'Strategy: $_currentLayoutStrategy',
    ));
  }

  void _resetLayout() {
    // Reset layout positions
    setState(() {});
    _logEvent(DebugEvent(
      type: EventType.layout,
      source: 'WorkbenchHomePage',
      message: 'Layout reset',
      timestamp: DateTime.now(),
    ));
  }

  void _loadDataPreset() {
    // Load the selected data preset (UI only for now)
    setState(() {
      _rebuildCount = 0; // Reset rebuild count on preset load
    });
    _logEvent(DebugEvent(
      type: EventType.callback,
      source: 'WorkbenchHomePage',
      message: 'Data preset selected',
      timestamp: DateTime.now(),
      details: 'Preset: $_currentDataPreset',
    ));
  }

  void _reloadGraphData() {
    // Reload current graph data
    setState(() {});
    _logEvent(DebugEvent(
      type: EventType.callback,
      source: 'WorkbenchHomePage',
      message: 'Graph data reloaded',
      timestamp: DateTime.now(),
    ));
  }

  void _forceRebuild() {
    // Force a complete rebuild
    setState(() {});
    _logEvent(DebugEvent(
      type: EventType.rebuild,
      source: 'WorkbenchHomePage',
      message: 'Force rebuild triggered',
      timestamp: DateTime.now(),
    ));
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

  void _updateGestureState(String gestureType, Map<String, dynamic> data) {
    if (!_monitorGestureStates) return;
    
    setState(() {
      _totalGestureEvents++;
      
      switch (gestureType) {
        case 'tap':
          _isTapTracking = data['tracking'] ?? false;
          _currentTapCount = data['tapCount'] ?? 0;
          _trackedTapEntityId = data['entityId'];
          break;
        case 'dragStart':
          _isDragging = true;
          _lastDraggedEntityId = data['entityId'];
          break;
        case 'dragEnd':
          _isDragging = false;
          break;
        case 'hoverEnter':
          _isHovering = true;
          _hoveredEntityId = data['entityId'];
          break;
        case 'hoverEnd':
          _isHovering = false;
          _hoveredEntityId = null;
          break;
      }
    });
  }

  Widget _buildGestureStateDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStateIndicator('Dragging', _isDragging, Colors.purple),
        _buildStateIndicator('Hovering', _isHovering, Colors.blue),
        _buildStateIndicator('Tap Tracking', _isTapTracking, Colors.green),
        const SizedBox(height: 4),
        _buildEntityInfo('Last Dragged', _lastDraggedEntityId),
        _buildEntityInfo('Hovered Entity', _hoveredEntityId),
        _buildEntityInfo('Tap Target', _trackedTapEntityId),
        const SizedBox(height: 4),
        _buildCounterInfo('Tap Count', _currentTapCount),
        _buildTimerInfo('Double-tap Timer', _doubleTapTimeRemaining),
        _buildCounterInfo('Total Gestures', _totalGestureEvents),
      ],
    );
  }

  Widget _buildStateIndicator(String label, bool isActive, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? color : Colors.grey[300],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? color : Colors.grey[600],
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntityInfo(String label, String? entityId) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Text(
        '$label: ${entityId ?? 'None'}',
        style: TextStyle(
          fontSize: 10,
          color: entityId != null ? Colors.black87 : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildCounterInfo(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 10, color: Colors.black87),
      ),
    );
  }

  Widget _buildTimerInfo(String label, int? timeRemaining) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Text(
        '$label: ${timeRemaining != null ? '${timeRemaining}ms' : 'Inactive'}',
        style: TextStyle(
          fontSize: 10,
          color: timeRemaining != null ? Colors.orange : Colors.grey[600],
        ),
      ),
    );
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
  final bool animationEnabled;
  final Function(String, Map<String, dynamic>)? updateGestureState;

  const DebugGraphView({
    super.key,
    required this.graph,
    required this.onEvent,
    required this.onRebuild,
    required this.monitorCallbacks,
    required this.monitorRebuilds,
    required this.animationEnabled,
    this.updateGestureState,
  });

  @override
  State<DebugGraphView> createState() => _DebugGraphViewState();
}

class _DebugGraphViewState extends State<DebugGraphView> {
  @override
  Widget build(BuildContext context) {
    if (widget.monitorRebuilds) {
      // Increment counter but don't log event to avoid rebuild loop
      widget.onRebuild();
    }

    return GraphView(
      graph: widget.graph,
      layoutStrategy: GraphForceDirectedLayoutStrategy(),
      animationEnabled: widget.animationEnabled,
      behavior: _createDebugBehavior(),
    );
  }

  GraphViewBehavior _createDebugBehavior() {
    return DebugGraphViewBehavior(
      onEvent: widget.onEvent,
      monitorCallbacks: widget.monitorCallbacks,
      updateGestureState: widget.updateGestureState,
    );
  }
}

// Custom behavior for debugging
class DebugGraphViewBehavior extends GraphViewDefaultBehavior {
  final Function(DebugEvent) onEvent;
  final bool monitorCallbacks;
  final Function(String, Map<String, dynamic>)? updateGestureState;

  DebugGraphViewBehavior({
    required this.onEvent,
    required this.monitorCallbacks,
    this.updateGestureState,
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
      // Update gesture state tracking
      updateGestureState?.call('tap', {
        'tracking': hasEntities,
        'tapCount': event.tapCount,
        'entityId': hasEntities ? event.entityIds.first.toString() : null,
      });
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
      // Update gesture state tracking
      updateGestureState?.call('dragStart', {
        'entityId': hasEntities ? event.entityIds.first.toString() : null,
      });
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
      // Update gesture state tracking
      updateGestureState?.call('dragEnd', {});
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
      // Update gesture state tracking
      updateGestureState?.call('hoverEnter', {
        'entityId': event.entityId.toString(),
      });
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
      // Update gesture state tracking
      updateGestureState?.call('hoverEnd', {});
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