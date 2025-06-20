// Debug event types
enum EventType {
  callback,
  rebuild,
  notification,
  gesture,
  layout,
}

// Gesture test types
enum GestureTestType {
  tap('Tap', 'Tap a node once to toggle its selection state'),
  doubleTap('Double Tap', 'Tap twice in quick succession'),
  drag('Drag', 'Press and drag a node to move it'),
  hover('Hover', 'Place mouse over a node to enter hover state'),
  longPress('Long Press', 'Press and hold for an extended period'),
  tapAndHold('Tap & Hold', 'Tap and hold briefly');

  const GestureTestType(this.displayName, this.description);
  final String displayName;
  final String description;
}

// Gesture validation result
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

// Individual validation check
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
  
  // New structured fields for enhanced workbench analysis
  final String? severity;
  final String? entityId;
  final String? gesturePhase;
  final String? gestureType;

  DebugEvent({
    required this.type,
    required this.source,
    required this.message,
    required this.timestamp,
    this.details,
    this.jsonData,
    this.severity,
    this.entityId,
    this.gesturePhase,
    this.gestureType,
  });
  
  /// Creates a DebugEvent from a structured GestureDebugEvent map
  factory DebugEvent.fromGestureDebugEvent(Map<String, dynamic> eventMap) {
    final gestureType = eventMap['type'] as String?;
    final eventType = _mapGestureTypeToEventType(gestureType);
    
    return DebugEvent(
      type: eventType,
      source: (eventMap['component'] as String?) ?? 'unknown',
      message: (eventMap['message'] as String?) ?? '',
      timestamp: DateTime.tryParse(eventMap['timestamp'] as String? ?? '') ?? DateTime.now(),
      details: _formatGestureDetails(eventMap),
      jsonData: eventMap['data'] as Map<String, dynamic>?,
      severity: eventMap['severity'] as String?,
      entityId: eventMap['entityId'] as String?,
      gesturePhase: eventMap['gesturePhase'] as String?,
      gestureType: gestureType,
    );
  }
  
  /// Maps gesture debug event types to workbench event types
  static EventType _mapGestureTypeToEventType(String? gestureType) {
    if (gestureType == null) return EventType.gesture;
    
    // Group related gesture events
    if (gestureType.startsWith('tap') || 
        gestureType.startsWith('drag') || 
        gestureType.startsWith('hover')) {
      return EventType.gesture;
    }
    
    if (gestureType.startsWith('timer')) {
      return EventType.notification;
    }
    
    if (gestureType.contains('state') || gestureType.contains('State')) {
      return EventType.notification;
    }
    
    return EventType.gesture;
  }
  
  /// Creates formatted details from gesture event data
  static String? _formatGestureDetails(Map<String, dynamic> eventMap) {
    final details = <String>[];
    
    if (eventMap['severity'] != null) {
      details.add('Severity: ${eventMap['severity']}');
    }
    
    if (eventMap['entityId'] != null) {
      details.add('Entity: ${_shortenId(eventMap['entityId'] as String)}');
    }
    
    if (eventMap['gesturePhase'] != null) {
      details.add('Phase: ${eventMap['gesturePhase']}');
    }
    
    final data = eventMap['data'] as Map<String, dynamic>?;
    if (data != null && data.isNotEmpty) {
      details.add('Data: ${data.length} fields');
    }
    
    return details.isEmpty ? null : details.join(' | ');
  }
  
  static String _shortenId(String id) {
    if (id.length <= 8) return id;
    return '...${id.substring(id.length - 6)}';
  }
}