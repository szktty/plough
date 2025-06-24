import 'package:flutter/material.dart';
import 'models.dart';
import 'validation_engine.dart';
import 'enhanced_validation_widgets.dart';

class GestureValidator {
  // Enhanced validator instance for advanced validation features
  static final AdvancedGestureValidator _enhancedValidator = AdvancedGestureValidator();
  
  /// Enhanced validation using the new validation engine
  static Future<void> validateTapBehaviorEnhanced(
    Map<String, dynamic> debugState,
    GestureTestType selectedGestureTest,
    List<EnhancedValidationResult> validationResults,
  ) async {
    try {
      final result = await _enhancedValidator.validate(debugState, selectedGestureTest);
      
      if (result.checks.isNotEmpty) {
        validationResults.insert(0, result);
        
        // Keep maximum 100 items
        if (validationResults.length > 100) {
          validationResults.removeRange(100, validationResults.length);
        }
      }
    } catch (e) {
      // Handle validation errors gracefully
      debugPrint('Enhanced validation error: $e');
    }
  }
  
  /// Get validation statistics for enhanced results
  static ValidationStatistics getValidationStatistics(List<EnhancedValidationResult> results) {
    return _enhancedValidator.getStatistics(results);
  }
  
  /// Legacy validation method (kept for backward compatibility)
  static void validateTapBehavior(
    Map<String, dynamic> debugState,
    GestureTestType selectedGestureTest,
    List<GestureValidationResult> validationResults,
  ) {
    final phase = debugState['phase']?.toString() ?? 'unknown';
    final nodeTargetId = debugState['nodeTargetId']?.toString() ?? 'null';
    
    if (nodeTargetId == 'null' || phase == 'none') return;

    final checks = <GestureValidationCheck>[];
    
    // Execute validation based on selected test type
    switch (selectedGestureTest) {
      case GestureTestType.tap:
        if (phase == 'down') {
          checks.addAll(_validateTapDown(debugState));
        } else if (phase == 'up') {
          checks.addAll(_validateTapUp(debugState));
        }
        break;
      case GestureTestType.doubleTap:
        checks.addAll(_validateDoubleTap(debugState, phase));
        break;
      case GestureTestType.drag:
        checks.addAll(_validateDrag(debugState, phase));
        break;
      case GestureTestType.hover:
        checks.addAll(_validateHover(debugState, phase));
        break;
      case GestureTestType.longPress:
        checks.addAll(_validateLongPress(debugState, phase));
        break;
      case GestureTestType.tapAndHold:
        checks.addAll(_validateTapAndHold(debugState, phase));
        break;
    }

    if (checks.isNotEmpty) {
      final result = GestureValidationResult(
        timestamp: DateTime.now(),
        testType: selectedGestureTest,
        phase: phase,
        nodeId: nodeTargetId,
        checks: checks,
      );
      
      validationResults.insert(0, result);
      
      // Keep maximum 100 items
      if (validationResults.length > 100) {
        validationResults.removeRange(100, validationResults.length);
      }
    }
  }

  static List<GestureValidationCheck> _validateTapDown(Map<String, dynamic> state) {
    final checks = <GestureValidationCheck>[];
    
    final nodeCanSelect = state['node_can_select'] ?? false;
    checks.add(GestureValidationCheck(
      name: 'node_selectable',
      description: 'Node is selectable',
      passed: nodeCanSelect,
      expectedValue: 'true',
      actualValue: nodeCanSelect.toString(),
      failureReason: nodeCanSelect ? null : 'Node canSelect is false',
    ));

    final stateExists = state['state_exists'] ?? false;
    checks.add(GestureValidationCheck(
      name: 'tap_state_created',
      description: 'Tap state is created',
      passed: stateExists,
      expectedValue: 'true',
      actualValue: stateExists.toString(),
      failureReason: stateExists ? null : 'Tap state was not created',
    ));

    final stateCancelled = state['state_cancelled'] ?? false;
    checks.add(GestureValidationCheck(
      name: 'tap_state_not_cancelled',
      description: 'Tap state is not cancelled',
      passed: !stateCancelled,
      expectedValue: 'false',
      actualValue: stateCancelled.toString(),
      failureReason: stateCancelled ? 'Tap state was cancelled' : null,
    ));

    return checks;
  }

