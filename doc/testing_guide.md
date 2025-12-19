# Plough Testing Guide

This guide provides comprehensive testing strategies for the Plough graph visualization library, focusing on testing without UI interactions.

## Overview

Testing a graph visualization library that uses CustomPaint and Positioned widgets presents unique challenges. This guide outlines a multi-layered approach to ensure comprehensive test coverage without relying on actual UI interactions.

## Testing Strategy (4-Layer Approach)

### 1. Data Model Layer Tests (Standard Unit Tests)

Test graph operations and data integrity without any UI involvement.

```dart
group('Graph Data Model Tests', () {
  test('should add and retrieve nodes correctly', () {
    final graph = Graph();
    final node = graph.createNode(data: 'test');
    
    expect(graph.nodes.length, 1);
    expect(graph.getNode(node.id), isNotNull);
  });

  test('should handle node connections properly', () {
    final graph = Graph();
    final node1 = graph.createNode(data: 'node1');
    final node2 = graph.createNode(data: 'node2');
    final link = graph.createLink(
      source: node1.id, 
      target: node2.id,
      data: 'connection'
    );
    
    expect(graph.links.length, 1);
    expect(link.source, node1.id);
  });
});
```

### 2. Layout Strategy Tests (Position Calculation Verification)

Test pure layout logic without UI rendering.

```dart
group('Layout Strategy Tests', () {
  test('ForceDirectedLayout should position nodes correctly', () {
    final graph = Graph();
    final node1 = graph.createNode(data: 'n1');
    final node2 = graph.createNode(data: 'n2');
    graph.createLink(source: node1.id, target: node2.id);
    
    final strategy = GraphForceDirectedLayoutStrategy(
      seed: 42, // For reproducible results
      springLength: 100.0,
    );
    
    // Execute layout
    strategy.performLayout(graph, const Size(400, 400));
    
    // Check positions are set
    expect((node1 as GraphNodeImpl).logicalPosition, isNot(Offset.zero));
    expect((node2 as GraphNodeImpl).logicalPosition, isNot(Offset.zero));
    
    // Check distance between nodes is reasonable
    final distance = ((node1 as GraphNodeImpl).logicalPosition - 
                    (node2 as GraphNodeImpl).logicalPosition).distance;
    expect(distance, greaterThan(50)); // Minimum distance
  });

  test('Manual layout should respect fixed positions', () {
    final graph = Graph();
    final node = graph.createNode(data: 'fixed');
    
    final fixedPosition = const Offset(100, 200);
    final strategy = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(
          id: node.id, 
          position: fixedPosition, 
          fixed: true
        )
      ]
    );
    
    strategy.performLayout(graph, const Size(400, 400));
    
    expect((node as GraphNodeImpl).logicalPosition, fixedPosition);
  });
});
```

### 3. Rendering Layer Tests (Widget Level)

Verify widget structure and properties without actual UI rendering.

```dart
group('Graph View Widget Tests', () {
  testWidgets('should build with minimal configuration', (tester) async {
    final graph = Graph();
    graph.createNode(data: 'test');
    
    final behavior = GraphViewDefaultBehavior(
      nodeRenderer: GraphDefaultNodeRenderer(
        style: const GraphDefaultNodeRendererStyle(
          shape: GraphCircle(),
          width: 50,
          height: 50,
        ),
      ),
    );
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 400,
            child: GraphView(
              graph: graph,
              behavior: behavior,
              layoutStrategy: GraphRandomLayoutStrategy(seed: 42),
            ),
          ),
        ),
      ),
    );
    
    // Verify GraphView exists
    expect(find.byType(GraphView), findsOneWidget);
    
    // Verify internal structure
    expect(find.byType(Stack), findsWidgets); // Layout structure
    expect(find.byType(Positioned), findsWidgets); // Node positioning
  });

  testWidgets('should handle empty graph', (tester) async {
    final graph = Graph();
    final behavior = GraphViewDefaultBehavior();
    
    await tester.pumpWidget(
      MaterialApp(
        home: GraphView(
          graph: graph,
          behavior: behavior,
          layoutStrategy: GraphRandomLayoutStrategy(),
        ),
      ),
    );
    
    expect(find.byType(GraphView), findsOneWidget);
    // Verify no errors occur
  });
});
```

