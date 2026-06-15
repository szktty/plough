import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plough/src/utils/logger.dart';

/// Sink for debug log telemetry.
///
/// This is the single injection point the package core knows about for sending
/// structured logs to a debug backend. The core never references the concrete
/// HTTP/server implementation directly; it talks to a [DebugSink].
///
/// The default sink ([debugSink]) is a [NoopDebugSink] — web-safe and
/// dependency-free. The real HTTP implementation lives in the separate
/// `plough_devtools` package; attach it at runtime via the `debugSink`
/// injection point (e.g. from `plough_devtools`'s setup) so the core stays
/// free of `dart:io`/`http`.
///
/// See `doc/b2_debug_separation_design.md` for the full plan.
///
/// Implemented by `plough_devtools` and injected via
/// `Plough().attachDebugSink(...)`.
abstract interface class DebugSink {
  /// Whether the sink is actively forwarding logs.
  ///
  /// Callers should guard on this before building per-call payloads so disabled
  /// sessions pay nothing for log construction.
  bool get enabled;

  /// Forwards a single structured log entry to the debug backend.
  ///
  /// Implementations that are disabled must make this a cheap no-op.
  void sendLog({
    required LogCategory category,
    required String level,
    required String message,
    Map<String, dynamic>? metadata,
  });
}

/// Default [DebugSink]: a web-safe no-op that forwards nothing.
///
/// Active unless `plough_devtools` (or a custom implementation) replaces
/// the sink with a real one.
class NoopDebugSink implements DebugSink {
  const NoopDebugSink();

  @override
  bool get enabled => false;

  @override
  void sendLog({
    required LogCategory category,
    required String level,
    required String message,
    Map<String, dynamic>? metadata,
  }) {}
}

/// The active debug sink used by the package core.
///
/// Defaults to [NoopDebugSink]. `plough_devtools` swaps in an HTTP-backed sink
/// when debug features are enabled.
@internal
DebugSink debugSink = const NoopDebugSink();
