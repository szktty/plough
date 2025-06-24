import 'package:flutter/foundation.dart';
import 'models.dart';

// Enhanced validation system with configurable rules
// and advanced testing capabilities

/// Validation rule severity levels
enum ValidationSeverity {
  info('Info', 'Informational, no action required'),
  warning('Warning', 'Potential issue, review recommended'),
  error('Error', 'Critical issue, action required'),
  critical('Critical', 'Severe issue, immediate action required');

  const ValidationSeverity(this.displayName, this.description);
  final String displayName;
  final String description;
}

/// Enhanced validation result with more context
class EnhancedValidationResult {
  final DateTime timestamp;
  final GestureTestType testType;
  final String phase;
  final String nodeId;
  final List<EnhancedValidationCheck> checks;
  final PerformanceMetrics? performanceMetrics;
  final List<ValidationSuggestion> suggestions;
  final ValidationContext validationContext;

  EnhancedValidationResult({
    required this.timestamp,
    required this.testType,
    required this.phase,
    required this.nodeId,
    required this.checks,
    this.performanceMetrics,
    List<ValidationSuggestion>? suggestions,
    ValidationContext? validationContext,
  }) : suggestions = suggestions ?? [],
       validationContext = validationContext ?? ValidationContext.empty();

  bool get isSuccess => checks.every((check) => check.passed || check.severity == ValidationSeverity.info);
  
  int get errorCount => checks.where((c) => c.severity == ValidationSeverity.error || c.severity == ValidationSeverity.critical).length;
  int get warningCount => checks.where((c) => c.severity == ValidationSeverity.warning).length;
  int get passedCount => checks.where((c) => c.passed).length;
}

/// Enhanced validation check with severity and suggestions
class EnhancedValidationCheck {
  final String id;
  final String name;
  final String description;
  final bool passed;
  final ValidationSeverity severity;
  final String? expectedValue;
  final String? actualValue;
  final String? failureReason;
  final List<String> suggestions;
  final Map<String, dynamic> metadata;

  EnhancedValidationCheck({
    required this.id,
    required this.name,
    required this.description,
    required this.passed,
    this.severity = ValidationSeverity.error,
    this.expectedValue,
    this.actualValue,
    this.failureReason,
    List<String>? suggestions,
    Map<String, dynamic>? metadata,
  }) : suggestions = suggestions ?? [],
       metadata = metadata ?? {};

  /// Convert from legacy GestureValidationCheck
  factory EnhancedValidationCheck.fromLegacy(GestureValidationCheck legacy) {
    return EnhancedValidationCheck(
      id: legacy.name,
      name: legacy.name,
      description: legacy.description,
      passed: legacy.passed,
      expectedValue: legacy.expectedValue,
      actualValue: legacy.actualValue,
      failureReason: legacy.failureReason,
    );
  }
}

/// Performance metrics for validation
class PerformanceMetrics {
  final Duration validationDuration;
  final Duration gestureLatency;
  final int eventCount;
  final double cpuUsage;
  final int memoryUsage;

  PerformanceMetrics({
    required this.validationDuration,
    required this.gestureLatency,
    required this.eventCount,
    required this.cpuUsage,
    required this.memoryUsage,
  });
}

/// Validation suggestions for improvements
class ValidationSuggestion {
  final String title;
  final String description;
  final ValidationSeverity severity;
  final String? actionText;
  final VoidCallback? action;

  ValidationSuggestion({
    required this.title,
    required this.description,
    this.severity = ValidationSeverity.info,
    this.actionText,
    this.action,
  });
}

/// Context information for validation
class ValidationContext {
  final String sessionId;
  final String environment;
  final Map<String, dynamic> configuration;
  final DateTime sessionStart;

  ValidationContext({
    required this.sessionId,
    required this.environment,
    required this.configuration,
    required this.sessionStart,
  });

  factory ValidationContext.empty() {
    return ValidationContext(
      sessionId: 'default',
      environment: 'development',
      configuration: {},
      sessionStart: DateTime.now(),
    );
  }
}

/// Configurable validation rule
abstract class ValidationRule {
  String get id;
  String get name;
  String get description;
  ValidationSeverity get defaultSeverity;
  Set<GestureTestType> get applicableTypes;
  
  /// Execute the validation rule
  EnhancedValidationCheck validate(
    Map<String, dynamic> state,
    GestureTestType testType,
    String phase,
    ValidationRuleParameters parameters,
  );
  
  /// Get default parameters for this rule
  ValidationRuleParameters get defaultParameters;
}

