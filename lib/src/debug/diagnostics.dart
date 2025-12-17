import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'diagnostics.freezed.dart';
part 'diagnostics.g.dart';

// Serialization helper
Map<String, dynamic> sizeToJson(Size size) => {
      'width': size.width,
      'height': size.height,
    };

// Deserialization helper
Size sizeFromJson(Map<String, dynamic> json) => Size(
      (json['width'] as num).toDouble(),
      (json['height'] as num).toDouble(),
    );

// Offset serialization helper (non-nullable)
Map<String, dynamic> offsetToJson(Offset offset) => {
      'dx': offset.dx,
      'dy': offset.dy,
    };

// Offset deserialization helper (non-nullable)
Offset offsetFromJson(Map<String, dynamic> json) => Offset(
      (json['dx'] as num).toDouble(),
      (json['dy'] as num).toDouble(),
    );

// Offset serialization helper (nullable)
Map<String, dynamic>? nullableOffsetToJson(Offset? offset) {
  if (offset == null) return null;
  return {
    'dx': offset.dx,
    'dy': offset.dy,
  };
}

// Offset deserialization helper (nullable)
Offset? nullableOffsetFromJson(Map<String, dynamic>? json) {
  if (json == null) return null;
  return Offset(
    (json['dx'] as num).toDouble(),
    (json['dy'] as num).toDouble(),
  );
}

/// Graph diagnostic data
@freezed
class GraphDiagnostics with _$GraphDiagnostics {
  const factory GraphDiagnostics({
    required GraphSnapshot snapshot,
    required List<GestureEvent> gestureHistory,
    required List<RenderEvent> renderHistory,
    required List<StateChange> stateChanges,
    required PerformanceMetrics performance,
  }) = _GraphDiagnostics;

  factory GraphDiagnostics.fromJson(Map<String, dynamic> json) =>
      _$GraphDiagnosticsFromJson(json);
}

/// Current state snapshot of the graph
@freezed
class GraphSnapshot with _$GraphSnapshot {
  const factory GraphSnapshot({
    required DateTime timestamp,
    required int nodeCount,
    required int linkCount,
    required Map<String, NodePosition> nodePositions,
    required LayoutMetrics layoutMetrics,
    required GestureState currentGesture,
    String? selectedNodeId,
    List<String>? draggedNodeIds,
  }) = _GraphSnapshot;

  factory GraphSnapshot.fromJson(Map<String, dynamic> json) =>
      _$GraphSnapshotFromJson(json);
}

/// Node position information
@freezed
class NodePosition with _$NodePosition {
  const factory NodePosition({
    required String nodeId,
    required double x,
    required double y,
    required bool isFixed,
    bool? isAnimating,
  }) = _NodePosition;

  factory NodePosition.fromJson(Map<String, dynamic> json) =>
      _$NodePositionFromJson(json);
}

/// Layout metrics
@freezed
class LayoutMetrics with _$LayoutMetrics {
  const factory LayoutMetrics({
    required String strategy,
    required Duration lastCalculationTime,
    required int iterationCount,
    required double totalEnergy,
    @JsonKey(fromJson: sizeFromJson, toJson: sizeToJson)
    required Size graphBounds,
  }) = _LayoutMetrics;

  factory LayoutMetrics.fromJson(Map<String, dynamic> json) =>
      _$LayoutMetricsFromJson(json);
}

/// Current gesture state
@freezed
class GestureState with _$GestureState {
  const factory GestureState({
    required bool isPanning,
    required bool isDragging,
    required bool isSelecting,
    @JsonKey(fromJson: nullableOffsetFromJson, toJson: nullableOffsetToJson)
    Offset? currentPosition,
    String? hoveredNodeId,
  }) = _GestureState;

  factory GestureState.fromJson(Map<String, dynamic> json) =>
      _$GestureStateFromJson(json);
}
/// Gesture event  const factory GestureEvent({
    DateTime timestamp,
    required GestureEventType type,
    @JsonKey(fromJson = offsetFromJson, toJson = offsetToJson)
    Offset position,
    required bool wasConsumed,
    required String callbackInvoked,
    String? targetNodeId,
    String? targetLinkId,
    Map<String, dynamic>? metadata,
  }) = _GestureEvent;

  GestureEvent.fromJson(Map<String, dynamic> json) =>
      _$GestureEventFromJson(json);
}

/// Type of gesture event
enum GestureEventType {
  pointerDown,
  pointerUp,
  pointerMove,
  tap,
  doubleTap,
  longPress,
  panStart,
  panUpdate,
  panEnd,
  scale,
}

/// Render event
@freezed
class RenderEvent with _$RenderEvent {
  const factory RenderEvent({
    required DateTime timestamp,
    required RenderPhase phase,
    required Duration duration,
    required int affectedNodes,
    required String trigger,
    String? stackTrace,
  }) = _RenderEvent;

  factory RenderEvent.fromJson(Map<String, dynamic> json) =>
      _$RenderEventFromJson(json);
}

/// Render phase
enum RenderPhase {
  layout,
  paint,
  composite,
  build,
  postFrameCallback,
}

