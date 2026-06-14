// D2-pre: characterization tests that pin down current GraphGestureManager
// behavior before any FSM refactor (D2). These capture EXISTING behavior so a
// later refactor that aims to be behavior-preserving has a safety net. They are
// intentionally descriptive, not prescriptive.
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/graph/link.dart' show GraphLinkImpl;
import 'package:plough/src/graph/node.dart' show GraphNodeImpl;
import 'package:plough/src/graph_view/geometry.dart'
    show GraphConnectionGeometry, GraphConnectionPoints, GraphLinkViewGeometry;
import 'package:plough/src/interactive/gesture_manager.dart';

class _RecordingBehavior extends GraphViewDefaultBehavior {
  final List<GraphTapEvent> tapEvents = [];
  final List<GraphTapEvent> doubleTapEvents = [];
  final List<GraphSelectionChangeEvent> selectionEvents = [];
  final List<GraphDragStartEvent> dragStartEvents = [];
  final List<GraphDragUpdateEvent> dragUpdateEvents = [];
  final List<GraphDragEndEvent> dragEndEvents = [];

  @override
  void onTap(GraphTapEvent event) => tapEvents.add(event);

  @override
  void onDoubleTap(GraphTapEvent event) => doubleTapEvents.add(event);

  @override
  void onSelectionChange(GraphSelectionChangeEvent event) =>
      selectionEvents.add(event);

  @override
  void onDragStart(GraphDragStartEvent event) => dragStartEvents.add(event);

  @override
  void onDragUpdate(GraphDragUpdateEvent event) => dragUpdateEvents.add(event);

