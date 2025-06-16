import 'dart:async';
import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:plough/src/utils/logger.dart';

/// 外部デバッグサーバーへログを送信するクライアント
@internal
class ExternalDebugClient {
  ExternalDebugClient._();

  factory ExternalDebugClient() => _instance ??= ExternalDebugClient._();

  static ExternalDebugClient? _instance;

  String _serverUrl = 'http://localhost:8082';
  bool _enabled = false;
  Timer? _batchTimer;
  final List<Map<String, dynamic>> _logQueue = [];
  static const int _batchSize = 10;
  static const Duration _batchInterval = Duration(milliseconds: 500);

  /// サーバーURLを設定
  void setServerUrl(String url) {
    _serverUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  /// 外部デバッグサーバーへの送信を有効化
  void enable({String? serverUrl}) {
    if (serverUrl != null) {
      _serverUrl = serverUrl;
    }
    _enabled = true;
    _startBatchTimer();
    logInfo(LogCategory.debug, 'External debug client enabled: $_serverUrl');
  }

  /// 外部デバッグサーバーへの送信を無効化
  void disable() {
    _enabled = false;
    _stopBatchTimer();
    _flushLogs(); // 残っているログを送信
    logInfo(LogCategory.debug, 'External debug client disabled');
  }

  /// ログを送信（バッチング）
  void sendLog({
    required LogCategory category,
    required String level,
    required String message,
    Map<String, dynamic>? metadata,
  }) {
    if (!_enabled) return;

    final logEntry = {
      'timestamp': DateTime.now().toIso8601String(),
      'category': category.name,
      'level': level,
      'message': message,
      if (metadata != null) 'metadata': metadata,
    };

    _logQueue.add(logEntry);

    // キューが大きくなったら即座に送信
    if (_logQueue.length >= _batchSize) {
      _flushLogs();
    }
  }

  /// バッチタイマーを開始
  void _startBatchTimer() {
    _stopBatchTimer();
    _batchTimer = Timer.periodic(_batchInterval, (_) {
      if (_logQueue.isNotEmpty) {
        _flushLogs();
      }
    });
  }

  /// バッチタイマーを停止
  void _stopBatchTimer() {
    _batchTimer?.cancel();
    _batchTimer = null;
  }

  /// 溜まったログを送信
  Future<void> _flushLogs() async {
    if (_logQueue.isEmpty) return;

    // キューをコピーして即座にクリア（並行性の問題を避ける）
    final logsToSend = List<Map<String, dynamic>>.from(_logQueue);
    _logQueue.clear();

    try {
      final response = await http.post(
        Uri.parse('$_serverUrl/api/logs/batch'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'logs': logsToSend}),
      ).timeout(const Duration(seconds: 2));

      if (response.statusCode != 200) {
        // エラーの場合はコンソールに出力（無限ループを避けるため）
        print('[ExternalDebugClient] Failed to send logs: ${response.statusCode}');
      }
    } catch (e) {
      // ネットワークエラーなどはコンソールに出力
      print('[ExternalDebugClient] Error sending logs: $e');
    }
  }

  /// サーバーの接続テスト
  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_serverUrl/api/status'),
      ).timeout(const Duration(seconds: 2));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// サーバー情報を取得
  Future<Map<String, dynamic>?> getServerInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$_serverUrl/api/status'),
      ).timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      // エラーは無視
    }
    return null;
  }
}

/// グローバルインスタンス
final externalDebugClient = ExternalDebugClient();