/// Parameters for validation rules
class ValidationRuleParameters {
  final Map<String, dynamic> _parameters;

  ValidationRuleParameters(this._parameters);

  T get<T>(String key, T defaultValue) {
    return _parameters[key] as T? ?? defaultValue;
  }

  void set<T>(String key, T value) {
    _parameters[key] = value;
  }

  Map<String, dynamic> toMap() => Map.from(_parameters);

  factory ValidationRuleParameters.empty() => ValidationRuleParameters({});
}

/// Validation profile containing multiple rules
class ValidationProfile {
  final String id;
  final String name;
  final String description;
  final List<ValidationRuleConfig> rules;
  final ValidationConfiguration configuration;

  ValidationProfile({
    required this.id,
    required this.name,
    required this.description,
    required this.rules,
    ValidationConfiguration? configuration,
  }) : configuration = configuration ?? ValidationConfiguration.defaultConfig();

  /// Get rules applicable to a specific gesture type
  List<ValidationRuleConfig> getRulesForType(GestureTestType type) {
    return rules.where((config) => config.rule.applicableTypes.contains(type)).toList();
  }
}

/// Configuration for a specific validation rule
class ValidationRuleConfig {
  final ValidationRule rule;
  final ValidationRuleParameters parameters;
  final bool enabled;
  final ValidationSeverity? overrideSeverity;

  ValidationRuleConfig({
    required this.rule,
    ValidationRuleParameters? parameters,
    this.enabled = true,
    this.overrideSeverity,
  }) : parameters = parameters ?? rule.defaultParameters;

  ValidationSeverity get effectiveSeverity => overrideSeverity ?? rule.defaultSeverity;
}

/// Global validation configuration
class ValidationConfiguration {
  final bool enableRealTimeValidation;
  final bool enablePerformanceMetrics;
  final Duration performanceThreshold;
  final int maxValidationHistory;
  final bool autoGenerateTests;

  ValidationConfiguration({
    this.enableRealTimeValidation = true,
    this.enablePerformanceMetrics = true,
    this.performanceThreshold = const Duration(milliseconds: 10),
    this.maxValidationHistory = 100,
    this.autoGenerateTests = false,
  });

  factory ValidationConfiguration.defaultConfig() => ValidationConfiguration();
}

/// Built-in validation rules

/// Rule to check if node is selectable for tap gestures
class NodeSelectableRule extends ValidationRule {
  @override
  String get id => 'node_selectable';
  
  @override
  String get name => 'Node Selectable';
  
  @override
  String get description => 'Validates that the target node allows selection';
  
  @override
  ValidationSeverity get defaultSeverity => ValidationSeverity.error;
  
  @override
  Set<GestureTestType> get applicableTypes => {GestureTestType.tap, GestureTestType.doubleTap};
  
  @override
  ValidationRuleParameters get defaultParameters => ValidationRuleParameters({});

  @override
  EnhancedValidationCheck validate(
    Map<String, dynamic> state,
    GestureTestType testType,
    String phase,
    ValidationRuleParameters parameters,
  ) {
    final nodeCanSelect = state['node_can_select'] ?? false;
    
    return EnhancedValidationCheck(
      id: id,
      name: name,
      description: description,
      passed: nodeCanSelect,
      severity: defaultSeverity,
      expectedValue: 'true',
      actualValue: nodeCanSelect.toString(),
      failureReason: nodeCanSelect ? null : 'Node canSelect property is false',
      suggestions: nodeCanSelect ? [] : [
        'Check if allowSelection is enabled in GraphView configuration',
        'Verify node behavior allows selection'
      ],
    );
  }
}

/// Rule to check tap state creation
class TapStateCreatedRule extends ValidationRule {
  @override
  String get id => 'tap_state_created';
  
  @override
  String get name => 'Tap State Created';
  
  @override
  String get description => 'Validates that tap state is properly created on pointer down';
  
  @override
  ValidationSeverity get defaultSeverity => ValidationSeverity.error;
  
  @override
  Set<GestureTestType> get applicableTypes => {GestureTestType.tap, GestureTestType.doubleTap};
  
  @override
  ValidationRuleParameters get defaultParameters => ValidationRuleParameters({});

