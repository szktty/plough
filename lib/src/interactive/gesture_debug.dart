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
  timerStart,
  timerCancel,
  timerExpire,
  stateTransition,
  conditionCheck,
  backgroundCallback,
  hitTest,
  gestureDecision,
  tapDebugState,
}

/// Internal debug event for gesture processing
class GestureDebugEvent {
  final GestureDebugEventType type;
  final String component;
  final String message;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  GestureDebugEvent({
    required this.type,
    required this.component,
    required this.message,
    this.data = const {},
  }) : timestamp = DateTime.now();

  @override
  String toString() {
    final dataStr = data.isNotEmpty ? ' | Data: $data' : '';
    return '[${_formatTime(timestamp)}] ${component}: ${message}$dataStr';
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
  String message, [
  Map<String, dynamic>? data,
]) {
  if (!_gestureDebugEnabled) return;

  final event = GestureDebugEvent(
    type: type,
    component: component,
    message: message,
    data: data ?? {},
  );

  // Use different emoji/prefix for different event types
  final prefix = _getEventPrefix(type);
  debugPrint('$prefix $event');
  
  // Also send to stream for external consumption
  _debugEventController.add(event);
}

String _getEventPrefix(GestureDebugEventType type) {
  switch (type) {
    case GestureDebugEventType.timerStart:
      return '⏱️';
    case GestureDebugEventType.timerCancel:
      return '⏹️';
    case GestureDebugEventType.timerExpire:
      return '⏰';
    case GestureDebugEventType.stateTransition:
      return '🔄';
    case GestureDebugEventType.conditionCheck:
      return '🔍';
    case GestureDebugEventType.backgroundCallback:
      return '📞';
    case GestureDebugEventType.hitTest:
      return '🎯';
    case GestureDebugEventType.gestureDecision:
      return '⚖️';
    case GestureDebugEventType.tapDebugState:
      return '🔧';
  }
}

/// Helper for logging timer-related events
class GestureTimerLogger {
  final String component;
  final String timerName;

  GestureTimerLogger(this.component, this.timerName);

  void started(Duration duration, [Map<String, dynamic>? data]) {
    logGestureDebug(
      GestureDebugEventType.timerStart,
      component,
      '$timerName timer started (${duration.inMilliseconds}ms)',
      data,
    );
  }

  void cancelled([Map<String, dynamic>? data]) {
    logGestureDebug(
      GestureDebugEventType.timerCancel,
      component,
      '$timerName timer cancelled',
      data,
    );
  }

  void expired([Map<String, dynamic>? data]) {
    logGestureDebug(
      GestureDebugEventType.timerExpire,
      component,
      '$timerName timer expired',
      data,
    );
  }
}

/// Helper for logging state transitions
void logStateTransition(
  String component,
  String fromState,
  String toState, [
  Map<String, dynamic>? data,
]) {
  logGestureDebug(
    GestureDebugEventType.stateTransition,
    component,
    'State: $fromState → $toState',
    data,
  );
}

/// Helper for logging condition checks
void logConditionCheck(
  String component,
  String condition,
  bool result, [
  Map<String, dynamic>? data,
]) {
  final resultStr = result ? 'PASS' : 'FAIL';
  logGestureDebug(
    GestureDebugEventType.conditionCheck,
    component,
    'Condition "$condition": $resultStr',
    data,
  );
}

/// Helper for logging gesture decisions
void logGestureDecision(
  String component,
  String decision,
  String reason, [
  Map<String, dynamic>? data,
]) {
  logGestureDebug(
    GestureDebugEventType.gestureDecision,
    component,
    'Decision: $decision - $reason',
    data,
  );
}

/// Helper for logging hit test results
void logHitTest(
  String component,
  String position,
  GraphId? hitEntity, [
  Map<String, dynamic>? data,
]) {
  final hitStr = hitEntity != null ? 'HIT: $hitEntity' : 'BACKGROUND';
  logGestureDebug(
    GestureDebugEventType.hitTest,
    component,
    'Hit test at $position → $hitStr',
    data,
  );
}

/// Helper for logging background callbacks
void logBackgroundCallback(
  String component,
  String callbackType,
  String position, [
  Map<String, dynamic>? data,
]) {
  logGestureDebug(
    GestureDebugEventType.backgroundCallback,
    component,
    'Background $callbackType at $position',
    data,
  );
}