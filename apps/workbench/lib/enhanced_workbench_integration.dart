import 'package:flutter/material.dart';
import 'models.dart';
import 'validation_engine.dart';
import 'enhanced_validation_widgets.dart';
import 'gesture_validation.dart';

/// Enhanced workbench integration example
/// This shows how the new validation system would be integrated
/// into the existing workbench architecture.

class EnhancedWorkbenchIntegration {
  /// Example of how to integrate enhanced validation into the workbench
  /// This would be added to the WorkbenchHomePage state
  
  // Enhanced validation results storage
  final List<EnhancedValidationResult> _enhancedValidationResults = [];
  
  // Enhanced validator instance
  final AdvancedGestureValidator _enhancedValidator = AdvancedGestureValidator();
  
  /// Method to handle enhanced gesture validation
  /// This would be called from _updateGestureState in WorkbenchHomePage
  Future<void> handleEnhancedValidation(
    Map<String, dynamic> debugState,
    GestureTestType selectedGestureTest,
  ) async {
    await GestureValidator.validateTapBehaviorEnhanced(
      debugState,
      selectedGestureTest,
      _enhancedValidationResults,
    );
  }
  
  /// Clear enhanced validation results
  void clearEnhancedResults() {
    _enhancedValidationResults.clear();
  }
  
  /// Get current enhanced validation results
  List<EnhancedValidationResult> get enhancedValidationResults => 
      List.unmodifiable(_enhancedValidationResults);
  
  /// Get validation statistics
  ValidationStatistics get validationStatistics => 
      _enhancedValidator.getStatistics(_enhancedValidationResults);
}

/// Example widget showing how to use the enhanced validation tab
class EnhancedValidationExample extends StatefulWidget {
  const EnhancedValidationExample({super.key});

  @override
  State<EnhancedValidationExample> createState() => _EnhancedValidationExampleState();
}