### 4. Interaction/State Management Tests (Without Gestures)

Test state changes directly without UI operations.

```dart
group('Graph Interaction Tests', () {
  test('should update selection state programmatically', () {
    final graph = Graph();
    final node = graph.createNode(data: 'selectable');
    
    // Test selection state change
    final nodeImpl = node as GraphNodeImpl;
    nodeImpl.isSelected = true;
    
    expect(nodeImpl.isSelected, isTrue);
    
    // Deselect
    nodeImpl.isSelected = false;
    expect(nodeImpl.isSelected, isFalse);
  });

  test('should handle drag state transitions', () {
    final graph = Graph();
    final node = graph.createNode(data: 'draggable');
    
    final dragState = GraphDragState();
    
    // Start drag
    dragState.startDrag(node.id, const Offset(100, 100));
    expect(dragState.isDragging, isTrue);
    expect(dragState.draggedEntityId, node.id);
    
    // End drag
    dragState.endDrag();
    expect(dragState.isDragging, isFalse);
  });

  testWidgets('should notify listeners on graph changes', (tester) async {
    final graph = Graph();
    var notificationCount = 0;
    
    // Add listener
    graph.addListener(() => notificationCount++);
    
    // Verify listener is called on node addition
    graph.createNode(data: 'listener test');
    await tester.pump();
    
    expect(notificationCount, greaterThan(0));
  });
});
```

### 5. Integration Tests (Layout + Rendering)

Verify actual rendering results at the pixel level.

```dart
group('Integration Tests', () {
  testWidgets('should render nodes at calculated positions', (tester) async {
    final graph = Graph();
    final node1 = graph.createNode(data: 'node1');
    final node2 = graph.createNode(data: 'node2');
    
    // Test with fixed positions
    final behavior = GraphViewDefaultBehavior(
      nodeRenderer: GraphDefaultNodeRenderer(
        style: const GraphDefaultNodeRendererStyle(
          shape: GraphCircle(),
          width: 50,
          height: 50,
        ),
      ),
    );
    
    final strategy = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(id: node1.id, position: const Offset(100, 100)),
        GraphNodeLayoutPosition(id: node2.id, position: const Offset(200, 200)),
      ]
    );
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 400,
            child: GraphView(
              graph: graph,
              behavior: behavior,
              layoutStrategy: strategy,
            ),
          ),
        ),
      ),
    );
    
    await tester.pumpAndSettle(); // Wait for animations
    
    // Verify rendering
    expect(find.byType(GraphView), findsOneWidget);
    
    // Check actual position data
    expect((node1 as GraphNodeImpl).logicalPosition, const Offset(100, 100));
    expect((node2 as GraphNodeImpl).logicalPosition, const Offset(200, 200));
  });
});
```

## Gesture Testing

Testing gestures without actual UI interactions requires different approaches:

### 1. Gesture Manager Unit Tests (Recommended)

Test gesture logic directly without UI operations.

