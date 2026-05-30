import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

/// Regression guard for the infinite-canvas hit-test region.
///
/// A node placed outside the *initial* viewport rectangle must remain
/// hit-testable once it is panned into view.  This broke when the viewport
/// collapsed to a single Transform whose child was a fixed `SizedBox`(viewport
/// size): the gesture overlay's RenderBox only accepted pointers inside the
/// initial scene rect `(0,0)-(viewportSize)`, so off-screen nodes — though
/// visible after panning — could not be tapped.  The fix sizes the Transform
/// child to the node content bounds in infinite mode.
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'infinite: node outside the initial viewport is tappable after panning',
    (tester) async {
      final graph = Graph();
      final node = GraphNode(properties: {'label': 'far'});
      graph.addNode(node);

      // The viewport is 200x200, but the node sits at scene (400,400) — well
      // outside the initial viewport rectangle.
      const nodeScenePos = Offset(400, 400);
      final layout = GraphManualLayoutStrategy(
        nodePositions: [
          GraphNodeLayoutPosition(id: node.id, position: nodeScenePos),
        ],
        origin: GraphLayoutPositionOrigin.topLeft,
      );

      final controller = GraphViewportController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: GraphViewport(
                  controller: controller,
                  canvasMode: GraphViewportCanvasMode.infinite,
                  child: GraphView(
                    graph: graph,
                    behavior: const _FixedNodeSizeBehavior(),
                    layoutStrategy: layout,
                    animationEnabled: false,
                    canvasMode: GraphViewportCanvasMode.infinite,
                    gestureMode: GraphGestureMode.exclusive,
                    allowSelection: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Pan so the node's center (430,430 in scene) lands near the viewport
      // center (100,100 screen).  pan = screenCenter - sceneCenter.
      const nodeCenterScene = Offset(430, 430);
      controller.pan(const Offset(100, 100) - nodeCenterScene);
      await tester.pumpAndSettle();

      final viewTopLeft = tester.getTopLeft(find.byType(GraphViewport));

      // Tap where the node now visually is (viewport center).
      await tester.tapAt(viewTopLeft + const Offset(100, 100));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(
        graph.selectedEntityIds,
        contains(node.id),
        reason:
            'A panned-in node outside the initial viewport must be tappable',
      );
    },
  );

  testWidgets(
    'viewport: a node can be dragged to a new position',
    (tester) async {
      final graph = Graph();
      final node = GraphNode(properties: {'label': 'drag'});
      graph.addNode(node);

      const startScene = Offset(80, 80);
      final layout = GraphManualLayoutStrategy(
        nodePositions: [
          GraphNodeLayoutPosition(id: node.id, position: startScene),
        ],
        origin: GraphLayoutPositionOrigin.topLeft,
      );

      final controller = GraphViewportController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
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
                    gestureMode: GraphGestureMode.exclusive,
                    allowSelection: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final before = (graph.getNode(node.id)! as GraphNode).logicalPosition;

      // Drag from the node's center (scene 80+30=110) by (60, 40) screen px.
      final viewTopLeft = tester.getTopLeft(find.byType(GraphViewport));
      await tester.dragFrom(
        viewTopLeft + const Offset(110, 110),
        const Offset(60, 40),
      );
      await tester.pumpAndSettle();

      final after = (graph.getNode(node.id)! as GraphNode).logicalPosition;

      expect(
        after,
        isNot(before),
        reason: 'Dragging a node through the viewport must move it',
      );
      // At scale 1 the node moves by roughly the drag delta.
      expect(after.dx, closeTo(before.dx + 60, 1.0));
      expect(after.dy, closeTo(before.dy + 40, 1.0));
    },
  );

  testWidgets(
    'viewport: a selected node stays selected after being dragged off-screen '
    'and panned back into view',
    (tester) async {
      final graph = Graph();
      final node = GraphNode(properties: {'label': 'sel'});
      graph.addNode(node);

      const startScene = Offset(80, 80);
      final layout = GraphManualLayoutStrategy(
        nodePositions: [
          GraphNodeLayoutPosition(id: node.id, position: startScene),
        ],
        origin: GraphLayoutPositionOrigin.topLeft,
      );

      final controller = GraphViewportController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
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
                    gestureMode: GraphGestureMode.exclusive,
                    allowSelection: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final viewTopLeft = tester.getTopLeft(find.byType(GraphViewport));

      // 1. Tap the node to select it.
      await tester.tapAt(viewTopLeft + const Offset(110, 110));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(
        graph.selectedEntityIds,
        contains(node.id),
        reason: 'Tapping the node must select it',
      );

      // 2. Drag the (selected) node far off the bottom-right, well outside the
      //    300x300 viewport.
      await tester.dragFrom(
        viewTopLeft + const Offset(110, 110),
        const Offset(400, 400),
      );
      await tester.pumpAndSettle();

      // 3. Pan the viewport via a background drag gesture (empty area) to bring
      //    the node back into view — this is how a user pans, and it must not
      //    deselect the node.
      await tester.dragFrom(
        viewTopLeft + const Offset(20, 20),
        const Offset(-150, -150),
      );
      await tester.pumpAndSettle();

      expect(
        graph.selectedEntityIds,
        contains(node.id),
        reason: 'Dragging a selected node and panning must not deselect it',
      );
    },
  );
}
