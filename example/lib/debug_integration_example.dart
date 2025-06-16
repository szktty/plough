import 'package:flutter/foundation.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/debug/external_debug_client.dart';

/// デバッグサーバーとの接続設定例
class DebugIntegrationExample {
  
  /// 拡張デバッグサーバーに接続する設定
  static Future<void> setupEnhancedDebugConnection() async {
    if (!kDebugMode) return; // リリースビルドでは何もしない

    // 1. 基本的なデバッグ設定
    Plough()
      ..enableLogCategories({
        LogCategory.gesture: Level.debug,
        LogCategory.rendering: Level.info,
        LogCategory.layout: Level.debug,
        LogCategory.performance: Level.debug,
        LogCategory.debug: Level.info,
        LogCategory.state: Level.debug,
        LogCategory.animation: Level.info,
      })
      ..debugLogEnabled = true
      ..debugSignalsEnabled = false;

    // 2. 内蔵デバッグサーバーを起動（ポート8080）
    await Plough().initializeDebugFeatures(
      enableServer: true,
      enablePerformanceMonitoring: true,
      serverPort: 8080,
    );

    // 3. 外部デバッグサーバー（Python）に接続（ポート8081）
    final sessionId = 'flutter_session_${DateTime.now().millisecondsSinceEpoch}';
    
    // 外部デバッグクライアントを設定
    externalDebugClient
      ..setServerUrl('http://localhost:8081')
      ..enable();

    // 接続テスト
    final isConnected = await externalDebugClient.testConnection();
    if (isConnected) {
      logInfo(LogCategory.debug, 
          'Successfully connected to enhanced debug server at http://localhost:8081');
    } else {
      logWarning(LogCategory.debug, 
          'Could not connect to enhanced debug server. Make sure it is running.');
    }

    print('🔧 Debug Setup Complete:');
    print('   📊 Internal Debug Server: http://localhost:8080');
    print('   🚀 Enhanced Debug Server: http://localhost:8081');
    print('   📱 Session ID: $sessionId');
  }

  /// 手動でデバッグデータを送信する例
  static void sendCustomDebugData() {
    // カスタムメタデータ付きでログを送信
    externalDebugClient.sendLog(
      category: LogCategory.gesture,
      level: 'INFO',
      message: 'Custom gesture event occurred',
      metadata: {
        'user_action': 'node_tap',
        'node_id': 'node_123',
        'position': {'x': 150.0, 'y': 200.0},
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// デバッグサーバーの状態確認
  static Future<void> checkDebugServerStatus() async {
    final serverInfo = await externalDebugClient.getServerInfo();
    if (serverInfo != null) {
      print('Debug Server Info: $serverInfo');
    } else {
      print('Debug server not available');
    }
  }

  /// デバッグ接続をクリーンアップ
  static void cleanup() {
    externalDebugClient.disable();
    print('Debug connections cleaned up');
  }
}

/// より詳細な診断データを送信するヘルパー関数群
class DiagnosticsHelper {
  
  /// ジェスチャーイベントの詳細ログ
  static void logGestureEvent({
    required String eventType,
    required Offset position,
    String? nodeId,
    bool? backgroundHit,
    String? gestureMode,
  }) {
    externalDebugClient.sendLog(
      category: LogCategory.gesture,
      level: 'DEBUG',
      message: 'Gesture event: $eventType',
      metadata: {
        'event_type': eventType,
        'position': {'x': position.dx, 'y': position.dy},
        'node_id': nodeId,
        'background_hit': backgroundHit,
        'gesture_mode': gestureMode,
        'stack_trace': _getShortStackTrace(),
      },
    );
  }

  /// レンダリングパフォーマンスのログ
  static void logRenderPerformance({
    required String operation,
    required Duration duration,
    int? nodeCount,
    String? trigger,
  }) {
    externalDebugClient.sendLog(
      category: LogCategory.performance,
      level: 'INFO',
      message: 'Render operation: $operation took ${duration.inMilliseconds}ms',
      metadata: {
        'operation': operation,
        'duration_ms': duration.inMilliseconds,
        'node_count': nodeCount,
        'trigger': trigger,
        'fps_impact': duration.inMilliseconds > 16 ? 'high' : 'low',
      },
    );
  }

  /// 状態変更の詳細ログ
  static void logStateChange({
    required String target,
    required String changeType,
    Map<String, dynamic>? oldValue,
    Map<String, dynamic>? newValue,
    String? source,
  }) {
    externalDebugClient.sendLog(
      category: LogCategory.state,
      level: 'DEBUG',
      message: 'State change: $target ($changeType)',
      metadata: {
        'target': target,
        'change_type': changeType,
        'old_value': oldValue,
        'new_value': newValue,
        'source': source,
        'stack_trace': _getShortStackTrace(),
      },
    );
  }

  /// フレームレート監視
  static void logFrameRate({
    required double currentFps,
    required Duration frameTime,
    bool? dropped,
  }) {
    externalDebugClient.sendLog(
      category: LogCategory.performance,
      level: dropped == true ? 'WARNING' : 'DEBUG',
      message: 'Frame rate: ${currentFps.toStringAsFixed(1)} FPS',
      metadata: {
        'fps': currentFps,
        'frame_time_ms': frameTime.inMicroseconds / 1000.0,
        'dropped_frame': dropped ?? false,
        'target_fps': 60.0,
        'performance_level': _getPerformanceLevel(currentFps),
      },
    );
  }

  /// ちらつき問題の専用ログ
  static void logFlickeringIssue({
    required String component,
    required String trigger,
    Map<String, dynamic>? context,
  }) {
    externalDebugClient.sendLog(
      category: LogCategory.rendering,
      level: 'ERROR',
      message: '🚨 Flickering detected in $component',
      metadata: {
        'component': component,
        'trigger': trigger,
        'context': context,
        'timestamp': DateTime.now().toIso8601String(),
        'stack_trace': _getShortStackTrace(),
        'investigation_needed': true,
      },
    );
  }

  /// 簡易スタックトレース（最初の5行のみ）
  static String _getShortStackTrace() {
    final stackTrace = StackTrace.current.toString();
    final lines = stackTrace.split('\n');
    return lines.take(5).join('\n');
  }

  /// パフォーマンスレベルの判定
  static String _getPerformanceLevel(double fps) {
    if (fps >= 55) return 'excellent';
    if (fps >= 45) return 'good';
    if (fps >= 30) return 'acceptable';
    return 'poor';
  }
}