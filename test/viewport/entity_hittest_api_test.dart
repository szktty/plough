import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

/// Covers the scene-space hit-test API a host application uses to build
/// context menus: [GraphViewportController.nodeIdAt], [linkIdAt] and the
/// combined [entityIdAt]. A right-click has no gesture of its own inside
/// plough, so the host resolves what sits under the pointer itself.
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

  testWidgets('linkIdAt and entityIdAt resolve entities in scene space',
      (tester) async {
    final graph = Graph();
    final a = GraphNode(properties: {'label': 'a'});
    final b = GraphNode(properties: {'label': 'b'});
    graph
      ..addNode(a)
      ..addNode(b)
      ..addLink(
        GraphLink(source: a, target: b, direction: GraphLinkDirection.none),
      );

    // Two 60x60 nodes on the same horizontal line, far enough apart that the
    // midpoint of the link between them is over neither node.
    const aPos = Offset(50, 150);
    const bPos = Offset(250, 150);
    final layout = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(id: a.id, position: aPos),
        GraphNodeLayoutPosition(id: b.id, position: bPos),
      ],
      origin: GraphLayoutPositionOrigin.topLeft,
    );

    final controller = GraphViewportController();
    await tester.pumpWidget(_buildViewport(graph, layout, controller));
    await tester.pumpAndSettle();

    // The default renderer pads the styled 60x60 box out to 64x64, so centers
    // sit at topLeft + 32.
    const aCenter = Offset(82, 182);
    const bCenter = Offset(282, 182);
    final linkMidpoint = Offset.lerp(aCenter, bCenter, 0.5)!;

    // Nodes.
    expect(controller.nodeIdAt(aCenter), a.id);
    expect(controller.nodeIdAt(bCenter), b.id);
    expect(controller.entityIdAt(aCenter), a.id);

    // The link, at a point that is over no node.
    expect(controller.nodeIdAt(linkMidpoint), isNull);
    final linkId = controller.linkIdAt(linkMidpoint);
    expect(linkId, isNotNull);
    expect(linkId!.type, GraphIdType.link);
    expect(controller.entityIdAt(linkMidpoint), linkId);

    // Empty space.
    const empty = Offset(350, 380);
    expect(controller.nodeIdAt(empty), isNull);
    expect(controller.linkIdAt(empty), isNull);
    expect(controller.entityIdAt(empty), isNull);

    // A node takes precedence over a link that passes under it.
    expect(controller.entityIdAt(aCenter)!.type, GraphIdType.node);
  });

  testWidgets('the hit-test API returns null before a GraphView attaches',
      (tester) async {
    final controller = GraphViewportController();

    expect(controller.nodeIdAt(Offset.zero), isNull);
    expect(controller.linkIdAt(Offset.zero), isNull);
    expect(controller.entityIdAt(Offset.zero), isNull);
  });
}