  @override
  EnhancedValidationCheck validate(
    Map<String, dynamic> state,
    GestureTestType testType,
    String phase,
    ValidationRuleParameters parameters,
  ) {
    if (phase != 'down') {
      return EnhancedValidationCheck(
        id: id,
        name: name,
        description: 'N/A for phase $phase',
        passed: true,
        severity: ValidationSeverity.info,
      );
    }

    final stateExists = state['state_exists'] ?? false;
    
    return EnhancedValidationCheck(
      id: id,
      name: name,
      description: description,
      passed: stateExists,
      severity: defaultSeverity,
      expectedValue: 'true',
      actualValue: stateExists.toString(),
      failureReason: stateExists ? null : 'Tap state was not created on pointer down',
      suggestions: stateExists ? [] : [
        'Check if tap gesture recognizer is properly initialized',
        'Verify entity hit testing is working correctly',
        'Ensure gesture manager is receiving pointer events'
      ],
    );
  }
}

/// Rule to check touch slop validation
class TouchSlopRule extends ValidationRule {
  @override
  String get id => 'touch_slop_validation';
  
  @override
  String get name => 'Touch Slop Validation';
  
  @override
  String get description => 'Validates that pointer movement is within touch slop threshold';
  
  @override
  ValidationSeverity get defaultSeverity => ValidationSeverity.warning;
  
  @override
  Set<GestureTestType> get applicableTypes => {GestureTestType.tap, GestureTestType.doubleTap};
  
  @override
  ValidationRuleParameters get defaultParameters => ValidationRuleParameters({
    'tolerance_factor': 1.0, // Allow for some tolerance
  });

  @override
  EnhancedValidationCheck validate(
    Map<String, dynamic> state,
    GestureTestType testType,
    String phase,
    ValidationRuleParameters parameters,
  ) {
    if (phase != 'up') {
      return EnhancedValidationCheck(
        id: id,
        name: name,
        description: 'N/A for phase $phase',
        passed: true,
        severity: ValidationSeverity.info,
      );
    }

    final isWithinSlop = state['isWithinSlop'];
    if (isWithinSlop == null) {
      return EnhancedValidationCheck(
        id: id,
        name: name,
        description: description,
        passed: false,
        severity: ValidationSeverity.warning,
        failureReason: 'Touch slop data not available',
        suggestions: ['Ensure debug mode is enabled in gesture system'],
      );
    }

    final distance = state['distance'] ?? 0.0;
    final touchSlop = state['touch_slop'] ?? 32.0;
    final toleranceFactor = parameters.get('tolerance_factor', 1.0);
    final adjustedThreshold = touchSlop * toleranceFactor;
    
    return EnhancedValidationCheck(
      id: id,
      name: name,
      description: description,
      passed: isWithinSlop,
      severity: isWithinSlop ? ValidationSeverity.info : ValidationSeverity.warning,
      expectedValue: '<= ${adjustedThreshold.toStringAsFixed(1)}px',
      actualValue: '${distance.toStringAsFixed(1)}px',
      failureReason: isWithinSlop ? null : 'Pointer moved ${distance.toStringAsFixed(1)}px, exceeding slop threshold of ${touchSlop.toStringAsFixed(1)}px',
      suggestions: isWithinSlop ? [] : [
        'Consider using a larger touch slop for better user experience',
        'Check if pan gesture detection is interfering with tap',
        'Verify pointer event accuracy on this device'
      ],
    );
  }
}

/// Rule to check double tap timing
class DoubleTapTimingRule extends ValidationRule {
  @override
  String get id => 'double_tap_timing';
  
  @override
  String get name => 'Double Tap Timing';
  
  @override
  String get description => 'Validates double tap timing is within acceptable range';
  
  @override
  ValidationSeverity get defaultSeverity => ValidationSeverity.error;
  
  @override
  Set<GestureTestType> get applicableTypes => {GestureTestType.doubleTap};
  
  @override
  ValidationRuleParameters get defaultParameters => ValidationRuleParameters({
    'timeout_ms': 500,
    'warning_threshold_ms': 400,
  });

  @override
  EnhancedValidationCheck validate(
    Map<String, dynamic> state,
    GestureTestType testType,
    String phase,
    ValidationRuleParameters parameters,
  ) {
    if (phase != 'up' || state['tap_count'] != 2) {
      return EnhancedValidationCheck(
        id: id,
        name: name,
        description: 'N/A for this event',
        passed: true,
        severity: ValidationSeverity.info,
      );
    }

    final timeSinceDown = state['time_since_down_ms'] ?? 0;
    final timeoutMs = parameters.get('timeout_ms', 500);
    final warningThresholdMs = parameters.get('warning_threshold_ms', 400);
    
    final passed = timeSinceDown <= timeoutMs;
    final severity = passed 
        ? (timeSinceDown > warningThresholdMs ? ValidationSeverity.warning : ValidationSeverity.info)
        : ValidationSeverity.error;
    
    return EnhancedValidationCheck(
      id: id,
      name: name,
      description: description,
      passed: passed,
      severity: severity,
      expectedValue: '<= ${timeoutMs}ms',
      actualValue: '${timeSinceDown}ms',
      failureReason: passed ? null : 'Double tap timeout exceeded (${timeSinceDown}ms > ${timeoutMs}ms)',
      suggestions: passed ? [] : [
        'Increase double tap timeout threshold',
        'Check system performance and gesture processing latency',
        'Consider user accessibility needs for tap timing'
      ],
    );
  }
}

