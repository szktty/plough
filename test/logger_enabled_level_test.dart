// E2: PloughLogger.enabled(category, [level]) level-hierarchy precision.
//
// A category configured at a given level should report enabled==true only for
// severities at or above that level, so hot paths can skip closure evaluation
// for sub-threshold messages — not just for fully-disabled categories.
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart' show Level;
import 'package:plough/plough.dart';
import 'package:plough/src/utils/logger.dart' show configureLogging;

void main() {
  setUp(() {
    // Reset to a known state between tests.
    configureLogging();
  });

  tearDown(configureLogging);

  test('off category is disabled for any level', () {
    configureLogging(categoryLevels: {LogCategory.gesture: Level.off});
    expect(logEnabled(LogCategory.gesture), isFalse);
    expect(logEnabled(LogCategory.gesture, Level.error), isFalse);
    expect(logEnabled(LogCategory.gesture, Level.debug), isFalse);
  });

  test('category at warning enables warning/error but not debug/info', () {
    configureLogging(categoryLevels: {LogCategory.gesture: Level.warning});

    // No level: just "not off".
    expect(logEnabled(LogCategory.gesture), isTrue);

    expect(logEnabled(LogCategory.gesture, Level.warning), isTrue);
    expect(logEnabled(LogCategory.gesture, Level.error), isTrue);

    expect(logEnabled(LogCategory.gesture, Level.debug), isFalse);
    expect(logEnabled(LogCategory.gesture, Level.info), isFalse);
  });

  test('category at debug enables everything at or above debug', () {
    configureLogging(categoryLevels: {LogCategory.gesture: Level.debug});
    expect(logEnabled(LogCategory.gesture, Level.debug), isTrue);
    expect(logEnabled(LogCategory.gesture, Level.info), isTrue);
    expect(logEnabled(LogCategory.gesture, Level.warning), isTrue);
    expect(logEnabled(LogCategory.gesture, Level.error), isTrue);
  });

  test('debug closure is skipped for a sub-threshold (warning) category', () {
    configureLogging(categoryLevels: {LogCategory.gesture: Level.warning});

    var evaluated = false;
    logDebug(LogCategory.gesture, () {
      evaluated = true;
      return 'expensive';
    });

    expect(
      evaluated,
      isFalse,
      reason: 'debug closure must not run when category is at warning',
    );
  });

  test('debug closure runs when category is at debug', () {
    configureLogging(categoryLevels: {LogCategory.gesture: Level.debug});

    var evaluated = false;
    logDebug(LogCategory.gesture, () {
      evaluated = true;
      return 'cheap enough';
    });

    expect(evaluated, isTrue);
  });
}
