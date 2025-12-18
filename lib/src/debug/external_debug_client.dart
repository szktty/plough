import 'dart:async';
import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:plough/src/utils/logger.dart';

/// Client that sends logs to external debug server
@internal
class ExternalDebugClient {
  factory ExternalDebugClient() => _instance ??= ExternalDebugClient._();
  ExternalDebugClient._();

  static ExternalDebugClient? _instance;

  String _serverUrl = 'http://localhost:8082';
  bool _enabled = false;
  Timer? _batchTimer;
  final List<Map<String, dynamic>> _logQueue = [];
  static const int _batchSize = 10;
  static const Duration _batchInterval = Duration(milliseconds: 500);

  /// Set server URL
  void setServerUrl(String url) {
    _serverUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  /// Enable sending to external debug server
  void enable({String? serverUrl}) {
    if (serverUrl != null) {
      _serverUrl = serverUrl;
    }
    _enabled = true;
    _startBatchTimer();
    logInfo(LogCategory.debug, 'External debug client enabled: $_serverUrl');
  }

  /// Disable sending to external debug server
  void disable() {
    _enabled = false;
    _stopBatchTimer();
    _flushLogs(); // Send remaining logs
    logInfo(LogCategory.debug, 'External debug client disabled');
  }

  /// Send log (batching)
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

    // Send immediately if queue grows large
    if (_logQueue.length >= _batchSize) {
      _flushLogs();
    }
  }

  /// Starts the batch timer
  void _startBatchTimer() {
    _stopBatchTimer();
    _batchTimer = Timer.periodic(_batchInterval, (_) {
      if (_logQueue.isNotEmpty) {
        _flushLogs();
      }
    });
  }

  /// Stops the batch timer
  void _stopBatchTimer() {
    _batchTimer?.cancel();
    _batchTimer = null;
  }

  /// Sends accumulated logs
  Future<void> _flushLogs() async {
    if (_logQueue.isEmpty) return;

    // Copy and clear the queue immediately (to avoid concurrency issues)
    final logsToSend = List<Map<String, dynamic>>.from(_logQueue);
    _logQueue.clear();

    try {
      final response = await http
          .post(
            Uri.parse('$_serverUrl/api/logs/batch'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'logs': logsToSend}),
          )
          .timeout(const Duration(seconds: 2));

      if (response.statusCode != 200) {
        // Print to console on error (to avoid infinite loop)
        print(
          '[ExternalDebugClient] Failed to send logs: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Print network errors etc. to console
      print('[ExternalDebugClient] Error sending logs: $e');
    }
  }

  /// Tests server connection
  Future<bool> testConnection() async {
    try {
      final response = await http
          .get(Uri.parse('$_serverUrl/api/status'))
          .timeout(const Duration(seconds: 2));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Gets server information
  Future<Map<String, dynamic>?> getServerInfo() async {
    try {
      final response = await http
          .get(Uri.parse('$_serverUrl/api/status'))
          .timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      // Ignore errors
    }
    return null;
  }
}

/// Global instance
final externalDebugClient = ExternalDebugClient();
