import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/graph/node.dart' show GraphNodeImpl;
import 'package:plough/src/interactive/gesture_manager.dart';

class TestBehavior extends GraphViewDefaultBehavior {
  TestBehavior();

  final List<GraphSelectionChangeEvent> selectionEvents = [];
  final List<GraphTapEvent> tapEvents = [];
  final List<GraphDragStartEvent> dragStartEvents = [];
  final List<GraphDragUpdateEvent> dragUpdateEvents = [];
  final List<GraphDragEndEvent> dragEndEvents = [];

  @override
  void onSelectionChange(GraphSelectionChangeEvent event) {
    selectionEvents.add(event);
  }

  @override
  void onTap(GraphTapEvent event) {
    tapEvents.add(event);
  }

  @override
  void onDragStart(GraphDragStartEvent event) {
    dragStartEvents.add(event);
  }

  @override
  void onDragUpdate(GraphDragUpdateEvent event) {
    dragUpdateEvents.add(event);
  }

  @override
  void onDragEnd(GraphDragEndEvent event) {
    dragEndEvents.add(event);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('GraphGestureManager (internal)', () {
    late Graph graph;
    late TestBehavior behavior;

    setUp(() {
      graph = Graph();
      behavior = TestBehavior();
    });

    test('tap on node selects it and emits events', () {
      final node = GraphNode(properties: {'label': 'tap'});
      graph.addNode(node);
      final impl = graph.getNode(node.id)! as GraphNodeImpl;
      impl.logicalPosition = const Offset(100, 100);
      impl.geometry = const GraphNodeViewGeometry(
        bounds: Rect.fromLTWH(75, 75, 50, 50),
      );

      final gestures = GraphGestureManager(
        graph: graph,
        viewBehavior: behavior,
        viewportSize: const Size(400, 400),
      );

      const p = Offset(100, 100);
      gestures.handlePointerDown(const PointerDownEvent(position: p));
      gestures.handlePointerUp(const PointerUpEvent(position: p));

      expect(graph.selectedEntityIds, contains(node.id));
      expect(behavior.selectionEvents.length, greaterThan(0));
      expect(behavior.tapEvents.length, greaterThan(0));
    });

    test('drag updates position and emits drag events', () {
      final node = GraphNode(properties: {'label': 'drag'});
      graph.addNode(node);
      final impl = graph.getNode(node.id)! as GraphNodeImpl;
      impl.logicalPosition = const Offset(100, 100);
      impl.geometry = const GraphNodeViewGeometry(
        bounds: Rect.fromLTWH(75, 75, 50, 50),
      );

      final gestures = GraphGestureManager(
        graph: graph,
        viewBehavior: behavior,
        viewportSize: const Size(400, 400),
      );

      const start = Offset(100, 100);
      const delta = Offset(40, 30);
      final end = start + delta;

      gestures.handlePointerDown(
        const PointerDownEvent(position: start),
      );
      gestures.handlePanStart(
        DragStartDetails(localPosition: start, globalPosition: start),
      );
      // Set last pointer details used by the manager
      gestures.handleMouseHover(const PointerHoverEvent(position: start));
      gestures.handlePanUpdate(
        DragUpdateDetails(
            globalPosition: end, localPosition: end, delta: delta),
      );
      gestures.handlePanEnd(DragEndDetails());

      // No explicit onDragStart is dispatched in current design
      expect(behavior.dragUpdateEvents.length, greaterThan(0));
      expect(behavior.dragEndEvents.length, 1);
      // Position should change from initial
      expect(impl.logicalPosition, isNot(const Offset(100, 100)));
    });

    test('gestureMode.nodeEdgeOnly consumes only on entities', () {
      final node = GraphNode(properties: {'label': 'n'});
      graph.addNode(node);
      final impl = graph.getNode(node.id)! as GraphNodeImpl;
      impl.logicalPosition = const Offset(100, 100);
      impl.geometry = const GraphNodeViewGeometry(
        bounds: Rect.fromLTWH(75, 75, 50, 50),
      );

      final gm = GraphGestureManager(
        graph: graph,
        viewBehavior: behavior,
        viewportSize: const Size(400, 400),
        gestureMode: GraphGestureMode.nodeEdgeOnly,
      );

      expect(gm.shouldConsumeGestureAt(const Offset(100, 100)), isTrue);
      expect(gm.shouldConsumeGestureAt(const Offset(10, 10)), isFalse);
    });
  });
}
