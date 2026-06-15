/// Debug tooling for the Plough graph package.
///
/// `plough` (the core package) is web-safe and free of `dart:io`/`http`. The
/// heavyweight debug stack — an HTTP debug server, an external log client,
/// structured logging, performance monitoring and diagnostics — lives here.
///
/// Call [attachPloughDevtools] once at startup (before enabling debug features)
/// to wire this implementation into the core's injection points. Call
/// [detachPloughDevtools] to restore the no-op defaults.
///
/// ```dart
/// import 'package:plough_devtools/plough_devtools.dart';
///
/// void main() {
///   attachPloughDevtools();
///   Plough().initializeDebugFeatures();
///   runApp(const MyApp());
/// }
/// ```
library;

import 'package:plough/plough.dart';
import 'package:plough_devtools/src/debug_manager_backend.dart';
import 'package:plough_devtools/src/external_client_debug_sink.dart';

// The debug implementation classes/functions moved from `plough` retain their
// `@internal` annotation, so they are not re-exported here (doing so trips
// `invalid_export_of_internal_element`). The public surface of plough_devtools
// is the attach/detach setup below plus the two adapter classes; everything
// else is reached through `Plough()`'s existing debug API once attached.
export 'package:plough_devtools/src/debug_manager_backend.dart'
    show DebugManagerBackend;
export 'package:plough_devtools/src/external_client_debug_sink.dart'
    show ExternalClientDebugSink;

/// Wires the devtools implementations into the core's debug injection points.
///
/// After this call, `Plough().initializeDebugFeatures()` starts the real HTTP
/// debug server and structured logs flow to the external client.
void attachPloughDevtools() {
  Plough()
    ..attachDebugSink(const ExternalClientDebugSink())
    ..attachDebugBackend(const DebugManagerBackend());
}

/// Restores the core's no-op debug defaults.
void detachPloughDevtools() {
  Plough().detachDebug();
}
