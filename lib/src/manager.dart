import 'package:logger/logger.dart';
import 'package:plough/src/debug/debug_manager.dart';
import 'package:plough/src/utils/logger.dart';
import 'package:plough/src/utils/widget/position_plotter.dart';

// ignore_for_file: avoid_return_this

/// Singleton class that manages the global settings of the Plough library.
final class Plough {
  factory Plough() => _instance;

  Plough._() {
    debugViewEnabled = false;
    debugSignalsEnabled = false;
  }

  static final _instance = Plough._();

  /// Controls the output of debug logs.
  bool get debugLogEnabled => _debugLogEnabled;

  set debugLogEnabled(bool enabled) {
    _debugLogEnabled = enabled;
    if (enabled) {
      configureLogging(
        defaultLevel: Level.debug,
        categoryLevels: _enabledLogCategories.isEmpty
            ? {for (final cat in LogCategory.values) cat: Level.debug}
            : _enabledLogCategories,
      );
    } else {
      configureLogging();
    }
  }

  bool _debugLogEnabled = false;
  Map<LogCategory, Level> _enabledLogCategories = {};

  /// Controls debug drawing in the graph view.
  ///
  /// When set to true, the following information is displayed in the graph view:
  ///
  /// * Bounding boxes of nodes and links
  /// * Built-in grid lines
  /// * Points indicating logical positions of nodes
  /// * Calculation points for connection lines
  bool get debugViewEnabled => _debugViewEnabled;

  bool _debugViewEnabled = false;

  set debugViewEnabled(bool enabled) {
    _debugViewEnabled = enabled;
    GraphPositionPlotter.enabled = enabled;
  }

  /// Controls the output of debug information related to state management within the graph view.
  ///
  /// When set to true, the following state changes are logged:
  ///
  /// * Changes in graph data structure
  /// * Updates to node and link properties
  /// * Changes in layout state
  /// * Changes in selection state
  bool get debugSignalsEnabled => _debugSignalsEnabled;

  bool _debugSignalsEnabled = false;

  set debugSignalsEnabled(bool enabled) {
    _debugSignalsEnabled = enabled;
    // Note: signalsDevToolsEnabled is no longer available since we removed signals
  }

  /// Enable logging for specific categories.
  ///
  /// Example:
  /// ```dart
  /// Plough()
  ///   ..enableLogCategories({
  ///     LogCategory.gesture: Level.debug,
  ///     LogCategory.layout: Level.info,
  ///   })
  ///   ..debugLogEnabled = true;
  /// ```
  Plough enableLogCategories(Map<LogCategory, Level> categories) {
    _enabledLogCategories = Map.from(categories);
    if (_debugLogEnabled) {
      configureLogging(categoryLevels: _enabledLogCategories);
    }
    return this;
  }

  /// Enable all log categories with debug level.
  Plough enableAllLogCategories([Level level = Level.debug]) {
    _enabledLogCategories = {for (final cat in LogCategory.values) cat: level};
    if (_debugLogEnabled) {
      configureLogging(
        defaultLevel: level,
        categoryLevels: _enabledLogCategories,
      );
    }
    return this;
  }

  /// Clear all log category configurations.
  Plough clearLogCategories() {
    _enabledLogCategories.clear();
    if (_debugLogEnabled) {
      configureLogging();
    }
    return this;
  }

  /// Controls advanced debug features including debug server and performance monitoring.
  ///
  /// When set to true, the following features are enabled:
  ///
  /// * Debug HTTP server for real-time log monitoring
  /// * Structured logging with context and metadata
  /// * Performance monitoring and profiling
  /// * Web-based debug console
  bool get debugAdvancedEnabled => _debugAdvancedEnabled;

  bool _debugAdvancedEnabled = false;

  set debugAdvancedEnabled(bool enabled) {
    _debugAdvancedEnabled = enabled;
    if (enabled) {
      initializeDebug();
    } else {
      shutdownDebug();
    }
  }

  /// Initialize debug features with custom settings.
  ///
  /// Example:
  /// ```dart
  /// Plough().initializeDebugFeatures(
  ///   enableServer: true,
  ///   enablePerformanceMonitoring: true,
  ///   serverPort: 8080,
  /// );
  /// ```
  Future<void> initializeDebugFeatures({
    bool enableServer = true,
    bool enableStructuredLogging = true,
    bool enablePerformanceMonitoring = true,
    int serverPort = 8080,
    bool tryAlternativePorts = true,
  }) async {
    logInfo(LogCategory.debug, 'Initializing Plough debug features...');

    await initializeDebug(
      enableServer: enableServer,
      enableStructuredLogging: enableStructuredLogging,
      enablePerformanceMonitoring: enablePerformanceMonitoring,
      serverPort: serverPort,
      tryAlternativePorts: tryAlternativePorts,
    );
    _debugAdvancedEnabled = true;

    // Display URL if debug server started
    if (enableServer) {
      if (debugManager.isServerRunning) {
        logInfo(
          LogCategory.debug,
          '🌐 Debug server is running at: ${debugManager.serverUrl}',
        );
        logInfo(
          LogCategory.debug,
          '💡 Open the URL in your browser to access the debug console',
        );
        logInfo(
          LogCategory.debug,
          '🔧 Use CLI tools: python3 debug/simple_cli.py recent --category gesture',
        );
        if (debugManager.serverPort != serverPort) {
          logInfo(
            LogCategory.debug,
            'ℹ️ Server started on alternative port ${debugManager.serverPort}',
          );
        }
      } else {
        logWarning(
          LogCategory.debug,
          '⚠️ Debug server failed to start. Check if port $serverPort is available.',
        );
        logInfo(
          LogCategory.debug,
          '💡 You can still use basic logging features',
        );
      }
    }

    logInfo(
      LogCategory.debug,
      'Plough debug features initialized successfully',
    );
  }

  /// Shutdown all debug features.
  Future<void> shutdownDebugFeatures() async {
    logInfo(LogCategory.debug, 'Shutting down Plough debug features...');
    await shutdownDebug();
    _debugAdvancedEnabled = false;
    logInfo(LogCategory.debug, 'Plough debug features shut down successfully');
  }

  /// Get debug server URL if running.
  String? get debugServerUrl {
    return debugManager.isServerRunning ? debugManager.serverUrl : null;
  }

  /// Generate comprehensive debug report.
  Map<String, dynamic> generateDebugReport() {
    return debugManager.generateDebugReport();
  }
}