```dart
group('Gesture Manager Tests', () {
  late Graph graph;
  late GraphGestureManager gestureManager;
  late GraphViewBehavior behavior;
  late List<GraphSelectionChangeEvent> selectionEvents;
  late List<GraphTapEvent> tapEvents;
  late List<GraphDragStartEvent> dragStartEvents;

  setUp(() {
    graph = Graph();
    selectionEvents = [];
    tapEvents = [];
    dragStartEvents = [];
    
    behavior = GraphViewDefaultBehavior(
      onSelectionChange: (event) => selectionEvents.add(event),
      onTap: (event) => tapEvents.add(event),
      onDragStart: (event) => dragStartEvents.add(event),
    );
    
    gestureManager = GraphGestureManager(
      graph: graph,
      viewBehavior: behavior,
      viewportSize: const Size(400, 400),
    );
  });

  test('should handle node selection correctly', () {
    // Add node to graph
    final node = graph.createNode(data: 'test');
    
    // Set node position and size for hit testing
    (node as GraphNodeImpl).logicalPosition = const Offset(100, 100);
    (node as GraphNodeImpl).geometry = GraphNodeViewGeometry(
      bounds: const Rect.fromLTWH(75, 75, 50, 50),
    );
    
    // Simulate PointerDown/Up events
    const tapPosition = Offset(100, 100);
    final downEvent = PointerDownEvent(
      position: tapPosition,
      localPosition: tapPosition,
    );
    final upEvent = PointerUpEvent(
      position: tapPosition,
      localPosition: tapPosition,
    );
    
    // Process gestures
    gestureManager.handlePointerDown(downEvent);
    gestureManager.handlePointerUp(upEvent);
    
    // Verify results
    expect(graph.selectedEntityIds.contains(node.id), isTrue);
    expect(selectionEvents.length, 1);
    expect(selectionEvents.first.selectedIds, contains(node.id));
    expect(tapEvents.length, 1);
    expect(tapEvents.first.entityIds, contains(node.id));
  });

  test('should handle drag gesture correctly', () {
    final node = graph.createNode(data: 'draggable');
    
    // Set initial position
    (node as GraphNodeImpl).logicalPosition = const Offset(100, 100);
    (node as GraphNodeImpl).geometry = GraphNodeViewGeometry(
      bounds: const Rect.fromLTWH(75, 75, 50, 50),
    );
    
    const startPosition = Offset(100, 100);
    const endPosition = Offset(150, 150);
    
    // Simulate drag sequence
    final downEvent = PointerDownEvent(
      position: startPosition,
      localPosition: startPosition,
    );
    
    final panStartDetails = DragStartDetails(
      localPosition: startPosition,
    );
    
    final panUpdateDetails = DragUpdateDetails(
      localPosition: endPosition,
      delta: endPosition - startPosition,
    );
    
    final panEndDetails = DragEndDetails();
    
    // Process gestures
    gestureManager.handlePointerDown(downEvent);
    gestureManager.handlePanStart(panStartDetails);
    gestureManager.handlePanUpdate(panUpdateDetails);
    gestureManager.handlePanEnd(panEndDetails);
    
    // Check drag events were fired
    expect(dragStartEvents.length, 1);
    expect(dragStartEvents.first.entityIds, contains(node.id));
    
    // Check node position was updated
    final nodeImpl = node as GraphNodeImpl;
    expect(nodeImpl.logicalPosition, isNot(const Offset(100, 100)));
  });

  test('should handle different gesture modes correctly', () {
    final node = graph.createNode(data: 'test');
    (node as GraphNodeImpl).logicalPosition = const Offset(100, 100);
    (node as GraphNodeImpl).geometry = GraphNodeViewGeometry(
      bounds: const Rect.fromLTWH(75, 75, 50, 50),
    );
    
    // Test NodeEdgeOnly mode
    final nodeEdgeManager = GraphGestureManager(
      graph: graph,
      viewBehavior: behavior,
      viewportSize: const Size(400, 400),
      gestureMode: GraphGestureMode.nodeEdgeOnly,
    );
    
    // Gesture on node
    expect(
      nodeEdgeManager.shouldConsumeGestureAt(const Offset(100, 100)),
      isTrue
    );
    
    // Gesture on background
    expect(
      nodeEdgeManager.shouldConsumeGestureAt(const Offset(200, 200)),
      isFalse
    );
    
    // Test Transparent mode
    final transparentManager = GraphGestureManager(
      graph: graph,
      viewBehavior: behavior,
      viewportSize: const Size(400, 400),
      gestureMode: GraphGestureMode.transparent,
    );
    
    expect(
      transparentManager.shouldConsumeGestureAt(const Offset(100, 100)),
      isFalse
    );
  });

  test('should handle hit testing correctly', () {
    final node1 = graph.createNode(data: 'node1');
    final node2 = graph.createNode(data: 'node2');
    
    // Set node positions
    (node1 as GraphNodeImpl).logicalPosition = const Offset(100, 100);
    (node1 as GraphNodeImpl).geometry = GraphNodeViewGeometry(
      bounds: const Rect.fromLTWH(75, 75, 50, 50),
    );
    
    (node2 as GraphNodeImpl).logicalPosition = const Offset(200, 200);
    (node2 as GraphNodeImpl).geometry = GraphNodeViewGeometry(
      bounds: const Rect.fromLTWH(175, 175, 50, 50),
    );
    
    // Verify hit test results
    final hitResult1 = gestureManager.createHitTestResult(const Offset(100, 100));
    expect(hitResult1.node?.id, node1.id);
    
    final hitResult2 = gestureManager.createHitTestResult(const Offset(200, 200));
    expect(hitResult2.node?.id, node2.id);
    
    final hitResultBackground = gestureManager.createHitTestResult(const Offset(300, 300));
    expect(hitResultBackground.node, isNull);
    expect(hitResultBackground.hasEntity, isFalse);
  });
});
```

