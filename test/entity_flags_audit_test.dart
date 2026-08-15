import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

/// Audits every [GraphEntity] flag for whether it actually does anything.
///
/// `visible` shipped declared but never read by the render path, so a node with
/// `visible = false` was untappable yet fully drawn. Nothing caught it because
/// no test ever set the flag and checked the result — the suite covered the
/// half that worked (hit-testing) and never touched the half that did not.
/// Auditing the rest turned up three more of the same shape, since fixed.
///
/// These tests set each flag and assert on observable behaviour, so a flag that
/// is only declared fails here rather than in an application.
GraphLink _link(GraphNode source, GraphNode target) => GraphLink(
      source: source,
      target: target,
      direction: GraphLinkDirection.none,
    );

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

Widget _build(
  Graph graph,
  GraphLayoutStrategy layout,
  GraphViewportController controller,
) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          height: 400,
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

  group('canSelect', () {
    test('a node that cannot be selected is not selected by selectNode', () {
      final graph = Graph();
      final node = GraphNode();
      graph.addNode(node);

      node.canSelect = false;
      graph.selectNode(node.id);

      expect(node.isSelected, isFalse);
      expect(graph.selectedNodeIds, isEmpty);
    });

    test('clearing canSelect deselects an already selected node', () {
      final graph = Graph();
      final node = GraphNode();
      graph.addNode(node);

      graph.selectNode(node.id);
      expect(node.isSelected, isTrue);

      node.canSelect = false;

      expect(node.isSelected, isFalse);
    });

    test('a link that cannot be selected is not selected by selectLink', () {
      final graph = Graph();
      final a = GraphNode();
      final b = GraphNode();
      final link = _link(a, b);
      graph
        ..addNode(a)
        ..addNode(b)
        ..addLink(link);

      link.canSelect = false;
      graph.selectLink(link.id);

      expect(link.isSelected, isFalse);
      expect(graph.selectedLinkIds, isEmpty);
    });

    test('clearing canSelect deselects an already selected link', () {
      final graph = Graph();
      final a = GraphNode();
      final b = GraphNode();
      final link = _link(a, b);
      graph
        ..addNode(a)
        ..addNode(b)
        ..addLink(link);

      graph.selectLink(link.id);
      expect(link.isSelected, isTrue);

      link.canSelect = false;

      expect(link.isSelected, isFalse);
    });
  });

  group('isEnabled', () {
    testWidgets('a disabled node does not respond to a tap', (tester) async {
      final graph = Graph();
      final node = GraphNode(properties: {'label': 'n'});
      graph.addNode(node);

      final layout = GraphManualLayoutStrategy(
        nodePositions: [
          GraphNodeLayoutPosition(id: node.id, position: const Offset(50, 50)),
        ],
        origin: GraphLayoutPositionOrigin.topLeft,
      );
      final controller = GraphViewportController();
      await tester.pumpWidget(_build(graph, layout, controller));
      await tester.pumpAndSettle();

      node.isEnabled = false;
      await tester.pumpAndSettle();

      final viewTopLeft = tester.getTopLeft(find.byType(GraphViewport));
      await tester.tapAt(viewTopLeft + const Offset(82, 82));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));

      expect(node.isSelected, isFalse);
    });

    testWidgets('a disabled link does not respond to a tap', (tester) async {
      final graph = Graph();
      final a = GraphNode(properties: {'label': 'a'});
      final b = GraphNode(properties: {'label': 'b'});
      final link = _link(a, b);
      graph
        ..addNode(a)
        ..addNode(b)
        ..addLink(link);

      final layout = GraphManualLayoutStrategy(
        nodePositions: [
          GraphNodeLayoutPosition(id: a.id, position: const Offset(50, 150)),
          GraphNodeLayoutPosition(id: b.id, position: const Offset(250, 150)),
        ],
        origin: GraphLayoutPositionOrigin.topLeft,
      );
      final controller = GraphViewportController();
      await tester.pumpWidget(_build(graph, layout, controller));
      await tester.pumpAndSettle();

      link.isEnabled = false;
      await tester.pumpAndSettle();

      // Tap the link's midpoint, which is over neither node.
      final viewTopLeft = tester.getTopLeft(find.byType(GraphViewport));
      await tester.tapAt(viewTopLeft + const Offset(182, 182));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));

      expect(link.isSelected, isFalse);
    });
  });

  group('canDrag', () {
    testWidgets('a node that cannot be dragged does not move', (tester) async {
      final graph = Graph();
      final node = GraphNode(properties: {'label': 'n'});
      graph.addNode(node);

      final layout = GraphManualLayoutStrategy(
        nodePositions: [
          GraphNodeLayoutPosition(id: node.id, position: const Offset(50, 50)),
        ],
        origin: GraphLayoutPositionOrigin.topLeft,
      );
      final controller = GraphViewportController();
      await tester.pumpWidget(_build(graph, layout, controller));
      await tester.pumpAndSettle();

      final before = node.logicalPosition;
      node.canDrag = false;
      await tester.pumpAndSettle();

      final viewTopLeft = tester.getTopLeft(find.byType(GraphViewport));
      await tester.dragFrom(
        viewTopLeft + const Offset(82, 82),
        const Offset(80, 60),
      );
      await tester.pumpAndSettle();
      // Drain the double-tap timeout timer so it does not outlive the tree.
      await tester.pump(const Duration(milliseconds: 600));

      expect(node.logicalPosition, before);
    });

    testWidgets('a draggable node does move, proving the drag reaches it',
        (tester) async {
      final graph = Graph();
      final node = GraphNode(properties: {'label': 'n'});
      graph.addNode(node);

      final layout = GraphManualLayoutStrategy(
        nodePositions: [
          GraphNodeLayoutPosition(id: node.id, position: const Offset(50, 50)),
        ],
        origin: GraphLayoutPositionOrigin.topLeft,
      );
      final controller = GraphViewportController();
      await tester.pumpWidget(_build(graph, layout, controller));
      await tester.pumpAndSettle();

      final before = node.logicalPosition;
      final viewTopLeft = tester.getTopLeft(find.byType(GraphViewport));
      await tester.dragFrom(
        viewTopLeft + const Offset(82, 82),
        const Offset(80, 60),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));

      expect(node.logicalPosition, isNot(before));
    });
  });

  group('weight', () {
    test('weight changes the force-directed result', () {
      Offset run(double weight) {
        final graph = Graph();
        final heavy = GraphNode();
        final a = GraphNode();
        final b = GraphNode();
        graph
          ..addNode(heavy)
          ..addNode(a)
          ..addNode(b)
          ..addLink(_link(heavy, a))
          ..addLink(_link(heavy, b));
        heavy.weight = weight;

        GraphForceDirectedLayoutStrategy(seed: 11)
            .performLayout(graph, const Size(800, 600));
        return a.logicalPosition;
      }

      // Mass feeds the Barnes-Hut repulsion, so a heavier node pushes its
      // neighbours further away. Identical seeds, so any difference is the
      // weight.
      expect(run(1), isNot(run(50)));
    });
  });

  group('stackOrder', () {
    test('the order manager reports the frontmost entity by stack order', () {
      // frontmostWhereOrNull walks the id list in insertion order and never
      // sorts by stackOrder, so the first-added entity wins regardless of which
      // one is actually in front.
      final graph = Graph();
      final first = GraphNode();
      final second = GraphNode();
      graph
        ..addNode(first)
        ..addNode(second);

      first.stackOrder = 0;
      second.stackOrder = 99;

      final found =
          graph.getOrderManagerSync().frontmostWhereOrNull((e) => true);

      expect(found?.id, second.id);
    });

    testWidgets('the frontmost node wins an overlapping hit test',
        (tester) async {
      final graph = Graph();
      final back = GraphNode(properties: {'label': 'back'});
      final front = GraphNode(properties: {'label': 'front'});
      graph
        ..addNode(back)
        ..addNode(front);

      // Deliberately overlapping.
      final layout = GraphManualLayoutStrategy(
        nodePositions: [
          GraphNodeLayoutPosition(id: back.id, position: const Offset(50, 50)),
          GraphNodeLayoutPosition(id: front.id, position: const Offset(60, 60)),
        ],
        origin: GraphLayoutPositionOrigin.topLeft,
      );
      final controller = GraphViewportController();
      await tester.pumpWidget(_build(graph, layout, controller));
      await tester.pumpAndSettle();

      back.stackOrder = 0;
      front.stackOrder = 10;
      await tester.pumpAndSettle();

      // A point inside both boxes resolves to the frontmost.
      expect(controller.nodeIdAt(const Offset(100, 100)), front.id);

      // Swapping the order swaps the answer.
      back.stackOrder = 10;
      front.stackOrder = 0;
      await tester.pumpAndSettle();

      expect(controller.nodeIdAt(const Offset(100, 100)), back.id);
    });

    testWidgets('bringToFront makes a node win the hit test', (tester) async {
      // bringToFront only raises stackOrder, so it was cosmetic for hit
      // testing: the node was painted on top but the pointer still found the
      // one beneath it.
      final graph = Graph();
      final a = GraphNode(properties: {'label': 'a'});
      final b = GraphNode(properties: {'label': 'b'});
      graph
        ..addNode(a)
        ..addNode(b);

      final layout = GraphManualLayoutStrategy(
        nodePositions: [
          GraphNodeLayoutPosition(id: a.id, position: const Offset(50, 50)),
          GraphNodeLayoutPosition(id: b.id, position: const Offset(60, 60)),
        ],
        origin: GraphLayoutPositionOrigin.topLeft,
      );
      final controller = GraphViewportController();
      await tester.pumpWidget(_build(graph, layout, controller));
      await tester.pumpAndSettle();

      const overlap = Offset(100, 100);

      graph.bringToFront(a.id);
      await tester.pumpAndSettle();
      expect(controller.nodeIdAt(overlap), a.id);

      graph.bringToFront(b.id);
      await tester.pumpAndSettle();
      expect(controller.nodeIdAt(overlap), b.id);
    });
  });
}
