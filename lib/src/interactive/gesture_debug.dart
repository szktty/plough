// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/foundation.dart';
import '../graph/id.dart';

/// Global gesture debug mode flag
bool _gestureDebugEnabled = false;

/// Stream controller for debug events
final _debugEventController = StreamController<GestureDebugEvent>.broadcast();

/// Enable or disable gesture debug mode
void setGestureDebugMode(bool enabled) {
  _gestureDebugEnabled = enabled;
  if (enabled) {
    debugPrint('🔧 Gesture Debug Mode ENABLED - Internal state logging activated');
  } else {
    debugPrint('🔧 Gesture Debug Mode DISABLED');
  }
}

/// Check if gesture debug mode is enabled
bool get isGestureDebugEnabled => _gestureDebugEnabled;

/// Get stream of debug events
Stream<GestureDebugEvent> get gestureDebugEventStream => _debugEventController.stream;

/// Debug event types for internal gesture processing
enum GestureDebugEventType {
  // Timer events
  timerStart,
  timerCancel,
  timerExpire,
  
  // State transitions
  stateTransition,
  stateCreate,
  stateDestroy,
  
  // Validation events
  conditionCheck,
  gestureDecision,
  
  // Interaction events
  hitTest,
  backgroundCallback,
  
  // Gesture flow events
  tapStart,
  tapComplete,
  tapCancel,
  dragStart,
  dragUpdate,
  dragEnd,
  hoverEnter,
  hoverExit,
  
  // Debug state snapshots
  tapDebugState,
  dragDebugState,
  hoverDebugState,
}

/// Debug event severity levels
enum GestureDebugSeverity {
  trace,
  debug,
  info,
  warn,
  error,
}

/// Internal debug event for gesture processing
class GestureDebugEvent {
  GestureDebugEvent({
    required this.type,
    required this.component,
    required this.message,
    this.data = const {},
    this.severity = GestureDebugSeverity.debug,
    this.entityId,
    this.gesturePhase,
  }) : timestamp = DateTime.now();

  final GestureDebugEventType type;
  final String component;
  final String message;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final GestureDebugSeverity severity;
  final String? entityId;
  final String? gesturePhase;

  /// Human-readable format for console output
  @override
  String toString() {
    final prefix = _getEventPrefix(type);
    final dataStr = data.isNotEmpty ? ' | Data: $data' : '';
    return '$prefix [${_formatTime(timestamp)}] $component: $message$dataStr';
  }
  
  /// Structured format for workbench analysis
  Map<String, dynamic> toStructuredMap() {
    return {
      'type': type.name,
      'component': component,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'severity': severity.name,
      'entityId': entityId,
      'gesturePhase': gesturePhase,
      'data': data,
    };
  }
  
  /// Creates event from structured map (for deserialization)
  static GestureDebugEvent fromStructuredMap(Map<String, dynamic> map) {
    return GestureDebugEvent(
      type: GestureDebugEventType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => GestureDebugEventType.tapDebugState,
      ),
      component: (map['component'] as String?) ?? 'unknown',
      message: (map['message'] as String?) ?? '',
      data: Map<String, dynamic>.from(
        (map['data'] as Map<dynamic, dynamic>?) ?? <String, dynamic>{},
      ),
      severity: GestureDebugSeverity.values.firstWhere(
        (e) => e.name == map['severity'],
        orElse: () => GestureDebugSeverity.debug,
      ),
      entityId: map['entityId'] as String?,
      gesturePhase: map['gesturePhase'] as String?,
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
           '${time.minute.toString().padLeft(2, '0')}:'
           '${time.second.toString().padLeft(2, '0')}.'
           '${time.millisecond.toString().padLeft(3, '0')}';
  }
}

/// Log internal gesture debug events
void logGestureDebug(
  GestureDebugEventType type,
  String component,
  String message, {
  Map<String, dynamic>? data,
  GestureDebugSeverity severity = GestureDebugSeverity.debug,
  String? entityId,
  String? gesturePhase,
}) {
  if (!_gestureDebugEnabled) return;

  final event = GestureDebugEvent(
    type: type,
    component: component,
    message: message,
    data: data ?? {},
    severity: severity,
    entityId: entityId,
    gesturePhase: gesturePhase,
  );

  // Human-readable console output
  debugPrint(event.toString());
  
  // Structured event for external consumption (workbench)
  _debugEventController.add(event);
}

/// Convenience method for logging gesture flow events
void logGestureFlow(
  GestureDebugEventType type,
  String component,
  String entityId,
  String phase, {
  Map<String, dynamic>? data,
  String? message,
}) {
  logGestureDebug(
    type,
    component,
    message ?? '${type.name} for $entityId in $phase phase',
    data: data,
    entityId: entityId,
    gesturePhase: phase,
  );
}

