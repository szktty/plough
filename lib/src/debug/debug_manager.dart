import 'dart:async';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plough/src/utils/logger.dart';
import 'package:plough/src/debug/debug_server.dart';
import 'package:plough/src/debug/structured_logger.dart';
import 'package:plough/src/debug/performance_monitor.dart';

/// デバッグ機能の統合管理クラス
@internal
class PloughDebugManager {
  PloughDebugManager._();

  static PloughDebugManager? _instance;
  factory PloughDebugManager() => _instance ??= PloughDebugManager._();

  final PloughDebugServer _debugServer = PloughDebugServer();
  final StructuredLogger _structuredLogger = StructuredLogger();
  final PerformanceMonitor _performanceMonitor = PerformanceMonitor();

  bool _initialized = false;

  /// デバッグ機能を初期化
  Future<void> initialize({
    bool enableServer = true,
    bool enableStructuredLogging = true,
    bool enablePerformanceMonitoring = true,
    int serverPort = 8080,
    bool tryAlternativePorts = true,
  }) async {
    if (_initialized) {
      logWarning(LogCategory.debug, 'Debug manager already initialized');
      return;
    }

    logInfo(LogCategory.debug, 'Initializing debug manager...');

    // 構造化ログを有効化
    if (enableStructuredLogging) {
      logInfo(LogCategory.debug, 'Structured logging enabled');
    }

    // パフォーマンス監視を有効化
    if (enablePerformanceMonitoring) {
      _performanceMonitor.setEnabled(true);
      logInfo(LogCategory.debug, 'Performance monitoring enabled');
    }

    // デバッグサーバーを開始
    bool serverStarted = false;
    if (enableServer) {
      try {
        await _debugServer.start(
            port: serverPort, tryAlternativePorts: tryAlternativePorts);
        serverStarted = true;
        logInfo(LogCategory.debug,
            'Debug server started on port ${_debugServer.port}');
        logInfo(LogCategory.debug,
            'Debug console available at: ${_debugServer.url}');
        logInfo(LogCategory.debug,
            'Note: If browser access fails, check macOS sandbox restrictions');
        logInfo(LogCategory.debug,
            'Alternative: Use Flutter DevTools or VM Service for debugging');
      } on Exception catch (e) {
        logError(LogCategory.debug, 'Failed to start debug server: $e');
        // サーバーの起動に失敗しても、他のデバッグ機能は有効にする
      }
    }

    _initialized = true;
    logInfo(
        LogCategory.debug,
        serverStarted
            ? 'Debug manager initialized successfully with server'
            : 'Debug manager initialized successfully (server not started)');
  }

  /// デバッグ機能を終了
  Future<void> shutdown() async {
    if (!_initialized) return;

    logInfo(LogCategory.debug, 'Shutting down debug manager...');

    await _debugServer.stop();
    _performanceMonitor.setEnabled(false);

    _initialized = false;
    logInfo(LogCategory.debug, 'Debug manager shut down');
  }

  /// デバッグサーバーの状態を取得
  bool get isServerRunning => _debugServer.isRunning;

  /// デバッグサーバーのURLを取得
  String get serverUrl => _debugServer.url;

  /// デバッグサーバーのポートを取得
  int get serverPort => _debugServer.port;

  /// 構造化ログを記録
  void logStructured({
    required LogCategory category,
    required String level,
    required String message,
    Map<String, dynamic>? context,
    Map<String, dynamic>? data,
    StackTrace? stackTrace,
  }) {
    _structuredLogger.log(
      category: category,
      level: level,
      message: message,
      context: context,
      data: data,
      stackTrace: stackTrace,
    );
  }

  /// パフォーマンス測定を開始
  void startPerformanceMeasurement(String operationName,
      {Map<String, dynamic>? metadata}) {
    _performanceMonitor.startOperation(operationName, metadata: metadata);
  }

  /// パフォーマンス測定を終了
  void endPerformanceMeasurement(String operationName,
      {Map<String, dynamic>? metadata}) {
    _performanceMonitor.endOperation(operationName, metadata: metadata);
  }

  /// パフォーマンス測定（同期）
  T measurePerformance<T>(
    String operationName,
    T Function() operation, {
    Map<String, dynamic>? metadata,
  }) {
    return _performanceMonitor.measureOperation(operationName, operation,
        metadata: metadata);
  }

  /// パフォーマンス測定（非同期）
  Future<T> measurePerformanceAsync<T>(
    String operationName,
    Future<T> Function() operation, {
    Map<String, dynamic>? metadata,
  }) {
    return _performanceMonitor.measureOperationAsync(operationName, operation,
        metadata: metadata);
  }