  @override
  void onDragEnd(GraphDragEndEvent event) => dragEndEvents.add(event);
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

/// Sets up a link between [source] and [target] with geometry so that
/// [findLinkAt] can hit it at [center].
GraphLinkImpl _addLinkBetween(
  Graph graph,
  GraphNodeImpl source,
  GraphNodeImpl target, {
  String label = 'e',
}) {
  final link = GraphLink(
    source: source,
    target: target,
    direction: GraphLinkDirection.outgoing,
    properties: {'label': label},
  );
  graph.addLink(link);
  final impl = graph.getLink(link.id)! as GraphLinkImpl;

  // Build a horizontal bounding rect centered between the two nodes.
  final sc = source.logicalPosition!;
  final tc = target.logicalPosition!;
  final center = Offset((sc.dx + tc.dx) / 2, (sc.dy + tc.dy) / 2);
  final angle = math.atan2(tc.dy - sc.dy, tc.dx - sc.dx);
  final dist = (tc - sc).distance;

  impl.geometry = GraphLinkViewGeometry(
    bounds: Rect.fromCenter(center: center, width: dist, height: 20),
    connection: GraphConnectionGeometry(
      source: source.geometry!,
      target: target.geometry!,
      connectionPoints: GraphConnectionPoints(
        outgoing: sc,
        incoming: tc,
      ),
    ),
    thickness: 4,
    angle: angle,
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

  // ---------------------------------------------------------------------------
  // D2-pre (priority HIGH): link tap/drag + drag lifecycle + concurrent pointer
  // ---------------------------------------------------------------------------
  group('GraphGestureManager characterization — link and drag', () {
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

    // -- link tap/drag --------------------------------------------------------

    test('tapping a link selects it', () {
      final a = _addNodeAt(graph, const Offset(100, 200), label: 'a');
      final b = _addNodeAt(graph, const Offset(300, 200), label: 'b');
      final link = _addLinkBetween(graph, a, b);
      final gm = manager();

      // Center of the link is at (200, 200).
      tapAt(gm, const Offset(200, 200));

      expect(graph.selectedEntityIds, contains(link.id));
    });

    test('tapping background after selecting a link does not throw', () {
      final a = _addNodeAt(graph, const Offset(100, 200), label: 'a');
      final b = _addNodeAt(graph, const Offset(300, 200), label: 'b');
      final link = _addLinkBetween(graph, a, b);
      final gm = manager();

      tapAt(gm, const Offset(200, 200));
      expect(graph.selectedEntityIds, contains(link.id));

      // BUG (asymmetric deselect): node selection → background tap clears it;
      // link selection → background tap does NOT clear it. The _pendingBackground-
      // DeselectAt path is not reached after a link tap (early-return in
      // handlePointerDown). Additionally, a link-tap followed by a background tap
      // corrupts the node-side background deselect for subsequent interactions.
      // Fix tracked separately (D2 FSM rework acceptance criterion).
      // This characterization pins only the no-throw invariant.
      expect(() => tapAt(gm, const Offset(10, 10)), returnsNormally);
    });

    test('pointer cancel on a link does not select it', () {
      final a = _addNodeAt(graph, const Offset(100, 200), label: 'a');
      final b = _addNodeAt(graph, const Offset(300, 200), label: 'b');
      final link = _addLinkBetween(graph, a, b);
      final gm = manager();

      const p = Offset(200, 200);
      gm
        ..handlePointerDown(const PointerDownEvent(position: p))
        ..handlePointerCancel(const PointerCancelEvent(position: p));

      expect(graph.selectedEntityIds, isNot(contains(link.id)));
    });

    // -- drag lifecycle -------------------------------------------------------

    test('pan gesture on a node produces drag-update events (not a tap)', () {
      final node = _addNodeAt(graph, const Offset(200, 200));
      final gm = manager();

      const start = Offset(200, 200);
      const end = Offset(260, 200);
      final delta = end - start;

      gm
        ..handlePointerDown(const PointerDownEvent(position: start))
        ..handlePanStart(
          DragStartDetails(localPosition: start, globalPosition: start),
        )
        ..handlePanUpdate(
          DragUpdateDetails(
            globalPosition: end,
            localPosition: end,
            delta: delta,
          ),
        )
        ..handlePanEnd(DragEndDetails());

      // At least one drag-update event must be dispatched.
      expect(behavior.dragUpdateEvents, isNotEmpty);
      // Node position must have shifted.
      expect(node.logicalPosition, isNot(const Offset(200, 200)));
      // Tap events must NOT fire (it became a drag, not a tap).
      expect(behavior.tapEvents, isEmpty);
    });

    test('drag does not toggle selection when pointer is released', () {
      _addNodeAt(graph, const Offset(200, 200));
      final gm = manager();

      // Tap first to select.
      tapAt(gm, const Offset(200, 200));
      expect(graph.selectedEntityIds, isNotEmpty);
      final selectedBefore = graph.selectedEntityIds.toList();

      // Now drag the same node.
      const start = Offset(200, 200);
      const end = Offset(260, 200);
      final delta = end - start;

      gm
        ..handlePointerDown(const PointerDownEvent(position: start))
        ..handlePanStart(
          DragStartDetails(localPosition: start, globalPosition: start),
        )
        ..handlePanUpdate(
          DragUpdateDetails(
            globalPosition: end,
            localPosition: end,
            delta: delta,
          ),
        )
        ..handlePanEnd(DragEndDetails());

      // Selection must remain (drag-end does not deselect).
      expect(graph.selectedEntityIds, containsAll(selectedBefore));
    });

    // -- concurrent pointer (second down while first is tracked) ---------------

    test('second pointer down while node is tracked does not throw', () {
      // NOTE: PointerDownEvent/PointerUpEvent here use the default pointer id (0),
      // so both events are treated as the *same* pointer by the framework. This
      // tests single-pointer-id reentrancy, NOT true multitouch (two independent
      // pointer ids). True multitouch behaviour (pointer: 1 vs pointer: 2) should
      // be characterised separately when needed.
      _addNodeAt(graph, const Offset(100, 100));
      final gm = manager();

      // First pointer down on the node.
      gm.handlePointerDown(const PointerDownEvent(position: Offset(100, 100)));

      // Second pointer down somewhere else — must not throw.
      expect(
        () => gm.handlePointerDown(
          const PointerDownEvent(position: Offset(300, 300)),
        ),
        returnsNormally,
      );

      // Clean up.
      gm
        ..handlePointerUp(const PointerUpEvent(position: Offset(300, 300)))
        ..handlePointerUp(const PointerUpEvent(position: Offset(100, 100)));
    });
  });
}
