import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models.dart';
import 'validation_engine.dart';

/// Enhanced validation tab with advanced features
class EnhancedGestureTestTab extends StatefulWidget {
  final GestureTestType selectedGestureTest;
  final List<EnhancedValidationResult> validationResults;
  final ValueChanged<GestureTestType> onGestureTestChanged;
  final VoidCallback onClearResults;
  final double uiScale;
  final AdvancedGestureValidator validator;

  const EnhancedGestureTestTab({
    super.key,
    required this.selectedGestureTest,
    required this.validationResults,
    required this.onGestureTestChanged,
    required this.onClearResults,
    required this.uiScale,
    required this.validator,
  });

  @override
  State<EnhancedGestureTestTab> createState() => _EnhancedGestureTestTabState();
}

class _EnhancedGestureTestTabState extends State<EnhancedGestureTestTab> {
  bool _showStatistics = true;
  bool _showSuggestions = true;
  ValidationSeverity? _severityFilter;

  @override
  Widget build(BuildContext context) {
    final statistics = widget.validator.getStatistics(widget.validationResults);
    final filteredResults = _filterResults(widget.validationResults);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Test configuration section
          EnhancedGestureTestSelector(
            selectedGestureTest: widget.selectedGestureTest,
            onGestureTestChanged: widget.onGestureTestChanged,
            onClearResults: widget.onClearResults,
            resultsCount: widget.validationResults.length,
            uiScale: widget.uiScale,
          ),
          const SizedBox(height: 16),

          // Statistics section
          if (_showStatistics) ...[
            ValidationStatisticsCard(
              statistics: statistics,
              uiScale: widget.uiScale,
              onToggle: () => setState(() => _showStatistics = !_showStatistics),
            ),
            const SizedBox(height: 16),
          ],

          // Filters and controls
          ValidationControlsBar(
            severityFilter: _severityFilter,
            onSeverityFilterChanged: (severity) => setState(() => _severityFilter = severity),
            showSuggestions: _showSuggestions,
            onShowSuggestionsChanged: (show) => setState(() => _showSuggestions = show),
            showStatistics: _showStatistics,
            onShowStatisticsChanged: (show) => setState(() => _showStatistics = show),
            uiScale: widget.uiScale,
          ),
          const SizedBox(height: 16),

          Divider(color: Colors.grey[400]),
          const SizedBox(height: 16),

          // Results section
          EnhancedGestureTestResults(
            selectedGestureTest: widget.selectedGestureTest,
            validationResults: filteredResults,
            showSuggestions: _showSuggestions,
            uiScale: widget.uiScale,
          ),
        ],
      ),
    );
  }

  List<EnhancedValidationResult> _filterResults(List<EnhancedValidationResult> results) {
    if (_severityFilter == null) return results;
    
    return results.where((result) {
      return result.checks.any((check) => check.severity == _severityFilter);
    }).toList();
  }
}

/// Enhanced test selector with more configuration options
class EnhancedGestureTestSelector extends StatelessWidget {
  final GestureTestType selectedGestureTest;
  final ValueChanged<GestureTestType> onGestureTestChanged;
  final VoidCallback onClearResults;
  final int resultsCount;
  final double uiScale;

