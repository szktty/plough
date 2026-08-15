import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

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
  GraphViewportController controller, {
  Set<GraphId> hiddenNodeIds = const {},
  Set<GraphId> hiddenLinkIds = const {},
}) {
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
              hiddenNodeIds: hiddenNodeIds,
              hiddenLinkIds: hiddenLinkIds,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a hidden node is neither drawn nor hit-tested', (tester) async {
    final graph = Graph();
    final shown = GraphNode(properties: {'label': 'shown'});
    final hidden = GraphNode(properties: {'label': 'hidden'});
    graph
      ..addNode(shown)
      ..addNode(hidden);

    final layout = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(id: shown.id, position: const Offset(50, 50)),
        GraphNodeLayoutPosition(id: hidden.id, position: const Offset(250, 50)),
      ],
      origin: GraphLayoutPositionOrigin.topLeft,
    );
    final controller = GraphViewportController();

    await tester.pumpWidget(
      _build(graph, layout, controller, hiddenNodeIds: {hidden.id}),
    );
    await tester.pumpAndSettle();

    expect(find.text('shown'), findsOneWidget);
    expect(find.text('hidden'), findsNothing);

    // The hidden node still occupies its position in the model, but nothing
    // there answers a pointer.
    expect(controller.nodeIdAt(const Offset(82, 82)), shown.id);
    expect(controller.nodeIdAt(const Offset(282, 82)), isNull);

    // It is still in the graph, with its properties intact — hiding removes it
    // from the view, not from the model. It holds no position yet because the
    // layout never saw it; see 'unhiding restores the node at the position it
    // kept' for a node hidden after it was placed.
    expect(graph.getNode(hidden.id), isNotNull);
    expect(hidden.properties['label'], 'hidden');
  });

  testWidgets('a link touching a hidden node is hidden with it',
      (tester) async {
    final graph = Graph();
    final a = GraphNode(properties: {'label': 'a'});
    final b = GraphNode(properties: {'label': 'b'});
    final c = GraphNode(properties: {'label': 'c'});
    graph
      ..addNode(a)
      ..addNode(b)
      ..addNode(c)
      ..addLink(_link(a, b))
      ..addLink(_link(a, c));

    final layout = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(id: a.id, position: const Offset(50, 50)),
        GraphNodeLayoutPosition(id: b.id, position: const Offset(250, 50)),
        GraphNodeLayoutPosition(id: c.id, position: const Offset(50, 250)),
      ],
      origin: GraphLayoutPositionOrigin.topLeft,
    );
    final controller = GraphViewportController();

    await tester.pumpWidget(
      _build(graph, layout, controller, hiddenNodeIds: {b.id}),
    );
    await tester.pumpAndSettle();

    // a–c stays: both endpoints visible. Its midpoint is hittable.
    expect(controller.linkIdAt(const Offset(82, 182)), isNotNull);

    // a–b is gone: no line is drawn to a node that is not there.
    expect(controller.linkIdAt(const Offset(182, 82)), isNull);
  });

  testWidgets('hidden nodes take no part in the layout', (tester) async {
    final graph = Graph();
    final a = GraphNode(properties: {'label': 'a'});
    final b = GraphNode(properties: {'label': 'b'});
    final hidden = GraphNode(properties: {'label': 'hidden'});
    graph
      ..addNode(a)
      ..addNode(b)
      ..addNode(hidden)
      ..addLink(_link(a, hidden))
      ..addLink(_link(hidden, b));

    final controller = GraphViewportController();
    await tester.pumpWidget(
      _build(
        graph,
        GraphForceDirectedLayoutStrategy(seed: 3),
        controller,
        hiddenNodeIds: {hidden.id},
      ),
    );
    await tester.pumpAndSettle();

    // The hidden node is never positioned: the layout does not see it, so it
    // keeps the origin it was constructed at rather than being placed.
    expect(hidden.logicalPosition, Offset.zero);
    expect(a.logicalPosition, isNot(Offset.zero));
    expect(b.logicalPosition, isNot(Offset.zero));
  });

  testWidgets('unhiding restores the node at the position it kept',
      (tester) async {
    final graph = Graph();
    final a = GraphNode(properties: {'label': 'a'});
    final b = GraphNode(properties: {'label': 'b'});
    graph
      ..addNode(a)
      ..addNode(b)
      ..addLink(_link(a, b));

    final layout = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(id: a.id, position: const Offset(50, 50)),
        GraphNodeLayoutPosition(id: b.id, position: const Offset(250, 250)),
      ],
      origin: GraphLayoutPositionOrigin.topLeft,
    );
    final controller = GraphViewportController();

    await tester.pumpWidget(_build(graph, layout, controller));
    await tester.pumpAndSettle();
    final bAt = b.logicalPosition;
    expect(find.text('b'), findsOneWidget);

    // Hide…
    await tester.pumpWidget(
      _build(graph, layout, controller, hiddenNodeIds: {b.id}),
    );
    await tester.pumpAndSettle();
    expect(find.text('b'), findsNothing);

    // …and show again. The position survived, because the node never left the
    // graph — this is the whole point of hiding rather than removing.
    await tester.pumpWidget(_build(graph, layout, controller));
    await tester.pumpAndSettle();

    expect(find.text('b'), findsOneWidget);
    expect(b.logicalPosition, bAt);
    expect(b.logicalPosition, isNot(Offset.zero));
  });

  testWidgets('the visible flag hides an entity on its own', (tester) async {
    final graph = Graph();
    final shown = GraphNode(properties: {'label': 'shown'});
    final hidden = GraphNode(properties: {'label': 'flagged'});
    graph
      ..addNode(shown)
      ..addNode(hidden);

    final layout = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(id: shown.id, position: const Offset(50, 50)),
        GraphNodeLayoutPosition(id: hidden.id, position: const Offset(250, 50)),
      ],
      origin: GraphLayoutPositionOrigin.topLeft,
    );
    final controller = GraphViewportController();

    hidden.visible = false;
    await tester.pumpWidget(_build(graph, layout, controller));
    await tester.pumpAndSettle();

    expect(find.text('shown'), findsOneWidget);
    expect(find.text('flagged'), findsNothing);
    expect(controller.nodeIdAt(const Offset(282, 82)), isNull);
  });

  testWidgets('hiddenLinkIds hides a link whose endpoints both remain',
      (tester) async {
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
    expect(controller.linkIdAt(const Offset(182, 182)), link.id);

    await tester.pumpWidget(
      _build(graph, layout, controller, hiddenLinkIds: {link.id}),
    );
    await tester.pumpAndSettle();

    // Both nodes stay; only the link goes.
    expect(find.text('a'), findsOneWidget);
    expect(find.text('b'), findsOneWidget);
    expect(controller.linkIdAt(const Offset(182, 182)), isNull);
  });

  testWidgets('a node hidden before it is ever laid out needs a position',
      (tester) async {
    // Hiding keeps a node's position, but only once it has one. A node added
    // while already hidden never enters the layout, so it holds the origin
    // until something places it. Give it a position at construction (or pin it
    // through a snapshot) rather than expecting the layout to catch up.
    final graph = Graph();
    final shown = GraphNode(properties: {'label': 'shown'});
    final addedHidden = GraphNode(
      properties: {'label': 'late'},
      logicalPosition: const Offset(300, 120),
      isArranged: true,
    );
    graph
      ..addNode(shown)
      ..addNode(addedHidden);

    final layout = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(id: shown.id, position: const Offset(50, 50)),
      ],
      origin: GraphLayoutPositionOrigin.topLeft,
    );
    final controller = GraphViewportController();

    await tester.pumpWidget(
      _build(graph, layout, controller, hiddenNodeIds: {addedHidden.id}),
    );
    await tester.pumpAndSettle();
    expect(find.text('late'), findsNothing);

    // Revealing it shows it exactly where it was constructed.
    await tester.pumpWidget(_build(graph, layout, controller));
    await tester.pumpAndSettle();

    expect(find.text('late'), findsOneWidget);
    expect(addedHidden.logicalPosition, const Offset(300, 120));
  });
}
