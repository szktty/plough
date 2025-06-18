import 'package:flutter/material.dart';
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
}