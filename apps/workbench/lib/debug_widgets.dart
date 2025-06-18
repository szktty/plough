import 'package:flutter/material.dart';
import 'dart:convert';
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
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4, right: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getEventColor(event.type),
                ),
              ),
              Expanded(
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
                        if (hasJsonData)
                          IconButton(
                            icon: Icon(
                              _isExpanded ? Icons.expand_less : Icons.expand_more,
                              size: 20 * widget.uiScale,
                            ),
                            onPressed: () {
                              setState(() {
                                _isExpanded = !_isExpanded;
                              });
                            },
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
        String valueStr;
        if (entry.value is Map || entry.value is List) {
          valueStr = const JsonEncoder.withIndent('  ').convert(entry.value);
        } else {
          valueStr = entry.value?.toString() ?? 'null';
        }
        
        return TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12, bottom: 4),
              child: Text(
                '${entry.key}:',
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
                valueStr,
                style: TextStyle(
                  fontSize: 14 * widget.uiScale,
                  fontFamily: 'monospace',
                  color: Colors.grey[800],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
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