String _getEventPrefix(GestureDebugEventType type) {
  switch (type) {
    // Timer events
    case GestureDebugEventType.timerStart:
      return '⏱️';
    case GestureDebugEventType.timerCancel:
      return '⏹️';
    case GestureDebugEventType.timerExpire:
      return '⏰';
    
    // State events
    case GestureDebugEventType.stateTransition:
      return '🔄';
    case GestureDebugEventType.stateCreate:
      return '🆕';
    case GestureDebugEventType.stateDestroy:
      return '🗑️';
    
    // Validation events
    case GestureDebugEventType.conditionCheck:
      return '🔍';
    case GestureDebugEventType.gestureDecision:
      return '⚖️';
    
    // Interaction events
    case GestureDebugEventType.hitTest:
      return '🎯';
    case GestureDebugEventType.backgroundCallback:
      return '📞';
    
    // Gesture flow events
    case GestureDebugEventType.tapStart:
      return '👆';
    case GestureDebugEventType.tapComplete:
      return '✅';
    case GestureDebugEventType.tapCancel:
      return '❌';
    case GestureDebugEventType.dragStart:
      return '👋';
    case GestureDebugEventType.dragUpdate:
      return '🔄';
    case GestureDebugEventType.dragEnd:
      return '🏁';
    case GestureDebugEventType.hoverEnter:
      return '🔍';
    case GestureDebugEventType.hoverExit:
      return '👋';
    
    // Debug state snapshots
    case GestureDebugEventType.tapDebugState:
      return '🔧';
    case GestureDebugEventType.dragDebugState:
      return '🔧';
    case GestureDebugEventType.hoverDebugState:
      return '🔧';
  }
}

/// Helper for logging timer-related events
class GestureTimerLogger {
  GestureTimerLogger(this.component, this.timerName, [this.entityId]);

  final String component;
  final String timerName;
  final String? entityId;

  void started(Duration duration, [Map<String, dynamic>? data]) {
    logGestureDebug(
      GestureDebugEventType.timerStart,
      component,
      '$timerName timer started (${duration.inMilliseconds}ms)',
      data: data,
      entityId: entityId,
      );
  }

  void cancelled([Map<String, dynamic>? data]) {
    logGestureDebug(
      GestureDebugEventType.timerCancel,
      component,
      '$timerName timer cancelled',
      data: data,
      entityId: entityId,
      );
  }

  void expired([Map<String, dynamic>? data]) {
    logGestureDebug(
      GestureDebugEventType.timerExpire,
      component,
      '$timerName timer expired',
      data: data,
      entityId: entityId,
      );
  }
}

/// Helper for logging state transitions
void logStateTransition(
  String component,
  String fromState,
  String toState, {
  Map<String, dynamic>? data,
  String? entityId,
  String? gesturePhase,
}) {
  logGestureDebug(
    GestureDebugEventType.stateTransition,
    component,
    'State: $fromState → $toState',
    data: data,
    entityId: entityId,
    gesturePhase: gesturePhase,
  );
}

/// Helper for logging state creation
void logStateCreate(
  String component,
  String stateType,
  String entityId, {
  Map<String, dynamic>? data,
  String? gesturePhase,
}) {
  logGestureDebug(
    GestureDebugEventType.stateCreate,
    component,
    'Created $stateType state',
    data: data,
    entityId: entityId,
    gesturePhase: gesturePhase,
  );
}

/// Helper for logging state destruction
void logStateDestroy(
  String component,
  String stateType,
  String entityId, {
  Map<String, dynamic>? data,
  String? gesturePhase,
}) {
  logGestureDebug(
    GestureDebugEventType.stateDestroy,
    component,
    'Destroyed $stateType state',
    data: data,
    entityId: entityId,
    gesturePhase: gesturePhase,
  );
}

/// Helper for logging condition checks
void logConditionCheck(
  String component,
  String condition, {
  required bool result,
  Map<String, dynamic>? data,
  String? entityId,
  String? gesturePhase,
}) {
  final resultStr = result ? 'PASS' : 'FAIL';
  logGestureDebug(
    GestureDebugEventType.conditionCheck,
    component,
    'Condition "$condition": $resultStr',
    data: data,
    entityId: entityId,
    gesturePhase: gesturePhase,
    severity: result ? GestureDebugSeverity.debug : GestureDebugSeverity.warn,
  );
}

/// Helper for logging gesture decisions
void logGestureDecision(
  String component,
  String decision,
  String reason, {
  Map<String, dynamic>? data,
  String? entityId,
  String? gesturePhase,
}) {
  logGestureDebug(
    GestureDebugEventType.gestureDecision,
    component,
    'Decision: $decision - $reason',
    data: data,
    entityId: entityId,
    gesturePhase: gesturePhase,
  );
}

/// Helper for logging hit test results
void logHitTest(
  String component,
  String position,
  GraphId? hitEntity, {
  Map<String, dynamic>? data,
  String? gesturePhase,
}) {
  final hitStr = hitEntity != null ? 'HIT: $hitEntity' : 'BACKGROUND';
  logGestureDebug(
    GestureDebugEventType.hitTest,
    component,
    'Hit test at $position → $hitStr',
    data: data,
    entityId: hitEntity?.toString(),
    gesturePhase: gesturePhase,
  );
}

/// Helper for logging background callbacks
void logBackgroundCallback(
  String component,
  String callbackType,
  String position, {
  Map<String, dynamic>? data,
  String? gesturePhase,
}) {
  logGestureDebug(
    GestureDebugEventType.backgroundCallback,
    component,
    'Background $callbackType at $position',
    data: data,
    gesturePhase: gesturePhase,
  );
}
