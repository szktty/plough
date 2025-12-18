import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';
import 'package:plough/src/debug/external_debug_client.dart';

/// Logger categories for selective logging control
enum LogCategory {
  gesture,
  selection,
  drag,
  tap,
  layout,
  rendering,
  graph,
  performance,
  debug,
  state,
  animation,
  hitTest,
}

/// Centralized logging configuration
@internal
class PloughLogger {
  factory PloughLogger() => _instance ??= PloughLogger._();
  PloughLogger._();

  static PloughLogger? _instance;

  final Map<LogCategory, Logger> _loggers = {};
  final Map<LogCategory, Level> _levels = {};

  /// Configure log levels for different categories
  void configure({
    Level defaultLevel = Level.off,
    Map<LogCategory, Level>? categoryLevels,
  }) {
    _levels.clear();
    _loggers.clear();

    for (final category in LogCategory.values) {
      final level = categoryLevels?[category] ?? defaultLevel;
      _levels[category] = level;
      _loggers[category] = _createLogger(level, category);
    }
  }

  Logger _createLogger(Level level, LogCategory category) {
    return Logger(printer: _SimplePrinter(category), level: level);
  }

  /// Get logger for specific category
  Logger getLogger(LogCategory category) {
    return _loggers[category] ?? _createLogger(Level.off, category);
  }

  /// Quick logging methods
  void d(LogCategory category, String message) {
    getLogger(category).d(message);
    _sendToExternalDebug(category, 'DEBUG', message);
  }

  void i(LogCategory category, String message) {
    getLogger(category).i(message);
    _sendToExternalDebug(category, 'INFO', message);
  }

  void w(LogCategory category, String message) {
    getLogger(category).w(message);
    _sendToExternalDebug(category, 'WARNING', message);
  }

  void e(LogCategory category, String message) {
    getLogger(category).e(message);
    _sendToExternalDebug(category, 'ERROR', message);
  }

  /// Sends logs to external debug server
  void _sendToExternalDebug(
    LogCategory category,
    String level,
    String message,
  ) {
    try {
      externalDebugClient.sendLog(
        category: category,
        level: level,
        message: message,
      );
    } catch (_) {
      // Ignore errors (app continues even if logging system fails)
    }
  }
}

/// Global logger instance
final PloughLogger _logger = PloughLogger();

/// Internal logging functions - not part of public API
@internal
void logDebug(LogCategory category, String message) =>
    _logger.d(category, message);
@internal
void logInfo(LogCategory category, String message) =>
    _logger.i(category, message);
@internal
void logWarning(LogCategory category, String message) =>
    _logger.w(category, message);
@internal
void logError(LogCategory category, String message) =>
    _logger.e(category, message);

/// Configure logging for the entire package
@internal
void configureLogging({
  Level defaultLevel = Level.off,
  Map<LogCategory, Level>? categoryLevels,
}) {
  _logger.configure(defaultLevel: defaultLevel, categoryLevels: categoryLevels);
}

/// Legacy support - gradually replace these
@Deprecated('Use logDebug with LogCategory instead')
Logger log = Logger(level: Level.off);

/// Simple printer that outputs clean, timestamped logs
class _SimplePrinter extends LogPrinter {
  _SimplePrinter(this.category);

  final LogCategory category;

  @override
  List<String> log(LogEvent event) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    final level = event.level.name.toUpperCase();
    final categoryName = category.name.toUpperCase();
    return ['$timestamp [$level] [$categoryName] ${event.message}'];
  }
}

@Deprecated('Use configureLogging instead')
void setLogLevel(Level level) {
  log = Logger(level: level);
}
