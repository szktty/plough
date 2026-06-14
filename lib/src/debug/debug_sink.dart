import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plough/src/debug/external_debug_client.dart';
import 'package:plough/src/utils/logger.dart';

/// Sink for debug log telemetry.
///
/// This is the single injection point the package core knows about for sending
/// structured logs to a debug backend. The core never references the concrete
/// HTTP/server implementation directly; it talks to a [DebugSink].
///
/// The default sink ([defaultDebugSink]) forwards to the in-package
/// [ExternalDebugClient], preserving existing behavior. A later step (B2-b)
/// moves that implementation into a separate `plough_devtools` package and
/// swaps the default to a no-op, making the core web-safe and dependency-light.
///
/// See `doc/b2_debug_separation_design.md` for the full plan.
@internal
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

/// Default [DebugSink] that forwards to the in-package [ExternalDebugClient].
///
/// Behavior is identical to calling `externalDebugClient` directly; this only
/// routes the call through the [DebugSink] interface so the dependency can be
/// relocated later without touching call sites.
@internal
class ExternalClientDebugSink implements DebugSink {
  const ExternalClientDebugSink();

  @override
  bool get enabled => externalDebugClient.enabled;

  @override
  void sendLog({
    required LogCategory category,
    required String level,
    required String message,
    Map<String, dynamic>? metadata,
  }) {
    externalDebugClient.sendLog(
      category: category,
      level: level,
      message: message,
      metadata: metadata,
    );
  }
}

/// The active debug sink used by the package core.
///
/// Defaults to [ExternalClientDebugSink] (existing behavior). B2-b will allow
/// swapping this via `Plough().attachDebugSink(...)` and default it to a no-op.
@internal
DebugSink debugSink = const ExternalClientDebugSink();
