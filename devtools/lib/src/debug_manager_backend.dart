import 'package:plough/plough.dart';
import 'package:plough_devtools/src/debug_manager.dart';

/// [DebugBackend] implementation backed by the `dart:io` HTTP debug server via
/// [PloughDebugManager].
///
/// Lives in `plough_devtools` so the `dart:io` dependency stays out of the core
/// package. Attach it via [debugBackend] (see `attachPloughDevtools`).
class DebugManagerBackend implements DebugBackend {
  const DebugManagerBackend();

  @override
  Future<void> initialize({
    bool enableServer = true,
    bool enableStructuredLogging = true,
    bool enablePerformanceMonitoring = true,
    int serverPort = 8080,
    bool tryAlternativePorts = true,
  }) {
    return initializeDebug(
      enableServer: enableServer,
      enableStructuredLogging: enableStructuredLogging,
      enablePerformanceMonitoring: enablePerformanceMonitoring,
      serverPort: serverPort,
      tryAlternativePorts: tryAlternativePorts,
    );
  }

  @override
  Future<void> shutdown() => shutdownDebug();

  @override
  bool get isServerRunning => debugManager.isServerRunning;

  @override
  String? get serverUrl =>
      debugManager.isServerRunning ? debugManager.serverUrl : null;

  @override
  int? get serverPort =>
      debugManager.isServerRunning ? debugManager.serverPort : null;

  @override
  Map<String, dynamic> generateDebugReport() =>
      debugManager.generateDebugReport();
}
