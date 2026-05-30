import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

/// Regression guard for node geometry under viewport zoom.
///
/// Nodes live inside the viewport's `Transform`, which scales only at paint
/// time and does not affect the child's layout.  `renderBox.size` is therefore
/// already in logical (scene) units and must NOT be divided by the viewport
/// scale when computing geometry bounds.  A previous implementation divided by
/// scale, which shrank the bounds when zoomed — breaking node hit-testing (the
/// background was dragged instead of the node) and pulling link endpoints
/// toward node centers.
class _FixedNodeSizeBehavior extends GraphViewDefaultBehavior {
  const _FixedNodeSizeBehavior();

  @override
  GraphNodeViewBehavior createNodeViewBehavior() {
    return GraphNodeViewBehavior.defaultBehavior(
      nodeRendererStyle: const GraphDefaultNodeRendererStyle(
        shape: GraphDefaultNodeRendererShape.rectangle,
        width: 60,
        height: 60,
      ),
    );
  }
}

Widget _buildViewport(
  Graph graph,
  GraphLayoutStrategy layout,
  GraphViewportController controller,
) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          height: 300,
          child: GraphViewport(
            controller: controller,
            canvasMode: GraphViewportCanvasMode.infinite,
            child: GraphView(
              graph: graph,
              behavior: const _FixedNodeSizeBehavior(),
              layoutStrategy: layout,
              animationEnabled: false,
              canvasMode: GraphViewportCanvasMode.infinite,
              allowSelection: true,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'node geometry size stays logical after dragging while zoomed in',
    (tester) async {
      // The bug only surfaced when a node was rebuilt (e.g. dragged) *while*
      // the viewport was zoomed: _updateGeometry then ran with scale != 1 and
      // divided the logical box size by scale, shrinking the bounds.  Merely
      // zooming does not rebuild nodes, so this test drags a node at scale 2.
      final graph = Graph();
      final node = GraphNode(properties: {'label': 'n'});
      graph.addNode(node);

      const scenePos = Offset(100, 100);
      const sceneCenter = Offset(130, 130); // topLeft + half of rendered box.
      final layout = GraphManualLayoutStrategy(
        nodePositions: [
          GraphNodeLayoutPosition(id: node.id, position: scenePos),
        ],
        origin: GraphLayoutPositionOrigin.topLeft,
      );

      final controller = GraphViewportController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_buildViewport(graph, layout, controller));
      await tester.pumpAndSettle();

      final sizeAtScale1 = (graph.getNode(node.id)!).geometry!.bounds.size;
      final posBeforeDrag = (graph.getNode(node.id)!).logicalPosition;

      // Zoom to 2x, keeping the node center at the viewport center.
      const scale = 2.0;
      const screenCenter = Offset(150, 150);
      controller
        ..setScale(scale)
        ..setPanOffset(screenCenter - sceneCenter * scale);
      await tester.pumpAndSettle();

      // Drag the node — this rebuilds it and recomputes its geometry at scale 2.
      final viewTopLeft = tester.getTopLeft(find.byType(GraphViewport));
      await tester.dragFrom(
        viewTopLeft + screenCenter,
        const Offset(40, 40),
      );
      await tester.pumpAndSettle();

      final sizeAfterDrag = (graph.getNode(node.id)!).geometry!.bounds.size;

      expect(
        sizeAfterDrag,
        sizeAtScale1,
        reason: 'Node geometry size must stay in logical units, not shrink by '
            'the viewport scale, when the node is rebuilt while zoomed',
      );

      // A 40px screen drag at scale 2 must move the node 20px in scene space —
      // the node must track the pointer, not run ahead at 2x speed.
      final posAfterDrag = (graph.getNode(node.id)!).logicalPosition;
      final sceneDelta = posAfterDrag - posBeforeDrag;
      expect(sceneDelta.dx, closeTo(20, 1.0));
      expect(sceneDelta.dy, closeTo(20, 1.0));
    },
  );

  testWidgets(
    'a node stays tappable while the viewport is zoomed in',
    (tester) async {
      final graph = Graph();
      final node = GraphNode(properties: {'label': 'n'});
      graph.addNode(node);

      // Node center at scene (130,130) (topLeft 100,100 + half of 60).
      const scenePos = Offset(100, 100);
      const sceneCenter = Offset(130, 130);
      final layout = GraphManualLayoutStrategy(
        nodePositions: [
          GraphNodeLayoutPosition(id: node.id, position: scenePos),
        ],
        origin: GraphLayoutPositionOrigin.topLeft,
      );

      final controller = GraphViewportController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_buildViewport(graph, layout, controller));
      await tester.pumpAndSettle();

      // Zoom to 2x around the node center so it stays put on screen:
      // screen = scale * scene + pan  =>  pan = screen - scale * scene.
      const scale = 2.0;
      const screenTarget = Offset(150, 150); // viewport center (300/2).
      controller
        ..setScale(scale)
        ..setPanOffset(screenTarget - sceneCenter * scale);
      await tester.pumpAndSettle();

      final viewTopLeft = tester.getTopLeft(find.byType(GraphViewport));

      // Tap where the node center now visually sits (viewport center).
      await tester.tapAt(viewTopLeft + screenTarget);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(
        graph.selectedEntityIds,
        contains(node.id),
        reason: 'A zoomed-in node must remain tappable at its visual center',
      );
    },
  );

  testWidgets(
    'nodes stay tappable after the graph is swapped (reload)',
    (tester) async {
      // Reloading the sample data swaps the GraphView's graph, rebuilding the
      // interactive overlay.  The replacement overlay publishes its pointer
      // handlers to the shared viewport controller; the old overlay must NOT
      // null them out in its dispose, or every gesture falls through to the
      // background and nodes become untappable.
      final controller = GraphViewportController();
      addTearDown(controller.dispose);

      final key = GlobalKey<_SwappableState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: _Swappable(key: key, controller: controller),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Swap to a fresh graph, as a reload does.
      key.currentState!.swapGraph();
      await tester.pumpAndSettle();

      final viewTopLeft = tester.getTopLeft(find.byType(GraphViewport));
      // The node sits at scene (100,100)+half(30) = (130,130); at scale 1 with
      // no pan, that is its screen position too.
      await tester.tapAt(viewTopLeft + const Offset(130, 130));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      final graph = key.currentState!.graph;
      expect(
        graph.selectedEntityIds,
        isNotEmpty,
        reason: 'After a graph swap, the new graph nodes must be tappable',
      );
    },
  );
}