### 2. Widget Test Gesture Simulation

More integrated testing using actual Flutter widget tree.

```dart
group('GraphView Gesture Integration Tests', () {
  testWidgets('should handle tap gestures in widget tree', (tester) async {
    final graph = Graph();
    final node = graph.createNode(data: 'tappable');
    
    var tapCount = 0;
    final behavior = GraphViewDefaultBehavior(
      onTap: (event) => tapCount++,
      nodeRenderer: GraphDefaultNodeRenderer(
        style: const GraphDefaultNodeRendererStyle(
          shape: GraphCircle(),
          width: 50,
          height: 50,
        ),
      ),
    );
    
    // Test with fixed position
    final strategy = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(
          id: node.id, 
          position: const Offset(200, 200)
        )
      ]
    );
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 400,
            child: GraphView(
              graph: graph,
              behavior: behavior,
              layoutStrategy: strategy,
            ),
          ),
        ),
      ),
    );
    
    await tester.pumpAndSettle();
    
    // Tap node
    await tester.tapAt(const Offset(200, 200));
    await tester.pump();
    
    expect(tapCount, 1);
    expect(graph.selectedEntityIds.contains(node.id), isTrue);
  });

  testWidgets('should handle drag gestures in widget tree', (tester) async {
    final graph = Graph();
    final node = graph.createNode(data: 'draggable');
    
    var dragStartCount = 0;
    var dragUpdateCount = 0;
    var dragEndCount = 0;
    
    final behavior = GraphViewDefaultBehavior(
      onDragStart: (event) => dragStartCount++,
      onDragUpdate: (event) => dragUpdateCount++,
      onDragEnd: (event) => dragEndCount++,
      nodeRenderer: GraphDefaultNodeRenderer(
        style: const GraphDefaultNodeRendererStyle(
          shape: GraphCircle(),
          width: 50,
          height: 50,
        ),
      ),
    );
    
    final strategy = GraphManualLayoutStrategy(
      nodePositions: [
        GraphNodeLayoutPosition(
          id: node.id, 
          position: const Offset(200, 200)
        )
      ]
    );
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 400,
            child: GraphView(
              graph: graph,
              behavior: behavior,
              layoutStrategy: strategy,
            ),
          ),
        ),
      ),
    );
    
    await tester.pumpAndSettle();
    
    // Execute drag gesture
    await tester.drag(
      find.byType(GraphView),
      const Offset(50, 50),
      startLocation: const Offset(200, 200),
    );
    
    await tester.pumpAndSettle();
    
    expect(dragStartCount, 1);
    expect(dragUpdateCount, greaterThan(0));
    expect(dragEndCount, 1);
    
    // Check node position changed
    final nodeImpl = node as GraphNodeImpl;
    expect(nodeImpl.logicalPosition, isNot(const Offset(200, 200)));
  });
});
```

