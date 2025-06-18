import 'package:flutter/material.dart';
import 'package:plough/plough.dart';
import 'dart:async';

import 'models.dart';
import 'gesture_validation.dart';
import 'sidebar_widgets.dart';
import 'toolbar_widgets.dart';
import 'event_log_widgets.dart';
import 'workbench_state.dart';

class WorkbenchHomePage extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onDarkModeChanged;

  const WorkbenchHomePage({
    super.key,
    required this.isDarkMode,
    required this.onDarkModeChanged,
  });

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

  // UI scale
  double _uiScale = 1.0;
  
  // Sidebar width
  double _rightSidebarWidth = 300.0;
  final double _minSidebarWidth = 200.0;
  final double _maxSidebarWidth = 600.0;
  

  // Timeline filters
  Set<EventType> _timelineFilters = createDefaultTimelineFilters();

  // Layout and data controls
  String _currentLayoutStrategy = 'Force Directed';
  String _currentDataPreset = 'Default';
  GraphGestureMode _gestureMode = GraphGestureMode.exclusive;
  bool _useInteractiveViewer = false;

  // Gesture state tracking
  bool _isDragging = false;
  
  // Internal debug state from TAP_DEBUG_STATE events
  Map<String, dynamic> _internalDebugState = createDefaultDebugState();

  // Gesture validation
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

  // Debug state
  bool _gestureDebugMode = false;
  StreamSubscription<GestureDebugEvent>? _gestureDebugSubscription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              LeftSidebar(
                graph: graph, 
                uiScale: _uiScale,
                currentDataPreset: _currentDataPreset,
                onDataPresetChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _currentDataPreset = newValue;
                    });
                    _loadDataPreset();
                  }
                },
              ),
              Expanded(
                child: CentralArea(
                  graph: graph,
                  rebuildCount: _rebuildCount,
                  onRebuildCountChanged: _incrementRebuildCount,
                  onEvent: _addEvent,
                  monitorCallbacks: _monitorCallbacks,
                  monitorRebuilds: _monitorRebuilds,
                  gestureMode: _gestureMode,
                  updateGestureState: _updateGestureState,
                  buildToolbar: _buildToolbar,
                ),
              ),
              // Draggable divider
              MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      final newWidth = _rightSidebarWidth - details.delta.dx;
                      _rightSidebarWidth = newWidth.clamp(_minSidebarWidth, _maxSidebarWidth);
                    });
                  },
                  child: Container(
                    width: 8,
                    color: Colors.grey[300],
                    child: Center(
                      child: Container(
                        width: 2,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Right sidebar with fixed width
              SizedBox(
                width: _rightSidebarWidth,
                child: EventLogPanel(
                  events: _events,
                  timelineFilters: _timelineFilters,
                  onTimelineFiltersChanged: (filters) => setState(() => _timelineFilters = filters),
                  onClearEvents: () => setState(() => _events.clear()),
                  uiScale: _uiScale,
                  internalDebugState: _internalDebugState,
                  isDragging: _isDragging,
                  isHovering: _isHovering,
                  isTapTracking: _isTapTracking,
                  lastDraggedEntityId: _lastDraggedEntityId,
                  hoveredEntityId: _hoveredEntityId,
                  trackedTapEntityId: _trackedTapEntityId,
                  currentTapCount: _currentTapCount,
                  doubleTapTimeRemaining: _doubleTapTimeRemaining,
                  totalGestureEvents: _totalGestureEvents,
                  selectedGestureTest: _selectedGestureTest,
                  gestureValidationResults: _gestureValidationResults,
                  onGestureTestChanged: (newValue) {
                    setState(() {
                      _selectedGestureTest = newValue;
                      _gestureValidationResults.clear();
                    });
                  },
                  onClearValidationResults: () {
                    setState(() {
                      _gestureValidationResults.clear();
                    });
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildToolbar() {
    return Toolbar(
      currentLayoutStrategy: _currentLayoutStrategy,
      onLayoutStrategyChanged: (newValue) {
        if (newValue != null) {
          setState(() {
            _currentLayoutStrategy = newValue;
          });
          _applyLayoutStrategy();
        }
      },
      onResetLayout: _resetLayout,
      gestureMode: _gestureMode,
      onGestureModeChanged: (newValue) {
        if (newValue != null) {
          setState(() {
            _gestureMode = newValue;
          });
        }
      },
      useInteractiveViewer: _useInteractiveViewer,
      onUseInteractiveViewerChanged: (value) {
        setState(() {
          _useInteractiveViewer = value;
        });
      },
      gestureDebugMode: _gestureDebugMode,
      onGestureDebugModeChanged: (value) {
        setState(() {
          _gestureDebugMode = value;
        });
        // Enable/disable gesture debug mode in the library
        setGestureDebugMode(_gestureDebugMode);
      },
      isDarkMode: widget.isDarkMode,
      onDarkModeChanged: widget.onDarkModeChanged,
      uiScale: _uiScale,
      onDecreaseUIScale: () {
        setState(() {
          _uiScale = (_uiScale - 0.1).clamp(0.5, 2.0);
        });
      },
      onIncreaseUIScale: () {
        setState(() {
          _uiScale = (_uiScale + 0.1).clamp(0.5, 2.0);
        });
      },
    );
  }

  void _updateGestureState(String gestureType, Map<String, dynamic> data) {
    debugPrint('🏠 WORKBENCH: _updateGestureState called with gestureType=$gestureType, data=$data');
    
    if (!_monitorGestureStates) {
      debugPrint('🏠 WORKBENCH: _monitorGestureStates is false, returning early');
      return;
    }

    // Use addPostFrameCallback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        debugPrint('🏠 WORKBENCH: Processing gestureType=$gestureType in setState');
        setState(() {
          switch (gestureType) {
            case 'tapDebugState':
              _internalDebugState = Map<String, dynamic>.from(data);
              
              // Execute tap validation
              GestureValidator.validateTapBehavior(
                data,
                _selectedGestureTest,
                _gestureValidationResults,
              );
              break;
            case 'dragStart':
              _isDragging = true;
              _lastDraggedEntityId = data['entityId'];
              break;
            case 'dragEnd':
              _isDragging = false;
              break;
            case 'tap':
              debugPrint('🏠 WORKBENCH: Processing tap case');
              _isTapTracking = data['tracking'] ?? false;
              _currentTapCount = data['tapCount'] ?? 0;
              _trackedTapEntityId = data['entityId'];
              _totalGestureEvents++;
              debugPrint('🏠 WORKBENCH: Updated tap state - tracking=$_isTapTracking, tapCount=$_currentTapCount, entityId=$_trackedTapEntityId, totalEvents=$_totalGestureEvents');
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
    });
  }

  @override
  void initState() {
    super.initState();
    graph = initializeGraph();

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

  void _subscribeToGestureDebugEvents() {
    // Subscribe to gesture debug events from the plough package
    _gestureDebugSubscription = gestureDebugEventStream.listen(
      (event) {
        final data = {
          'type': event.type.toString().split('.').last,
          'component': event.component,
          'message': event.message,
          ...event.data,
        };
        final eventType = data['type']?.toString() ?? 'unknown';
        debugPrint('WORKBENCH: Received gesture debug event: $eventType with data: $data');
        
        // Update internal gesture state for State tab
        _updateGestureState(eventType, data);
        
        // Add to event log for Event Log tab
        _addEvent(DebugEvent(
          type: EventType.gesture,
          source: event.component,
          message: event.message,
          timestamp: event.timestamp,
          jsonData: _cleanupEventData(data),
        ));
      },
      onError: (error) {
        debugPrint('WORKBENCH: Error in gesture debug stream: $error');
      },
    );
  }

  Map<String, dynamic> _cleanupEventData(Map<String, dynamic> data) {
    // Clean up event data for display, excluding common fields
    final cleanData = Map<String, dynamic>.from(data);
    cleanData.remove('type');
    cleanData.remove('component');
    cleanData.remove('message');
    
    return cleanData;
  }

  void _addEvent(DebugEvent event) {
    // Use addPostFrameCallback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _events.insert(0, event); // Add to beginning for newest-first
          if (_events.length > 1000) {
            _events.removeRange(1000, _events.length);
          }
        });
      }
    });
    _eventStreamController.add(event);
  }

  void _incrementRebuildCount() {
    // Don't use setState here as it can cause infinite rebuild loops
    // Just increment the counter directly
    if (mounted) {
      _rebuildCount++;
    }
  }

  void _applyLayoutStrategy() {
    // Apply the selected layout strategy
    setState(() {
      _rebuildCount = 0; // Reset rebuild count on layout change
    });
    _addEvent(DebugEvent(
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
    _addEvent(DebugEvent(
      type: EventType.layout,
      source: 'WorkbenchHomePage',
      message: 'Layout reset',
      timestamp: DateTime.now(),
    ));
  }

  void _loadDataPreset() {
    debugPrint('WORKBENCH: Loading template: $_currentDataPreset');
    // Load the selected data preset and replace the current graph
    setState(() {
      final newGraph = loadGraphTemplate(_currentDataPreset);
      debugPrint('WORKBENCH: Created new graph with ${newGraph.nodes.length} nodes and ${newGraph.links.length} links');
      graph = newGraph;
      _rebuildCount = 0; // Reset rebuild count on preset load
      // Clear events and reset state
      _events.clear();
      _gestureValidationResults.clear();
      _internalDebugState = createDefaultDebugState();
      _isDragging = false;
      _isHovering = false;
      _isTapTracking = false;
      _lastDraggedEntityId = null;
      _hoveredEntityId = null;
      _trackedTapEntityId = null;
      _currentTapCount = 0;
      _doubleTapTimeRemaining = null;
      _totalGestureEvents = 0;
    });
    
    // Force layout recalculation by applying the current layout strategy
    _applyLayoutStrategy();
    
    _addEvent(DebugEvent(
      type: EventType.layout,
      source: 'WorkbenchHomePage',
      message: 'Graph template loaded',
      timestamp: DateTime.now(),
      details: 'Template: $_currentDataPreset (Nodes: ${graph.nodes.length}, Links: ${graph.links.length})',
    ));
  }

  @override
  void dispose() {
    _gestureDebugSubscription?.cancel();
    _eventStreamController.close();
    super.dispose();
  }
}