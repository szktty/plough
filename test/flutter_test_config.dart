import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // 固定サイズでテスト（ゴールデンの安定性向上）
  final binding = TestWidgetsFlutterBinding.instance;
  binding.window.physicalSizeTestValue = const ui.Size(800, 600);
  binding.window.devicePixelRatioTestValue = 2.0;

  // Note: We intentionally do not reset the window size here because
  // addTearDown cannot be used outside of tests. The fixed size is safe
  // for our test suite.
  await testMain();
}
