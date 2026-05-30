import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:plough/plough.dart';

/// A self-contained screen for manually exercising the infinite canvas mode of
/// [GraphViewport].
///
/// It lays out a grid of nodes spread over a region larger than the viewport so
/// that panning is required to reach them, then surfaces a live coordinate
/// debug overlay and zoom controls.  Use it to verify the known infinite-mode
/// symptoms by hand:
///
/// - Pan away and back, then tap a node where it visually is (symptom 3b).
/// - Drag a node outside the viewport, pan to follow it, and tap/drag it again
///   at its new location (symptom 1).
/// - Switch the scale to 0.5 / 2.0 and repeat the above (the hit offset that
///   appears at scale != 1 is exactly the bug under investigation).
class InfiniteScenePage extends StatefulWidget {
  const InfiniteScenePage({super.key});

  @override
  State<InfiniteScenePage> createState() => _InfiniteScenePageState();
}

class _InfiniteScenePageState extends State<InfiniteScenePage>
    with TickerProviderStateMixin {
  final _controller = GraphViewportController(minScale: 0.2, maxScale: 4.0);

  // Grid configuration: nodes are placed on a spaced grid in logical space.
  static const _cols = 5;
  static const _rows = 5;
  static const _spacing = 220.0;

  late final Graph _graph;
  late final GraphManualLayoutStrategy _layoutStrategy;

  // Last interaction, shown on screen as proof that hit-testing landed.
  final ValueNotifier<String> _lastAction = ValueNotifier('—');

  // Live pointer position (screen + logical) for the debug overlay.
  final ValueNotifier<Offset?> _pointerScreen = ValueNotifier(null);

  // The scene-space position of the last tap, whether or not it hit a node.
  // Lets us compare "where the tap landed in scene coords" against the node
  // bounds list below.
  final ValueNotifier<Offset?> _lastTapScene = ValueNotifier(null);

  // Latest measured viewport size, used to flag which nodes are off-screen.
  Size _viewportSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _buildGraph();
  }

  void _buildGraph() {
    final graph = Graph();
    final positions = <GraphId, Offset>{};
    for (var r = 0; r < _rows; r++) {
      for (var c = 0; c < _cols; c++) {
        final node = GraphNode(
          properties: {'label': '($c,$r)'},
        );
        graph.addNode(node);
        positions[node.id] = Offset(c * _spacing, r * _spacing);
      }
    }
    _graph = graph;
    _layoutStrategy = GraphManualLayoutStrategy(
      nodePositions: GraphNodeLayoutPosition.fromMap(positions),
      origin: GraphLayoutPositionOrigin.topLeft,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _lastAction.dispose();
    _pointerScreen.dispose();
    _lastTapScene.dispose();
    super.dispose();
  }

  // UUIDv7 ids share a long timestamp prefix, so the first chars are identical
  // across nodes created together.  Use the tail to tell nodes apart.
  String _idStr(GraphId id) =>
      id.value.substring(math.max(0, id.value.length - 4));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Toolbar(controller: _controller),
        Expanded(child: _buildSceneStack()),
      ],
    );
  }

  Widget _buildSceneStack() {
    return LayoutBuilder(
      builder: (context, constraints) {
        _viewportSize = constraints.biggest;
        return _buildSceneStackContent();
      },
    );
  }

  Widget _buildSceneStackContent() {
    return Stack(
      children: [
        Positioned.fill(
          child: Listener(
            onPointerHover: (e) => _pointerScreen.value = e.localPosition,
            onPointerMove: (e) => _pointerScreen.value = e.localPosition,
            child: GraphViewport(
              controller: _controller,
              canvasMode: GraphViewportCanvasMode.infinite,
              minScale: 0.2,
              maxScale: 4.0,
              child: GraphView(
                graph: _graph,
                layoutStrategy: _layoutStrategy,
                canvasMode: GraphViewportCanvasMode.infinite,
                behavior: _InfiniteSceneBehavior(
                  graph: _graph,
                  onAction: (msg) => _lastAction.value = msg,
                  onTapScene: (scene) => _lastTapScene.value = scene,
                  idStr: _idStr,
                ),
                allowSelection: true,
                gestureMode: GraphGestureMode.nodeEdgeOnly,
              ),
            ),
          ),
        ),
        Positioned(
          left: 8,
          top: 8,
          child: IgnorePointer(
              child: _DebugOverlay(
            controller: _controller,
            graph: _graph,
            lastAction: _lastAction,
            pointerScreen: _pointerScreen,
            lastTapScene: _lastTapScene,
            viewportSize: () => _viewportSize,
            idStr: _idStr,
          )),
        ),
        const Positioned(
          left: 8,
          right: 8,
          bottom: 8,
          child: IgnorePointer(child: _GuideText()),
        ),
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.controller});

  final GraphViewportController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: () => controller.setScale(0.5),
            child: const Text('0.5x'),
          ),
          TextButton(
            onPressed: () => controller.setScale(1.0),
            child: const Text('1x'),
          ),
          TextButton(
            onPressed: () => controller.setScale(2.0),
            child: const Text('2x'),
          ),
          IconButton(
            tooltip: 'Reset view',
            icon: const Icon(Icons.fit_screen),
            onPressed: controller.reset,
          ),
        ],
      ),
    );
  }
}

class _DebugOverlay extends StatelessWidget {
  const _DebugOverlay({
    required this.controller,
    required this.graph,
    required this.lastAction,
    required this.pointerScreen,
    required this.lastTapScene,
    required this.viewportSize,
    required this.idStr,
  });

