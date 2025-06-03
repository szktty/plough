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
    setLogLevel(enabled ? Level.debug : Level.off);
  }

  bool _debugLogEnabled = false;

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
}