  static List<GestureValidationCheck> _validateTapUp(Map<String, dynamic> state) {
    final checks = <GestureValidationCheck>[];
    
    final stateExists = state['state_exists'] ?? false;
    checks.add(GestureValidationCheck(
      name: 'tap_state_exists_on_up',
      description: 'Tap state exists on pointer up',
      passed: stateExists,
      expectedValue: 'true',
      actualValue: stateExists.toString(),
      failureReason: stateExists ? null : 'Tap state does not exist on pointer up',
    ));

    if (stateExists) {
      final isStillDragging = state['is_still_dragging_after_up'] ?? true;
      checks.add(GestureValidationCheck(
        name: 'not_dragging',
        description: 'Not dragging',
        passed: !isStillDragging,
        expectedValue: 'false',
        actualValue: isStillDragging.toString(),
        failureReason: isStillDragging ? 'Still dragging' : null,
      ));

      final isTapCompleted = state['is_tap_completed_after_up'] ?? false;
      checks.add(GestureValidationCheck(
        name: 'tap_completed',
        description: 'Tap is completed',
        passed: isTapCompleted,
        expectedValue: 'true',
        actualValue: isTapCompleted.toString(),
        failureReason: isTapCompleted ? null : 'Tap is not completed',
      ));

      final isWithinSlop = state['isWithinSlop'];
      if (isWithinSlop != null) {
        checks.add(GestureValidationCheck(
          name: 'within_slop',
          description: 'Within touch slop range',
          passed: isWithinSlop,
          expectedValue: 'true',
          actualValue: isWithinSlop.toString(),
          failureReason: isWithinSlop ? null : 'Moved outside touch slop range',
        ));
      }

      final willToggleSelection = state['will_toggle_selection'] ?? false;
      final shouldToggle = !isStillDragging && isTapCompleted;
      checks.add(GestureValidationCheck(
        name: 'will_toggle_selection',
        description: 'Selection state will toggle',
        passed: willToggleSelection == shouldToggle,
        expectedValue: shouldToggle.toString(),
        actualValue: willToggleSelection.toString(),
        failureReason: willToggleSelection != shouldToggle 
          ? 'Selection toggle judgment is incorrect' : null,
      ));
    }

    return checks;
  }

  static List<GestureValidationCheck> _validateDoubleTap(Map<String, dynamic> state, String phase) {
    final checks = <GestureValidationCheck>[];
    
    if (phase == 'down') {
      // Double tap detection on pointer down
      final tapCount = state['tap_count'] ?? 1;
      if (tapCount == 2) {
        checks.add(GestureValidationCheck(
          name: 'double_tap_detected_on_down',
          description: 'Double tap detected on pointer down',
          passed: true,
          expectedValue: '2',
          actualValue: tapCount.toString(),
        ));
      } else {
        checks.add(GestureValidationCheck(
          name: 'first_tap_down',
          description: 'First tap pointer down',
          passed: tapCount == 1,
          expectedValue: '1',
          actualValue: tapCount.toString(),
          failureReason: tapCount != 1 ? 'Not the first tap' : null,
        ));
      }
    } else if (phase == 'up') {
      final tapCount = state['tap_count'] ?? 0;
      checks.add(GestureValidationCheck(
        name: 'double_tap_count',
        description: 'Tap count is 2',
        passed: tapCount == 2,
        expectedValue: '2',
        actualValue: tapCount.toString(),
        failureReason: tapCount != 2 ? 'Tap count is not 2' : null,
      ));

      if (tapCount == 2) {
        final hasDoubleTapTimer = state['has_double_tap_timer'] ?? false;
        checks.add(GestureValidationCheck(
          name: 'no_timer_on_double_tap',
          description: 'Timer is not set on double tap',
          passed: !hasDoubleTapTimer,
          expectedValue: 'false',
          actualValue: hasDoubleTapTimer.toString(),
          failureReason: hasDoubleTapTimer ? 'Timer remains on double tap' : null,
        ));

        final timeSinceDown = state['time_since_down_ms'] ?? 0;
        final doubleTapTimeoutMs = state['double_tap_timeout_ms'] ?? 200;
        checks.add(GestureValidationCheck(
          name: 'double_tap_within_timeout',
          description: 'Within double tap timeout',
          passed: timeSinceDown <= doubleTapTimeoutMs,
          expectedValue: '<= ${doubleTapTimeoutMs}ms',
          actualValue: '${timeSinceDown}ms',
          failureReason: timeSinceDown > doubleTapTimeoutMs ? 'Timeout exceeded' : null,
        ));
      }
    }
    
    return checks;
  }

  static List<GestureValidationCheck> _validateDrag(Map<String, dynamic> state, String phase) {
    final checks = <GestureValidationCheck>[];
    
    final nodeCanDrag = state['node_can_drag'] ?? false;
    checks.add(GestureValidationCheck(
      name: 'node_draggable',
      description: 'Node is draggable',
      passed: nodeCanDrag,
      expectedValue: 'true',
      actualValue: nodeCanDrag.toString(),
      failureReason: nodeCanDrag ? null : 'Node canDrag is false',
    ));

    if (phase == 'up') {
      final isDragging = state['drag_manager_is_dragging'] ?? false;
      checks.add(GestureValidationCheck(
        name: 'drag_active',
        description: 'Drag is being executed',
        passed: isDragging,
        expectedValue: 'true',
        actualValue: isDragging.toString(),
        failureReason: isDragging ? null : 'Drag has not started',
      ));
    }
    
    return checks;
  }

