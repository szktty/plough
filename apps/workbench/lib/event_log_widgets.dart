import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models.dart';
import 'debug_widgets.dart';
import 'gesture_validation.dart';
import 'workbench_state.dart';

class EventLogPanel extends StatelessWidget {
  final List<DebugEvent> events;
  final Set<EventType> timelineFilters;
  final Function(Set<EventType>) onTimelineFiltersChanged;
  final VoidCallback onClearEvents;
  final double uiScale;
  final Map<String, dynamic> internalDebugState;
  final bool isDragging;
  final bool isHovering;
  final bool isTapTracking;
  final String? lastDraggedEntityId;
  final String? hoveredEntityId;
  final String? trackedTapEntityId;
  final int currentTapCount;
  final int? doubleTapTimeRemaining;
  final int totalGestureEvents;
  final GestureTestType selectedGestureTest;
  final List<GestureValidationResult> gestureValidationResults;
  final Function(GestureTestType) onGestureTestChanged;
  final VoidCallback onClearValidationResults;

  const EventLogPanel({
    super.key,
    required this.events,
    required this.timelineFilters,
    required this.onTimelineFiltersChanged,
    required this.onClearEvents,
    required this.uiScale,
    required this.internalDebugState,
    required this.isDragging,
    required this.isHovering,
    required this.isTapTracking,
    required this.lastDraggedEntityId,
    required this.hoveredEntityId,
    required this.trackedTapEntityId,
    required this.currentTapCount,
    required this.doubleTapTimeRemaining,
    required this.totalGestureEvents,
    required this.selectedGestureTest,
    required this.gestureValidationResults,
    required this.onGestureTestChanged,
    required this.onClearValidationResults,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!),
      ),
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
              child: TabBar(
                labelColor: Colors.red[700],
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: Colors.red[700],
                labelStyle: TextStyle(fontSize: 12 * uiScale, fontWeight: FontWeight.bold),
                unselectedLabelStyle: TextStyle(fontSize: 12 * uiScale),
                tabs: const [
                  Tab(text: 'Event Log'),
                  Tab(text: 'State'),
                  Tab(text: 'Check'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildEventLogTab(context),
                  _buildStateDebugTab(context),
                  GestureTestTab(
                    selectedGestureTest: selectedGestureTest,
                    gestureValidationResults: gestureValidationResults,
                    onGestureTestChanged: onGestureTestChanged,
                    onClearResults: onClearValidationResults,
                    uiScale: uiScale,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventLogTab(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Filter events based on selected filters
    final filteredEvents = events
        .where((event) {
          if (timelineFilters.isEmpty) return true;
          return timelineFilters.contains(event.type);
        })
        .toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
          child: Row(
            children: [
              const Text('Event Log', style: TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(
                '${filteredEvents.length} events',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _copyAllEventsToClipboard(context),
                tooltip: 'Copy all events to clipboard',
                icon: const Icon(Icons.copy, size: 18),
                style: IconButton.styleFrom(
                  minimumSize: const Size(32, 32),
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 4),
              TextButton(
                onPressed: onClearEvents,
                style: TextButton.styleFrom(
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: Colors.transparent,
                ),
                child: const Text('Clear'),
              ),
            ],
          ),
        ),
        // Event type filters
        Container(
          padding: const EdgeInsets.all(8),
          color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter by Event Type:',
                style: TextStyle(
                  fontSize: 14 * uiScale,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: EventType.values.map((eventType) {
                  final isSelected = timelineFilters.contains(eventType);
                  return FilterChip(
                    label: Text(
                      getEventTypeLabel(eventType),
                      style: TextStyle(
                        fontSize: 14 * uiScale,
                        color: isSelected ? Colors.white : Colors.grey[700],
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: getEventColor(eventType),
                    onSelected: (selected) {
                      final newFilters = Set<EventType>.from(timelineFilters);
                      if (selected) {
                        newFilters.add(eventType);
                      } else {
                        newFilters.remove(eventType);
                      }
                      onTimelineFiltersChanged(newFilters);
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredEvents.length,
            itemBuilder: (context, index) {
              final event = filteredEvents[index];
              return ExpandableDebugEvent(
                event: event,
                index: index,
                uiScale: uiScale,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStateDebugTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Most critical info for immediate debugging
          Text(
            'Current State',
            style: TextStyle(
              fontSize: 16 * uiScale,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 4),
          DebugValueDisplay(
            label: 'Phase',
            value: internalDebugState['phase']?.toString() ?? 'none',
            uiScale: uiScale,
          ),
          DebugValueDisplay(
            label: 'Tap Completed',
            value: internalDebugState['is_tap_completed_after_up']?.toString() ?? 'N/A',
            uiScale: uiScale,
          ),
          DebugValueDisplay(
            label: 'Still Dragging',
            value: internalDebugState['is_still_dragging_after_up']?.toString() ?? 'N/A',
            uiScale: uiScale,
          ),
          DebugValueDisplay(
            label: 'Will Toggle',
            value: internalDebugState['will_toggle_selection']?.toString() ?? 'N/A',
            uiScale: uiScale,
          ),
          const SizedBox(height: 8),
          DebugValueDisplay(
            label: 'Node Target',
            value: shortenId(internalDebugState['nodeTargetId']?.toString() ?? 'null'),
            uiScale: uiScale,
          ),
          DebugValueDisplay(
            label: 'Distance',
            value: internalDebugState['distance']?.toString() ?? '0.0',
            uiScale: uiScale,
          ),
          DebugValueDisplay(
            label: 'Within Slop',
            value: internalDebugState['isWithinSlop']?.toString() ?? 'N/A',
            uiScale: uiScale,
          ),
          DebugValueDisplay(
            label: 'Touch Slop',
            value: internalDebugState['touch_slop']?.toString() ?? '144.0',
            uiScale: uiScale,
          ),
          const SizedBox(height: 8),
          // Failure reasons
          if (internalDebugState.containsKey('failure_reason'))
            DebugValueDisplay(
              label: 'Failure',
              value: internalDebugState['failure_reason']?.toString() ?? 'N/A',
              uiScale: uiScale,
            ),
          if (internalDebugState.containsKey('reason'))
            DebugValueDisplay(
              label: 'Reason',
              value: internalDebugState['reason']?.toString() ?? 'N/A',
              uiScale: uiScale,
            ),
          
          const SizedBox(height: 12),
          Divider(color: Colors.grey[400]),
          const SizedBox(height: 8),
          
          Text('Gesture State', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * uiScale)),
          const SizedBox(height: 4),
          GestureStateDisplay(
            isDragging: isDragging,
            isHovering: isHovering,
            isTapTracking: isTapTracking,
            lastDraggedEntityId: lastDraggedEntityId,
            hoveredEntityId: hoveredEntityId,
            trackedTapEntityId: trackedTapEntityId,
            currentTapCount: currentTapCount,
            doubleTapTimeRemaining: doubleTapTimeRemaining,
            totalGestureEvents: totalGestureEvents,
            internalDebugState: internalDebugState,
            uiScale: uiScale,
          ),
        ],
      ),
    );
  }

  Future<void> _copyAllEventsToClipboard(BuildContext context) async {
    try {
      final filteredEvents = events
          .where((event) {
            if (timelineFilters.isEmpty) return true;
            return timelineFilters.contains(event.type);
          })
          .toList();

      final buffer = StringBuffer();
      buffer.writeln('=== Event Log (${filteredEvents.length} events) ===');
      buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
      buffer.writeln();

      for (int i = 0; i < filteredEvents.length; i++) {
        final event = filteredEvents[i];
        buffer.writeln('[$i] ${event.timestamp.toIso8601String()}');
        buffer.writeln('    Type: ${getEventTypeLabel(event.type)}');
        buffer.writeln('    Source: ${event.source}');
        buffer.writeln('    Message: ${event.message}');
        
        // Include all details with proper formatting
        if (event.details != null && event.details!.isNotEmpty) {
          buffer.writeln('    Details: ${event.details}');
        }
        
        // Include JSON data if available
        if (event.jsonData != null && event.jsonData!.isNotEmpty) {
          buffer.writeln('    Data:');
          _formatDetailsMap(event.jsonData!, buffer, '        ');
        }
        
        // Also include raw JSON representation of the entire event
        buffer.writeln('    Raw JSON:');
        buffer.writeln('    ${_eventToJson(event)}');
        buffer.writeln();
      }

      await Clipboard.setData(ClipboardData(text: buffer.toString()));
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${filteredEvents.length} events copied to clipboard'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to copy events: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  
  void _formatDetailsMap(Map<String, dynamic> details, StringBuffer buffer, String indent) {
    details.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        buffer.writeln('$indent$key:');
        _formatDetailsMap(value, buffer, '$indent    ');
      } else if (value is List) {
        buffer.writeln('$indent$key: [');
        for (var item in value) {
          buffer.writeln('$indent    $item');
        }
        buffer.writeln('$indent]');
      } else {
        buffer.writeln('$indent$key: $value');
      }
    });
  }
  
  String _eventToJson(DebugEvent event) {
    final jsonMap = <String, dynamic>{
      'timestamp': event.timestamp.toIso8601String(),
      'type': event.type.toString(),
      'source': event.source,
      'message': event.message,
    };
    
    // Add optional fields if they exist
    if (event.details != null) jsonMap['details'] = event.details;
    if (event.jsonData != null) jsonMap['jsonData'] = event.jsonData;
    if (event.severity != null) jsonMap['severity'] = event.severity;
    if (event.entityId != null) jsonMap['entityId'] = event.entityId;
    if (event.gesturePhase != null) jsonMap['gesturePhase'] = event.gesturePhase;
    if (event.gestureType != null) jsonMap['gestureType'] = event.gestureType;
    
    // Simple JSON encoding with indentation
    return _encodeJsonPretty(jsonMap);
  }
  
  String _encodeJsonPretty(dynamic obj, [String indent = '']) {
    if (obj == null) return 'null';
    if (obj is String) return '"$obj"';
    if (obj is num || obj is bool) return obj.toString();
    
    if (obj is Map) {
      if (obj.isEmpty) return '{}';
      final entries = obj.entries.map((e) {
        final key = '"${e.key}"';
        final value = _encodeJsonPretty(e.value, '$indent  ');
        return '$indent  $key: $value';
      }).join(',\n');
      return '{\n$entries\n$indent}';
    }
    
    if (obj is List) {
      if (obj.isEmpty) return '[]';
      final items = obj.map((item) {
        return '$indent  ${_encodeJsonPretty(item, '$indent  ')}';
      }).join(',\n');
      return '[\n$items\n$indent]';
    }
    
    return obj.toString();
  }
}