import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';

@internal
void setLogLevel(Level level) {
  log = _createLogger(level);
}

Logger _createLogger(Level level) {
  return Logger(
    printer: PrefixPrinter(
      PrettyPrinter(
        colors: false,
        methodCount: 0,
        printEmojis: false,
        noBoxingByDefault: true,
        excludeBox: {Level.error: false},
      ),
    ),
    level: level,
  );
}

Logger log = _createLogger(Level.off);