class _EnhancedValidationExampleState extends State<EnhancedValidationExample> {
  GestureTestType _selectedGestureTest = GestureTestType.tap;
  final List<GestureValidationResult> _legacyResults = [];
  final List<EnhancedValidationResult> _enhancedResults = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhanced Gesture Validation Demo'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Demo controls
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: _simulateGestureEvent,
                  child: const Text('Simulate Gesture'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _simulateFailedGestureEvent,
                  child: const Text('Simulate Failed Gesture'),
                ),
                const Spacer(),
                Text('Results: ${_enhancedResults.length}'),
              ],
            ),
          ),
          
          // Enhanced validation tab
          Expanded(
            child: GestureTestTab(
              selectedGestureTest: _selectedGestureTest,
              gestureValidationResults: _legacyResults,
              enhancedValidationResults: _enhancedResults,
              onGestureTestChanged: (type) => setState(() => _selectedGestureTest = type),
              onClearResults: () => setState(() => _legacyResults.clear()),
              onClearEnhancedResults: () => setState(() => _enhancedResults.clear()),
              uiScale: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  /// Simulate a successful gesture event for demo purposes
  void _simulateGestureEvent() async {
    final debugState = _createMockSuccessfulGestureState();
    
    // Add to enhanced validation
    await GestureValidator.validateTapBehaviorEnhanced(
      debugState,
      _selectedGestureTest,
      _enhancedResults,
    );
    
    // Add to legacy validation for comparison
    GestureValidator.validateTapBehavior(
      debugState,
      _selectedGestureTest,
      _legacyResults,
    );
    
    setState(() {});
  }

  /// Simulate a failed gesture event for demo purposes
  void _simulateFailedGestureEvent() async {
    final debugState = _createMockFailedGestureState();
    
    // Add to enhanced validation
    await GestureValidator.validateTapBehaviorEnhanced(
      debugState,
      _selectedGestureTest,
      _enhancedResults,
    );
    
    // Add to legacy validation for comparison
    GestureValidator.validateTapBehavior(
      debugState,
      _selectedGestureTest,
      _legacyResults,
    );
    
    setState(() {});
  }

  /// Create mock gesture state for successful validation
  Map<String, dynamic> _createMockSuccessfulGestureState() {
    return {
      'phase': 'up',
      'nodeTargetId': 'node_demo_123',
      'node_can_select': true,
      'state_exists': true,
      'state_completed': true,
      'state_cancelled': false,
      'tap_count': _selectedGestureTest == GestureTestType.doubleTap ? 2 : 1,
      'distance': 2.5,
      'isWithinSlop': true,
      'touch_slop': 32.0,
      'is_still_dragging_after_up': false,
      'is_tap_completed_after_up': true,
      'will_toggle_selection': true,
      'time_since_down_ms': _selectedGestureTest == GestureTestType.doubleTap ? 150 : 0,
      'double_tap_timeout_ms': 500,
      'has_double_tap_timer': false,
      'node_can_drag': true,
      'drag_start_threshold': 8.0,
    };
  }

  /// Create mock gesture state for failed validation
  Map<String, dynamic> _createMockFailedGestureState() {
    return {
      'phase': 'up',
      'nodeTargetId': 'node_demo_456',
      'node_can_select': false, // This will cause a failure
      'state_exists': false, // This will cause a failure
      'state_completed': false,
      'state_cancelled': true,
      'tap_count': 1,
      'distance': 45.0, // Outside touch slop
      'isWithinSlop': false, // This will cause a warning
      'touch_slop': 32.0,
      'is_still_dragging_after_up': true, // This will cause a failure
      'is_tap_completed_after_up': false,
      'will_toggle_selection': false,
      'time_since_down_ms': _selectedGestureTest == GestureTestType.doubleTap ? 600 : 0, // Timeout exceeded
      'double_tap_timeout_ms': 500,
      'has_double_tap_timer': true,
      'node_can_drag': false,
      'drag_start_threshold': 20.0, // Outside recommended range
    };
  }
}

/// Performance monitoring integration example
class PerformanceMonitoringExample extends StatefulWidget {
  const PerformanceMonitoringExample({super.key});

  @override
  State<PerformanceMonitoringExample> createState() => _PerformanceMonitoringExampleState();
}

class _PerformanceMonitoringExampleState extends State<PerformanceMonitoringExample> {
  final List<EnhancedValidationResult> _results = [];
  final AdvancedGestureValidator _validator = AdvancedGestureValidator();
  
  @override
  Widget build(BuildContext context) {
    final statistics = _validator.getStatistics(_results);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Monitoring Demo'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Performance metrics display
            ValidationStatisticsCard(
              statistics: statistics,
              uiScale: 1.0,
              onToggle: () {},
            ),
            const SizedBox(height: 16),
            
            // Controls
            Row(
              children: [
                ElevatedButton(
                  onPressed: _addPerformanceTestResult,
                  child: const Text('Add Test Result'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => setState(() => _results.clear()),
                  child: const Text('Clear Results'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Results list
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final result = _results[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        result.isSuccess ? Icons.check_circle : Icons.error,
                        color: result.isSuccess ? Colors.green : Colors.red,
                      ),
                      title: Text('${result.testType.displayName} ${result.phase}'),
                      subtitle: Text('Node: ${result.nodeId}'),
                      trailing: result.performanceMetrics != null
                          ? Text(
                              '${(result.performanceMetrics!.validationDuration.inMicroseconds / 1000).toStringAsFixed(2)}ms',
                              style: const TextStyle(fontFamily: 'monospace'),
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _addPerformanceTestResult() async {
    // Simulate some validation work
    final stopwatch = Stopwatch()..start();
    
    // Create mock validation result with performance metrics
    await Future.delayed(Duration(milliseconds: 1 + (DateTime.now().millisecondsSinceEpoch % 10)));
    
    stopwatch.stop();
    
    final result = EnhancedValidationResult(
      timestamp: DateTime.now(),
      testType: GestureTestType.tap,
      phase: 'up',
      nodeId: 'perf_test_${_results.length}',
      checks: [
        EnhancedValidationCheck(
          id: 'perf_test',
          name: 'Performance Test',
          description: 'Synthetic performance test',
          passed: true,
        ),
      ],
      performanceMetrics: PerformanceMetrics(
        validationDuration: stopwatch.elapsed,
        gestureLatency: Duration(microseconds: 500 + (DateTime.now().microsecondsSinceEpoch % 2000)),
        eventCount: 1,
        cpuUsage: 5.0 + (DateTime.now().millisecondsSinceEpoch % 100) / 10,
        memoryUsage: 1024 * 1024 * (10 + (DateTime.now().millisecondsSinceEpoch % 50)),
      ),
    );
    
    setState(() {
      _results.insert(0, result);
      if (_results.length > 50) {
        _results.removeRange(50, _results.length);
      }
    });
  }
}

/// Validation rule configuration example
class ValidationRuleConfigExample extends StatefulWidget {
  const ValidationRuleConfigExample({super.key});

  @override
  State<ValidationRuleConfigExample> createState() => _ValidationRuleConfigExampleState();
}

class _ValidationRuleConfigExampleState extends State<ValidationRuleConfigExample> {
  ValidationProfile? _currentProfile;
  
  @override
  void initState() {
    super.initState();
    _loadDefaultProfile();
  }
  
  void _loadDefaultProfile() {
    _currentProfile = ValidationProfile(
      id: 'demo_profile',
      name: 'Demo Validation Profile',
      description: 'Example profile for demonstration',
      rules: [
        ValidationRuleConfig(
          rule: NodeSelectableRule(),
          enabled: true,
        ),
        ValidationRuleConfig(
          rule: TapStateCreatedRule(),
          enabled: true,
        ),
        ValidationRuleConfig(
          rule: TouchSlopRule(),
          enabled: true,
          parameters: ValidationRuleParameters({'tolerance_factor': 1.2}),
        ),
        ValidationRuleConfig(
          rule: DoubleTapTimingRule(),
          enabled: true,
          overrideSeverity: ValidationSeverity.warning,
        ),
        ValidationRuleConfig(
          rule: DragThresholdRule(),
          enabled: false, // Disabled for demo
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentProfile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Validation Rules Configuration'),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentProfile!.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_currentProfile!.description),
                    const SizedBox(height: 8),
                    Text(
                      '${_currentProfile!.rules.length} rules configured',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Rules list
            const Text(
              'Validation Rules:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            Expanded(
              child: ListView.builder(
                itemCount: _currentProfile!.rules.length,
                itemBuilder: (context, index) {
                  final ruleConfig = _currentProfile!.rules[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Switch(
                        value: ruleConfig.enabled,
                        onChanged: (enabled) {
                          setState(() {
                            _currentProfile = ValidationProfile(
                              id: _currentProfile!.id,
                              name: _currentProfile!.name,
                              description: _currentProfile!.description,
                              rules: [
                                ..._currentProfile!.rules.take(index),
                                ValidationRuleConfig(
                                  rule: ruleConfig.rule,
                                  enabled: enabled,
                                  parameters: ruleConfig.parameters,
                                  overrideSeverity: ruleConfig.overrideSeverity,
                                ),
                                ..._currentProfile!.rules.skip(index + 1),
                              ],
                            );
                          });
                        },
                      ),
                      title: Text(ruleConfig.rule.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ruleConfig.rule.description),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Chip(
                                label: Text(
                                  ruleConfig.effectiveSeverity.displayName,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: _getSeverityColor(ruleConfig.effectiveSeverity),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Applies to: ${ruleConfig.rule.applicableTypes.map((t) => t.displayName).join(", ")}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getSeverityColor(ValidationSeverity severity) {
    switch (severity) {
      case ValidationSeverity.info:
        return Colors.blue[100]!;
      case ValidationSeverity.warning:
        return Colors.orange[100]!;
      case ValidationSeverity.error:
        return Colors.red[100]!;
      case ValidationSeverity.critical:
        return Colors.purple[100]!;
    }
  }
}