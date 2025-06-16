import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:plough/src/utils/logger.dart';
import 'diagnostics.dart';

/// 拡張デバッグサーバーへの接続クライアント
@internal
class EnhancedDebugClient {
  EnhancedDebugClient._();

  factory EnhancedDebugClient() => _instance ??= EnhancedDebugClient._();

  static EnhancedDebugClient? _instance;

  String _serverUrl = 'http://localhost:8081';
  String? _sessionId;
  bool _enabled = false;
  Timer? _sendTimer;
  final List<Map<String, dynamic>> _dataQueue = [];
  static const int _batchSize = 20;
  static const Duration _batchInterval = Duration(milliseconds: 1000);

  /// クライアントの設定
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

  /// デバッグクライアントを有効化
  Future<void> enable() async {
    if (_sessionId == null) {
      logWarning(LogCategory.debug, 'Session ID not set. Call configure() first.');
      return;
    }

    _enabled = true;
    
    // セッションを作成
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

  /// デバッグクライアントを無効化
  void disable() {
    _enabled = false;
    _stopBatchTimer();
    _flushData();
    logInfo(LogCategory.debug, 'Enhanced debug client disabled');
  }

  /// ジェスチャーイベントを送信
  void sendGestureEvent({
    required GestureEventType type,
    required Offset position,
    String? targetNodeId,
    String? targetLinkId,
    required bool wasConsumed,
    required String callbackInvoked,
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

  /// レンダリングイベントを送信
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

  /// 状態変更イベントを送信
  void sendStateChange({
    required StateChangeType type,
    required String target,
    Map<String, dynamic>? oldValue,
    Map<String, dynamic>? newValue,
    required String source,
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

  /// パフォーマンスサンプルを送信
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

  /// グラフスナップショットを送信
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

  /// データをキューに追加
  void _enqueueData(String type, Map<String, dynamic> data) {
    _dataQueue.add({
      'type': type,
      'data': data,
    });

    // キューが大きくなったら即座に送信
    if (_dataQueue.length >= _batchSize) {
      _flushData();
    }
  }

  /// セッションを作成
  Future<bool> _createSession() async {
    try {
      final response = await http.post(
        Uri.parse('$_serverUrl/api/sessions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'session_id': _sessionId}),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      logError(LogCategory.debug, 'Failed to create session: $e');
      return false;
    }
  }

  /// バッチタイマーを開始
  void _startBatchTimer() {
    _stopBatchTimer();
    _sendTimer = Timer.periodic(_batchInterval, (_) {
      if (_dataQueue.isNotEmpty) {
        _flushData();
      }
    });
  }

  /// バッチタイマーを停止
  void _stopBatchTimer() {
    _sendTimer?.cancel();
    _sendTimer = null;
  }

  /// キューのデータを送信
  Future<void> _flushData() async {
    if (_dataQueue.isEmpty || _sessionId == null) return;

    // キューをコピーして即座にクリア
    final dataToSend = List<Map<String, dynamic>>.from(_dataQueue);
    _dataQueue.clear();

    for (final item in dataToSend) {
      try {
        await http.post(
          Uri.parse('$_serverUrl/api/sessions/$_sessionId/diagnostics'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(item),
        ).timeout(const Duration(seconds: 2));
      } catch (e) {
        // エラーは静かに処理（デバッグログが無限ループしないように）
        if (kDebugMode) {
          print('[EnhancedDebugClient] Failed to send data: $e');
        }
      }
    }
  }

  /// 接続テスト
  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_serverUrl/api/sessions'),
      ).timeout(const Duration(seconds: 3));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

/// グローバルインスタンス
final enhancedDebugClient = EnhancedDebugClient();