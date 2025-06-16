import 'package:flutter/material.dart';
import 'package:plough/plough.dart';

import '../sample_data/force_directed.dart';

/// Demonstrates the new gesture pass-through functionality.
///
/// Shows different gesture modes and InteractiveViewer integration.
class GesturePassthroughDemoPage extends StatefulWidget {
  const GesturePassthroughDemoPage({super.key});

  @override
  State<GesturePassthroughDemoPage> createState() =>
      _GesturePassthroughDemoPageState();
}

class _GesturePassthroughDemoPageState
    extends State<GesturePassthroughDemoPage> {
  late Graph graph;
  GraphGestureMode _gestureMode = GraphGestureMode.nodeEdgeOnly;
  final TransformationController _transformationController =
      TransformationController();
  String _lastBackgroundAction = 'None';
  bool _isUpdateScheduled = false;

  @override
  void initState() {
    super.initState();
    graph = forceDirectedSample().graph;
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _scheduleUpdate() {
    // シンプルなデバウンス処理
    if (!_isUpdateScheduled && mounted) {
      _isUpdateScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isUpdateScheduled = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🔄 GesturePassthroughDemoPage build() called');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gesture Pass-through Demo'),
        backgroundColor: Colors.blue.shade100,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildControls(),
          Expanded(
            child: _buildGraphView(),
          ),
          _buildStatusBar(),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gesture Mode:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: GraphGestureMode.values.map((mode) {
              return ChoiceChip(
                label: Text(_getGestureModeLabel(mode)),
                selected: _gestureMode == mode,
                onSelected: (selected) {
                  if (selected && _gestureMode != mode) {
                    setState(() {
                      debugPrint('setState for mode change');
                      _gestureMode = mode;
                      _lastBackgroundAction = 'Changed to $_gestureMode';
                    });
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            _getGestureModeDescription(_gestureMode),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraphView() {
    final behavior = GraphViewDefaultBehavior();
    final layoutStrategy = GraphForceDirectedLayoutStrategy(
      springLength: 150,
      springConstant: 0.15,
      damping: 0.9,
    );

    final graphView = GraphView(
      graph: graph,
      behavior: behavior,
      layoutStrategy: layoutStrategy,
      allowSelection: true,
      gestureMode: _gestureMode,
      onBackgroundTapped: (position) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        debugPrint(
            'onBackgroundTapped called at $position (timestamp: $timestamp)');
        _lastBackgroundAction =
            'Background tapped at ${position.dx.toStringAsFixed(1)}, ${position.dy.toStringAsFixed(1)}';
        _scheduleUpdate(); // Use debounced update instead of immediate setState
      },
      onBackgroundPanStart: (position) {
        debugPrint('onBackgroundPanStart called at $position');
        _lastBackgroundAction =
            'Background pan started at ${position.dx.toStringAsFixed(1)}, ${position.dy.toStringAsFixed(1)}';
        _scheduleUpdate(); // Use debounced update instead of immediate setState
      },
      onBackgroundPanUpdate: (position, delta) {
        debugPrint('onBackgroundPanUpdate called at $position, delta: $delta');
        // Use debounce for frequent pan updates
        final action =
            'Background pan update: delta ${delta.dx.toStringAsFixed(1)}, ${delta.dy.toStringAsFixed(1)}';
        if (_lastBackgroundAction != action) {
          _lastBackgroundAction = action;
          _scheduleUpdate();
        }
      },
      onBackgroundPanEnd: (position) {
        debugPrint('onBackgroundPanEnd called at $position');
        _lastBackgroundAction =
            'Background pan ended at ${position.dx.toStringAsFixed(1)}, ${position.dy.toStringAsFixed(1)}';
        _scheduleUpdate(); // Use debounced update instead of immediate setState
      },
    );

    // Only wrap with InteractiveViewer if not in exclusive mode
    if (_gestureMode == GraphGestureMode.exclusive) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: graphView,
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 利用可能なスペースに基づいて動的にサイズを決定
          final availableWidth = constraints.maxWidth;
          final availableHeight = constraints.maxHeight;

          // 最小サイズを確保しつつ、利用可能なスペースを活用
          final containerWidth = (availableWidth * 1.5).clamp(800.0, 2000.0);
          final containerHeight = (availableHeight * 1.5).clamp(600.0, 1500.0);

          return InteractiveViewer(
            transformationController: _transformationController,
            boundaryMargin: const EdgeInsets.all(50),
            minScale: 0.3,
            maxScale: 3.0,
            child: Container(
              width: containerWidth,
              height: containerHeight,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.blue.shade200, width: 2),
              ),
              child: graphView,
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.blue.shade50,
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Last background action: $_lastBackgroundAction\nDouble Tap Timeout: 100ms (modified from 300ms)',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          if (_gestureMode != GraphGestureMode.exclusive) ...[
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _transformationController.value = Matrix4.identity();
                  _lastBackgroundAction = 'Reset zoom/pan';
                });
              },
              child: const Text('Reset View'),
            ),
          ],
        ],
      ),
    );
  }

  String _getGestureModeLabel(GraphGestureMode mode) {
    switch (mode) {
      case GraphGestureMode.exclusive:
        return 'Exclusive';
      case GraphGestureMode.nodeEdgeOnly:
        return 'Node/Edge Only';
      case GraphGestureMode.transparent:
        return 'Transparent';
      case GraphGestureMode.custom:
        return 'Custom';
    }
  }

  String _getGestureModeDescription(GraphGestureMode mode) {
    switch (mode) {
      case GraphGestureMode.exclusive:
        return 'GraphView consumes all gestures. No InteractiveViewer integration.';
      case GraphGestureMode.nodeEdgeOnly:
        return 'GraphView only consumes gestures on nodes/edges. Background gestures pass through to InteractiveViewer.';
      case GraphGestureMode.transparent:
        return 'All gestures pass through to InteractiveViewer. Graph interactions disabled.';
      case GraphGestureMode.custom:
        return 'Custom logic determines gesture consumption (not implemented in this demo).';
    }
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gesture Pass-through Help'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This demo shows different gesture handling modes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              _ModeDescription(
                title: 'Exclusive Mode',
                description: 'All gestures are consumed by GraphView. '
                    'You can interact with nodes and edges, but cannot pan/zoom the viewport.',
              ),
              SizedBox(height: 8),
              _ModeDescription(
                title: 'Node/Edge Only Mode',
                description:
                    'Gestures on nodes and edges are handled by GraphView. '
                    'Background gestures pass through to InteractiveViewer for pan/zoom.',
              ),
              SizedBox(height: 8),
              _ModeDescription(
                title: 'Transparent Mode',
                description: 'All gestures pass through to InteractiveViewer. '
                    'Graph interactions are disabled, but you can pan/zoom freely.',
              ),
              SizedBox(height: 8),
              _ModeDescription(
                title: 'Custom Mode',
                description:
                    'Uses custom logic to determine which gestures to consume. '
                    'This allows fine-grained control over gesture handling.',
              ),
              SizedBox(height: 16),
              Text(
                'Try different modes and interact with both the graph and the background!',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _ModeDescription extends StatelessWidget {
  const _ModeDescription({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}
