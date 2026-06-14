// D2-pre: characterization tests that pin down current GraphGestureManager
// behavior before any FSM refactor (D2). These capture EXISTING behavior so a
// later refactor that aims to be behavior-preserving has a safety net. They are
// intentionally descriptive, not prescriptive.
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/graph/node.dart' show GraphNodeImpl;
import 'package:plough/src/interactive/gesture_manager.dart';

class _RecordingBehavior extends GraphViewDefaultBehavior {
  final List<GraphTapEvent> tapEvents = [];
  final List<GraphTapEvent> doubleTapEvents = [];
  final List<GraphSelectionChangeEvent> selectionEvents = [];

  @override
  void onTap(GraphTapEvent event) => tapEvents.add(event);

  @override
  void onDoubleTap(GraphTapEvent event) => doubleTapEvents.add(event);

  @override
  void onSelectionChange(GraphSelectionChangeEvent event) =>
      selectionEvents.add(event);
}

GraphNodeImpl _addNodeAt(Graph graph, Offset center, {String label = 'n'}) {
  final node = GraphNode(properties: {'label': label});
  graph.addNode(node);
  final impl = graph.getNode(node.id)! as GraphNodeImpl;
  impl.logicalPosition = center;
  impl.geometry = GraphNodeViewGeometry(
    bounds: Rect.fromCenter(center: center, width: 50, height: 50),
  );
  return impl;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GraphGestureManager characterization', () {
    late Graph graph;
    late _RecordingBehavior behavior;

    setUp(() {
      graph = Graph();
      behavior = _RecordingBehavior();
    });

    GraphGestureManager manager({
      GraphGestureMode mode = GraphGestureMode.exclusive,
    }) {
      return GraphGestureManager(
        graph: graph,
        viewBehavior: behavior,
        viewportSize: const Size(400, 400),
        gestureMode: mode,
      );
    }

    void tapAt(GraphGestureManager gm, Offset p) {
      gm
        ..handlePointerDown(PointerDownEvent(position: p))
        ..handlePointerUp(PointerUpEvent(position: p));
    }

    test('tapping empty background after selecting a node clears selection',
        () {
      final node = _addNodeAt(graph, const Offset(100, 100));
      final gm = manager();

      tapAt(gm, const Offset(100, 100));
      expect(graph.selectedEntityIds, contains(node.id));

      // Tap far from any node.
      tapAt(gm, const Offset(10, 10));
      expect(graph.selectedEntityIds, isEmpty);
    });

    test('tapping a second node moves single-selection to it', () {
      final a = _addNodeAt(graph, const Offset(100, 100), label: 'a');
      final b = _addNodeAt(graph, const Offset(300, 300), label: 'b');
      final gm = manager();

      tapAt(gm, const Offset(100, 100));
      expect(graph.selectedEntityIds, contains(a.id));

      tapAt(gm, const Offset(300, 300));
      expect(graph.selectedEntityIds, contains(b.id));
      expect(graph.selectedEntityIds, isNot(contains(a.id)));
    });

    test('two taps on a node dispatch a double tap', () {
      _addNodeAt(graph, const Offset(100, 100));
      final gm = manager();

      const p = Offset(100, 100);
      tapAt(gm, p);
      tapAt(gm, p);

      // Current behavior: the second tap is recognized as a double tap.
      expect(behavior.doubleTapEvents, isNotEmpty);
    });

    test('pointer cancel after down does not select or throw', () {
      final node = _addNodeAt(graph, const Offset(100, 100));
      final gm = manager();

      const p = Offset(100, 100);
      gm
        ..handlePointerDown(const PointerDownEvent(position: p))
        ..handlePointerCancel(const PointerCancelEvent(position: p));

      expect(graph.selectedEntityIds, isNot(contains(node.id)));
    });

    test('transparent mode never consumes gestures', () {
      _addNodeAt(graph, const Offset(100, 100));
      final gm = manager(mode: GraphGestureMode.transparent);

      // On a node and on empty space alike.
      expect(gm.shouldConsumeGestureAt(const Offset(100, 100)), isFalse);
      expect(gm.shouldConsumeGestureAt(const Offset(10, 10)), isFalse);
    });

    test('exclusive mode consumes everywhere', () {
      _addNodeAt(graph, const Offset(100, 100));
      final gm = manager();

      expect(gm.shouldConsumeGestureAt(const Offset(100, 100)), isTrue);
      expect(gm.shouldConsumeGestureAt(const Offset(10, 10)), isTrue);
    });

    test('nodeEdgeOnly consumes on a node but not on empty space', () {
      _addNodeAt(graph, const Offset(100, 100));
      final gm = manager(mode: GraphGestureMode.nodeEdgeOnly);

      expect(gm.shouldConsumeGestureAt(const Offset(100, 100)), isTrue);
      expect(gm.shouldConsumeGestureAt(const Offset(10, 10)), isFalse);
    });

    test('tapping a non-selectable node does not select it', () {
      final node = _addNodeAt(graph, const Offset(100, 100))..canSelect = false;
      final gm = manager();

      tapAt(gm, const Offset(100, 100));

      expect(graph.selectedEntityIds, isNot(contains(node.id)));
    });
  });
}