/// Rule to check drag threshold
class DragThresholdRule extends ValidationRule {
  @override
  String get id => 'drag_threshold';
  
  @override
  String get name => 'Drag Threshold';
  
  @override
  String get description => 'Validates drag detection threshold is appropriate';
  
  @override
  ValidationSeverity get defaultSeverity => ValidationSeverity.warning;
  
  @override
  Set<GestureTestType> get applicableTypes => {GestureTestType.drag};
  
  @override
  ValidationRuleParameters get defaultParameters => ValidationRuleParameters({
    'min_threshold_px': 4.0,
    'max_threshold_px': 16.0,
  });

  @override
  EnhancedValidationCheck validate(
    Map<String, dynamic> state,
    GestureTestType testType,
    String phase,
    ValidationRuleParameters parameters,
  ) {
    final dragStartThreshold = state['drag_start_threshold'] ?? 8.0;
    final minThreshold = parameters.get('min_threshold_px', 4.0);
    final maxThreshold = parameters.get('max_threshold_px', 16.0);
    
    final passed = dragStartThreshold >= minThreshold && dragStartThreshold <= maxThreshold;
    
    return EnhancedValidationCheck(
      id: id,
      name: name,
      description: description,
      passed: passed,
      severity: passed ? ValidationSeverity.info : ValidationSeverity.warning,
      expectedValue: '$minThreshold-$maxThreshold px',
      actualValue: '$dragStartThreshold px',
      failureReason: passed ? null : 'Drag threshold outside recommended range',
      suggestions: passed ? [] : [
        dragStartThreshold < minThreshold 
            ? 'Consider increasing drag threshold to prevent accidental drags'
            : 'Consider decreasing drag threshold for more responsive dragging',
        'Test with different device types and screen densities'
      ],
    );
  }
}

/// Main validation engine
class AdvancedGestureValidator {
  final ValidationProfile _profile;
  final ValidationConfiguration _config;
  final Map<String, ValidationRule> _availableRules = {};

  AdvancedGestureValidator({
    ValidationProfile? profile,
    ValidationConfiguration? config,
  }) : _profile = profile ?? _createDefaultProfile(),
       _config = config ?? ValidationConfiguration.defaultConfig() {
    _initializeBuiltInRules();
  }

  /// Initialize built-in validation rules
  void _initializeBuiltInRules() {
    final rules = [
      NodeSelectableRule(),
      TapStateCreatedRule(),
      TouchSlopRule(),
      DoubleTapTimingRule(),
      DragThresholdRule(),
    ];
    
    for (final rule in rules) {
      _availableRules[rule.id] = rule;
    }
  }

