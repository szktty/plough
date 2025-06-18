import 'package:flutter/material.dart';
import 'package:plough/plough.dart';
import 'debug_graph_view.dart';
import 'workbench_state.dart';
import 'models.dart';

class CentralArea extends StatelessWidget {
  final Graph graph;
  final int rebuildCount;
  final VoidCallback onRebuildCountChanged;
  final Function(DebugEvent) onEvent;
  final bool monitorCallbacks;
  final bool monitorRebuilds;
  final GraphGestureMode gestureMode;
  final Function(String, Map<String, dynamic>) updateGestureState;
  final Widget Function() buildToolbar;
  final bool animationEnabled;

  const CentralArea({
    super.key,
    required this.graph,
    required this.rebuildCount,
    required this.onRebuildCountChanged,
    required this.onEvent,
    required this.monitorCallbacks,
    required this.monitorRebuilds,
    required this.gestureMode,
    required this.updateGestureState,
    required this.buildToolbar,
    this.animationEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          buildToolbar(),
          Expanded(
            child: _buildGraphViewContainer(),
          ),
          _buildStatusBar(),
        ],
      ),
    );
  }

  Widget _buildGraphViewContainer() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRect(
        child: Stack(
          children: [
            // Dot grid background
            CustomPaint(
              painter: DotGridPainter(),
              size: Size.infinite,
            ),
            // Graph view on top
            DebugGraphView(
              graph: graph,
              onEvent: onEvent,
              onRebuild: onRebuildCountChanged,
              monitorCallbacks: monitorCallbacks,
              monitorRebuilds: monitorRebuilds,
              animationEnabled: animationEnabled,
              updateGestureState: updateGestureState,
              gestureMode: gestureMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey[300],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Nodes: ${graph.nodes.length}', style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 16),
          Text('Links: ${graph.links.length}', style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 16),
          Text('Rebuilds: $rebuildCount', style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class Toolbar extends StatelessWidget {
  final String currentLayoutStrategy;
  final Function(String?) onLayoutStrategyChanged;
  final VoidCallback onResetLayout;
  final GraphGestureMode gestureMode;
  final Function(GraphGestureMode?) onGestureModeChanged;
  final bool useInteractiveViewer;
  final Function(bool) onUseInteractiveViewerChanged;
  final bool gestureDebugMode;
  final Function(bool) onGestureDebugModeChanged;
  final double uiScale;
  final VoidCallback onDecreaseUIScale;
  final VoidCallback onIncreaseUIScale;

  const Toolbar({
    super.key,
    required this.currentLayoutStrategy,
    required this.onLayoutStrategyChanged,
    required this.onResetLayout,
    required this.gestureMode,
    required this.onGestureModeChanged,
    required this.useInteractiveViewer,
    required this.onUseInteractiveViewerChanged,
    required this.gestureDebugMode,
    required this.onGestureDebugModeChanged,
    required this.uiScale,
    required this.onDecreaseUIScale,
    required this.onIncreaseUIScale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey[200],
      child: Column(
        children: [
          // First row - Layout and data controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Layout strategy dropdown
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: currentLayoutStrategy,
                  onChanged: onLayoutStrategyChanged,
                  items: layoutStrategies.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(fontSize: 16 * uiScale)),
                    );
                  }).toList(),
                  isDense: true,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onResetLayout,
                tooltip: 'Reset Layout',
                icon: const Icon(Icons.restart_alt),
                iconSize: 20,
              ),
              const SizedBox(width: 16),
              // Gesture Mode dropdown
              DropdownButtonHideUnderline(
                child: DropdownButton<GraphGestureMode>(
                  value: gestureMode,
                  onChanged: onGestureModeChanged,
                  items: const [
                    DropdownMenuItem(
                      value: GraphGestureMode.exclusive,
                      child: Text('Exclusive', style: TextStyle(fontSize: 12)),
                    ),
                    DropdownMenuItem(
                      value: GraphGestureMode.nodeEdgeOnly,
                      child: Text('NodeEdgeOnly', style: TextStyle(fontSize: 12)),
                    ),
                    DropdownMenuItem(
                      value: GraphGestureMode.transparent,
                      child: Text('Transparent', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                  isDense: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Second row - Settings and controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // InteractiveViewer toggle
              InkWell(
                onTap: () => onUseInteractiveViewerChanged(!useInteractiveViewer),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: useInteractiveViewer,
                      onChanged: (value) => onUseInteractiveViewerChanged(value ?? false),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      splashRadius: 0,
                      visualDensity: VisualDensity.compact,
                    ),
                    const Text('InteractiveViewer', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Gesture debug mode toggle
              InkWell(
                onTap: () => onGestureDebugModeChanged(!gestureDebugMode),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: gestureDebugMode,
                      onChanged: (value) => onGestureDebugModeChanged(value ?? false),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      splashRadius: 0,
                      visualDensity: VisualDensity.compact,
                    ),
                    Text('Debug Mode', style: TextStyle(fontSize: 16 * uiScale)),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // UI Scale controls
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Text Size:', style: TextStyle(fontSize: 16 * uiScale, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onDecreaseUIScale,
                    tooltip: 'Decrease text size',
                    icon: const Icon(Icons.text_decrease),
                    iconSize: 20,
                  ),
                  Text(uiScale.toStringAsFixed(1), style: TextStyle(fontSize: 16 * uiScale)),
                  IconButton(
                    onPressed: onIncreaseUIScale,
                    tooltip: 'Increase text size',
                    icon: const Icon(Icons.text_increase),
                    iconSize: 20,
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

class DotGridPainter extends CustomPainter {
  final double dotSpacing;
  final double dotSize;
  final Color dotColor;

  DotGridPainter({
    this.dotSpacing = 24.0,
    this.dotSize = 1.5,
    this.dotColor = const Color(0xFFE0E0E0),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    // Calculate the number of dots in each direction
    final horizontalDots = (size.width / dotSpacing).ceil();
    final verticalDots = (size.height / dotSpacing).ceil();

    // Draw dots
    for (int x = 0; x <= horizontalDots; x++) {
      for (int y = 0; y <= verticalDots; y++) {
        final dx = x * dotSpacing;
        final dy = y * dotSpacing;
        
        if (dx <= size.width && dy <= size.height) {
          canvas.drawCircle(
            Offset(dx, dy),
            dotSize,
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (oldDelegate is DotGridPainter) {
      return oldDelegate.dotSpacing != dotSpacing ||
             oldDelegate.dotSize != dotSize ||
             oldDelegate.dotColor != dotColor;
    }
    return true;
  }
}