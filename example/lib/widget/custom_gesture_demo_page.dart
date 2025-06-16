import 'package:flutter/material.dart';
import 'package:plough/plough.dart';

import '../sample_data/force_directed.dart';

/// Demonstrates custom gesture handling logic.
///
/// Shows how to use GraphGestureMode.custom with shouldConsumeGesture callback.
class CustomGestureDemoPage extends StatefulWidget {
  const CustomGestureDemoPage({super.key});

  @override
  State<CustomGestureDemoPage> createState() => _CustomGestureDemoPageState();
}

class _CustomGestureDemoPageState extends State<CustomGestureDemoPage> {
  late Graph graph;
  final TransformationController _transformationController =
      TransformationController();
  String _lastAction = 'None';
  bool _consumeNodesOnly = true;
  bool _consumeEdges = false;
  bool _consumeCenterArea = false;
  double _centerAreaRadius = 100.0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Gesture Handling Demo'),
        backgroundColor: Colors.purple.shade100,
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
            'Custom Gesture Rules:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Consume gestures on nodes'),
            value: _consumeNodesOnly,
            onChanged: (value) {
              setState(() {
                _consumeNodesOnly = value;
              });
            },
            dense: true,
          ),
          SwitchListTile(
            title: const Text('Consume gestures on edges'),
            value: _consumeEdges,
            onChanged: (value) {
              setState(() {
                _consumeEdges = value;
              });
            },
            dense: true,
          ),
          SwitchListTile(
            title: const Text('Consume gestures in center area'),
            value: _consumeCenterArea,
            onChanged: (value) {
              setState(() {
                _consumeCenterArea = value;
              });
            },
            dense: true,
          ),
          if (_consumeCenterArea) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Center area radius: '),
                Expanded(
                  child: Slider(
                    value: _centerAreaRadius,
                    min: 50,
                    max: 200,
                    divisions: 15,
                    label: _centerAreaRadius.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        _centerAreaRadius = value;
                      });
                    },
                  ),
                ),
                Text('${_centerAreaRadius.round()}px'),
              ],
            ),
          ],
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

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: InteractiveViewer(
        transformationController: _transformationController,
        boundaryMargin: const EdgeInsets.all(50),
        minScale: 0.5,
        maxScale: 3.0,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              width: 1000,
              height: 1000,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.purple.shade200, width: 2),
              ),
              child: Stack(
                children: [
                  // Show center area if enabled
                  if (_consumeCenterArea)
                    Positioned(
                      left: 500 - _centerAreaRadius,
                      top: 500 - _centerAreaRadius,
                      child: Container(
                        width: _centerAreaRadius * 2,
                        height: _centerAreaRadius * 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.purple.withValues(alpha: 0.1),
                          border: Border.all(
                            color: Colors.purple.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  // Graph view
                  GraphView(
                    graph: graph,
                    behavior: behavior,
                    layoutStrategy: layoutStrategy,
                    allowSelection: true,
                    gestureMode: GraphGestureMode.custom,
                    shouldConsumeGesture: _shouldConsumeGesture,
                    onBackgroundTapped: (position) {
                      setState(() {
                        _lastAction = 'Background tapped at '
                            '${position.dx.toStringAsFixed(1)}, '
                            '${position.dy.toStringAsFixed(1)}';
                      });
                    },
                    onBackgroundPanStart: (position) {
                      setState(() {
                        _lastAction = 'Background pan started';
                      });
                    },
                    onBackgroundPanUpdate: (position, delta) {
                      setState(() {
                        _lastAction = 'Background pan: '
                            'Δ${delta.dx.toStringAsFixed(1)}, '
                            '${delta.dy.toStringAsFixed(1)}';
                      });
                    },
                    onBackgroundPanEnd: (position) {
                      setState(() {
                        _lastAction = 'Background pan ended';
                      });
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  bool _shouldConsumeGesture(
    Offset localPosition,
    GraphHitTestResult hitTestResult,
  ) {
    // Log what was hit for debugging
    String hitInfo = 'Hit: ';
    if (hitTestResult.hasNode) {
      hitInfo += 'node ';
    }
    if (hitTestResult.hasLink) {
      hitInfo += 'link ';
    }
    if (hitTestResult.isBackground) {
      hitInfo += 'background ';
    }

    // Check center area
    if (_consumeCenterArea) {
      final center = const Offset(500, 500);
      final distance = (localPosition - center).distance;
      if (distance <= _centerAreaRadius) {
        hitInfo += '(in center area)';
        setState(() {
          _lastAction = '$hitInfo - consumed by center area rule';
        });
        return true;
      }
    }

    // Check nodes
    if (_consumeNodesOnly && hitTestResult.hasNode) {
      setState(() {
        _lastAction = '$hitInfo - consumed by node rule';
      });
      return true;
    }

    // Check edges
    if (_consumeEdges && hitTestResult.hasLink) {
      setState(() {
        _lastAction = '$hitInfo - consumed by edge rule';
      });
      return true;
    }

    // Pass through
    setState(() {
      _lastAction = '$hitInfo - passed through';
    });
    return false;
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.purple.shade50,
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: Colors.purple),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Last action: $_lastAction',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _transformationController.value = Matrix4.identity();
              setState(() {
                _lastAction = 'Reset zoom/pan';
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade100,
            ),
            child: const Text('Reset View'),
          ),
        ],
      ),
    );
  }
}