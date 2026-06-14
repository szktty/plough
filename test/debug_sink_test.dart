// B2-a regression: the package core routes structured debug logs through the
// injectable `debugSink` rather than referencing ExternalDebugClient directly.
//
// This guards the injection point introduced for B2: a custom DebugSink swapped
// in via `debugSink` must receive the logs that the logger emits. B2-b relies
// on this to relocate the concrete implementation into a separate package.
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart' show Level;
import 'package:plough/src/debug/debug_sink.dart';
import 'package:plough/src/utils/logger.dart';

/// Records the calls it receives so the test can assert on them.
class _RecordingDebugSink implements DebugSink {
  bool sinkEnabled = true;
  final List<
      ({
        LogCategory category,
        String level,
        String message,
        Map<String, dynamic>? metadata,
      })> calls = [];

  @override
  bool get enabled => sinkEnabled;

  @override
  void sendLog({
    required LogCategory category,
    required String level,
    required String message,
    Map<String, dynamic>? metadata,
  }) {
    calls.add(
      (
        category: category,
        level: level,
        message: message,
        metadata: metadata,
      ),
    );
  }
}

void main() {
  late DebugSink original;

  setUp(() {
    original = debugSink;
    // Logging is gated by category level; enable the category under test.
    configureLogging(categoryLevels: {LogCategory.debug: Level.debug});
  });

  tearDown(() {
    debugSink = original;
    configureLogging();
  });

  test('logger forwards to the injected debug sink', () {
    final sink = _RecordingDebugSink();
    debugSink = sink;

    logDebug(LogCategory.debug, 'hello sink');

    expect(sink.calls, hasLength(1));
    expect(sink.calls.single.category, LogCategory.debug);
    expect(sink.calls.single.level, 'DEBUG');
    expect(sink.calls.single.message, 'hello sink');
  });

  test('disabled sink receives nothing (enabled guard short-circuits)', () {
    final sink = _RecordingDebugSink()..sinkEnabled = false;
    debugSink = sink;

    logDebug(LogCategory.debug, 'should be dropped');

    expect(sink.calls, isEmpty);
  });

  test('default sink is the external-client adapter', () {
    expect(debugSink, isA<ExternalClientDebugSink>());
  });

  test('sendLog carries metadata through to the sink', () {
    // gesture_manager passes a `metadata:` map on every call; guard that the
    // DebugSink contract preserves it (regression net for B2-b sink swaps).
    final sink = _RecordingDebugSink();
    debugSink = sink;

    debugSink.sendLog(
      category: LogCategory.gesture,
      level: 'INFO',
      message: 'with metadata',
      metadata: {'x': 1.0, 'y': 2.0},
    );

    expect(sink.calls, hasLength(1));
    expect(sink.calls.single.metadata, {'x': 1.0, 'y': 2.0});
  });
}