  final GraphViewportController controller;
  final Graph graph;
  final ValueNotifier<String> lastAction;
  final ValueNotifier<Offset?> pointerScreen;
  final ValueNotifier<Offset?> lastTapScene;
  final Size Function() viewportSize;
  final String Function(GraphId) idStr;

  String _fmt(Offset o) =>
      '(${o.dx.toStringAsFixed(1)}, ${o.dy.toStringAsFixed(1)})';
  String _fmtRect(Rect r) =>
      'LTRB(${r.left.toStringAsFixed(0)},${r.top.toStringAsFixed(0)},'
      '${r.right.toStringAsFixed(0)},${r.bottom.toStringAsFixed(0)})';

  // The currently visible scene rectangle, derived from the viewport transform:
  // screen (0,0)..(w,h) maps back to scene via toScene.
  Rect _visibleSceneRect() {
    final size = viewportSize();
    final tl = controller.toScene(Offset.zero);
    final br = controller.toScene(Offset(size.width, size.height));
    return Rect.fromLTRB(tl.dx, tl.dy, br.dx, br.dy);
  }

  // Hit-testing now lives in the viewport, outside the Transform, so the
  // hit-testable region is simply whatever scene area is currently visible —
  // the whole viewport in screen space mapped back to scene.  Any node whose
  // bounds overlap this (i.e. is on screen) is tappable, at any pan/zoom.
  Rect _hittableSceneRect() => _visibleSceneRect();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: AnimatedBuilder(
          animation: Listenable.merge(
            [controller, lastAction, pointerScreen, lastTapScene, graph],
          ),
          builder: (context, _) {
            final pointer = pointerScreen.value;
            final scene = pointer == null ? null : controller.toScene(pointer);
            final tap = lastTapScene.value;
            final visible = _visibleSceneRect();
            final hittable = _hittableSceneRect();
            final lines = <String>[
              'scale:    ${controller.scale.toStringAsFixed(3)}',
              'panOffset: ${_fmt(controller.panOffset)}',
              'visible scene:  ${_fmtRect(visible)}',
              'HITTABLE scene: ${_fmtRect(hittable)}',
              'pointer screen: ${pointer == null ? '—' : _fmt(pointer)}',
              'pointer scene:  ${scene == null ? '—' : _fmt(scene)}',
              'last tap scene: ${tap == null ? '—' : _fmt(tap)}',
              'last action: ${lastAction.value}',
              '── nodes (id: logicalPos | bounds | flags) ──',
              '   OFF=not visible  HIT=inside hittable rect  TAP-IN=tap hit bounds',
            ];
            for (final node in graph.nodes) {
              final b = node.geometry?.bounds;
              final pos = node.logicalPosition;
              final offscreen = b != null && !b.overlaps(visible);
              final hitOk = b != null && b.overlaps(hittable);
              final tapInside = b != null && tap != null && b.contains(tap);
              final flags = <String>[
                if (offscreen) 'OFF',
                if (hitOk) 'HIT' else 'NO-HIT',
                if (tapInside) 'TAP-IN',
              ].join(',');
              lines.add(
                '${idStr(node.id)}: ${_fmt(pos)} | '
                '${b == null ? 'null' : _fmtRect(b)}'
                '${flags.isEmpty ? '' : '  <$flags>'}',
              );
            }
            return Text(
              lines.join('\n'),
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 11,
                height: 1.35,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GuideText extends StatelessWidget {
  const _GuideText();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Padding(
        padding: EdgeInsets.all(8),
        child: Text(
          'Pan with background drag, pinch / use 0.5x–2x to zoom.\n'
          '• Pan away & back, then tap a node where you see it (symptom 3b).\n'
          '• Drag a node off-screen, pan to follow, tap/drag it again (symptom 1).\n'
          '• Watch pointer screen vs scene in the overlay for hit offset.',
          style: TextStyle(color: Colors.black87, fontSize: 12, height: 1.3),
        ),
      ),
    );
  }
}

class _InfiniteSceneBehavior extends GraphViewDefaultBehavior {
  _InfiniteSceneBehavior({
    required this.graph,
    required this.onAction,
    required this.onTapScene,
    required this.idStr,
  });

  final Graph graph;
  final void Function(String) onAction;
  final void Function(Offset) onTapScene;
  final String Function(GraphId) idStr;

  @override
  GraphNodeViewBehavior createNodeViewBehavior() {
    return GraphNodeViewBehavior.defaultBehavior(
      nodeRendererBuilder: (context, graph, node, child) {
        final label = node['label']?.toString() ?? '';
        return GraphDefaultNodeRenderer(
          node: node,
          style: const GraphDefaultNodeRendererStyle(
            shape: GraphDefaultNodeRendererShape.circle,
            width: 64,
            height: 64,
          ),
          child: Center(
            child: Text(label, style: const TextStyle(fontSize: 11)),
          ),
        );
      },
    );
  }

  @override
  void onTap(GraphTapEvent event) {
    super.onTap(event);
    // Record the scene-space tap location regardless of hit, so the overlay
    // can show taps that landed on empty space (missed a node).
    onTapScene(event.details.localPosition);
    if (event.entityIds.isNotEmpty) {
      final id = event.entityIds.first;
      final isNode = graph.getNode(id) != null;
      onAction(
        '${isNode ? 'Node' : 'Link'} tap ${idStr(id)} '
        '@ ${event.details.localPosition}',
      );
    } else {
      onAction('MISS @ ${event.details.localPosition}');
    }
  }

  @override
  void onDragEnd(GraphDragEndEvent event) {
    super.onDragEnd(event);
    if (event.entityIds.isNotEmpty) {
      final id = event.entityIds.first;
      onAction('Drag end ${idStr(id)} @ ${event.details.localPosition}');
    }
  }
}
