import 'package:logger/logger.dart';
import 'package:plough/src/utils/logger.dart';
import 'package:plough/src/utils/widget/position_plotter.dart';

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
      configureLogging(defaultLevel: Level.off);
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
      configureLogging(
        defaultLevel: Level.off,
        categoryLevels: _enabledLogCategories,
      );
    }
    return this;
  }

  /// Enable all log categories with debug level.
  Plough enableAllLogCategories([Level level = Level.debug]) {
    _enabledLogCategories = {
      for (final cat in LogCategory.values) cat: level
    };
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
      configureLogging(defaultLevel: Level.off);
    }
    return this;
  }
}
