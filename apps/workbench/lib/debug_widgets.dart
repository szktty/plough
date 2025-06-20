import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:super_clipboard/super_clipboard.dart';
import 'models.dart';

class ExpandableDebugEvent extends StatefulWidget {
  final DebugEvent event;
  final int index;
  final double uiScale;

  const ExpandableDebugEvent({
    super.key,
    required this.event,
    required this.index,
    required this.uiScale,
  });

  @override
  State<ExpandableDebugEvent> createState() => _ExpandableDebugEventState();
}

class _ExpandableDebugEventState extends State<ExpandableDebugEvent> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final hasJsonData = event.jsonData != null && event.jsonData!.isNotEmpty;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.index % 2 == 0 ? Colors.white : Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Expand/collapse handle on the left
              if (hasJsonData)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Container(
                    width: 24 * widget.uiScale,
                    height: 24 * widget.uiScale,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 18 * widget.uiScale,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              // Event type indicator
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 8, right: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getEventColor(event.type),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: hasJsonData ? () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  } : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.message,
                              style: TextStyle(fontSize: 16 * widget.uiScale),
                            ),
                          ),
                          // Copy button on the right
                          IconButton(
                            icon: Icon(
                              Icons.copy,
                              size: 18 * widget.uiScale,
                            ),
                            onPressed: () => _copyEventToClipboard(),
                            tooltip: 'Copy log to clipboard',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      Text(
                        '${event.source} - ${_formatTime(event.timestamp)}',
                        style: TextStyle(
                          fontSize: 16 * widget.uiScale,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (!hasJsonData && event.details != null)
                        Text(
                          event.details!,
                          style: TextStyle(
                            fontSize: 16 * widget.uiScale,
                            color: Colors.grey[700],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isExpanded && hasJsonData)
            Container(
              margin: const EdgeInsets.only(left: 16, top: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: _buildJsonTable(event.jsonData!),
            ),
        ],
      ),
    );
  }

  Widget _buildJsonTable(Map<String, dynamic> data) {
    final entries = data.entries.toList();
    
    return Table(
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
      },
      children: entries.map((entry) {
        final humanReadableKey = _getHumanReadableKey(entry.key);
        final formattedValue = _formatValue(entry.key, entry.value);
        
        return TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12, bottom: 4),
              child: Text(
                '$humanReadableKey:',
                style: TextStyle(
                  fontSize: 14 * widget.uiScale,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SelectableText(
                formattedValue,
                style: TextStyle(
                  fontSize: 14 * widget.uiScale,
                  fontFamily: entry.value is Map || entry.value is List ? 'monospace' : null,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _getHumanReadableKey(String key) {
    const keyTranslations = {
      // Event information
      'event_type': 'Event Type',
      'phase': 'Phase',
      'timestamp': 'Timestamp',
      
      // Entity information
      'nodeTargetId': 'Target Node',
      'entityId': 'Entity ID',
      'tracked_entity_id': 'Tracked Entity',
      'node_at_position': 'Node at Position',
      
      // State information
      'state_exists': 'State Exists',
      'state_completed': 'State Completed',
      'state_cancelled': 'State Cancelled',
      'tap_count': 'Tap Count',
      
      // Drag information
      'is_still_dragging_after_up': 'Still Dragging After Up',
      'is_tap_completed_after_up': 'Tap Completed After Up',
      'will_toggle_selection': 'Will Toggle Selection',
      'drag_state_exists': 'Drag State Exists',
      'drag_manager_is_dragging': 'Drag Manager Active',
      
      // Touch/gesture information
      'touch_slop': 'Touch Slop',
      'k_touch_slop': 'Touch Slop Constant',
      'distance': 'Distance',
      'isWithinSlop': 'Within Slop',
      'gesture_mode': 'Gesture Mode',
      
      // Position information
      'pointer_position': 'Pointer Position',
      'node_position': 'Node Position',
      'down_position': 'Down Position',
      'up_position': 'Up Position',
      'downPosition': 'Down Position',
      
      // Node capabilities
      'node_can_select': 'Node Can Select',
      'node_can_drag': 'Node Can Drag',
      'node_is_selected': 'Node Is Selected',
      
      // Timing information
      'downTime': 'Down Time',
      'timeout_ms': 'Timeout (ms)',
      'double_tap_timeout_ms': 'Double Tap Timeout (ms)',
      'has_double_tap_timer': 'Has Double Tap Timer',
      'time_since_down_ms': 'Time Since Down (ms)',
      
      // State counts
      'tap_manager_states_count': 'Tap Manager States Count',
      
      // Debug information
      'tap_debug_info': 'Tap Debug Info',
      'completed': 'Completed',
      'cancelled': 'Cancelled',
      'tapCount': 'Tap Count',
      
      // Failure information
      'failure_reason': 'Failure Reason',
      'reason': 'Reason',
    };
    
    return keyTranslations[key] ?? _convertCamelCaseToReadable(key);
  }
  
  String _convertCamelCaseToReadable(String camelCase) {
    // Convert camelCase to readable format
    final result = camelCase.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );
    
    // Convert underscores to spaces and capitalize first letter
    return result
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
  
  String _formatValue(String key, dynamic value) {
    if (value == null) return 'null';
    
    // Format specific value types
    if (key.contains('position') && value is Map<String, dynamic>) {
      final x = value['x']?.toString() ?? '0';
      final y = value['y']?.toString() ?? '0';
      return '($x, $y)';
    }
    
    if (key.contains('Id') || key.contains('entity')) {
      final str = value.toString();
      if (str != 'null' && str.length > 8) {
        return '${str.substring(0, 8)}...';
      }
    }
    
    if (key.contains('Time') && value is int) {
      return '${value}ms';
    }
    
    if (value is bool) {
      return value ? 'true' : 'false';
    }
    
    if (value is Map || value is List) {
      return const JsonEncoder.withIndent('  ').convert(value);
    }
    
    return value.toString();
  }

  Future<void> _copyEventToClipboard() async {
    try {
      final event = widget.event;
      
      // Create a comprehensive log entry
      final logData = {
        'timestamp': event.timestamp.toIso8601String(),
        'type': event.type.toString(),
        'source': event.source,
        'message': event.message,
        if (event.details != null) 'details': event.details,
        if (event.jsonData != null) 'data': event.jsonData,
      };
      
      // Format as readable JSON
      final jsonString = const JsonEncoder.withIndent('  ').convert(logData);
      
      // Copy to clipboard
      final clipboard = SystemClipboard.instance;
      if (clipboard != null) {
        final item = DataWriterItem();
        item.add(Formats.plainText(jsonString));
        await clipboard.write([item]);
        
        // Show success feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Log copied to clipboard'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Failed to copy to clipboard: $e');
      
      // Show error feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Copy failed: $e'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getEventColor(EventType type) {
    switch (type) {
      case EventType.gesture:
        return Colors.red;
      case EventType.callback:
        return Colors.brown;
      case EventType.layout:
        return Colors.pink;
      case EventType.rebuild:
        return Colors.orange;
      case EventType.notification:
        return Colors.teal;
    }
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

class TapValidationSection extends StatelessWidget {
  final List<GestureValidationResult> gestureValidationResults;
  final double uiScale;

  const TapValidationSection({
    super.key,
    required this.gestureValidationResults,
    required this.uiScale,
  });

  @override
  Widget build(BuildContext context) {
    final recentResults = gestureValidationResults.take(3).toList();
    
    if (recentResults.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tap Validation (Live Tests)',
            style: TextStyle(
              fontSize: 16 * uiScale,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No tap attempts yet',
            style: TextStyle(
              fontSize: 14 * uiScale,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.fact_check, size: 18, color: Colors.blue[700]),
            const SizedBox(width: 4),
            Text(
              'Tap Validation (Live Tests)',
              style: TextStyle(
                fontSize: 16 * uiScale,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...recentResults.map((result) => ValidationResultCard(
          result: result,
          uiScale: uiScale,
        )),
      ],
    );
  }
}

class ValidationResultCard extends StatelessWidget {
  final GestureValidationResult result;
  final double uiScale;

  const ValidationResultCard({
    super.key,
    required this.result,
    required this.uiScale,
  });

  String _shortenId(String id) {
    if (id == 'null' || id == 'N/A') return id;
    return id.length > 6 ? id.substring(id.length - 6) : id;
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = result.isSuccess;
    final failedChecks = result.checks.where((check) => !check.passed).toList();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSuccess ? Colors.green[50] : Colors.red[50],
        border: Border.all(
          color: isSuccess ? Colors.green[300]! : Colors.red[300]!,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                size: 16,
                color: isSuccess ? Colors.green[700] : Colors.red[700],
              ),
              const SizedBox(width: 4),
              Text(
                '${result.phase.toUpperCase()} - ${_shortenId(result.nodeId)}',
                style: TextStyle(
                  fontSize: 14 * uiScale,
                  fontWeight: FontWeight.bold,
                  color: isSuccess ? Colors.green[700] : Colors.red[700],
                ),
              ),
              const Spacer(),
              Text(
                '${result.checks.where((c) => c.passed).length}/${result.checks.length}',
                style: TextStyle(
                  fontSize: 12 * uiScale,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          if (!isSuccess && failedChecks.isNotEmpty) ...[
            const SizedBox(height: 4),
            ...failedChecks.take(2).map((check) => Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                '✗ ${check.description}${check.failureReason != null ? ': ${check.failureReason}' : ''}',
                style: TextStyle(
                  fontSize: 12 * uiScale,
                  color: Colors.red[600],
                ),
              ),
            )),
            if (failedChecks.length > 2)
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  '... and ${failedChecks.length - 2} more failures',
                  style: TextStyle(
                    fontSize: 12 * uiScale,
                    color: Colors.red[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class DebugValueDisplay extends StatelessWidget {
  final String label;
  final String value;
  final double uiScale;

  const DebugValueDisplay({
    super.key,
    required this.label,
    required this.value,
    required this.uiScale,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          SizedBox(
            width: 120 * uiScale,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14 * uiScale,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                fontSize: 14 * uiScale,
                color: Colors.grey[800],
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PositionInfo extends StatelessWidget {
  final String label;
  final dynamic position;
  final double uiScale;

  const PositionInfo({
    super.key,
    required this.label,
    required this.position,
    required this.uiScale,
  });

  @override
  Widget build(BuildContext context) {
    String positionText = 'N/A';
    if (position is Map<String, dynamic>) {
      final x = position['x']?.toString() ?? '0';
      final y = position['y']?.toString() ?? '0';
      positionText = '($x, $y)';
    } else if (position != null) {
      positionText = position.toString();
    }

    return DebugValueDisplay(
      label: label,
      value: positionText,
      uiScale: uiScale,
    );
  }
}

class GestureStateDisplay extends StatelessWidget {
  final bool isDragging;
  final bool isHovering;
  final bool isTapTracking;
  final String? lastDraggedEntityId;
  final String? hoveredEntityId;
  final String? trackedTapEntityId;
  final int currentTapCount;
  final int? doubleTapTimeRemaining;
  final int totalGestureEvents;
  final Map<String, dynamic> internalDebugState;
  final double uiScale;

  const GestureStateDisplay({
    super.key,
    required this.isDragging,
    required this.isHovering,
    required this.isTapTracking,
    required this.lastDraggedEntityId,
    required this.hoveredEntityId,
    required this.trackedTapEntityId,
    required this.currentTapCount,
    required this.doubleTapTimeRemaining,
    required this.totalGestureEvents,
    required this.internalDebugState,
    required this.uiScale,
  });

  String _shortenId(String? id) {
    if (id == null || id == 'null' || id == 'N/A') return id ?? 'None';
    return id.length > 6 ? id.substring(id.length - 6) : id;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DebugValueDisplay(
          label: 'Dragging',
          value: isDragging ? 'Active' : 'Inactive',
          uiScale: uiScale,
        ),
        DebugValueDisplay(
          label: 'Hovering',
          value: isHovering ? 'Active' : 'Inactive',
          uiScale: uiScale,
        ),
        DebugValueDisplay(
          label: 'Tap Tracking',
          value: isTapTracking ? 'Active' : 'Inactive',
          uiScale: uiScale,
        ),
        const SizedBox(height: 4),
        DebugValueDisplay(
          label: 'Last Dragged',
          value: _shortenId(lastDraggedEntityId),
          uiScale: uiScale,
        ),
        DebugValueDisplay(
          label: 'Hovered Entity',
          value: _shortenId(hoveredEntityId),
          uiScale: uiScale,
        ),
        DebugValueDisplay(
          label: 'Tap Target',
          value: _shortenId(trackedTapEntityId),
          uiScale: uiScale,
        ),
        const SizedBox(height: 4),
        DebugValueDisplay(
          label: 'Tap Count',
          value: currentTapCount.toString(),
          uiScale: uiScale,
        ),
        DebugValueDisplay(
          label: 'Double-tap Timer',
          value: doubleTapTimeRemaining != null ? '${doubleTapTimeRemaining}ms' : 'Inactive',
          uiScale: uiScale,
        ),
        DebugValueDisplay(
          label: 'Total Gestures',
          value: totalGestureEvents.toString(),
          uiScale: uiScale,
        ),
        const SizedBox(height: 8),
        InternalDetailsSection(
          internalDebugState: internalDebugState,
          uiScale: uiScale,
        ),
      ],
    );
  }
}

class InternalDetailsSection extends StatelessWidget {
  final Map<String, dynamic> internalDebugState;
  final double uiScale;

  const InternalDetailsSection({
    super.key,
    required this.internalDebugState,
    required this.uiScale,
  });

  String _shortenId(String id) {
    if (id == 'null' || id == 'N/A') return id;
    return id.length > 6 ? id.substring(id.length - 6) : id;
  }

  @override
  Widget build(BuildContext context) {
    final tapDebugInfo = internalDebugState['tap_debug_info'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Internal Details',
          style: TextStyle(
            fontSize: 16 * uiScale,
            fontWeight: FontWeight.bold,
            color: Colors.indigo[700],
          ),
        ),
        const SizedBox(height: 4),
        
        DebugValueDisplay(
          label: 'Node Position',
          value: internalDebugState['node_position']?.toString() ?? 'N/A',
          uiScale: uiScale,
        ),
        DebugValueDisplay(
          label: 'Pointer Position',
          value: internalDebugState['pointer_position']?.toString() ?? 'N/A',
          uiScale: uiScale,
        ),
        DebugValueDisplay(
          label: 'Node At Position',
          value: _shortenId(internalDebugState['node_at_position']?.toString() ?? 'null'),
          uiScale: uiScale,
        ),
        DebugValueDisplay(
          label: 'Gesture Mode',
          value: internalDebugState['gesture_mode']?.toString() ?? 'unknown',
          uiScale: uiScale,
        ),
        DebugValueDisplay(
          label: 'Node Can Select',
          value: internalDebugState['node_can_select']?.toString() ?? 'false',
          uiScale: uiScale,
        ),
        DebugValueDisplay(
          label: 'Node Can Drag',
          value: internalDebugState['node_can_drag']?.toString() ?? 'false',
          uiScale: uiScale,
        ),
        DebugValueDisplay(
          label: 'Node Is Selected',
          value: internalDebugState['node_is_selected']?.toString() ?? 'false',
          uiScale: uiScale,
        ),
        DebugValueDisplay(
          label: 'States Count',
          value: internalDebugState['tap_manager_states_count']?.toString() ?? '0',
          uiScale: uiScale,
        ),
        DebugValueDisplay(
          label: 'Drag State Exists',
          value: internalDebugState['drag_state_exists']?.toString() ?? 'false',
          uiScale: uiScale,
        ),
        DebugValueDisplay(
          label: 'Drag Manager Dragging',
          value: internalDebugState['drag_manager_is_dragging']?.toString() ?? 'false',
          uiScale: uiScale,
        ),
        
        if (tapDebugInfo != null) ...[
          const SizedBox(height: 8),
          ...TapDebugInfoSection(
            tapDebugInfo: tapDebugInfo,
            uiScale: uiScale,
          ).build(),
        ],
      ],
    );
  }
}

class TapDebugInfoSection {
  final dynamic tapDebugInfo;
  final double uiScale;

  const TapDebugInfoSection({
    required this.tapDebugInfo,
    required this.uiScale,
  });

  String _shortenId(String id) {
    if (id == 'null' || id == 'N/A') return id;
    return id.length > 6 ? id.substring(id.length - 6) : id;
  }

  List<Widget> build() {
    if (tapDebugInfo is! Map<String, dynamic>) {
      return [DebugValueDisplay(
        label: 'Tap Debug Info',
        value: 'Invalid data',
        uiScale: uiScale,
      )];
    }
    
    final List<Widget> widgets = [];
    widgets.add(Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: Text(
        'Tap State Manager Details:',
        style: TextStyle(
          fontSize: 16 * uiScale,
          fontWeight: FontWeight.bold,
          color: Colors.indigo[700],
        ),
      ),
    ));
    
    (tapDebugInfo as Map<String, dynamic>).forEach((key, value) {
      final displayKey = key.replaceAll('_', ' ').split(' ').map((word) => 
        word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : word
      ).join(' ');
      
      if (key == 'down_position' || key == 'up_position') {
        widgets.add(PositionInfo(
          label: displayKey,
          position: value,
          uiScale: uiScale,
        ));
      } else if (key.contains('entityId') || key.contains('entity_id')) {
        widgets.add(DebugValueDisplay(
          label: displayKey,
          value: _shortenId(value.toString()),
          uiScale: uiScale,
        ));
      } else {
        widgets.add(DebugValueDisplay(
          label: displayKey,
          value: value.toString(),
          uiScale: uiScale,
        ));
      }
    });
    
    return widgets;
  }
}