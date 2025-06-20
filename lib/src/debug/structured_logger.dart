import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plough/src/utils/logger.dart';
import 'package:plough/src/debug/debug_server.dart';

/// Structured log entry
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

/// Class that provides structured logging functionality
@internal
class StructuredLogger {
  StructuredLogger._();

  static StructuredLogger? _instance;
  factory StructuredLogger() => _instance ??= StructuredLogger._();

  final List<StructuredLogEntry> _entries = [];
  final int _maxEntries = 10000;

  /// Add log entry
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

    // Normal log output
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

    // Broadcast to monitoring server
    final monitorServer = PloughMonitorServer();
    if (monitorServer.isRunning) {
      monitorServer.broadcastLog(category, level, message);
    }
  }

  /// Debug level log
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

  /// Info level log
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

  /// Warning level log
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

  /// Error level log
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

  /// Get all log entries
  List<StructuredLogEntry> getAllEntries() => List.unmodifiable(_entries);

  /// Filter by category
  List<StructuredLogEntry> getEntriesByCategory(LogCategory category) {
    return _entries.where((entry) => entry.category == category).toList();
  }

  /// Filter by level
  List<StructuredLogEntry> getEntriesByLevel(String level) {
    return _entries.where((entry) => entry.level == level).toList();
  }

  /// Filter by time range
  List<StructuredLogEntry> getEntriesByTimeRange(DateTime start, DateTime end) {
    return _entries
        .where((entry) =>
            entry.timestamp.isAfter(start) && entry.timestamp.isBefore(end))
        .toList();
  }

  /// Export logs as JSON
  String exportAsJson() {
    return jsonEncode(_entries.map((entry) => entry.toJson()).toList());
  }

  /// Clear logs
  void clear() {
    _entries.clear();
  }
}

/// Global structured log instance
final StructuredLogger structuredLogger = StructuredLogger();

/// Convenience functions
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
