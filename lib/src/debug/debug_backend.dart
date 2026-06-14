import 'package:freezed_annotation/freezed_annotation.dart';

/// Backend for advanced debug features (HTTP server, structured logging,
/// performance monitoring).
///
/// This is the single injection point the package core ([Plough]) knows about
/// for the heavyweight debug server stack. The core never references the
/// concrete `dart:io`/`http` implementation directly; it talks to a
/// [DebugBackend].
///
/// The default backend ([debugBackend]) is a [NoopDebugBackend] — web-safe and
/// dependency-free. The real server stack lives in the separate
/// `plough_devtools` package; attach it at runtime via the `debugBackend`
/// injection point so the core stays free of `dart:io`/`http`.
///
/// See `doc/b2_debug_separation_design.md` for the full plan. This complements
/// [DebugSink] (log telemetry); [DebugBackend] covers server lifecycle and
/// reporting.
///
/// Implemented by `plough_devtools` and injected via
/// `Plough().attachDebugBackend(...)`.
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

/// Default [DebugBackend]: a web-safe no-op with no server.
///
/// Active unless `plough_devtools` (or a custom implementation) replaces
/// the backend with the real server-backed one.
class NoopDebugBackend implements DebugBackend {
  const NoopDebugBackend();

  @override
  Future<void> initialize({
    bool enableServer = true,
    bool enableStructuredLogging = true,
    bool enablePerformanceMonitoring = true,
    int serverPort = 8080,
    bool tryAlternativePorts = true,
  }) async {}

  @override
  Future<void> shutdown() async {}

  @override
  bool get isServerRunning => false;

  @override
  String? get serverUrl => null;

  @override
  int? get serverPort => null;

  @override
  Map<String, dynamic> generateDebugReport() => const {};
}

/// The active debug backend used by the package core.
///
/// Defaults to [NoopDebugBackend]. `plough_devtools` swaps in the real
/// server-backed backend when debug features are enabled.
@internal
DebugBackend debugBackend = const NoopDebugBackend();
