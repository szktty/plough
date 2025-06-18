import 'package:flutter/material.dart';
import 'package:plough/plough.dart';
import 'models.dart';

// Custom GraphView with debug instrumentation
class DebugGraphView extends StatefulWidget {
  final Graph graph;
  final Function(DebugEvent) onEvent;
  final VoidCallback onRebuild;
  final bool monitorCallbacks;
  final bool monitorRebuilds;
  final bool animationEnabled;
  final Function(String, Map<String, dynamic>)? updateGestureState;
  final GraphGestureMode gestureMode;
  final GraphBackgroundGestureCallback? onBackgroundTapped;
  final GraphBackgroundGestureCallback? onBackgroundPanStart;
  final GraphBackgroundPanCallback? onBackgroundPanUpdate;
  final GraphBackgroundGestureCallback? onBackgroundPanEnd;

  const DebugGraphView({
    super.key,
    required this.graph,
    required this.onEvent,
    required this.onRebuild,
    required this.monitorCallbacks,
    required this.monitorRebuilds,
    required this.animationEnabled,
    this.updateGestureState,
    this.gestureMode = GraphGestureMode.exclusive,
    this.onBackgroundTapped,
    this.onBackgroundPanStart,
    this.onBackgroundPanUpdate,
    this.onBackgroundPanEnd,
  });

  @override
  State<DebugGraphView> createState() => _DebugGraphViewState();
}

class _DebugGraphViewState extends State<DebugGraphView> {
  @override
  Widget build(BuildContext context) {
    if (widget.monitorRebuilds) {
      // Increment counter but don't log event to avoid rebuild loop
      widget.onRebuild();
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    debugPrint('DebugGraphView rebuild - isDarkMode: $isDarkMode');

    return GraphView(
      key: ValueKey('${widget.graph.hashCode}_$isDarkMode'), // Include dark mode in key to force rebuild
      graph: widget.graph,
      layoutStrategy: GraphForceDirectedLayoutStrategy(),
      animationEnabled: widget.animationEnabled,
      behavior: _createDebugBehavior(context),
      gestureMode: widget.gestureMode,
      allowSelection: true, // Enable selection for tap/double-tap
      onBackgroundTapped: widget.onBackgroundTapped,
      onBackgroundPanStart: widget.onBackgroundPanStart,
      onBackgroundPanUpdate: widget.onBackgroundPanUpdate,
      onBackgroundPanEnd: widget.onBackgroundPanEnd,
    );
  }

  GraphViewBehavior _createDebugBehavior(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return DebugGraphViewBehavior(
      onEvent: widget.onEvent,
      monitorCallbacks: widget.monitorCallbacks,
      updateGestureState: widget.updateGestureState,
      isDarkMode: isDarkMode,
    );
  }
}

// Custom behavior for debugging
class DebugGraphViewBehavior extends GraphViewDefaultBehavior {
  final Function(DebugEvent) onEvent;
  final bool monitorCallbacks;
  final Function(String, Map<String, dynamic>)? updateGestureState;
  final bool isDarkMode;

  DebugGraphViewBehavior({
    required this.onEvent,
    required this.monitorCallbacks,
    this.updateGestureState,
    required this.isDarkMode,
  });

  @override
  void onTap(GraphTapEvent event) {
    super.onTap(event);
    debugPrint('onTap');
    if (monitorCallbacks) {
      final hasEntities = event.entityIds.isNotEmpty;
      final details = hasEntities
          ? 'Entities: ${event.entityIds.length}, Tap count: ${event.tapCount}, Position: ${event.details.localPosition}'
          : 'Background tap at ${event.details.localPosition}';
      onEvent(DebugEvent(
        type: EventType.callback,
        source: 'DebugGraphViewBehavior',
        message: 'onTap fired',
        timestamp: DateTime.now(),
        details: details,
      ));
      // Update gesture state tracking
      updateGestureState?.call('tap', {
        'tracking': hasEntities,
        'tapCount': event.tapCount,
        'entityId': hasEntities ? event.entityIds.first.toString() : null,
      });
    }
  }