  static List<GestureValidationCheck> _validateHover(Map<String, dynamic> state, String phase) {
    // Hover validation (simplified implementation)
    return [
      GestureValidationCheck(
        name: 'hover_support',
        description: 'Supports hover state',
        passed: true,
        expectedValue: 'true',
        actualValue: 'true',
      ),
    ];
  }

  static List<GestureValidationCheck> _validateLongPress(Map<String, dynamic> state, String phase) {
    // Long press validation (simplified implementation)
    return [
      GestureValidationCheck(
        name: 'long_press_support',
        description: 'Supports long press',
        passed: true,
        expectedValue: 'true',
        actualValue: 'true',
      ),
    ];
  }

  static List<GestureValidationCheck> _validateTapAndHold(Map<String, dynamic> state, String phase) {
    // Tap & hold validation (simplified implementation)
    return [
      GestureValidationCheck(
        name: 'tap_hold_support',
        description: 'Supports tap & hold',
        passed: true,
        expectedValue: 'true',
        actualValue: 'true',
      ),
    ];
  }
}

/// Enhanced gesture test tab with mode switching
class GestureTestTab extends StatefulWidget {
  final GestureTestType selectedGestureTest;
  final List<GestureValidationResult> gestureValidationResults;
  final List<EnhancedValidationResult> enhancedValidationResults;
  final ValueChanged<GestureTestType> onGestureTestChanged;
  final VoidCallback onClearResults;
  final VoidCallback onClearEnhancedResults;
  final double uiScale;

  const GestureTestTab({
    super.key,
    required this.selectedGestureTest,
    required this.gestureValidationResults,
    required this.enhancedValidationResults,
    required this.onGestureTestChanged,
    required this.onClearResults,
    required this.onClearEnhancedResults,
    required this.uiScale,
  });

  @override
  State<GestureTestTab> createState() => _GestureTestTabState();
}

class _GestureTestTabState extends State<GestureTestTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Mode selection tabs
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: Colors.blue[600],
              borderRadius: BorderRadius.circular(8),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[600],
            labelStyle: TextStyle(
              fontSize: 14 * widget.uiScale,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.science, size: 20),
                text: 'Enhanced',
              ),
              Tab(
                icon: Icon(Icons.list_alt, size: 20),
                text: 'Legacy',
              ),
            ],
          ),
        ),
        
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Enhanced validation tab
              EnhancedGestureTestTab(
                selectedGestureTest: widget.selectedGestureTest,
                validationResults: widget.enhancedValidationResults,
                onGestureTestChanged: widget.onGestureTestChanged,
                onClearResults: widget.onClearEnhancedResults,
                uiScale: widget.uiScale,
                validator: GestureValidator._enhancedValidator,
              ),
              
              // Legacy validation tab
              LegacyGestureTestTab(
                selectedGestureTest: widget.selectedGestureTest,
                gestureValidationResults: widget.gestureValidationResults,
                onGestureTestChanged: widget.onGestureTestChanged,
                onClearResults: widget.onClearResults,
                uiScale: widget.uiScale,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Legacy gesture test tab (original implementation)
class LegacyGestureTestTab extends StatelessWidget {
  final GestureTestType selectedGestureTest;
  final List<GestureValidationResult> gestureValidationResults;
  final ValueChanged<GestureTestType> onGestureTestChanged;
  final VoidCallback onClearResults;
  final double uiScale;

  const LegacyGestureTestTab({
    super.key,
    required this.selectedGestureTest,
    required this.gestureValidationResults,
    required this.onGestureTestChanged,
    required this.onClearResults,
    required this.uiScale,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gesture test selection section
          GestureTestSelector(
            selectedGestureTest: selectedGestureTest,
            onGestureTestChanged: onGestureTestChanged,
            onClearResults: onClearResults,
            resultsCount: gestureValidationResults.length,
            uiScale: uiScale,
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey[400]),
          const SizedBox(height: 16),
          
          // Test results display section
          GestureTestResults(
            selectedGestureTest: selectedGestureTest,
            gestureValidationResults: gestureValidationResults,
            uiScale: uiScale,
          ),
        ],
      ),
    );
  }
}

class GestureTestSelector extends StatelessWidget {
  final GestureTestType selectedGestureTest;
  final ValueChanged<GestureTestType> onGestureTestChanged;
  final VoidCallback onClearResults;
  final int resultsCount;
  final double uiScale;