  /// Validate gesture behavior using current profile
  Future<EnhancedValidationResult> validate(
    Map<String, dynamic> debugState,
    GestureTestType selectedGestureTest,
  ) async {
    final stopwatch = Stopwatch()..start();
    
    final phase = debugState['phase']?.toString() ?? 'unknown';
    final nodeTargetId = debugState['nodeTargetId']?.toString() ?? 'null';
    
    if (nodeTargetId == 'null' || phase == 'none') {
      return EnhancedValidationResult(
        timestamp: DateTime.now(),
        testType: selectedGestureTest,
        phase: phase,
        nodeId: nodeTargetId,
        checks: [],
        performanceMetrics: _config.enablePerformanceMetrics 
            ? PerformanceMetrics(
                validationDuration: stopwatch.elapsed,
                gestureLatency: Duration.zero,
                eventCount: 0,
                cpuUsage: 0.0,
                memoryUsage: 0,
              )
            : null,
      );
    }

    final applicableRules = _profile.getRulesForType(selectedGestureTest);
    final checks = <EnhancedValidationCheck>[];
    final suggestions = <ValidationSuggestion>[];
    
    for (final ruleConfig in applicableRules) {
      if (!ruleConfig.enabled) continue;
      
      try {
        final check = ruleConfig.rule.validate(
          debugState,
          selectedGestureTest,
          phase,
          ruleConfig.parameters,
        );
        
        // Apply severity override if configured
        final adjustedCheck = ruleConfig.overrideSeverity != null
            ? EnhancedValidationCheck(
                id: check.id,
                name: check.name,
                description: check.description,
                passed: check.passed,
                severity: ruleConfig.overrideSeverity!,
                expectedValue: check.expectedValue,
                actualValue: check.actualValue,
                failureReason: check.failureReason,
                suggestions: check.suggestions,
                metadata: check.metadata,
              )
            : check;
            
        checks.add(adjustedCheck);
        
        // Add suggestions for failed checks
        if (!check.passed && check.suggestions.isNotEmpty) {
          suggestions.addAll(
            check.suggestions.map((s) => ValidationSuggestion(
              title: 'Fix: ${check.name}',
              description: s,
              severity: check.severity,
            ))
          );
        }
      } catch (e) {
        // Handle rule execution errors gracefully
        checks.add(EnhancedValidationCheck(
          id: '${ruleConfig.rule.id}_error',
          name: 'Rule Execution Error',
          description: 'Error executing rule: ${ruleConfig.rule.name}',
          passed: false,
          severity: ValidationSeverity.critical,
          failureReason: 'Rule execution failed: $e',
          suggestions: ['Check rule implementation and parameters'],
        ));
      }
    }

    stopwatch.stop();
    
    return EnhancedValidationResult(
      timestamp: DateTime.now(),
      testType: selectedGestureTest,
      phase: phase,
      nodeId: nodeTargetId,
      checks: checks,
      suggestions: suggestions,
      performanceMetrics: _config.enablePerformanceMetrics 
          ? PerformanceMetrics(
              validationDuration: stopwatch.elapsed,
              gestureLatency: Duration.zero, // Would be calculated from gesture events
              eventCount: 1,
              cpuUsage: 0.0, // Would need platform-specific implementation
              memoryUsage: 0,
            )
          : null,
    );
  }

  /// Get validation statistics
  ValidationStatistics getStatistics(List<EnhancedValidationResult> results) {
    if (results.isEmpty) {
      return ValidationStatistics.empty();
    }

    final totalChecks = results.fold<int>(0, (sum, result) => sum + result.checks.length);
    final passedChecks = results.fold<int>(0, (sum, result) => sum + result.passedCount);
    final errorCount = results.fold<int>(0, (sum, result) => sum + result.errorCount);
    final warningCount = results.fold<int>(0, (sum, result) => sum + result.warningCount);
    
    final avgValidationTime = results
        .where((r) => r.performanceMetrics != null)
        .map((r) => r.performanceMetrics!.validationDuration.inMicroseconds)
        .fold<int>(0, (sum, duration) => sum + duration) / results.length;

    return ValidationStatistics(
      totalValidations: results.length,
      totalChecks: totalChecks,
      passedChecks: passedChecks,
      failedChecks: totalChecks - passedChecks,
      errorCount: errorCount,
      warningCount: warningCount,
      successRate: totalChecks > 0 ? passedChecks / totalChecks : 0.0,
      averageValidationTime: Duration(microseconds: avgValidationTime.round()),
    );
  }

  /// Create default validation profile
  static ValidationProfile _createDefaultProfile() {
    return ValidationProfile(
      id: 'default',
      name: 'Default Validation Profile',
      description: 'Standard validation rules for gesture testing',
      rules: [
        ValidationRuleConfig(rule: NodeSelectableRule()),
        ValidationRuleConfig(rule: TapStateCreatedRule()),
        ValidationRuleConfig(rule: TouchSlopRule()),
        ValidationRuleConfig(rule: DoubleTapTimingRule()),
        ValidationRuleConfig(rule: DragThresholdRule()),
      ],
    );
  }
}

/// Validation statistics
class ValidationStatistics {
  final int totalValidations;
  final int totalChecks;
  final int passedChecks;
  final int failedChecks;
  final int errorCount;
  final int warningCount;
  final double successRate;
  final Duration averageValidationTime;

  ValidationStatistics({
    required this.totalValidations,
    required this.totalChecks,
    required this.passedChecks,
    required this.failedChecks,
    required this.errorCount,
    required this.warningCount,
    required this.successRate,
    required this.averageValidationTime,
  });

  factory ValidationStatistics.empty() {
    return ValidationStatistics(
      totalValidations: 0,
      totalChecks: 0,
      passedChecks: 0,
      failedChecks: 0,
      errorCount: 0,
      warningCount: 0,
      successRate: 0.0,
      averageValidationTime: Duration.zero,
    );
  }
}