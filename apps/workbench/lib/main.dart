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

  // Tab state
  int _selectedTabIndex = 0;
  
  // UI scale
  double _uiScale = 1.0;

  // Timeline filters
  final Set<EventType> _timelineFilters = {
    EventType.gesture,
    EventType.rebuild,
    EventType.notification,
    EventType.layout,
  };

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
  StreamSubscription<GestureDebugEvent>? _debugEventSubscription;
  Timer? _timerCountdown;

  // Layout and data management
  String _currentLayoutStrategy = 'ForceDirected';
  String _currentDataPreset = 'Default';
  bool _animationEnabled = false;

  // Gesture mode and interaction settings
  GraphGestureMode _gestureMode = GraphGestureMode.exclusive;
  bool _useInteractiveViewer = false;
  String _lastBackgroundAction = '';
  Timer? _updateTimer;
  bool _gestureDebugMode = false;

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
    _updateTimer?.cancel();
    _debugEventSubscription?.cancel();
    _timerCountdown?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left sidebar
          Container(
            width: 250,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey[300]!)),
              color: Colors.grey[50],
            ),
            child: Column(
              children: [
                // Sidebar header
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey[200],
                  child: Row(
                    children: [
                      Icon(Icons.list, size: 16),
                      SizedBox(width: 8),
                      Text('Graph Entities',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16 * _uiScale)),
                    ],
                  ),
                ),
                // Nodes section
                Expanded(
                  child: Column(
                    children: [
                      _buildNodesSection(),
                      _buildLinksSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                    child: Column(
                      children: [
                        // First row - Basic controls
                        Row(
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
                                items: _layoutStrategies
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value,
                                        style: TextStyle(fontSize: 16 * _uiScale)),
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
                                items: _dataPresets
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value,
                                        style: TextStyle(fontSize: 16 * _uiScale)),
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
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _animationEnabled = !_animationEnabled;
                                });
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: _animationEnabled,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _animationEnabled = value ?? false;
                                      });
                                    },
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    splashRadius: 0,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  const Text('Animation',
                                      style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Second row - Gesture controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Gesture mode selector
                            const Text('Gesture Mode:',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<GraphGestureMode>(
                                value: _gestureMode,
                                onChanged: (GraphGestureMode? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _gestureMode = newValue;
                                    });
                                  }
                                },
                                items: const [
                                  DropdownMenuItem(
                                    value: GraphGestureMode.exclusive,
                                    child: Text('Exclusive',
                                        style: TextStyle(fontSize: 12)),
                                  ),
                                  DropdownMenuItem(
                                    value: GraphGestureMode.nodeEdgeOnly,
                                    child: Text('NodeEdgeOnly',
                                        style: TextStyle(fontSize: 12)),
                                  ),
                                  DropdownMenuItem(
                                    value: GraphGestureMode.transparent,
                                    child: Text('Transparent',
                                        style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                                isDense: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // InteractiveViewer toggle
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _useInteractiveViewer =
                                      !_useInteractiveViewer;
                                });
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: _useInteractiveViewer,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _useInteractiveViewer = value ?? false;
                                      });
                                    },
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    splashRadius: 0,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  const Text('InteractiveViewer',
                                      style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Gesture debug mode toggle
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _gestureDebugMode = !_gestureDebugMode;
                                });
                                // Enable/disable gesture debug mode in the library
                                setGestureDebugMode(_gestureDebugMode);
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: _gestureDebugMode,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _gestureDebugMode = value ?? false;
                                      });
                                      // Enable/disable gesture debug mode in the library
                                      setGestureDebugMode(_gestureDebugMode);
                                    },
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    splashRadius: 0,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  Text('Debug Mode',
                                      style: TextStyle(fontSize: 16 * _uiScale)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            // UI Scale controls
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Text Size:', style: TextStyle(fontSize: 16 * _uiScale, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _uiScale = (_uiScale - 0.1).clamp(0.5, 2.0);
                                    });
                                  },
                                  tooltip: 'Decrease text size',
                                  icon: const Icon(Icons.text_decrease),
                                  iconSize: 16,
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                ),
                                Text('${(_uiScale * 100).round()}%', style: TextStyle(fontSize: 16 * _uiScale)),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _uiScale = (_uiScale + 0.1).clamp(0.5, 2.0);
                                    });
                                  },
                                  tooltip: 'Increase text size',
                                  icon: const Icon(Icons.text_increase),
                                  iconSize: 16,
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _buildGraphViewContainer(),
                  ),
                  // Status bar
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.grey[300],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Nodes: ${graph.nodes.length}',
                            style: TextStyle(fontSize: 16 * _uiScale)),
                        const SizedBox(width: 16),
                        Text('Links: ${graph.links.length}',
                            style: TextStyle(fontSize: 16 * _uiScale)),
                        const SizedBox(width: 16),
                        Text('Rebuilds: $_rebuildCount',
                            style: TextStyle(fontSize: 16 * _uiScale)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Debug panel with tabs
          Expanded(
            flex: 1,
            child: _buildTabbedDebugPanel(),
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

  @override
  void initState() {
    super.initState();
    _initializeGraph();

    // Listen to debug events for timer tracking
    _listenToDebugEvents();

    // Subscribe to gesture debug events
    _subscribeToGestureDebugEvents();
  }

  void _listenToDebugEvents() {
    // This would ideally listen to a stream of debug events
    // For now, we'll simulate timer updates based on events
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted && _gestureDebugMode) {
        // Look for recent timer events to update the display
        final recentTimerEvents = _events
            .where((event) =>
                event.timestamp.isAfter(
                    DateTime.now().subtract(const Duration(seconds: 1))) &&
                event.message.contains('timer'))
            .toList();

        if (recentTimerEvents.isNotEmpty) {
          setState(() {
            // Update timer display based on recent events
            final timerStartEvents = recentTimerEvents
                .where((e) => e.message.contains('timer started'))
                .toList();
            if (timerStartEvents.isNotEmpty) {
              _doubleTapTimeRemaining = 100; // Default timeout
            }

            final timerEndEvents = recentTimerEvents
                .where((e) =>
                    e.message.contains('timer expired') ||
                    e.message.contains('timer cancelled'))
                .toList();
            if (timerEndEvents.isNotEmpty) {
              _doubleTapTimeRemaining = null;
            }
          });
        }
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
              fontSize: 16 * _uiScale,
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
          fontSize: 16 * _uiScale,
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
        style: TextStyle(fontSize: 16 * _uiScale, color: Colors.black87),
      ),
    );
  }

  Widget _buildTimerInfo(String label, int? timeRemaining) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Text(
        '$label: ${timeRemaining != null ? '${timeRemaining}ms' : 'Inactive'}',
        style: TextStyle(
          fontSize: 16 * _uiScale,
          color: timeRemaining != null ? Colors.orange : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildNodesSection() {
    return Container(
      color: Colors.blue[50],
      child: ExpansionTile(
        title: Text('Nodes (${graph.nodes.length})',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * _uiScale)),
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 8),
        childrenPadding: EdgeInsets.zero,
        backgroundColor: Colors.blue[50],
        collapsedBackgroundColor: Colors.blue[50],
        iconColor: Colors.blue[700],
        collapsedIconColor: Colors.blue[700],
        shape: const Border(),
        collapsedShape: const Border(),
        controlAffinity: ListTileControlAffinity.leading,
        children: [
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: graph.nodes.length,
              itemBuilder: (context, index) {
                final node = graph.nodes.elementAt(index);
                final label =
                    node.properties['label']?.toString() ?? 'Node ${index + 1}';
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.blue[200]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                  fontSize: 16 * _uiScale, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'ID: ${node.id.toString().substring(0, 8)}...',
                              style: TextStyle(
                                  fontSize: 16 * _uiScale, color: Colors.grey[600]),
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
    );
  }

  Widget _buildLinksSection() {
    return Container(
      color: Colors.orange[50],
      child: ExpansionTile(
        title: Text('Links (${graph.links.length})',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * _uiScale)),
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 8),
        childrenPadding: EdgeInsets.zero,
        backgroundColor: Colors.orange[50],
        collapsedBackgroundColor: Colors.orange[50],
        iconColor: Colors.orange[700],
        collapsedIconColor: Colors.orange[700],
        shape: const Border(),
        collapsedShape: const Border(),
        controlAffinity: ListTileControlAffinity.leading,
        children: [
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: graph.links.length,
              itemBuilder: (context, index) {
                final link = graph.links.elementAt(index);
                final sourceLabel =
                    link.source.properties['label']?.toString() ?? 'Node';
                final targetLabel =
                    link.target.properties['label']?.toString() ?? 'Node';
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.orange[200]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$sourceLabel → $targetLabel',
                              style: TextStyle(
                                  fontSize: 16 * _uiScale, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'ID: ${link.id.toString().substring(0, 8)}...',
                              style: TextStyle(
                                  fontSize: 16 * _uiScale, color: Colors.grey[600]),
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
    );
  }

  Widget _buildGraphViewContainer() {
    final graphView = DebugGraphView(
      graph: graph,
      onEvent: _logEvent,
      onRebuild: () {
        _rebuildCount++;
      },
      monitorCallbacks: _monitorCallbacks,
      monitorRebuilds: _monitorRebuilds,
      animationEnabled: _animationEnabled,
      updateGestureState: _updateGestureState,
      gestureMode: _gestureMode,
      onBackgroundTapped: _gestureMode != GraphGestureMode.exclusive
          ? (localPosition) {
              setState(() {
                _lastBackgroundAction = 'Background tapped at $localPosition';
              });
              _scheduleUpdate();
            }
          : null,
      onBackgroundPanStart: _gestureMode != GraphGestureMode.exclusive
          ? (localPosition) {
              setState(() {
                _lastBackgroundAction =
                    'Background pan started at $localPosition';
              });
              _scheduleUpdate();
            }
          : null,
      onBackgroundPanUpdate: _gestureMode != GraphGestureMode.exclusive
          ? (localPosition, delta) {
              setState(() {
                _lastBackgroundAction = 'Background panning: delta=$delta';
              });
              _scheduleUpdate();
            }
          : null,
      onBackgroundPanEnd: _gestureMode != GraphGestureMode.exclusive
          ? (localPosition) {
              setState(() {
                _lastBackgroundAction = 'Background pan ended';
              });
              _scheduleUpdate();
            }
          : null,
    );

    if (_useInteractiveViewer && _gestureMode != GraphGestureMode.exclusive) {
      return Stack(
        children: [
          InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(100),
            minScale: 0.5,
            maxScale: 3.0,
            child: Container(
              width: 3000,
              height: 3000,
              color: Colors.grey[100],
              child: Center(
                child: Container(
                  width: 800,
                  height: 600,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    color: Colors.white,
                  ),
                  child: graphView,
                ),
              ),
            ),
          ),
          if (_lastBackgroundAction.isNotEmpty)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.yellow[100],
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _lastBackgroundAction,
                  style: TextStyle(fontSize: 16 * _uiScale),
                ),
              ),
            ),
        ],
      );
    }

    return graphView;
  }

  void _scheduleUpdate() {
    _updateTimer?.cancel();
    _updateTimer = Timer(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Widget _buildTabbedDebugPanel() {
    return DefaultTabController(
      length: 3,
      initialIndex: _selectedTabIndex,
      child: Column(
        children: [
          Container(
            color: Colors.grey[200],
            child: TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.blue,
              labelStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontSize: 12),
              onTap: (index) => setState(() => _selectedTabIndex = index),
              tabs: const [
                Tab(text: 'Gesture State'),
                Tab(text: 'State Timeline'),
                Tab(text: 'Event Log'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildGestureStateTab(),
                _buildStateTimelineTab(),
                _buildEventLogTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGestureStateTab() {
    return Container(
      color: Colors.purple[50],
      child: ExpansionTile(
        title: Text('Current Gesture State',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * _uiScale)),
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
    );
  }

  Widget _buildStateTimelineTab() {
    return Container(
      color: Colors.orange[50],
      child: Column(
        children: [
          // Filter controls
          Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gesture State Transitions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * _uiScale),
                ),
                const SizedBox(height: 8),
                _buildTimelineFilters(),
              ],
            ),
          ),
          Expanded(
            child: _buildStateTransitionTimeline(),
          ),
        ],
      ),
    );
  }

  Widget _buildEventLogTab() {
    return Container(
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
                const Text('Event Log',
                    style: TextStyle(fontWeight: FontWeight.bold)),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                              style: TextStyle(fontSize: 16 * _uiScale),
                            ),
                            Text(
                              '${event.source} - ${_formatTime(event.timestamp)}',
                              style: TextStyle(
                                  fontSize: 16 * _uiScale, color: Colors.grey[600]),
                            ),
                            if (event.details != null)
                              Text(
                                event.details!,
                                style: TextStyle(
                                    fontSize: 16 * _uiScale, color: Colors.grey[700]),
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
    );
  }

  Widget _buildTimelineFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter control buttons
        Row(
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  _timelineFilters.addAll(EventType.values);
                });
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('All', style: TextStyle(fontSize: 16 * _uiScale)),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _timelineFilters.clear();
                });
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('Clear', style: TextStyle(fontSize: 16 * _uiScale)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Filter chips
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: EventType.values.map((eventType) {
            final isSelected = _timelineFilters.contains(eventType);
            return FilterChip(
              label: Text(
                _getEventTypeLabel(eventType),
                style: TextStyle(
                  fontSize: 16 * _uiScale,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
              selected: isSelected,
              selectedColor: _getEventColor(eventType),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _timelineFilters.add(eventType);
                  } else {
                    _timelineFilters.remove(eventType);
                  }
                });
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getEventTypeLabel(EventType type) {
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

  Widget _buildStateTransitionTimeline() {
    // Filter events based on selected filters
    final filteredEvents = _events
        .where((event) {
          return _timelineFilters.contains(event.type);
        })
        .take(200)
        .toList();

    // Group consecutive events of the same type and message
    final groupedEvents = <GroupedEvent>[];
    for (final event in filteredEvents) {
      if (groupedEvents.isNotEmpty &&
          groupedEvents.last.type == event.type &&
          groupedEvents.last.message == event.message) {
        // Same event type and message - increment count
        groupedEvents.last.count++;
        groupedEvents.last.lastTimestamp = event.timestamp;
      } else {
        // New event or different type/message - create new group
        groupedEvents.add(GroupedEvent(
          type: event.type,
          source: event.source,
          message: event.message,
          details: event.details,
          timestamp: event.timestamp,
          lastTimestamp: event.timestamp,
          count: 1,
        ));
      }
    }

    final stateEvents = groupedEvents.take(50).toList();

    if (stateEvents.isEmpty) {
      return const Center(
        child: Text(
          'No gesture state transitions yet.\nPerform some gestures to see the timeline.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: stateEvents.length,
      itemBuilder: (context, index) {
        final event = stateEvents[index];
        final isLastItem = index == stateEvents.length - 1;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline visual
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getEventColor(event.type),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                  if (!isLastItem)
                    Container(
                      width: 2,
                      height: 30,
                      color: Colors.grey[300],
                    ),
                ],
              ),
              const SizedBox(width: 8),
              // Event details
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.message,
                              style: TextStyle(
                                  fontSize: 16 * _uiScale, fontWeight: FontWeight.w500),
                            ),
                          ),
                          if (event.count > 1)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getEventColor(event.type)
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: _getEventColor(event.type),
                                    width: 1),
                              ),
                              child: Text(
                                '×${event.count}',
                                style: TextStyle(
                                  fontSize: 16 * _uiScale,
                                  color: _getEventColor(event.type),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${event.source} • ${_formatTime(event.timestamp)}${event.count > 1 ? ' - ${_formatTime(event.lastTimestamp)}' : ''}',
                        style: TextStyle(fontSize: 16 * _uiScale, color: Colors.grey[600]),
                      ),
                      if (event.details != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            event.details!,
                            style:
                                TextStyle(fontSize: 16 * _uiScale, color: Colors.grey[700]),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _subscribeToGestureDebugEvents() {
    _debugEventSubscription = gestureDebugEventStream.listen((event) {
      if (!mounted) return;

      // Map GestureDebugEvent to DebugEvent for display
      EventType eventType;
      switch (event.type) {
        case GestureDebugEventType.timerStart:
        case GestureDebugEventType.timerCancel:
        case GestureDebugEventType.timerExpire:
          eventType = EventType.gesture;
          // Update timer display
          if (event.type == GestureDebugEventType.timerStart) {
            final timeoutMs = event.data['timeout_ms'] as int?;
            if (timeoutMs != null) {
              setState(() {
                _doubleTapTimeRemaining = timeoutMs;
              });
              _startTimerCountdown(timeoutMs);
            }
          } else {
            setState(() {
              _doubleTapTimeRemaining = null;
            });
            _timerCountdown?.cancel();
          }
          break;
        case GestureDebugEventType.stateTransition:
        case GestureDebugEventType.gestureDecision:
          eventType = EventType.gesture;
          break;
        case GestureDebugEventType.conditionCheck:
        case GestureDebugEventType.hitTest:
          eventType = EventType.gesture;
          break;
        case GestureDebugEventType.backgroundCallback:
          eventType = EventType.callback;
          break;
      }

      // Create display event
      final debugEvent = DebugEvent(
        type: eventType,
        source: event.component,
        message: event.message,
        timestamp: event.timestamp,
        details: event.data.isEmpty ? null : event.data.toString(),
      );

      _logEvent(debugEvent);
    });
  }

  void _startTimerCountdown(int durationMs) {
    _timerCountdown?.cancel();
    final endTime = DateTime.now().add(Duration(milliseconds: durationMs));

    _timerCountdown = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final remaining = endTime.difference(DateTime.now()).inMilliseconds;
      if (remaining <= 0) {
        setState(() {
          _doubleTapTimeRemaining = null;
        });
        timer.cancel();
      } else {
        setState(() {
          _doubleTapTimeRemaining = remaining;
        });
      }
    });
  }
}

// Grouped event for timeline display
class GroupedEvent {
  final EventType type;
  final String source;
  final String message;
  final String? details;
  final DateTime timestamp;
  DateTime lastTimestamp;
  int count;

  GroupedEvent({
    required this.type,
    required this.source,
    required this.message,
    this.details,
    required this.timestamp,
    required this.lastTimestamp,
    required this.count,
  });
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
  final GraphGestureMode gestureMode;
  final GraphBackgroundGestureCallback? onBackgroundTapped;
  final GraphBackgroundGestureCallback? onBackgroundPanStart;
  final GraphBackgroundPanCallback? onBackgroundPanUpdate;
  final GraphBackgroundGestureCallback? onBackgroundPanEnd;

  const DebugGraphView({
    super.key,
    required this.graph,
    required this.onEvent,
    required this.onRebuild,
    required this.monitorCallbacks,
    required this.monitorRebuilds,
    required this.animationEnabled,
    this.updateGestureState,
    this.gestureMode = GraphGestureMode.exclusive,
    this.onBackgroundTapped,
    this.onBackgroundPanStart,
    this.onBackgroundPanUpdate,
    this.onBackgroundPanEnd,
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
      gestureMode: widget.gestureMode,
      allowSelection: true, // Enable selection for tap/double-tap
      onBackgroundTapped: widget.onBackgroundTapped,
      onBackgroundPanStart: widget.onBackgroundPanStart,
      onBackgroundPanUpdate: widget.onBackgroundPanUpdate,
      onBackgroundPanEnd: widget.onBackgroundPanEnd,
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
    print('onTap');
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
        details:
            'Selected: $selectedCount, Deselected: $deselectedCount, Current: $currentCount',
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
        details:
            'Entity ID: ${event.entityId}, Position: ${event.details.localPosition}',
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
        details:
            'Entity ID: ${event.entityId}, Position: ${event.details.localPosition}',
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
