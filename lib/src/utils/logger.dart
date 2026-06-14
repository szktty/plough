import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';
import 'package:plough/src/debug/debug_sink.dart';

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

  /// Whether logging is enabled for [category].
  ///
  /// Used to skip building log messages (string interpolation, map literals,
  /// `DateTime.now()` etc.) on hot paths when the category is disabled.
  /// Mirrors the level the underlying [Logger] was created with; `configure`
  /// has not run yet means everything defaults to [Level.off].
  bool enabled(LogCategory category) {
    final level = _levels[category];
    if (level == null) return false;
    return level != Level.off;
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
    // Guard before calling sendLog so the disabled case pays nothing; sendLog
    // also re-checks internally, but the metadata/log-entry map would otherwise
    // be built on every call regardless.
    if (!debugSink.enabled) return;
    try {
      debugSink.sendLog(
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
///
/// [message] accepts either a [String] (evaluated eagerly by the caller) or a
/// `String Function()` closure. Passing a closure defers message construction
/// until the category is known to be enabled, so hot paths can avoid string
/// interpolation when logging is off; for a disabled category the closure is
/// never invoked. Returns `null` when nothing should be logged.
String? _resolve(LogCategory category, Object message) {
  assert(
    message is String || message is String Function(),
    'log message must be a String or a String Function(), got '
    '${message.runtimeType}',
  );
  if (message is String Function()) {
    return _logger.enabled(category) ? message() : null;
  }
  return message as String;
}

void logDebug(LogCategory category, Object message) {
  final resolved = _resolve(category, message);
  if (resolved != null) _logger.d(category, resolved);
}

void logInfo(LogCategory category, Object message) {
  final resolved = _resolve(category, message);
  if (resolved != null) _logger.i(category, resolved);
}

void logWarning(LogCategory category, Object message) {
  final resolved = _resolve(category, message);
  if (resolved != null) _logger.w(category, resolved);
}

void logError(LogCategory category, Object message) {
  final resolved = _resolve(category, message);
  if (resolved != null) _logger.e(category, resolved);
}

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
