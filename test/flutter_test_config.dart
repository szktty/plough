import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Test with fixed size (improves golden test stability)
  final binding = TestWidgetsFlutterBinding.instance;
  binding.window.physicalSizeTestValue = const ui.Size(800, 600);
  binding.window.devicePixelRatioTestValue = 2.0;

  // Load fonts to suppress differences in text rendering
  await loadAppFonts();

  // Note: We intentionally do not reset the window size here because
  // addTearDown cannot be used outside of tests. The fixed size is safe
  // for our test suite.
  await testMain();
}