  /// グラフの状態をデバッグサーバーにブロードキャスト
  void broadcastGraphState(Map<String, dynamic> state) {
    if (_debugServer.isRunning) {
      _debugServer.broadcastGraphState(state);
    }
  }

  /// デバッグレポートを生成
  Map<String, dynamic> generateDebugReport() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'debug_manager': {
        'initialized': _initialized,
        'server_running': _debugServer.isRunning,
        'server_url': _debugServer.isRunning ? _debugServer.url : null,
      },
      'structured_logs': {
        'total_entries': _structuredLogger.getAllEntries().length,
        'categories': _structuredLogger
            .getAllEntries()
            .map((e) => e.category.name)
            .toSet()
            .toList(),
      },
      'performance': _performanceMonitor.exportAsJson(),
    };
  }

  /// デバッグ情報をクリア
  void clearDebugData() {
    _structuredLogger.clear();
    _performanceMonitor.clear();
    logInfo(LogCategory.debug, 'Debug data cleared');
  }

  /// デバッグ設定を取得
  Map<String, dynamic> getDebugSettings() {
    return {
      'initialized': _initialized,
      'server_enabled': _debugServer.isRunning,
      'server_port': _debugServer.port,
      'performance_monitoring': _performanceMonitor.isEnabled,
    };
  }

  /// デバッグ設定を更新
  Future<void> updateDebugSettings({
    bool? enableServer,
    bool? enablePerformanceMonitoring,
    int? serverPort,
  }) async {
    if (enableServer != null) {
      if (enableServer && !_debugServer.isRunning) {
        await _debugServer.start(port: serverPort ?? _debugServer.port);
      } else if (!enableServer && _debugServer.isRunning) {
        await _debugServer.stop();
      }
    }

    if (enablePerformanceMonitoring != null) {
      _performanceMonitor.setEnabled(enablePerformanceMonitoring);
    }

    logInfo(LogCategory.debug, 'Debug settings updated');
  }

  /// Hot reload時のクリーンアップ
  void _cleanupForHotReload() {
    try {
      // サーバーを強制停止
      if (_debugServer.isRunning) {
        PloughDebugServer.resetInstance();
      }
      _initialized = false;
    } on Exception {
      // エラーを無視
    }
  }
}

/// グローバルなデバッグマネージャーインスタンス
final PloughDebugManager debugManager = PloughDebugManager();

/// 便利な関数群
@internal
Future<void> initializeDebug({
  bool enableServer = true,
  bool enableStructuredLogging = true,
  bool enablePerformanceMonitoring = true,
  int serverPort = 8080,
  bool tryAlternativePorts = true,
}) {
  return debugManager.initialize(
    enableServer: enableServer,
    enableStructuredLogging: enableStructuredLogging,
    enablePerformanceMonitoring: enablePerformanceMonitoring,
    serverPort: serverPort,
    tryAlternativePorts: tryAlternativePorts,
  );
}

@internal
Future<void> shutdownDebug() {
  return debugManager.shutdown();
}

@internal
void logDebugStructuredGlobal({
  required LogCategory category,
  required String level,
  required String message,
  Map<String, dynamic>? context,
  Map<String, dynamic>? data,
  StackTrace? stackTrace,
}) {
  debugManager.logStructured(
    category: category,
    level: level,
    message: message,
    context: context,
    data: data,
    stackTrace: stackTrace,
  );
}

@internal
void startPerformanceMeasurementGlobal(String operationName,
    {Map<String, dynamic>? metadata}) {
  debugManager.startPerformanceMeasurement(operationName, metadata: metadata);
}

@internal
void endPerformanceMeasurementGlobal(String operationName,
    {Map<String, dynamic>? metadata}) {
  debugManager.endPerformanceMeasurement(operationName, metadata: metadata);
}

@internal
T measurePerformanceGlobal<T>(
  String operationName,
  T Function() operation, {
  Map<String, dynamic>? metadata,
}) {
  return debugManager.measurePerformance(operationName, operation,
      metadata: metadata);
}

@internal
Future<T> measurePerformanceAsyncGlobal<T>(
  String operationName,
  Future<T> Function() operation, {
  Map<String, dynamic>? metadata,
}) {
  return debugManager.measurePerformanceAsync(operationName, operation,
      metadata: metadata);
}

@internal
void broadcastGraphStateGlobal(Map<String, dynamic> state) {
  debugManager.broadcastGraphState(state);
}
