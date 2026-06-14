import 'package:plough/plough.dart';
import 'package:plough_devtools/src/external_debug_client.dart';

/// [DebugSink] implementation that forwards to the HTTP-backed
/// [ExternalDebugClient].
///
/// Lives in `plough_devtools` so the `http` dependency stays out of the core
/// package. Attach it via [debugSink] (see `attachPloughDevtools`).
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