  const EnhancedGestureTestSelector({
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
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.indigo[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.blue[200]!),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.science, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Advanced Gesture Validation',
                      style: TextStyle(
                        fontSize: 18 * uiScale,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    Text(
                      'Enhanced testing with configurable rules and performance metrics',
                      style: TextStyle(
                        fontSize: 12 * uiScale,
                        color: Colors.blue[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Text(
            'Gesture Type:',
            style: TextStyle(
              fontSize: 14 * uiScale,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          
          // Enhanced dropdown with icons
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 2,
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<GestureTestType>(
                value: selectedGestureTest,
                isDense: true,
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                onChanged: (GestureTestType? newValue) {
                  if (newValue != null) {
                    onGestureTestChanged(newValue);
                  }
                },
                items: GestureTestType.values.map<DropdownMenuItem<GestureTestType>>((type) {
                  return DropdownMenuItem<GestureTestType>(
                    value: type,
                    child: Row(
                      children: [
                        Icon(_getGestureIcon(type), size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          type.displayName,
                          style: TextStyle(fontSize: 14 * uiScale),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Test description
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedGestureTest.description,
                    style: TextStyle(
                      fontSize: 13 * uiScale,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: onClearResults,
                icon: const Icon(Icons.clear_all, size: 16),
                label: Text('Clear Results', style: TextStyle(fontSize: 12 * uiScale)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red[700],
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.analytics, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '$resultsCount validations',
                      style: TextStyle(
                        fontSize: 12 * uiScale,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getGestureIcon(GestureTestType type) {
    switch (type) {
      case GestureTestType.tap:
        return Icons.touch_app;
      case GestureTestType.doubleTap:
        return Icons.double_arrow;
      case GestureTestType.drag:
        return Icons.drag_indicator;
      case GestureTestType.hover:
        return Icons.mouse;
      case GestureTestType.longPress:
        return Icons.timer;
      case GestureTestType.tapAndHold:
        return Icons.pan_tool;
    }
  }
}

/// Statistics card showing validation metrics
class ValidationStatisticsCard extends StatelessWidget {
  final ValidationStatistics statistics;
  final double uiScale;
  final VoidCallback onToggle;

  const ValidationStatisticsCard({
    super.key,
    required this.statistics,
    required this.uiScale,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[50]!, Colors.teal[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[600],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.analytics, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Validation Statistics',
                    style: TextStyle(
                      fontSize: 16 * uiScale,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onToggle,
                  icon: const Icon(Icons.expand_less),
                  color: Colors.green[600],
                ),
              ],
            ),
          ),
          
          // Statistics grid
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _StatisticTile(
                            icon: Icons.check_circle_outline,
                            label: 'Success Rate',
                            value: '${(statistics.successRate * 100).toStringAsFixed(1)}%',
                            color: Colors.green,
                            uiScale: uiScale,
                          ),
                          const SizedBox(height: 12),
                          _StatisticTile(
                            icon: Icons.error_outline,
                            label: 'Errors',
                            value: '${statistics.errorCount}',
                            color: Colors.red,
                            uiScale: uiScale,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          _StatisticTile(
                            icon: Icons.speed,
                            label: 'Avg Time',
                            value: '${(statistics.averageValidationTime.inMicroseconds / 1000).toStringAsFixed(1)}ms',
                            color: Colors.blue,
                            uiScale: uiScale,
                          ),
                          const SizedBox(height: 12),
                          _StatisticTile(
                            icon: Icons.warning_amber_outlined,
                            label: 'Warnings',
                            value: '${statistics.warningCount}',
                            color: Colors.orange,
                            uiScale: uiScale,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatisticTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final MaterialColor color;
  final double uiScale;

  const _StatisticTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.uiScale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 70,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color[600], size: 18),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13 * uiScale,
              fontWeight: FontWeight.bold,
              color: color[700],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9 * uiScale,
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Controls bar with filters and options
class ValidationControlsBar extends StatelessWidget {
  final ValidationSeverity? severityFilter;
  final ValueChanged<ValidationSeverity?> onSeverityFilterChanged;
  final bool showSuggestions;
  final ValueChanged<bool> onShowSuggestionsChanged;
  final bool showStatistics;
  final ValueChanged<bool> onShowStatisticsChanged;
  final double uiScale;

  const ValidationControlsBar({
    super.key,
    required this.severityFilter,
    required this.onSeverityFilterChanged,
    required this.showSuggestions,
    required this.onShowSuggestionsChanged,
    required this.showStatistics,
    required this.onShowStatisticsChanged,
    required this.uiScale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Display Options',
            style: TextStyle(
              fontSize: 14 * uiScale,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              // Severity filter
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Filter:',
                    style: TextStyle(fontSize: 12 * uiScale, color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<ValidationSeverity?>(
                    value: severityFilter,
                    underline: const SizedBox(),
                    isDense: true,
                    onChanged: onSeverityFilterChanged,
                    items: [
                      const DropdownMenuItem<ValidationSeverity?>(
                        value: null,
                        child: Text('All'),
                      ),
                      ...ValidationSeverity.values.map((severity) =>
                        DropdownMenuItem<ValidationSeverity?>(
                          value: severity,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _SeverityIcon(severity: severity, size: 12),
                              const SizedBox(width: 4),
                              Text(severity.displayName),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Show suggestions toggle
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: showSuggestions,
                    onChanged: (value) => onShowSuggestionsChanged(value ?? false),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  Text(
                    'Show suggestions',
                    style: TextStyle(fontSize: 12 * uiScale, color: Colors.grey[700]),
                  ),
                ],
              ),
              
              // Show statistics toggle
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: showStatistics,
                    onChanged: (value) => onShowStatisticsChanged(value ?? false),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  Text(
                    'Show statistics',
                    style: TextStyle(fontSize: 12 * uiScale, color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Enhanced test results display
class EnhancedGestureTestResults extends StatelessWidget {
  final GestureTestType selectedGestureTest;
  final List<EnhancedValidationResult> validationResults;
  final bool showSuggestions;
  final double uiScale;

  const EnhancedGestureTestResults({
    super.key,
    required this.selectedGestureTest,
    required this.validationResults,
    required this.showSuggestions,
    required this.uiScale,
  });

  @override
  Widget build(BuildContext context) {
    if (validationResults.isEmpty) {
      return _EmptyResultsWidget(
        selectedGestureTest: selectedGestureTest,
        uiScale: uiScale,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Validation Results',
              style: TextStyle(
                fontSize: 16 * uiScale,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _exportResults(context),
              icon: const Icon(Icons.download, size: 16),
              label: Text('Export', style: TextStyle(fontSize: 12 * uiScale)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...validationResults.map((result) => EnhancedValidationCard(
          result: result,
          showSuggestions: showSuggestions,
          uiScale: uiScale,
        )),
      ],
    );
  }

  void _exportResults(BuildContext context) {
    // Export functionality - copy to clipboard for now
    final jsonData = validationResults.map((result) => {
      'timestamp': result.timestamp.toIso8601String(),
      'testType': result.testType.name,
      'phase': result.phase,
      'nodeId': result.nodeId,
      'success': result.isSuccess,
      'checks': result.checks.map((check) => {
        'id': check.id,
        'name': check.name,
        'passed': check.passed,
        'severity': check.severity.name,
        'expectedValue': check.expectedValue,
        'actualValue': check.actualValue,
        'failureReason': check.failureReason,
      }).toList(),
    }).toList();

    Clipboard.setData(ClipboardData(text: jsonData.toString()));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Validation results copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Enhanced validation result card
class EnhancedValidationCard extends StatelessWidget {
  final EnhancedValidationResult result;
  final bool showSuggestions;
  final double uiScale;

  const EnhancedValidationCard({
    super.key,
    required this.result,
    required this.showSuggestions,
    required this.uiScale,
  });

  @override
  Widget build(BuildContext context) {
    final hasErrors = result.errorCount > 0;
    final hasWarnings = result.warningCount > 0;
    
    Color borderColor;
    Color backgroundColor;
    if (hasErrors) {
      borderColor = Colors.red[400]!;
      backgroundColor = Colors.red[50]!;
    } else if (hasWarnings) {
      borderColor = Colors.orange[400]!;
      backgroundColor = Colors.orange[50]!;
    } else {
      borderColor = Colors.green[400]!;
      backgroundColor = Colors.green[50]!;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with enhanced status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: _buildHeader(),
          ),
          
          // Validation checks
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildChecksSection(),
                
                // Suggestions section
                if (showSuggestions && result.suggestions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSuggestionsSection(),
                ],
                
                // Performance metrics
                if (result.performanceMetrics != null) ...[
                  const SizedBox(height: 16),
                  _buildPerformanceSection(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _ResultStatusIcon(result: result),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${result.testType.displayName} ${result.phase.toUpperCase()}',
                style: TextStyle(
                  fontSize: 16 * uiScale,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                'Node: ${_shortenId(result.nodeId)} • ${_formatTime(result.timestamp)}',
                style: TextStyle(
                  fontSize: 12 * uiScale,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadges(),
      ],
    );
  }

  Widget _buildStatusBadges() {
    return Row(
      children: [
        if (result.errorCount > 0)
          _StatusBadge(
            count: result.errorCount,
            label: 'errors',
            color: Colors.red,
            uiScale: uiScale,
          ),
        if (result.warningCount > 0) ...[
          if (result.errorCount > 0) const SizedBox(width: 8),
          _StatusBadge(
            count: result.warningCount,
            label: 'warnings',
            color: Colors.orange,
            uiScale: uiScale,
          ),
        ],
        if (result.errorCount == 0 && result.warningCount == 0)
          _StatusBadge(
            count: result.passedCount,
            label: 'passed',
            color: Colors.green,
            uiScale: uiScale,
          ),
      ],
    );
  }

  Widget _buildChecksSection() {
    final groupedChecks = <ValidationSeverity, List<EnhancedValidationCheck>>{};
    for (final check in result.checks) {
      groupedChecks.putIfAbsent(check.severity, () => []).add(check);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group by severity
        ...groupedChecks.entries.map((entry) {
          final severity = entry.key;
          final checks = entry.value;
          final passed = checks.where((c) => c.passed).toList();
          final failed = checks.where((c) => !c.passed).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (failed.isNotEmpty) ...[
                _SeverityHeader(severity: severity, count: failed.length, failed: true, uiScale: uiScale),
                const SizedBox(height: 8),
                ...failed.map((check) => _CheckItem(check: check, uiScale: uiScale)),
                const SizedBox(height: 12),
              ],
              if (passed.isNotEmpty) ...[
                _SeverityHeader(severity: severity, count: passed.length, failed: false, uiScale: uiScale),
                const SizedBox(height: 8),
                ...passed.map((check) => _CheckItem(check: check, uiScale: uiScale)),
                const SizedBox(height: 12),
              ],
            ],
          );
        }),
      ],
    );
  }

  Widget _buildSuggestionsSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.blue[600], size: 16),
              const SizedBox(width: 8),
              Text(
                'Suggestions',
                style: TextStyle(
                  fontSize: 14 * uiScale,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...result.suggestions.map((suggestion) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: Colors.blue[600])),
                Expanded(
                  child: Text(
                    suggestion.description,
                    style: TextStyle(
                      fontSize: 12 * uiScale,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection() {
    final metrics = result.performanceMetrics!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.speed, color: Colors.grey[600], size: 16),
              const SizedBox(width: 8),
              Text(
                'Performance Metrics',
                style: TextStyle(
                  fontSize: 14 * uiScale,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            children: [
              _MetricChip(
                label: 'Validation',
                value: '${(metrics.validationDuration.inMicroseconds / 1000).toStringAsFixed(2)}ms',
                uiScale: uiScale,
              ),
              _MetricChip(
                label: 'Events',
                value: '${metrics.eventCount}',
                uiScale: uiScale,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _shortenId(String id) {
    if (id == 'null' || id == 'N/A') return id;
    return id.length > 8 ? '...${id.substring(id.length - 6)}' : id;
  }

  String _formatTime(DateTime time) {
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
}

// Supporting widgets

class _ResultStatusIcon extends StatelessWidget {
  final EnhancedValidationResult result;

  const _ResultStatusIcon({required this.result});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    
    if (result.errorCount > 0) {
      icon = Icons.error;
      color = Colors.red[600]!;
    } else if (result.warningCount > 0) {
      icon = Icons.warning;
      color = Colors.orange[600]!;
    } else {
      icon = Icons.check_circle;
      color = Colors.green[600]!;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final int count;
  final String label;
  final MaterialColor color;
  final double uiScale;

  const _StatusBadge({
    required this.count,
    required this.label,
    required this.color,
    required this.uiScale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color[300]!),
      ),
      child: Text(
        '$count $label',
        style: TextStyle(
          fontSize: 12 * uiScale,
          fontWeight: FontWeight.w600,
          color: color[700],
        ),
      ),
    );
  }
}

class _SeverityHeader extends StatelessWidget {
  final ValidationSeverity severity;
  final int count;
  final bool failed;
  final double uiScale;

  const _SeverityHeader({
    required this.severity,
    required this.count,
    required this.failed,
    required this.uiScale,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SeverityIcon(severity: severity, size: 16),
        const SizedBox(width: 8),
        Text(
          '${failed ? "Failed" : "Passed"} ${severity.displayName} Checks ($count)',
          style: TextStyle(
            fontSize: 14 * uiScale,
            fontWeight: FontWeight.w600,
            color: _getSeverityColor(severity),
          ),
        ),
      ],
    );
  }

  Color _getSeverityColor(ValidationSeverity severity) {
    switch (severity) {
      case ValidationSeverity.info:
        return Colors.blue[700]!;
      case ValidationSeverity.warning:
        return Colors.orange[700]!;
      case ValidationSeverity.error:
        return Colors.red[700]!;
      case ValidationSeverity.critical:
        return Colors.purple[700]!;
    }
  }
}

class _SeverityIcon extends StatelessWidget {
  final ValidationSeverity severity;
  final double size;

  const _SeverityIcon({required this.severity, required this.size});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    
    switch (severity) {
      case ValidationSeverity.info:
        icon = Icons.info_outline;
        color = Colors.blue[600]!;
        break;
      case ValidationSeverity.warning:
        icon = Icons.warning_amber_outlined;
        color = Colors.orange[600]!;
        break;
      case ValidationSeverity.error:
        icon = Icons.error_outline;
        color = Colors.red[600]!;
        break;
      case ValidationSeverity.critical:
        icon = Icons.dangerous_outlined;
        color = Colors.purple[600]!;
        break;
    }

    return Icon(icon, color: color, size: size);
  }
}

class _CheckItem extends StatelessWidget {
  final EnhancedValidationCheck check;
  final double uiScale;

  const _CheckItem({required this.check, required this.uiScale});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                check.passed ? Icons.check_circle_outline : Icons.cancel_outlined,
                color: check.passed ? Colors.green[600] : Colors.red[600],
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  check.description,
                  style: TextStyle(
                    fontSize: 13 * uiScale,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (!check.passed && check.failureReason != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                check.failureReason!,
                style: TextStyle(
                  fontSize: 12 * uiScale,
                  color: Colors.red[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          if (check.expectedValue != null && check.actualValue != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                'Expected: ${check.expectedValue}, Got: ${check.actualValue}',
                style: TextStyle(
                  fontSize: 11 * uiScale,
                  color: Colors.grey[600],
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final double uiScale;

  const _MetricChip({
    required this.label,
    required this.value,
    required this.uiScale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 11 * uiScale,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11 * uiScale,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyResultsWidget extends StatelessWidget {
  final GestureTestType selectedGestureTest;
  final double uiScale;

  const _EmptyResultsWidget({
    required this.selectedGestureTest,
    required this.uiScale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.gesture,
              size: 48,
              color: Colors.blue[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No validation results yet',
            style: TextStyle(
              fontSize: 18 * uiScale,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Perform a ${selectedGestureTest.displayName.toLowerCase()} gesture on a node to see enhanced validation results',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14 * uiScale,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, color: Colors.blue[600], size: 16),
                const SizedBox(width: 8),
                Text(
                  'Enhanced validation includes performance metrics and suggestions',
                  style: TextStyle(
                    fontSize: 12 * uiScale,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}