  @override
  void onSelectionChange(GraphSelectionChangeEvent event) {
    super.onSelectionChange(event);
    if (monitorCallbacks) {
      final selectedCount = event.selectedIds.length;
      final deselectedCount = event.deselectedIds.length;
      final currentCount = event.currentSelectionIds.length;
      onEvent(DebugEvent(
        type: EventType.callback,
        source: 'DebugGraphViewBehavior',
        message: 'onSelectionChange fired',
        timestamp: DateTime.now(),
        details:
            'Selected: $selectedCount, Deselected: $deselectedCount, Current: $currentCount',
      ));
    }
  }

  @override
  void onDragStart(GraphDragStartEvent event) {
    super.onDragStart(event);
    if (monitorCallbacks) {
      final hasEntities = event.entityIds.isNotEmpty;
      final details = hasEntities
          ? 'Entities: ${event.entityIds.length}, Position: ${event.details.localPosition}'
          : 'Background drag start at ${event.details.localPosition}';
      onEvent(DebugEvent(
        type: EventType.gesture,
        source: 'DebugGraphViewBehavior',
        message: 'onDragStart fired',
        timestamp: DateTime.now(),
        details: details,
      ));
      // Update gesture state tracking
      updateGestureState?.call('dragStart', {
        'entityId': hasEntities ? event.entityIds.first.toString() : null,
      });
    }
  }

  @override
  void onDragUpdate(GraphDragUpdateEvent event) {
    super.onDragUpdate(event);
    if (monitorCallbacks) {
      final hasEntities = event.entityIds.isNotEmpty;
      final details = hasEntities
          ? 'Entities: ${event.entityIds.length}, Delta: ${event.delta}'
          : 'Background drag, Delta: ${event.delta}';
      onEvent(DebugEvent(
        type: EventType.gesture,
        source: 'DebugGraphViewBehavior',
        message: 'onDragUpdate fired',
        timestamp: DateTime.now(),
        details: details,
      ));
    }
  }

  @override
  void onDragEnd(GraphDragEndEvent event) {
    super.onDragEnd(event);
    if (monitorCallbacks) {
      final hasEntities = event.entityIds.isNotEmpty;
      final details = hasEntities
          ? 'Entities: ${event.entityIds.length}, Position: ${event.details.localPosition}'
          : 'Background drag end at ${event.details.localPosition}';
      onEvent(DebugEvent(
        type: EventType.gesture,
        source: 'DebugGraphViewBehavior',
        message: 'onDragEnd fired',
        timestamp: DateTime.now(),
        details: details,
      ));
      // Update gesture state tracking
      updateGestureState?.call('dragEnd', {});
    }
  }

  @override
  void onHoverEnter(GraphHoverEvent event) {
    super.onHoverEnter(event);
    if (monitorCallbacks) {
      onEvent(DebugEvent(
        type: EventType.callback,
        source: 'DebugGraphViewBehavior',
        message: 'onHoverEnter fired',
        timestamp: DateTime.now(),
        details:
            'Entity ID: ${event.entityId}, Position: ${event.details.localPosition}',
      ));
      // Update gesture state tracking
      updateGestureState?.call('hoverEnter', {
        'entityId': event.entityId.toString(),
      });
    }
  }

  @override
  void onHoverMove(GraphHoverEvent event) {
    super.onHoverMove(event);
    if (monitorCallbacks) {
      onEvent(DebugEvent(
        type: EventType.callback,
        source: 'DebugGraphViewBehavior',
        message: 'onHoverMove fired',
        timestamp: DateTime.now(),
        details:
            'Entity ID: ${event.entityId}, Position: ${event.details.localPosition}',
      ));
    }
  }

