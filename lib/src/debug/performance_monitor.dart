import 'dart:async';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plough/src/utils/logger.dart';

/// Performance measurement result
@internal
class PerformanceMeasurement {
  const PerformanceMeasurement({
    required this.name,
    required this.duration,
    required this.timestamp,
    this.metadata,
  });

  final String name;
  final Duration duration;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'duration_ms': duration.inMicroseconds / 1000,
      'timestamp': timestamp.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }
}

/// Performance statistics
@internal
class PerformanceStats {
  const PerformanceStats({
    required this.name,
    required this.count,
    required this.totalDuration,
    required this.averageDuration,
    required this.minDuration,
    required this.maxDuration,
    required this.lastMeasurement,
  });

  final String name;
  final int count;
  final Duration totalDuration;
  final Duration averageDuration;
  final Duration minDuration;
  final Duration maxDuration;
  final DateTime lastMeasurement;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'count': count,
      'total_duration_ms': totalDuration.inMicroseconds / 1000,
      'average_duration_ms': averageDuration.inMicroseconds / 1000,
      'min_duration_ms': minDuration.inMicroseconds / 1000,
      'max_duration_ms': maxDuration.inMicroseconds / 1000,
      'last_measurement': lastMeasurement.toIso8601String(),
    };
  }
}

/// Performance monitoring class
@internal
class PerformanceMonitor {
  factory PerformanceMonitor() => _instance ??= PerformanceMonitor._();
  PerformanceMonitor._();

  static PerformanceMonitor? _instance;

  final Map<String, List<PerformanceMeasurement>> _measurements = {};
  final Map<String, Stopwatch> _activeTimers = {};
  final int _maxMeasurementsPerOperation = 1000;

  bool _enabled = false;

  /// Enables/disables performance monitoring
  void setEnabled(bool enabled) {
    _enabled = enabled;
    if (enabled) {
      logInfo(LogCategory.performance, 'Performance monitoring enabled');
    } else {
      logInfo(LogCategory.performance, 'Performance monitoring disabled');
    }
  }

  bool get isEnabled => _enabled;

  /// Records the start of an operation
  void startOperation(String operationName, {Map<String, dynamic>? metadata}) {
    if (!_enabled) return;

    if (_activeTimers.containsKey(operationName)) {
      logWarning(LogCategory.performance,
          'Operation "$operationName" is already being measured');
      return;
    }

    final stopwatch = Stopwatch()..start();
    _activeTimers[operationName] = stopwatch;

    logDebug(
        LogCategory.performance, 'Started measuring operation: $operationName');
  }

  /// Records the end of an operation
  void endOperation(String operationName, {Map<String, dynamic>? metadata}) {
    if (!_enabled) return;

    final stopwatch = _activeTimers.remove(operationName);
    if (stopwatch == null) {
      logWarning(LogCategory.performance,
          'Operation "$operationName" was not started or already ended');
      return;
    }

    stopwatch.stop();
    final duration = stopwatch.elapsed;

    final measurement = PerformanceMeasurement(
      name: operationName,
      duration: duration,
      timestamp: DateTime.now(),
      metadata: metadata,
    );

    _addMeasurement(measurement);

    logDebug(LogCategory.performance,
        'Completed operation: $operationName in ${duration.inMicroseconds / 1000}ms');
  }

  /// Measures an operation (synchronous)
  T measureOperation<T>(
    String operationName,
    T Function() operation, {
    Map<String, dynamic>? metadata,
  }) {
    if (!_enabled) return operation();

    startOperation(operationName, metadata: metadata);
    try {
      return operation();
    } finally {
      endOperation(operationName, metadata: metadata);
    }
  }

  /// Measures an operation (asynchronous)
  Future<T> measureOperationAsync<T>(
    String operationName,
    Future<T> Function() operation, {
    Map<String, dynamic>? metadata,
  }) async {
    if (!_enabled) return operation();

    startOperation(operationName, metadata: metadata);
    try {
      return await operation();
    } finally {
      endOperation(operationName, metadata: metadata);
    }
  }

