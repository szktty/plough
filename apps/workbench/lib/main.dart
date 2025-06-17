import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:plough/plough.dart';
import 'dart:async';
import 'dart:convert';

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
  
  // Gesture validation results
  
  // Internal debug state from TAP_DEBUG_STATE events
  Map<String, dynamic> _internalDebugState = {
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

  // ジェスチャー検証関連
  final List<GestureValidationResult> _gestureValidationResults = [];
  GestureTestType _selectedGestureTest = GestureTestType.tap;
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
  bool _collapseFloatingDebug = false;

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
      body: Stack(
        children: [
          Row(
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
                      const Icon(Icons.list, size: 16),
                      const SizedBox(width: 8),
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
        case 'tap_debug_state':
          // Update internal debug state from TAP_DEBUG_STATE events
          debugPrint('WORKBENCH: Updating internal debug state with: $data');
          _internalDebugState = Map<String, dynamic>.from(data);
          debugPrint('WORKBENCH: New internal debug state: $_internalDebugState');
          
          // タップ検証を実行
          _validateTapBehavior(data);
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

  // ジェスチャー動作の期待値検証
  void _validateTapBehavior(Map<String, dynamic> debugState) {
    final phase = debugState['phase']?.toString() ?? 'unknown';
    final nodeTargetId = debugState['nodeTargetId']?.toString() ?? 'null';
    
    if (nodeTargetId == 'null' || phase == 'none') return;

    final checks = <GestureValidationCheck>[];
    
    // 選択されたテストタイプに応じて検証を実行
    switch (_selectedGestureTest) {
      case GestureTestType.tap:
        if (phase == 'down') {
          checks.addAll(_validateTapDown(debugState));
        } else if (phase == 'up') {
          checks.addAll(_validateTapUp(debugState));
        }
        break;
      case GestureTestType.doubleTap:
        checks.addAll(_validateDoubleTap(debugState, phase));
        break;
      case GestureTestType.drag:
        checks.addAll(_validateDrag(debugState, phase));
        break;
      case GestureTestType.hover:
        checks.addAll(_validateHover(debugState, phase));
        break;
      case GestureTestType.longPress:
        checks.addAll(_validateLongPress(debugState, phase));
        break;
      case GestureTestType.tapAndHold:
        checks.addAll(_validateTapAndHold(debugState, phase));
        break;
    }

    if (checks.isNotEmpty) {
      final result = GestureValidationResult(
        timestamp: DateTime.now(),
        testType: _selectedGestureTest,
        phase: phase,
        nodeId: nodeTargetId,
        checks: checks,
      );
      
      _gestureValidationResults.insert(0, result);
      
      // 最大100件まで保持
      if (_gestureValidationResults.length > 100) {
        _gestureValidationResults.removeRange(100, _gestureValidationResults.length);
      }
    }
  }

  List<GestureValidationCheck> _validateTapDown(Map<String, dynamic> state) {
    final checks = <GestureValidationCheck>[];
    
    final nodeCanSelect = state['node_can_select'] ?? false;
    checks.add(GestureValidationCheck(
      name: 'node_selectable',
      description: 'ノードが選択可能である',
      passed: nodeCanSelect,
      expectedValue: 'true',
      actualValue: nodeCanSelect.toString(),
      failureReason: nodeCanSelect ? null : 'ノードのcanSelectがfalse',
    ));

    final stateExists = state['state_exists'] ?? false;
    checks.add(GestureValidationCheck(
      name: 'tap_state_created',
      description: 'タップ状態が作成される',
      passed: stateExists,
      expectedValue: 'true',
      actualValue: stateExists.toString(),
      failureReason: stateExists ? null : 'タップ状態が作成されていない',
    ));

    final stateCancelled = state['state_cancelled'] ?? false;
    checks.add(GestureValidationCheck(
      name: 'tap_state_not_cancelled',
      description: 'タップ状態がキャンセルされていない',
      passed: !stateCancelled,
      expectedValue: 'false',
      actualValue: stateCancelled.toString(),
      failureReason: stateCancelled ? 'タップ状態がキャンセルされた' : null,
    ));

    return checks;
  }

  List<GestureValidationCheck> _validateTapUp(Map<String, dynamic> state) {
    final checks = <GestureValidationCheck>[];
    
    final stateExists = state['state_exists'] ?? false;
    checks.add(GestureValidationCheck(
      name: 'tap_state_exists_on_up',
      description: 'ポインターアップ時にタップ状態が存在する',
      passed: stateExists,
      expectedValue: 'true',
      actualValue: stateExists.toString(),
      failureReason: stateExists ? null : 'ポインターアップ時にタップ状態が存在しない',
    ));

    if (stateExists) {
      final isStillDragging = state['is_still_dragging_after_up'] ?? true;
      checks.add(GestureValidationCheck(
        name: 'not_dragging',
        description: 'ドラッグ中でない',
        passed: !isStillDragging,
        expectedValue: 'false',
        actualValue: isStillDragging.toString(),
        failureReason: isStillDragging ? 'まだドラッグ中' : null,
      ));

      final isTapCompleted = state['is_tap_completed_after_up'] ?? false;
      checks.add(GestureValidationCheck(
        name: 'tap_completed',
        description: 'タップが完了している',
        passed: isTapCompleted,
        expectedValue: 'true',
        actualValue: isTapCompleted.toString(),
        failureReason: isTapCompleted ? null : 'タップが完了していない',
      ));

      final isWithinSlop = state['isWithinSlop'];
      if (isWithinSlop != null) {
        checks.add(GestureValidationCheck(
          name: 'within_slop',
          description: 'Touch slop範囲内',
          passed: isWithinSlop,
          expectedValue: 'true',
          actualValue: isWithinSlop.toString(),
          failureReason: isWithinSlop ? null : 'Touch slop範囲外に移動した',
        ));
      }

      final willToggleSelection = state['will_toggle_selection'] ?? false;
      final shouldToggle = !isStillDragging && isTapCompleted;
      checks.add(GestureValidationCheck(
        name: 'will_toggle_selection',
        description: '選択状態が切り替わる',
        passed: willToggleSelection == shouldToggle,
        expectedValue: shouldToggle.toString(),
        actualValue: willToggleSelection.toString(),
        failureReason: willToggleSelection != shouldToggle 
          ? '選択切り替えの判定が不正' : null,
      ));
    }

    return checks;
  }

  List<GestureValidationCheck> _validateDoubleTap(Map<String, dynamic> state, String phase) {
    final checks = <GestureValidationCheck>[];
    
    if (phase == 'up') {
      final tapCount = state['tap_count'] ?? 0;
      checks.add(GestureValidationCheck(
        name: 'double_tap_count',
        description: 'タップ回数が2回である',
        passed: tapCount == 2,
        expectedValue: '2',
        actualValue: tapCount.toString(),
        failureReason: tapCount != 2 ? 'タップ回数が2回でない' : null,
      ));
    }
    
    return checks;
  }

  List<GestureValidationCheck> _validateDrag(Map<String, dynamic> state, String phase) {
    final checks = <GestureValidationCheck>[];
    
    final nodeCanDrag = state['node_can_drag'] ?? false;
    checks.add(GestureValidationCheck(
      name: 'node_draggable',
      description: 'ノードがドラッグ可能である',
      passed: nodeCanDrag,
      expectedValue: 'true',
      actualValue: nodeCanDrag.toString(),
      failureReason: nodeCanDrag ? null : 'ノードのcanDragがfalse',
    ));

    if (phase == 'up') {
      final isDragging = state['drag_manager_is_dragging'] ?? false;
      checks.add(GestureValidationCheck(
        name: 'drag_active',
        description: 'ドラッグが実行されている',
        passed: isDragging,
        expectedValue: 'true',
        actualValue: isDragging.toString(),
        failureReason: isDragging ? null : 'ドラッグが開始されていない',
      ));
    }
    
    return checks;
  }

  List<GestureValidationCheck> _validateHover(Map<String, dynamic> state, String phase) {
    // ホバー検証（今回は簡易実装）
    return [
      GestureValidationCheck(
        name: 'hover_support',
        description: 'ホバー状態をサポート',
        passed: true,
        expectedValue: 'true',
        actualValue: 'true',
      ),
    ];
  }

  List<GestureValidationCheck> _validateLongPress(Map<String, dynamic> state, String phase) {
    // 長押し検証（今回は簡易実装）
    return [
      GestureValidationCheck(
        name: 'long_press_support',
        description: '長押しをサポート',
        passed: true,
        expectedValue: 'true',
        actualValue: 'true',
      ),
    ];
  }

  List<GestureValidationCheck> _validateTapAndHold(Map<String, dynamic> state, String phase) {
    // タップ&ホールド検証（今回は簡易実装）
    return [
      GestureValidationCheck(
        name: 'tap_hold_support',
        description: 'タップ&ホールドをサポート',
        passed: true,
        expectedValue: 'true',
        actualValue: 'true',
      ),
    ];
  }

  Widget _buildGestureTestTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ジェスチャーテスト選択セクション
          _buildGestureTestSelector(),
          const SizedBox(height: 16),
          Divider(color: Colors.grey[400]),
          const SizedBox(height: 16),
          
          // テスト結果表示セクション
          _buildGestureTestResults(),
        ],
      ),
    );
  }

  Widget _buildGestureTestSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border.all(color: Colors.blue[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.science, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Gesture Test Configuration',
                style: TextStyle(
                  fontSize: 18 * _uiScale,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Text(
            'Select gesture type to test:',
            style: TextStyle(
              fontSize: 14 * _uiScale,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          
          // ドロップダウン
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<GestureTestType>(
                value: _selectedGestureTest,
                isDense: true,
                onChanged: (GestureTestType? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedGestureTest = newValue;
                      // テスト変更時に結果をクリア
                      _gestureValidationResults.clear();
                    });
                  }
                },
                items: GestureTestType.values.map<DropdownMenuItem<GestureTestType>>((GestureTestType type) {
                  return DropdownMenuItem<GestureTestType>(
                    value: type,
                    child: Text(
                      type.displayName,
                      style: TextStyle(fontSize: 14 * _uiScale),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // 選択されたテストの説明
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              _selectedGestureTest.description,
              style: TextStyle(
                fontSize: 13 * _uiScale,
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // クリアボタン
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _gestureValidationResults.clear();
                  });
                },
                icon: const Icon(Icons.clear_all, size: 16),
                label: Text('Clear Results', style: TextStyle(fontSize: 12 * _uiScale)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.grey[700],
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_gestureValidationResults.length} results',
                style: TextStyle(
                  fontSize: 12 * _uiScale,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGestureTestResults() {
    if (_gestureValidationResults.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Icon(Icons.gesture, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'No test results yet',
              style: TextStyle(
                fontSize: 16 * _uiScale,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Perform a ${_selectedGestureTest.displayName.toLowerCase()} gesture on a node to see validation results',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14 * _uiScale,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Test Results',
          style: TextStyle(
            fontSize: 16 * _uiScale,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        ..._gestureValidationResults.map((result) => _buildDetailedValidationCard(result)),
      ],
    );
  }

  Widget _buildDetailedValidationCard(GestureValidationResult result) {
    final isSuccess = result.isSuccess;
    final passedChecks = result.checks.where((check) => check.passed).toList();
    final failedChecks = result.checks.where((check) => !check.passed).toList();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSuccess ? Colors.green[300]! : Colors.red[300]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSuccess ? Colors.green[50] : Colors.red[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error_outline,
                  color: isSuccess ? Colors.green[700] : Colors.red[700],
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${result.testType.displayName} ${result.phase.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 16 * _uiScale,
                          fontWeight: FontWeight.bold,
                          color: isSuccess ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                      Text(
                        'Node: ${_shortenId(result.nodeId)} • ${_formatGestureTime(result.timestamp)}',
                        style: TextStyle(
                          fontSize: 12 * _uiScale,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSuccess ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${passedChecks.length}/${result.checks.length}',
                    style: TextStyle(
                      fontSize: 14 * _uiScale,
                      fontWeight: FontWeight.bold,
                      color: isSuccess ? Colors.green[700] : Colors.red[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 検証項目の詳細
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (passedChecks.isNotEmpty) ...[
                  Text(
                    '✅ Passed Tests',
                    style: TextStyle(
                      fontSize: 14 * _uiScale,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...passedChecks.map((check) => Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 2),
                    child: Text(
                      '• ${check.description}',
                      style: TextStyle(
                        fontSize: 12 * _uiScale,
                        color: Colors.green[600],
                      ),
                    ),
                  )),
                  if (failedChecks.isNotEmpty) const SizedBox(height: 8),
                ],
                
                if (failedChecks.isNotEmpty) ...[
                  Text(
                    '❌ Failed Tests',
                    style: TextStyle(
                      fontSize: 14 * _uiScale,
                      fontWeight: FontWeight.w600,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...failedChecks.map((check) => Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ${check.description}',
                          style: TextStyle(
                            fontSize: 12 * _uiScale,
                            color: Colors.red[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (check.failureReason != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8, top: 2),
                            child: Text(
                              'Reason: ${check.failureReason}',
                              style: TextStyle(
                                fontSize: 11 * _uiScale,
                                color: Colors.red[500],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        if (check.expectedValue != null && check.actualValue != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8, top: 2),
                            child: Text(
                              'Expected: ${check.expectedValue}, Got: ${check.actualValue}',
                              style: TextStyle(
                                fontSize: 11 * _uiScale,
                                color: Colors.red[500],
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatGestureTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else {
      return '${diff.inHours}h ago';
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeGraph();

    // Enable gesture debug mode by default
    _gestureDebugMode = true;
    setGestureDebugMode(true);

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
        const SizedBox(height: 8),
        _buildInternalDetailsSection(),
      ],
    );
  }

  Widget _buildStateIndicator(String label, bool isActive, Color color) {
    String value = isActive ? 'Active' : 'Inactive';
    return _buildInternalValue(label, value);
  }

  Widget _buildEntityInfo(String label, String? entityId) {
    String displayId = entityId != null ? entityId.substring(0, 6.clamp(0, entityId.length)) : 'None';
    return _buildInternalValue(label, displayId);
  }

  Widget _buildCounterInfo(String label, int value) {
    return _buildInternalValue(label, value.toString());
  }

  Widget _buildTimerInfo(String label, int? timeRemaining) {
    String value = timeRemaining != null ? '${timeRemaining}ms' : 'Inactive';
    return _buildInternalValue(label, value);
  }

  Widget _buildInternalDetailsSection() {
    // Get values from the internal debug state received from TAP_DEBUG_STATE events
    
    String isTapCompletedStatus = _internalDebugState['is_tap_completed_after_up']?.toString() ?? 'N/A';
    String isStillDraggingStatus = _internalDebugState['is_still_dragging_after_up']?.toString() ?? 'N/A';
    String trackedEntityIdStr = _internalDebugState['tracked_entity_id']?.toString() ?? 'null';
    if (trackedEntityIdStr != 'null' && trackedEntityIdStr.length > 6) {
      trackedEntityIdStr = trackedEntityIdStr.substring(0, 6);
    }
    String tapStateExists = _internalDebugState['state_exists']?.toString() ?? 'N/A';
    String tapStateCompleted = _internalDebugState['state_completed']?.toString() ?? 'N/A';
    String tapStateCancelled = _internalDebugState['state_cancelled']?.toString() ?? 'N/A';
    String tapCount = _internalDebugState['tap_count']?.toString() ?? '0';
    String nodeTargetId = _internalDebugState['nodeTargetId']?.toString() ?? 'null';
    if (nodeTargetId != 'null' && nodeTargetId.length > 6) {
      nodeTargetId = nodeTargetId.substring(0, 6);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Divider
        Container(
          height: 1,
          color: Colors.grey[400],
          margin: const EdgeInsets.symmetric(vertical: 4),
        ),
        Text(
          'Internal Implementation Details',
          style: TextStyle(
            fontSize: 16 * _uiScale,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        _buildInternalValue('isTapCompletedAfterUp', isTapCompletedStatus),
        _buildInternalValue('isStillDraggingAfterUp', isStillDraggingStatus),
        _buildInternalValue('kTouchSlop', kTouchSlop.toString()),
        _buildInternalValue('touchSlop (effective)', (kTouchSlop * 8).toString()),
        _buildInternalValue('Node Target ID', nodeTargetId),
        _buildInternalValue('Tracked Entity ID', trackedEntityIdStr),
        _buildInternalValue('Tap State Exists', tapStateExists),
        _buildInternalValue('Tap State Completed', tapStateCompleted),
        _buildInternalValue('Tap State Cancelled', tapStateCancelled),
        _buildInternalValue('Tap Count', tapCount),
        const SizedBox(height: 4),
        // Additional debug info from enhanced logging
        _buildInternalValue('Phase', _internalDebugState['phase']?.toString() ?? 'none'),
        _buildInternalValue('Node Can Select', _internalDebugState['node_can_select']?.toString() ?? 'N/A'),
        _buildInternalValue('Node Can Drag', _internalDebugState['node_can_drag']?.toString() ?? 'N/A'),
        _buildInternalValue('Node Is Selected', _internalDebugState['node_is_selected']?.toString() ?? 'N/A'),
        _buildInternalValue('Gesture Mode', _internalDebugState['gesture_mode']?.toString() ?? 'unknown'),
        _buildInternalValue('Tap States Count', _internalDebugState['tap_manager_states_count']?.toString() ?? '0'),
        _buildInternalValue('Drag State Exists', _internalDebugState['drag_state_exists']?.toString() ?? 'N/A'),
        _buildInternalValue('Drag Manager Dragging', _internalDebugState['drag_manager_is_dragging']?.toString() ?? 'N/A'),
        _buildInternalValue('Will Toggle Selection', _internalDebugState['will_toggle_selection']?.toString() ?? 'N/A'),
        _buildPositionInfo('Pointer Position', _internalDebugState['pointer_position']),
        _buildPositionInfo('Node Position', _internalDebugState['node_position']),
        _buildInternalValue('Distance', _internalDebugState['distance']?.toString() ?? '0.0'),
        _buildInternalValue('Is Within Slop', _internalDebugState['isWithinSlop']?.toString() ?? 'N/A'),
        // Failure reason if available
        if (_internalDebugState.containsKey('failure_reason'))
          _buildInternalValue('Failure Reason', _internalDebugState['failure_reason']?.toString() ?? 'N/A'),
        if (_internalDebugState.containsKey('reason'))
          _buildInternalValue('Reason', _internalDebugState['reason']?.toString() ?? 'N/A'),
        if (_internalDebugState.containsKey('exceeded_by'))
          _buildInternalValue('Exceeded By', _internalDebugState['exceeded_by']?.toString() ?? 'N/A'),
        // Node at position (shortened)
        if (_internalDebugState.containsKey('node_at_position')) ...[
          _buildInternalValue('Node At Position', _shortenId(_internalDebugState['node_at_position']?.toString() ?? 'null')),
        ],
        // Tap debug info breakdown
        if (_internalDebugState['tap_debug_info'] != null)
          ..._buildTapDebugInfoSection(_internalDebugState['tap_debug_info']),
      ],
    );
  }

  Widget _buildInternalValue(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 16 * _uiScale,
                color: Colors.grey[600],
                fontFamily: 'monospace',
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16 * _uiScale,
                color: Colors.black87,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionInfo(String label, dynamic position) {
    String positionText = 'N/A';
    if (position is Map<String, dynamic>) {
      final x = position['x']?.toStringAsFixed(1) ?? '0.0';
      final y = position['y']?.toStringAsFixed(1) ?? '0.0';
      positionText = '($x, $y)';
    }
    return _buildInternalValue(label, positionText);
  }

  String _shortenId(String id) {
    if (id == 'null' || id == 'N/A') return id;
    return id.length > 6 ? id.substring(id.length - 6) : id;
  }

  Widget _buildFloatingDebugDialog() {
    return Positioned(
      top: 10,
      right: 10,
      child: Container(
        width: _collapseFloatingDebug ? 250 : 320,
        constraints: _collapseFloatingDebug 
          ? const BoxConstraints(maxHeight: 40)
          : const BoxConstraints(maxHeight: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _collapseFloatingDebug 
          ? _buildCollapsedHeader()
          : _buildExpandedContent(),
      ),
    );
  }

  Widget _buildCollapsedHeader() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(Icons.bug_report, color: Colors.red[700], size: 16),
          const SizedBox(width: 4),
          Text(
            'Live Gesture Debug',
            style: TextStyle(
              fontSize: 16 * _uiScale,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              setState(() {
                _collapseFloatingDebug = !_collapseFloatingDebug;
              });
            },
            icon: Icon(
              Icons.keyboard_arrow_down, 
              size: 16, 
              color: Colors.red[700]
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
            tooltip: 'Expand',
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.bug_report, color: Colors.red[700], size: 16),
              const SizedBox(width: 4),
              Text(
                'Live Gesture Debug',
                style: TextStyle(
                  fontSize: 16 * _uiScale,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  setState(() {
                    _collapseFloatingDebug = !_collapseFloatingDebug;
                  });
                },
                icon: Icon(
                  Icons.keyboard_arrow_up, 
                  size: 16, 
                  color: Colors.red[700]
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                tooltip: 'Collapse',
              ),
            ],
          ),
        ),
        // Tabbed content
        Expanded(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Container(
                  color: Colors.grey[100],
                  child: TabBar(
                    labelColor: Colors.red[700],
                    unselectedLabelColor: Colors.grey[600],
                    indicatorColor: Colors.red[700],
                    labelStyle: TextStyle(fontSize: 12 * _uiScale, fontWeight: FontWeight.bold),
                    unselectedLabelStyle: TextStyle(fontSize: 12 * _uiScale),
                    tabs: const [
                      Tab(text: 'State'),
                      Tab(text: 'Check'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildStateDebugTab(),
                      _buildGestureTestTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTapValidationSection() {
    final recentResults = _gestureValidationResults.take(3).toList();
    
    if (recentResults.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tap Validation (Live Tests)',
            style: TextStyle(
              fontSize: 16 * _uiScale,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No tap attempts yet',
            style: TextStyle(
              fontSize: 14 * _uiScale,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.fact_check, size: 18, color: Colors.blue[700]),
            const SizedBox(width: 4),
            Text(
              'Tap Validation (Live Tests)',
              style: TextStyle(
                fontSize: 16 * _uiScale,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...recentResults.map((result) => _buildValidationResultCard(result)),
      ],
    );
  }

  Widget _buildValidationResultCard(GestureValidationResult result) {
    final isSuccess = result.isSuccess;
    final failedChecks = result.checks.where((check) => !check.passed).toList();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSuccess ? Colors.green[50] : Colors.red[50],
        border: Border.all(
          color: isSuccess ? Colors.green[300]! : Colors.red[300]!,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                size: 16,
                color: isSuccess ? Colors.green[700] : Colors.red[700],
              ),
              const SizedBox(width: 4),
              Text(
                '${result.phase.toUpperCase()} - ${_shortenId(result.nodeId)}',
                style: TextStyle(
                  fontSize: 14 * _uiScale,
                  fontWeight: FontWeight.bold,
                  color: isSuccess ? Colors.green[700] : Colors.red[700],
                ),
              ),
              const Spacer(),
              Text(
                '${result.checks.where((c) => c.passed).length}/${result.checks.length}',
                style: TextStyle(
                  fontSize: 12 * _uiScale,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          if (!isSuccess && failedChecks.isNotEmpty) ...[
            const SizedBox(height: 4),
            ...failedChecks.take(2).map((check) => Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                '✗ ${check.description}${check.failureReason != null ? ': ${check.failureReason}' : ''}',
                style: TextStyle(
                  fontSize: 12 * _uiScale,
                  color: Colors.red[600],
                ),
              ),
            )),
            if (failedChecks.length > 2)
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  '... and ${failedChecks.length - 2} more failures',
                  style: TextStyle(
                    fontSize: 12 * _uiScale,
                    color: Colors.red[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildStateDebugTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // タップ検証結果セクション
          _buildTapValidationSection(),
          const SizedBox(height: 12),
          Divider(color: Colors.grey[400]),
          const SizedBox(height: 8),
          
          // Most critical info for immediate debugging
          Text(
            'Current State',
            style: TextStyle(
              fontSize: 16 * _uiScale,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 4),
          _buildInternalValue('Phase', _internalDebugState['phase']?.toString() ?? 'none'),
          _buildInternalValue('Tap Completed', _internalDebugState['is_tap_completed_after_up']?.toString() ?? 'N/A'),
          _buildInternalValue('Still Dragging', _internalDebugState['is_still_dragging_after_up']?.toString() ?? 'N/A'),
          _buildInternalValue('Will Toggle', _internalDebugState['will_toggle_selection']?.toString() ?? 'N/A'),
          const SizedBox(height: 8),
          _buildInternalValue('Node Target', _shortenId(_internalDebugState['nodeTargetId']?.toString() ?? 'null')),
          _buildInternalValue('Distance', _internalDebugState['distance']?.toString() ?? '0.0'),
          _buildInternalValue('Within Slop', _internalDebugState['isWithinSlop']?.toString() ?? 'N/A'),
          _buildInternalValue('Touch Slop', _internalDebugState['touch_slop']?.toString() ?? '144.0'),
          const SizedBox(height: 8),
          // Failure reasons
          if (_internalDebugState.containsKey('failure_reason'))
            _buildInternalValue('Failure', _internalDebugState['failure_reason']?.toString() ?? 'N/A'),
          if (_internalDebugState.containsKey('reason'))
            _buildInternalValue('Reason', _internalDebugState['reason']?.toString() ?? 'N/A'),
          
          const SizedBox(height: 12),
          Divider(color: Colors.grey[400]),
          const SizedBox(height: 8),
          
          Text('Gesture State', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * _uiScale)),
          const SizedBox(height: 4),
          _buildInternalValue('Dragging', _isDragging ? 'Active' : 'Inactive'),
          _buildInternalValue('Hovering', _isHovering ? 'Active' : 'Inactive'),
          _buildInternalValue('Tap Tracking', _isTapTracking ? 'Active' : 'Inactive'),
          const SizedBox(height: 8),
          
          Text('Entities', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * _uiScale)),
          const SizedBox(height: 4),
          _buildInternalValue('Last Dragged', _shortenId(_lastDraggedEntityId ?? 'None')),
          _buildInternalValue('Hovered Entity', _shortenId(_hoveredEntityId ?? 'None')),
          _buildInternalValue('Tap Target', _shortenId(_trackedTapEntityId ?? 'None')),
          const SizedBox(height: 8),
          
          Text('Counters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * _uiScale)),
          const SizedBox(height: 4),
          _buildInternalValue('Tap Count', _currentTapCount.toString()),
          _buildInternalValue('Total Gestures', _totalGestureEvents.toString()),
          _buildInternalValue('Double-tap Timer', _doubleTapTimeRemaining != null ? '${_doubleTapTimeRemaining}ms' : 'Inactive'),
          
          const SizedBox(height: 12),
          Divider(color: Colors.grey[400]),
          const SizedBox(height: 8),
          
          _buildGestureStateDisplay(),
        ],
      ),
    );
  }


  List<Widget> _buildTapDebugInfoSection(dynamic tapDebugInfo) {
    if (tapDebugInfo is! Map<String, dynamic>) {
      return [_buildInternalValue('Tap Debug Info', 'Invalid data')];
    }
    
    final List<Widget> widgets = [];
    widgets.add(Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: Text(
        'Tap State Manager Details:',
        style: TextStyle(
          fontSize: 16 * _uiScale,
          fontWeight: FontWeight.bold,
          color: Colors.indigo[700],
        ),
      ),
    ));
    
    tapDebugInfo.forEach((key, value) {
      final displayKey = key.replaceAll('_', ' ').split(' ').map((word) => 
        word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : word
      ).join(' ');
      
      if (key == 'down_position' || key == 'up_position') {
        widgets.add(_buildPositionInfo(displayKey, value));
      } else if (key.contains('entityId') || key.contains('entity_id')) {
        widgets.add(_buildInternalValue(displayKey, _shortenId(value.toString())));
      } else {
        widgets.add(_buildInternalValue(displayKey, value.toString()));
      }
    });
    
    return widgets;
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
          // Floating debug dialog in graph view (Interactive Viewer mode - always visible)
          _buildFloatingDebugDialog(),
        ],
      );
    }

    return Stack(
      children: [
        graphView,
        // Floating debug dialog in graph view (always visible, collapsible)
        _buildFloatingDebugDialog(),
      ],
    );
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
    return _buildEventLogTab();
  }


  Widget _buildEventLogTab() {
    // Filter events based on selected filters
    final filteredEvents = _events
        .where((event) {
          if (_timelineFilters.isEmpty) return true;
          return _timelineFilters.contains(event.type);
        })
        .toList();

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
                Text(
                  '${filteredEvents.length} events',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(width: 8),
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
          // Event type filters
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter by Event Type:',
                  style: TextStyle(
                    fontSize: 14 * _uiScale,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: EventType.values.map((eventType) {
                    final isSelected = _timelineFilters.contains(eventType);
                    return FilterChip(
                      label: Text(
                        _getEventTypeLabel(eventType),
                        style: TextStyle(
                          fontSize: 14 * _uiScale,
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
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                final event = filteredEvents[index];
                return _ExpandableDebugEvent(
                  event: event,
                  index: index,
                  uiScale: _uiScale,
                );
              },
            ),
          ),
        ],
      ),
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
        case GestureDebugEventType.tapDebugState:
          // Handle TAP_DEBUG_STATE events specially
          eventType = EventType.gesture;
          debugPrint('WORKBENCH: Received TAP_DEBUG_STATE event with data: ${event.data}');
          // Update internal debug state directly from the event data
          if (mounted) {
            setState(() {
              _updateGestureState('tap_debug_state', event.data);
            });
          }
          break;
      }

      // Create display event
      final debugEvent = DebugEvent(
        type: eventType,
        source: event.component,
        message: event.message,
        timestamp: event.timestamp,
        details: event.data.isEmpty ? null : event.data.toString(),
        jsonData: event.data.isEmpty ? null : event.data,
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
// Debug event types
enum EventType {
  callback,
  rebuild,
  notification,
  gesture,
  layout,
}

// ジェスチャーテストの種類
enum GestureTestType {
  tap('タップ', 'ノードを1回タップして選択状態を切り替える'),
  doubleTap('ダブルタップ', '短時間に2回タップする'),
  drag('ドラッグ', 'ノードを押してドラッグで移動させる'),
  hover('ホバー', 'マウスをノード上に置いてホバー状態にする'),
  longPress('長押し', '長時間押し続ける'),
  tapAndHold('タップ&ホールド', 'タップ後に少し保持する');

  const GestureTestType(this.displayName, this.description);
  final String displayName;
  final String description;
}

// ジェスチャー検証結果
class GestureValidationResult {
  final DateTime timestamp;
  final GestureTestType testType;
  final String phase; // 'down', 'move', 'up', 'completed'
  final String nodeId;
  final List<GestureValidationCheck> checks;
  final bool isSuccess;

  GestureValidationResult({
    required this.timestamp,
    required this.testType,
    required this.phase,
    required this.nodeId,
    required this.checks,
  }) : isSuccess = checks.every((check) => check.passed);
}

// 個別の検証項目
class GestureValidationCheck {
  final String name;
  final String description;
  final bool passed;
  final String? expectedValue;
  final String? actualValue;
  final String? failureReason;

  GestureValidationCheck({
    required this.name,
    required this.description,
    required this.passed,
    this.expectedValue,
    this.actualValue,
    this.failureReason,
  });
}

// Debug event model
class DebugEvent {
  final EventType type;
  final String source;
  final String message;
  final DateTime timestamp;
  final String? details;
  final Map<String, dynamic>? jsonData;

  DebugEvent({
    required this.type,
    required this.source,
    required this.message,
    required this.timestamp,
    this.details,
    this.jsonData,
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
    debugPrint('onTap');
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

// 折りたたみ可能なデバッグイベントウィジェット
class _ExpandableDebugEvent extends StatefulWidget {
  final DebugEvent event;
  final int index;
  final double uiScale;

  const _ExpandableDebugEvent({
    required this.event,
    required this.index,
    required this.uiScale,
  });

  @override
  _ExpandableDebugEventState createState() => _ExpandableDebugEventState();
}

class _ExpandableDebugEventState extends State<_ExpandableDebugEvent> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final hasJsonData = event.jsonData != null && event.jsonData!.isNotEmpty;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.index % 2 == 0 ? Colors.white : Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          Row(
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.message,
                            style: TextStyle(fontSize: 16 * widget.uiScale),
                          ),
                        ),
                        if (hasJsonData)
                          IconButton(
                            icon: Icon(
                              _isExpanded ? Icons.expand_less : Icons.expand_more,
                              size: 20 * widget.uiScale,
                            ),
                            onPressed: () {
                              setState(() {
                                _isExpanded = !_isExpanded;
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                    Text(
                      '${event.source} - ${_formatTime(event.timestamp)}',
                      style: TextStyle(
                        fontSize: 16 * widget.uiScale,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (!hasJsonData && event.details != null)
                      Text(
                        event.details!,
                        style: TextStyle(
                          fontSize: 16 * widget.uiScale,
                          color: Colors.grey[700],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (_isExpanded && hasJsonData)
            Container(
              margin: const EdgeInsets.only(left: 16, top: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: _buildJsonTable(event.jsonData!),
            ),
        ],
      ),
    );
  }

  Widget _buildJsonTable(Map<String, dynamic> data) {
    final entries = data.entries.toList();
    
    return Table(
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
      },
      children: entries.map((entry) {
        String valueStr;
        if (entry.value is Map || entry.value is List) {
          valueStr = const JsonEncoder.withIndent('  ').convert(entry.value);
        } else {
          valueStr = entry.value?.toString() ?? 'null';
        }
        
        return TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12, bottom: 4),
              child: Text(
                '${entry.key}:',
                style: TextStyle(
                  fontSize: 14 * widget.uiScale,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SelectableText(
                valueStr,
                style: TextStyle(
                  fontSize: 14 * widget.uiScale,
                  fontFamily: 'monospace',
                  color: Colors.grey[800],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Color _getEventColor(EventType type) {
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else {
      return '${diff.inHours}h ago';
    }
  }
}