### 3. Custom Gesture Test Helpers

Helper utilities for testing complex gesture sequences easily.

```dart
class GraphGestureTestHelper {
  final GraphGestureManager gestureManager;
  final Graph graph;
  
  GraphGestureTestHelper({
    required this.gestureManager,
    required this.graph,
  });
  
  // Helper to tap a node
  void tapNode(GraphId nodeId) {
    final node = graph.getNode(nodeId)!;
    final position = (node as GraphNodeImpl).logicalPosition;
    
    final downEvent = PointerDownEvent(
      position: position,
      localPosition: position,
    );
    final upEvent = PointerUpEvent(
      position: position,
      localPosition: position,
    );
    
    gestureManager.handlePointerDown(downEvent);
    gestureManager.handlePointerUp(upEvent);
  }
  
  // Helper to drag a node
  void dragNode(GraphId nodeId, Offset delta) {
    final node = graph.getNode(nodeId)!;
    final startPosition = (node as GraphNodeImpl).logicalPosition;
    final endPosition = startPosition + delta;
    
    final downEvent = PointerDownEvent(
      position: startPosition,
      localPosition: startPosition,
    );
    
    gestureManager.handlePointerDown(downEvent);
    gestureManager.handlePanStart(
      DragStartDetails(localPosition: startPosition)
    );
    gestureManager.handlePanUpdate(
      DragUpdateDetails(
        localPosition: endPosition,
        delta: delta,
      )
    );
    gestureManager.handlePanEnd(DragEndDetails());
  }
  
  // Helper to test multi-node selection
  void multiSelectNodes(List<GraphId> nodeIds) {
    for (final nodeId in nodeIds) {
      final node = graph.getNode(nodeId)!;
      final position = (node as GraphNodeImpl).logicalPosition;
      
      // Simulate Ctrl+click
      final downEvent = PointerDownEvent(
        position: position,
        localPosition: position,
        kind: PointerDeviceKind.mouse,
        buttons: kPrimaryButton,
      );
      final upEvent = PointerUpEvent(
        position: position,
        localPosition: position,
        kind: PointerDeviceKind.mouse,
      );
      
      gestureManager.handlePointerDown(downEvent);
      gestureManager.handlePointerUp(upEvent);
    }
  }
}

// Usage example
test('should handle complex gesture sequences', () {
  final helper = GraphGestureTestHelper(
    gestureManager: gestureManager,
    graph: graph,
  );
  
  final node1 = graph.createNode(data: 'node1');
  final node2 = graph.createNode(data: 'node2');
  
  // Tap node1 to select
  helper.tapNode(node1.id);
  expect(graph.selectedEntityIds.contains(node1.id), isTrue);
  
  // Drag node1
  helper.dragNode(node1.id, const Offset(50, 50));
  
  // Also select node2
  helper.multiSelectNodes([node2.id]);
  expect(graph.selectedEntityIds.length, 2);
});
```

## Summary

### Advantages of This Approach

- **No UI Operations Required**: Test state without actual gestures
- **Fast Execution**: Layout calculations only are very fast
- **Easy Debugging**: Each layer can be tested independently
- **High Reproducibility**: Deterministic tests using seeds

### Recommended Approach

1. **Gesture Manager Unit Tests** for core logic verification
2. **Widget Tests** for integration behavior confirmation
3. **Test Helpers** for complex scenario testing

Even with CustomPaint and Positioned widgets, the core state management and layout calculations are standard Dart code that can be tested using conventional testing methods.

## Best Practices

1. Always use fixed positions when testing gesture interactions
2. Set up proper node geometry for hit testing
3. Use seeds for reproducible layout tests
4. Test each gesture mode separately
5. Verify both state changes and event emissions
6. Use test helpers for complex gesture sequences