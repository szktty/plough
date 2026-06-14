import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plough/src/debug/debug_manager.dart';

/// Backend for advanced debug features (HTTP server, structured logging,
/// performance monitoring).
///
/// This is the single injection point the package core ([Plough]) knows about
/// for the heavyweight debug server stack. The core never references the
/// concrete `dart:io`/`http` implementation directly; it talks to a
/// [DebugBackend].
///
/// The default backend ([debugBackend]) forwards to the in-package
/// [PloughDebugManager], preserving existing behavior. A later step (B2-b)
/// moves that implementation into a separate `plough_devtools` package and
/// swaps the default to a no-op, making the core web-safe and
/// dependency-light.
///
/// See `doc/b2_debug_separation_design.md` for the full plan. This complements
/// [DebugSink] (log telemetry); [DebugBackend] covers server lifecycle and
/// reporting.
@internal
abstract interface class DebugBackend {
  /// Starts the configured debug features.
  Future<void> initialize({
    bool enableServer,
    bool enableStructuredLogging,
    bool enablePerformanceMonitoring,
    int serverPort,
    bool tryAlternativePorts,
  });

  /// Stops all debug features.
  Future<void> shutdown();

  /// Whether the debug HTTP server is currently running.
  bool get isServerRunning;

  /// The running server's URL, or null when not running.
  String? get serverUrl;

  /// The running server's port, or null when not running.
  int? get serverPort;

  /// Builds a comprehensive debug report snapshot.
  Map<String, dynamic> generateDebugReport();
}

/// Default [DebugBackend] forwarding to the in-package [PloughDebugManager].
///
/// Behavior is identical to calling `debugManager`/`initializeDebug`/
/// `shutdownDebug` directly; this only routes through the [DebugBackend]
/// interface so the dependency can be relocated later without touching
/// [Plough].
@internal
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

/// The active debug backend used by the package core.
///
/// Defaults to [DebugManagerBackend] (existing behavior). B2-b will allow
/// swapping this via `Plough().attachDebugBackend(...)` and default it to a
/// no-op so the core no longer depends on `dart:io`/`http`.
@internal
DebugBackend debugBackend = const DebugManagerBackend();