  void _addMeasurement(PerformanceMeasurement measurement) {
    _measurements.putIfAbsent(
        measurement.name, () => <PerformanceMeasurement>[]);
    final measurements = _measurements[measurement.name]!;

    measurements.add(measurement);

    // Remove old measurements
    if (measurements.length > _maxMeasurementsPerOperation) {
      measurements.removeAt(0);
    }
  }

  /// Gets statistics
  PerformanceStats? getStats(String operationName) {
    final measurements = _measurements[operationName];
    if (measurements == null || measurements.isEmpty) return null;

    final durations = measurements.map((m) => m.duration).toList();
    final totalDuration = durations.fold<Duration>(
      Duration.zero,
      (sum, duration) => sum + duration,
    );

    durations.sort((a, b) => a.compareTo(b));

    return PerformanceStats(
      name: operationName,
      count: measurements.length,
      totalDuration: totalDuration,
      averageDuration: Duration(
        microseconds: totalDuration.inMicroseconds ~/ measurements.length,
      ),
      minDuration: durations.first,
      maxDuration: durations.last,
      lastMeasurement: measurements.last.timestamp,
    );
  }

  /// Gets all statistics
  Map<String, PerformanceStats> getAllStats() {
    final stats = <String, PerformanceStats>{};
    for (final operationName in _measurements.keys) {
      final stat = getStats(operationName);
      if (stat != null) {
        stats[operationName] = stat;
      }
    }
    return stats;
  }

  /// Clears measurement results
  void clear() {
    _measurements.clear();
    _activeTimers.clear();
    logInfo(LogCategory.performance, 'Performance measurements cleared');
  }

  /// Generates a statistics report
  String generateReport() {
    final buffer = StringBuffer();
    buffer.writeln('=== Performance Report ===');
    buffer.writeln('Generated at: ${DateTime.now()}');
    buffer.writeln();

    final stats = getAllStats();
    if (stats.isEmpty) {
      buffer.writeln('No performance data available.');
      return buffer.toString();
    }

    // Sort by average execution time
    final sortedStats = stats.entries.toList()
      ..sort(
          (a, b) => b.value.averageDuration.compareTo(a.value.averageDuration));

    for (final entry in sortedStats) {
      final stat = entry.value;
      buffer.writeln('Operation: ${stat.name}');
      buffer.writeln('  Count: ${stat.count}');
      buffer.writeln(
          '  Average: ${stat.averageDuration.inMicroseconds / 1000}ms');
      buffer.writeln('  Min: ${stat.minDuration.inMicroseconds / 1000}ms');
      buffer.writeln('  Max: ${stat.maxDuration.inMicroseconds / 1000}ms');
      buffer.writeln('  Total: ${stat.totalDuration.inMicroseconds / 1000}ms');
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Exports in JSON format
  Map<String, dynamic> exportAsJson() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'enabled': _enabled,
      'stats': getAllStats().map((key, value) => MapEntry(key, value.toJson())),
      'measurements': _measurements.map(
        (key, value) => MapEntry(
          key,
          value.map((m) => m.toJson()).toList(),
        ),
      ),
    };
  }
}

/// Global performance monitoring instance
final PerformanceMonitor performanceMonitor = PerformanceMonitor();

/// Utility functions
@internal
void startPerformanceMeasurement(String operationName,
    {Map<String, dynamic>? metadata}) {
  performanceMonitor.startOperation(operationName, metadata: metadata);
}

@internal
void endPerformanceMeasurement(String operationName,
    {Map<String, dynamic>? metadata}) {
  performanceMonitor.endOperation(operationName, metadata: metadata);
}

@internal
T measurePerformance<T>(
  String operationName,
  T Function() operation, {
  Map<String, dynamic>? metadata,
}) {
  return performanceMonitor.measureOperation(operationName, operation,
      metadata: metadata);
}

@internal
Future<T> measurePerformanceAsync<T>(
  String operationName,
  Future<T> Function() operation, {
  Map<String, dynamic>? metadata,
}) {
  return performanceMonitor.measureOperationAsync(operationName, operation,
      metadata: metadata);
}
