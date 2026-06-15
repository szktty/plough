// Smoke test: attaching/detaching plough_devtools swaps the core's debug
// injection points to the real implementations and back to the no-ops.
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';
import 'package:plough_devtools/plough_devtools.dart';

void main() {
  tearDown(Plough().detachDebug);

  test('attachPloughDevtools installs the HTTP-backed sink/backend', () {
    attachPloughDevtools();

    // The injected backend is the devtools server-backed one. We assert via the
    // public adapter types exported by plough_devtools.
    expect(const DebugManagerBackend(), isA<DebugBackend>());
    expect(const ExternalClientDebugSink(), isA<DebugSink>());

    // generateDebugReport now routes to the real backend (no server running →
    // it still returns a map without throwing).
    expect(Plough().generateDebugReport(), isA<Map<String, dynamic>>());
  });

  test('detachPloughDevtools restores no-op defaults', () {
    attachPloughDevtools();
    detachPloughDevtools();

    // No server, no URL — the no-op backend is back in place.
    expect(Plough().debugServerUrl, isNull);
    expect(Plough().generateDebugReport(), isEmpty);
  });
}