/// State change event
@freezed
class StateChange with _$StateChange {
  const factory StateChange({
    required DateTime timestamp,
    required StateChangeType type,
    required String target,
    required String source,
    Map<String, dynamic>? oldValue,
    Map<String, dynamic>? newValue,
    String? stackTrace,
  }) = _StateChange;

  factory StateChange.fromJson(Map<String, dynamic> json) =>
      _$StateChangeFromJson(json);
}

/// Type of state change
enum StateChangeType {
  valueNotifier,
  setState,
  inheritedWidget,
  nodePosition,
  nodeSelection,
  graphStructure,
  layoutStrategy,
  animation,
}

/// Performance metrics
@freezed
class PerformanceMetrics with _$PerformanceMetrics {
  const factory PerformanceMetrics({
    required double averageFps,
    required double currentFps,
    required int droppedFrames,
    required Duration averageFrameTime,
    required Duration worstFrameTime,
    required int memoryUsageMB,
    required DateTime measurementStart,
    required DateTime measurementEnd,
  }) = _PerformanceMetrics;

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) =>
      _$PerformanceMetricsFromJson(json);
}

/// Diagnostics data collector
@internal
class DiagnosticsCollector {
  DiagnosticsCollector({
    this.maxHistorySize = 1000,
    this.performanceWindowSize = 60, // 60 frames = approx 1 second
  });

  final int maxHistorySize;
  final int performanceWindowSize;

  final List<GestureEvent> _gestureHistory = [];
  final List<RenderEvent> _renderHistory = [];
  final List<StateChange> _stateHistory = [];
  final List<Duration> _frameTimes = [];

  GraphSnapshot? _lastSnapshot;
  DateTime? _performanceStart;
  int _droppedFrames = 0;

  void recordGestureEvent(GestureEvent event) {
    _gestureHistory.add(event);
    _trimHistory(_gestureHistory);
  }

  void recordRenderEvent(RenderEvent event) {
    _renderHistory.add(event);
    _trimHistory(_renderHistory);
  }

  void recordStateChange(StateChange change) {
    _stateHistory.add(change);
    _trimHistory(_stateHistory);
  }

  void recordFrameTime(Duration frameTime) {
    _frameTimes.add(frameTime);
    if (_frameTimes.length > performanceWindowSize) {
      _frameTimes.removeAt(0);
    }

    // Count as dropped frame if exceeds 16.67ms (60fps)
    if (frameTime.inMicroseconds > 16667) {
      _droppedFrames++;
    }

    _performanceStart ??= DateTime.now();
  }

  void updateSnapshot(GraphSnapshot snapshot) {
    _lastSnapshot = snapshot;
  }

  GraphDiagnostics collectDiagnostics() {
    final now = DateTime.now();

    return GraphDiagnostics(
      snapshot: _lastSnapshot ??
          GraphSnapshot(
            timestamp: now,
            nodeCount: 0,
            linkCount: 0,
            nodePositions: {},
            layoutMetrics: const LayoutMetrics(
              strategy: 'unknown',
              lastCalculationTime: Duration.zero,
              iterationCount: 0,
              totalEnergy: 0,
              graphBounds: Size.zero,
            ),
            currentGesture: const GestureState(
              isPanning: false,
              isDragging: false,
              isSelecting: false,
            ),
          ),
      gestureHistory: List.unmodifiable(_gestureHistory),
      renderHistory: List.unmodifiable(_renderHistory),
      stateChanges: List.unmodifiable(_stateHistory),
      performance: _calculatePerformanceMetrics(now),
    );
  }

  PerformanceMetrics _calculatePerformanceMetrics(DateTime now) {
    if (_frameTimes.isEmpty) {
      return PerformanceMetrics(
        averageFps: 0,
        currentFps: 0,
        droppedFrames: 0,
        averageFrameTime: Duration.zero,
        worstFrameTime: Duration.zero,
        memoryUsageMB: 0,
        measurementStart: now,
        measurementEnd: now,
      );
    }

    final averageFrameTime = _frameTimes.fold<Duration>(
          Duration.zero,
          (total, time) => total + time,
        ) ~/
        _frameTimes.length;

    final worstFrameTime = _frameTimes.reduce(
      (max, time) => time > max ? time : max,
    );

    final averageFps = averageFrameTime.inMicroseconds > 0
        ? 1000000.0 / averageFrameTime.inMicroseconds
        : 0.0;

    final currentFps =
        _frameTimes.isNotEmpty && _frameTimes.last.inMicroseconds > 0
            ? 1000000.0 / _frameTimes.last.inMicroseconds
            : 0.0;

    return PerformanceMetrics(
      averageFps: averageFps,
      currentFps: currentFps,
      droppedFrames: _droppedFrames,
      averageFrameTime: averageFrameTime,
      worstFrameTime: worstFrameTime,
      memoryUsageMB: 0, // TODO: Get actual memory usage
      measurementStart: _performanceStart ?? now,
      measurementEnd: now,
    );
  }

  void _trimHistory<T>(List<T> history) {
    while (history.length > maxHistorySize) {
      history.removeAt(0);
    }
  }

  void clear() {
    _gestureHistory.clear();
    _renderHistory.clear();
    _stateHistory.clear();
    _frameTimes.clear();
    _droppedFrames = 0;
    _performanceStart = null;
    _lastSnapshot = null;
  }
}
