import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plough/src/utils/logger.dart';
import 'package:plough/src/debug/debug_server.dart';

/// 構造化ログエントリ
@internal
class StructuredLogEntry {
  const StructuredLogEntry({
    required this.category,
    required this.level,
    required this.message,
    required this.timestamp,
    this.context,
    this.data,
    this.stackTrace,
  });

  final LogCategory category;
  final String level;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic>? context;
  final Map<String, dynamic>? data;
  final StackTrace? stackTrace;

  Map<String, dynamic> toJson() {
    return {
      'category': category.name,
      'level': level,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      if (context != null) 'context': context,
      if (data != null) 'data': data,
      if (stackTrace != null) 'stackTrace': stackTrace.toString(),
    };
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('${timestamp.toIso8601String().substring(11, 23)} ');
    buffer.write('[${level.toUpperCase()}] ');
    buffer.write('[${category.name.toUpperCase()}] ');
    buffer.write(message);

    if (context != null && context!.isNotEmpty) {
      buffer.write(' | Context: ${jsonEncode(context)}');
    }

    if (data != null && data!.isNotEmpty) {
      buffer.write(' | Data: ${jsonEncode(data)}');
    }

    return buffer.toString();
  }
}

/// 構造化ログ機能を提供するクラス
@internal
class StructuredLogger {
  StructuredLogger._();

  static StructuredLogger? _instance;
  factory StructuredLogger() => _instance ??= StructuredLogger._();

  final List<StructuredLogEntry> _entries = [];
  final int _maxEntries = 10000;

  /// ログエントリを追加
  void log({
    required LogCategory category,
    required String level,
    required String message,
    Map<String, dynamic>? context,
    Map<String, dynamic>? data,
    StackTrace? stackTrace,
  }) {
    final entry = StructuredLogEntry(
      category: category,
      level: level,
      message: message,
      timestamp: DateTime.now(),
      context: context,
      data: data,
      stackTrace: stackTrace,
    );

    _entries.add(entry);
    if (_entries.length > _maxEntries) {
      _entries.removeAt(0);
    }

    // 通常のログ出力
    switch (level) {
      case 'DEBUG':
        logDebug(category, entry.toString());
      case 'INFO':
        logInfo(category, entry.toString());
      case 'WARNING':
        logWarning(category, entry.toString());
      case 'ERROR':
        logError(category, entry.toString());
      default:
        logDebug(category, entry.toString());
    }

    // デバッグサーバーにブロードキャスト
    final debugServer = PloughDebugServer();
    if (debugServer.isRunning) {
      debugServer.broadcastLog(category, level, message);
    }
  }

  /// デバッグレベルのログ
  void debug(
    LogCategory category,
    String message, {
    Map<String, dynamic>? context,
    Map<String, dynamic>? data,
  }) {
    log(
      category: category,
      level: 'DEBUG',
      message: message,
      context: context,
      data: data,
    );
  }

  /// 情報レベルのログ
  void info(
    LogCategory category,
    String message, {
    Map<String, dynamic>? context,
    Map<String, dynamic>? data,
  }) {
    log(
      category: category,
      level: 'INFO',
      message: message,
      context: context,
      data: data,
    );
  }

  /// 警告レベルのログ
  void warning(
    LogCategory category,
    String message, {
    Map<String, dynamic>? context,
    Map<String, dynamic>? data,
    StackTrace? stackTrace,
  }) {
    log(
      category: category,
      level: 'WARNING',
      message: message,
      context: context,
      data: data,
      stackTrace: stackTrace,
    );
  }

  /// エラーレベルのログ
  void error(
    LogCategory category,
    String message, {
    Map<String, dynamic>? context,
    Map<String, dynamic>? data,
    StackTrace? stackTrace,
  }) {
    log(
      category: category,
      level: 'ERROR',
      message: message,
      context: context,
      data: data,
      stackTrace: stackTrace,
    );
  }

  /// 全ログエントリを取得
  List<StructuredLogEntry> getAllEntries() => List.unmodifiable(_entries);

  /// カテゴリでフィルタリング
  List<StructuredLogEntry> getEntriesByCategory(LogCategory category) {
    return _entries.where((entry) => entry.category == category).toList();
  }

  /// レベルでフィルタリング
  List<StructuredLogEntry> getEntriesByLevel(String level) {
    return _entries.where((entry) => entry.level == level).toList();
  }

  /// 時間範囲でフィルタリング
  List<StructuredLogEntry> getEntriesByTimeRange(DateTime start, DateTime end) {
    return _entries
        .where((entry) =>
            entry.timestamp.isAfter(start) && entry.timestamp.isBefore(end))
        .toList();
  }

  /// ログをJSONで出力
  String exportAsJson() {
    return jsonEncode(_entries.map((entry) => entry.toJson()).toList());
  }

  /// ログをクリア
  void clear() {
    _entries.clear();
  }
}

/// グローバルな構造化ログインスタンス
final StructuredLogger structuredLogger = StructuredLogger();

/// 便利な関数群
@internal
void logStructured({
  required LogCategory category,
  required String level,
  required String message,
  Map<String, dynamic>? context,
  Map<String, dynamic>? data,
  StackTrace? stackTrace,
}) {
  structuredLogger.log(
    category: category,
    level: level,
    message: message,
    context: context,
    data: data,
    stackTrace: stackTrace,
  );
}

@internal
void logDebugStructured(
  LogCategory category,
  String message, {
  Map<String, dynamic>? context,
  Map<String, dynamic>? data,
}) {
  structuredLogger.debug(category, message, context: context, data: data);
}

@internal
void logInfoStructured(
  LogCategory category,
  String message, {
  Map<String, dynamic>? context,
  Map<String, dynamic>? data,
}) {
  structuredLogger.info(category, message, context: context, data: data);
}

@internal
void logWarningStructured(
  LogCategory category,
  String message, {
  Map<String, dynamic>? context,
  Map<String, dynamic>? data,
  StackTrace? stackTrace,
}) {
  structuredLogger.warning(
    category,
    message,
    context: context,
    data: data,
    stackTrace: stackTrace,
  );
}

@internal
void logErrorStructured(
  LogCategory category,
  String message, {
  Map<String, dynamic>? context,
  Map<String, dynamic>? data,
  StackTrace? stackTrace,
}) {
  structuredLogger.error(
    category,
    message,
    context: context,
    data: data,
    stackTrace: stackTrace,
  );
}
