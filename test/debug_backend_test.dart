// B2-b (stage 2-2) regression: the Plough singleton routes advanced debug
// features (server lifecycle / report) through the injectable `debugBackend`
// rather than referencing PloughDebugManager directly.
//
// This guards the injection point that B2-b relies on to relocate the
// dart:io/http implementation into a separate package and default to a no-op.
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/debug/debug_backend.dart';

/// Records calls and returns canned values so the test can assert routing.
class _RecordingDebugBackend implements DebugBackend {
  int initializeCount = 0;
  int shutdownCount = 0;
  bool reportGenerated = false;
  bool serverRunning = false;
  String? url;
  int? port;

  @override
  Future<void> initialize({
    bool enableServer = true,
    bool enableStructuredLogging = true,
    bool enablePerformanceMonitoring = true,
    int serverPort = 8080,
    bool tryAlternativePorts = true,
  }) async {
    initializeCount++;
  }

  @override
  Future<void> shutdown() async {
    shutdownCount++;
  }

  @override
  bool get isServerRunning => serverRunning;

  @override
  String? get serverUrl => url;

  @override
  int? get serverPort => port;

  @override
  Map<String, dynamic> generateDebugReport() {
    reportGenerated = true;
    return {'ok': true};
  }
}

void main() {
  late DebugBackend original;

  setUp(() {
    original = debugBackend;
  });

  tearDown(() {
    debugBackend = original;
  });

  test('default backend is the debug-manager adapter', () {
    expect(debugBackend, isA<DebugManagerBackend>());
  });

  test('generateDebugReport routes to the injected backend', () {
    final backend = _RecordingDebugBackend();
    debugBackend = backend;

    final report = Plough().generateDebugReport();

    expect(backend.reportGenerated, isTrue);
    expect(report, {'ok': true});
  });

  test('debugServerUrl reflects the injected backend', () {
    final backend = _RecordingDebugBackend()..url = 'http://localhost:9999';
    debugBackend = backend;

    expect(Plough().debugServerUrl, 'http://localhost:9999');
  });

  test('debugAdvancedEnabled toggles initialize/shutdown on the backend', () {
    final backend = _RecordingDebugBackend();
    debugBackend = backend;

    Plough().debugAdvancedEnabled = true;
    expect(backend.initializeCount, 1);

    Plough().debugAdvancedEnabled = false;
    expect(backend.shutdownCount, 1);
  });
}