/// A widget that hosts a [GraphView] in a [GraphViewport] and can swap its
/// graph for a brand-new one, mimicking the sample app's reload.
class _Swappable extends StatefulWidget {
  const _Swappable({required this.controller, super.key});

  final GraphViewportController controller;

  @override
  State<_Swappable> createState() => _SwappableState();
}

class _SwappableState extends State<_Swappable> {
  late Graph graph = _makeGraph();

  Graph _makeGraph() {
    return Graph()..addNode(GraphNode(properties: {'label': 'n'}));
  }

  GraphLayoutStrategy get _layout => GraphManualLayoutStrategy(
        nodePositions: [
          GraphNodeLayoutPosition(
            id: graph.nodes.first.id,
            position: const Offset(100, 100),
          ),
        ],
        origin: GraphLayoutPositionOrigin.topLeft,
      );

  void swapGraph() => setState(() => graph = _makeGraph());

  @override
  Widget build(BuildContext context) {
    return GraphViewport(
      controller: widget.controller,
      canvasMode: GraphViewportCanvasMode.infinite,
      child: GraphView(
        graph: graph,
        behavior: const _FixedNodeSizeBehavior(),
        layoutStrategy: _layout,
        animationEnabled: false,
        canvasMode: GraphViewportCanvasMode.infinite,
        allowSelection: true,
      ),
    );
  }
}
