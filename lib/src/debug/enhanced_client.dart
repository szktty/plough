import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:plough/src/debug/diagnostics.dart';
import 'package:plough/src/utils/logger.dart';

/// Connection client to enhanced debug server
@internal
class EnhancedDebugClient {
  factory EnhancedDebugClient() => _instance ??= EnhancedDebugClient._();
  EnhancedDebugClient._();

  static EnhancedDebugClient? _instance;

  String _serverUrl = 'http://localhost:8081';
  String? _sessionId;
  bool _enabled = false;
  Timer? _sendTimer;
  final List<Map<String, dynamic>> _dataQueue = [];
  static const int _batchSize = 20;
  static const Duration _batchInterval = Duration(milliseconds: 1000);

  /// Client configuration
  static void configure({
    required String serverUrl,
    required String sessionId,
  }) {
    final client = EnhancedDebugClient();
    client._serverUrl = serverUrl.endsWith('/')
        ? serverUrl.substring(0, serverUrl.length - 1)
        : serverUrl;
    client._sessionId = sessionId;
  }

  /// Enable debug client
  Future<void> enable() async {
    if (_sessionId == null) {
      logWarning(
          LogCategory.debug, 'Session ID not set. Call configure() first.');
      return;
    }

    _enabled = true;

    // Create session
    final success = await _createSession();
    if (success) {
      _startBatchTimer();
      logInfo(LogCategory.debug,
          'Enhanced debug client enabled: $_serverUrl (session: $_sessionId)');
    } else {
      _enabled = false;
      logError(LogCategory.debug, 'Failed to create debug session');
    }
  }

  /// Disables the debug client
  void disable() {
    _enabled = false;
    _stopBatchTimer();
    _flushData();
    logInfo(LogCategory.debug, 'Enhanced debug client disabled');
  }

  /// Sends a gesture event
  void sendGestureEvent({
    required GestureEventType type,
    required Offset position,
    required bool wasConsumed,
    required String callbackInvoked,
    String? targetNodeId,
    String? targetLinkId,
    Map<String, dynamic>? metadata,
  }) {
    if (!_enabled) return;

    final event = GestureEvent(
      timestamp: DateTime.now(),
      type: type,
      position: position,
      targetNodeId: targetNodeId,
      targetLinkId: targetLinkId,
      wasConsumed: wasConsumed,
      callbackInvoked: callbackInvoked,
      metadata: metadata,
    );

    _enqueueData('gesture_event', event.toJson());
  }

  /// Sends a rendering event
  void sendRenderEvent({
    required RenderPhase phase,
    required Duration duration,
    required int affectedNodes,
    required String trigger,
    String? stackTrace,
  }) {
    if (!_enabled) return;

    final event = RenderEvent(
      timestamp: DateTime.now(),
      phase: phase,
      duration: duration,
      affectedNodes: affectedNodes,
      trigger: trigger,
      stackTrace: stackTrace,
    );

    _enqueueData('render_event', event.toJson());
  }

  /// Sends a state change event
  void sendStateChange({
    required StateChangeType type,
    required String target,
    required String source,
    Map<String, dynamic>? oldValue,
    Map<String, dynamic>? newValue,
    String? stackTrace,
  }) {
    if (!_enabled) return;

    final change = StateChange(
      timestamp: DateTime.now(),
      type: type,
      target: target,
      oldValue: oldValue,
      newValue: newValue,
      source: source,
      stackTrace: stackTrace,
    );

    _enqueueData('state_change', change.toJson());
  }

  /// Sends a performance sample
  void sendPerformanceSample({
    required double fps,
    required Duration frameTime,
    int? droppedFrames,
    int? memoryUsageMB,
  }) {
    if (!_enabled) return;

    final sample = {
      'fps': fps,
      'frame_time_ms': frameTime.inMicroseconds / 1000.0,
      'dropped_frames': droppedFrames ?? 0,
      'memory_usage_mb': memoryUsageMB ?? 0,
    };

    _enqueueData('performance_sample', sample);
  }

  /// Sends a graph snapshot
  void sendSnapshot({
    required int nodeCount,
    required int linkCount,
    required Map<String, NodePosition> nodePositions,
    required LayoutMetrics layoutMetrics,
    required GestureState currentGesture,
    String? selectedNodeId,
    List<String>? draggedNodeIds,
  }) {
    if (!_enabled) return;

    final snapshot = GraphSnapshot(
      timestamp: DateTime.now(),
      nodeCount: nodeCount,
      linkCount: linkCount,
      nodePositions: nodePositions,
      layoutMetrics: layoutMetrics,
      currentGesture: currentGesture,
      selectedNodeId: selectedNodeId,
      draggedNodeIds: draggedNodeIds,
    );

    _enqueueData('snapshot', snapshot.toJson());
  }

  /// Enqueues data
  void _enqueueData(String type, Map<String, dynamic> data) {
    _dataQueue.add({
      'type': type,
      'data': data,
    });

    // Send immediately if queue grows large
    if (_dataQueue.length >= _batchSize) {
      _flushData();
    }
  }

  /// Creates a session
  Future<bool> _createSession() async {
    try {
      final response = await http
          .post(
            Uri.parse('$_serverUrl/api/sessions'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'session_id': _sessionId}),
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      logError(LogCategory.debug, 'Failed to create session: $e');
      return false;
    }
  }

  /// Starts the batch timer
  void _startBatchTimer() {
    _stopBatchTimer();
    _sendTimer = Timer.periodic(_batchInterval, (_) {
      if (_dataQueue.isNotEmpty) {
        _flushData();
      }
    });
  }

  /// Stops the batch timer
  void _stopBatchTimer() {
    _sendTimer?.cancel();
    _sendTimer = null;
  }

  /// Sends data in the queue
  Future<void> _flushData() async {
    if (_dataQueue.isEmpty || _sessionId == null) return;

    // Copy and clear the queue immediately
    final dataToSend = List<Map<String, dynamic>>.from(_dataQueue);
    _dataQueue.clear();

    for (final item in dataToSend) {
      try {
        await http
            .post(
              Uri.parse('$_serverUrl/api/sessions/$_sessionId/diagnostics'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(item),
            )
            .timeout(const Duration(seconds: 2));
      } catch (e) {
        // Handle errors silently (to prevent infinite debug logging loop)
        if (kDebugMode) {
          print('[EnhancedDebugClient] Failed to send data: $e');
        }
      }
    }
  }

  /// Tests connection
  Future<bool> testConnection() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_serverUrl/api/sessions'),
          )
          .timeout(const Duration(seconds: 3));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

/// Global instance
final enhancedDebugClient = EnhancedDebugClient();