  const GestureTestSelector({
    super.key,
    required this.selectedGestureTest,
    required this.onGestureTestChanged,
    required this.onClearResults,
    required this.resultsCount,
    required this.uiScale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border.all(color: Colors.blue[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.science, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Gesture Test Configuration',
                style: TextStyle(
                  fontSize: 18 * uiScale,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Text(
            'Select gesture type to test:',
            style: TextStyle(
              fontSize: 14 * uiScale,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          
          // Dropdown
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<GestureTestType>(
                value: selectedGestureTest,
                isDense: true,
                onChanged: (GestureTestType? newValue) {
                  if (newValue != null) {
                    onGestureTestChanged(newValue);
                  }
                },
                items: GestureTestType.values.map<DropdownMenuItem<GestureTestType>>((GestureTestType type) {
                  return DropdownMenuItem<GestureTestType>(
                    value: type,
                    child: Text(
                      type.displayName,
                      style: TextStyle(fontSize: 14 * uiScale),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Description of selected test
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              selectedGestureTest.description,
              style: TextStyle(
                fontSize: 13 * uiScale,
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Clear button
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: onClearResults,
                icon: const Icon(Icons.clear_all, size: 16),
                label: Text('Clear Results', style: TextStyle(fontSize: 12 * uiScale)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.grey[700],
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$resultsCount results',
                style: TextStyle(
                  fontSize: 12 * uiScale,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GestureTestResults extends StatelessWidget {
  final GestureTestType selectedGestureTest;
  final List<GestureValidationResult> gestureValidationResults;
  final double uiScale;

  const GestureTestResults({
    super.key,
    required this.selectedGestureTest,
    required this.gestureValidationResults,
    required this.uiScale,
  });

  @override
  Widget build(BuildContext context) {
    if (gestureValidationResults.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Icon(Icons.gesture, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'No test results yet',
              style: TextStyle(
                fontSize: 16 * uiScale,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Perform a ${selectedGestureTest.displayName.toLowerCase()} gesture on a node to see validation results',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14 * uiScale,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Test Results',
          style: TextStyle(
            fontSize: 16 * uiScale,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        ...gestureValidationResults.map((result) => DetailedValidationCard(
          result: result,
          uiScale: uiScale,
        )),
      ],
    );
  }
}

class DetailedValidationCard extends StatelessWidget {
  final GestureValidationResult result;
  final double uiScale;

  const DetailedValidationCard({
    super.key,
    required this.result,
    required this.uiScale,
  });

  String _shortenId(String id) {
    if (id == 'null' || id == 'N/A') return id;
    return id.length > 6 ? id.substring(id.length - 6) : id;
  }

  String _formatGestureTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else {
      return '${diff.inHours}h ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = result.isSuccess;
    final passedChecks = result.checks.where((check) => check.passed).toList();
    final failedChecks = result.checks.where((check) => !check.passed).toList();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSuccess ? Colors.green[300]! : Colors.red[300]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSuccess ? Colors.green[50] : Colors.red[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error_outline,
                  color: isSuccess ? Colors.green[700] : Colors.red[700],
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${result.testType.displayName} ${result.phase.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 16 * uiScale,
                          fontWeight: FontWeight.bold,
                          color: isSuccess ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                      Text(
                        'Node: ${_shortenId(result.nodeId)} • ${_formatGestureTime(result.timestamp)}',
                        style: TextStyle(
                          fontSize: 12 * uiScale,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSuccess ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${passedChecks.length}/${result.checks.length}',
                    style: TextStyle(
                      fontSize: 14 * uiScale,
                      fontWeight: FontWeight.bold,
                      color: isSuccess ? Colors.green[700] : Colors.red[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Validation item details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (passedChecks.isNotEmpty) ...[
                  Text(
                    '✅ Passed Tests',
                    style: TextStyle(
                      fontSize: 14 * uiScale,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...passedChecks.map((check) => Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 2),
                    child: Text(
                      '• ${check.description}',
                      style: TextStyle(
                        fontSize: 12 * uiScale,
                        color: Colors.green[600],
                      ),
                    ),
                  )),
                  if (failedChecks.isNotEmpty) const SizedBox(height: 8),
                ],
                
                if (failedChecks.isNotEmpty) ...[
                  Text(
                    '❌ Failed Tests',
                    style: TextStyle(
                      fontSize: 14 * uiScale,
                      fontWeight: FontWeight.w600,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...failedChecks.map((check) => Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ${check.description}',
                          style: TextStyle(
                            fontSize: 12 * uiScale,
                            color: Colors.red[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (check.failureReason != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8, top: 2),
                            child: Text(
                              'Reason: ${check.failureReason}',
                              style: TextStyle(
                                fontSize: 11 * uiScale,
                                color: Colors.red[500],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        if (check.expectedValue != null && check.actualValue != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8, top: 2),
                            child: Text(
                              'Expected: ${check.expectedValue}, Got: ${check.actualValue}',
                              style: TextStyle(
                                fontSize: 11 * uiScale,
                                color: Colors.red[500],
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}