  @override
  void onHoverEnd(GraphHoverEndEvent event) {
    super.onHoverEnd(event);
    if (monitorCallbacks) {
      onEvent(DebugEvent(
        type: EventType.callback,
        source: 'DebugGraphViewBehavior',
        message: 'onHoverEnd fired',
        timestamp: DateTime.now(),
        details: 'Position: ${event.details.localPosition}',
      ));
      // Update gesture state tracking
      updateGestureState?.call('hoverEnd', {});
    }
  }

  @override
  void onTooltipShow(GraphTooltipShowEvent event) {
    super.onTooltipShow(event);
    if (monitorCallbacks) {
      onEvent(DebugEvent(
        type: EventType.callback,
        source: 'DebugGraphViewBehavior',
        message: 'onTooltipShow fired',
        timestamp: DateTime.now(),
        details: 'Entity ID: ${event.entityId}',
      ));
    }
  }

  @override
  void onTooltipHide(GraphTooltipHideEvent event) {
    super.onTooltipHide(event);
    if (monitorCallbacks) {
      onEvent(DebugEvent(
        type: EventType.callback,
        source: 'DebugGraphViewBehavior',
        message: 'onTooltipHide fired',
        timestamp: DateTime.now(),
        details: 'Entity ID: ${event.entityId}',
      ));
    }
  }

  @override
  GraphNodeViewBehavior createNodeViewBehavior() {
    debugPrint('createNodeViewBehavior called - isDarkMode: $isDarkMode');
    final nodeColor = isDarkMode ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0);
    debugPrint('  Node color: $nodeColor');
    
    return GraphNodeViewBehavior.defaultBehavior(
      nodeRendererStyle: GraphDefaultNodeRendererStyle(
        color: nodeColor,
        borderColor: isDarkMode ? const Color(0xFF6B7280) : const Color(0xFF64748B),
        labelColor: isDarkMode ? Colors.white : const Color(0xFF1E293B),
        idColor: isDarkMode ? const Color(0xFFE5E7EB) : const Color(0xFF6B7280),
        hoverColor: isDarkMode ? const Color(0xFF374151) : const Color(0xFFDDD6FE),
        selectedHoverColor: isDarkMode ? const Color(0xFF059669) : const Color(0xFF10B981),
        selectedBorderColor: isDarkMode ? const Color(0xFF6366F1) : const Color(0xFF4F46E5),
        highlightColor: isDarkMode ? const Color(0xFFFBBF24) : const Color(0xFFFEF3C7),
      ),
    );
  }

  @override
  GraphLinkViewBehavior createLinkViewBehavior() {
    debugPrint('createLinkViewBehavior called - isDarkMode: $isDarkMode');
    final linkColor = isDarkMode ? Colors.white : const Color(0xFF374151);
    debugPrint('  Link color: $linkColor');
    
    return GraphLinkViewBehavior(
      builder: (context, graph, link, sourceView, targetView, routing, geometry, _) {
        return GraphDefaultLinkRenderer(
          link: link,
          sourceView: sourceView,
          targetView: targetView,
          routing: routing,
          geometry: geometry,
          style: GraphDefaultLinkRendererStyle(
            arrowColor: linkColor,
            borderColor: linkColor,
            labelColor: isDarkMode ? Colors.white : const Color(0xFF1F2937),
            hoverColor: isDarkMode ? const Color(0xFF6366F1) : const Color(0xFF8B5CF6),
            selectedHoverColor: isDarkMode ? const Color(0xFF10B981) : const Color(0xFF059669),
            selectedUnhoverColor: isDarkMode ? const Color(0xFF3B82F6) : const Color(0xFF2563EB),
            highlightColor: isDarkMode ? const Color(0xFFFBBF24) : const Color(0xFFFEF3C7),
          ),
          color: linkColor,
          thickness: 30,
        );
      },
      routing: GraphLinkRouting.straight,
    );
  }
}