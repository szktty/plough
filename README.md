# Plough

![Image](https://github.com/user-attachments/assets/d97ed817-ea44-479d-8a90-24a071fd6a30)

Plough is a library for creating interactive graph visualizations in Flutter applications.

## Features

- 📊 Add custom properties to nodes and links freely.
- 🔄 Multiple layout algorithms available: force-directed, tree, random, as well as custom layouts and manual node positioning.
- 🖱️ Interactive manipulation support: define behaviors for node/link dragging and tap gestures.
- 🎨 Customizable graph appearance and behavior: nodes and links are widgets, requiring no special rendering implementation.
- 🎬 Smooth animation of nodes from initial to final positions during first render.

## Documentation for AI assistant

To use AI assistance with this library, load `prompt/user_guide.xml` into the AI assistant.
`user_guide.xml` contains structured documentation in XML format, including the contents of this README, to help the AI assistant understand the library's functionality.

## Installation
Add to pubspec.yaml:

```yaml
dependencies:
  plough: ^0.6.0
```

Or run the command:

```
flutter pub add plough
```

## Simple example

This example shows how to draw a simple graph with two nodes and a connecting link using default settings:

```dart
@override
Widget build(BuildContext context) {
  final graph = Graph();
  final alice = GraphNode(properties: {
    'label': 'Alice',
    'description': 'Alice node'
  });
  final bob = GraphNode(properties: {
    'label': 'Bob',
    'description': 'Bob node'
  });
  final follow = GraphLink(
    source: alice,
    target: bob,
    properties: {
      'label': 'follows',
      'description': 'Alice follows Bob'
    },
    direction: GraphLinkDirection.outgoing,
  );
  graph
    ..addNode(alice)
    ..addNode(bob)
    ..addLink(follow);
  return GraphView(
    graph: graph,
    layoutStrategy: GraphForceDirectedLayoutStrategy(),
    behavior: const GraphViewDefaultBehavior(),
  );
}
```

This code generates graph data with two nodes and one link, laying out the nodes using a force-directed algorithm.
The graph view uses default implementations without customization.

## Basic Usage

Here are the basic steps to draw a graph with Plough:

1. Import `package:plough/plough.dart`.

2. Create a `Graph` object and build graph data. This is the library's core data structure for managing nodes and links.

3. Use `GraphNode` class to create nodes. The `properties` map can store arbitrary properties for customizing node display and properties.

4. Use `GraphLink` class to create links between nodes. Specify nodes with `source` and `target`, and set direction with `direction`. Links can also have a `properties` map.

5. Add the created nodes and links to the `Graph` object.

6. Use `GraphView` widget to render the graph. Specify node placement with `layoutStrategy` and customize graph view behavior with `behavior`.

Here's an example of drawing a simple graph with three nodes and two links:

```dart
// Import library
import 'package:plough/plough.dart';

// Create graph
final graph = Graph();

// Create nodes
final node1 = GraphNode(properties: {
  'label': 'Node1',
  'description': 'First node'
});
final node2 = GraphNode(properties: {
  'label': 'Node2',
  'description': 'Second node'
});
final node3 = GraphNode(properties: {
  'label': 'Node3',
  'description': 'Third node'
});

// Create links between nodes
final link1 = GraphLink(
  source: node1,
  target: node2,
  direction: GraphLinkDirection.outgoing,
);
final link2 = GraphLink(
  source: node2,
  target: node3,
  direction: GraphLinkDirection.outgoing,
);

// Add nodes and links to graph
graph
  ..addNode(node1)
  ..addNode(node2)
  ..addNode(node3)
  ..addLink(link1)
  ..addLink(link2);

// Display graph view
return GraphView(
  graph: graph,
  layoutStrategy: GraphForceDirectedLayoutStrategy(),
  behavior: const GraphViewDefaultBehavior(),
);
```

This example uses force-directed layout and default implementations for graph rendering and view behavior.
In the default implementation, a node's `label` property is displayed within the node view, and its `description` property appears as a tooltip.

## Behavior

Behavior (`GraphViewBehavior`) is a component for defining graph appearance and interactive operations.
The library provides `GraphViewDefaultBehavior` with basic behavior implementation, and recommends subclassing for custom behaviors.

### Main Methods

Methods that users can define. See API reference for details.

- `createNodeViewBehavior()`: Defines node display method. Returns node appearance and tooltip settings
- `createLinkViewBehavior()`: Defines link display method. Returns link appearance and connection settings
- `getConnectionPoints()`: Calculates connection points for links between nodes
- `onNodeSelect()`: Defines handling when a node is selected
- `onNodeTap()`: Defines handling when a node is tapped
- `onNodeDragStart()`, `onNodeDragUpdate()`, `onNodeDragEnd()`: Define handling for node drag operations

### Default Renderers

The library provides default implementations for rendering nodes and links.
Here are the features of each renderer:

- `GraphDefaultNodeRenderer`: Default implementation for node rendering
    - Circular or rectangular node shapes (default is circular)
    - Displays value of `label` key from `properties` as label
    - Style settings (color, size, etc.)

- `GraphDefaultLinkRenderer`: Default implementation for link rendering
    - Displays arrow-headed lines
    - Link thickness and color settings

To customize default renderers, implement `createNodeViewBehavior` or `createLinkViewBehavior`.

Example:

```dart
class CustomBehavior extends GraphViewDefaultBehavior {
  @override
  GraphNodeViewBehavior createNodeViewBehavior() {
    return GraphNodeViewBehavior.defaultBehavior(
      nodeRendererBuilder: (context, graph, node, child) {
        return GraphDefaultNodeRenderer(
          node: node,
          style: const GraphDefaultNodeRendererStyle(
            shape: GraphDefaultNodeRendererShape.rectangle,
          ),
          child: Center(
            child: Text(node['label']! as String),
          ),
        );
      },
    );
  }
}
```

## Layout Selection

Specify layout in `GraphView` with the `layoutStrategy` parameter. Layouts are implemented as instances of `GraphLayoutStrategy`
and the following layout strategies are available:

### Force-directed Layout

![Image](https://github.com/user-attachments/assets/93347d13-7f31-47e0-974a-5091c0d73c1a)

`GraphForceDirectedLayoutStrategy` applies a force-directed model between nodes and automatically calculates layout. It achieves balanced placement considering repulsive forces between nodes and attractive forces from links.

### Tree Layout

![Image](https://github.com/user-attachments/assets/685eeb65-7213-4f33-bd6a-a537482f3038)

`GraphTreeLayoutStrategy` is suitable for graphs with hierarchical structure. It arranges nodes hierarchically to visually represent parent-child relationships.

### Random Layout

`GraphRandomLayoutStrategy` places nodes at random positions. It can be used for initial placement or as a base for other layouts.

### Manual Layout

![Image](https://github.com/user-attachments/assets/a7de5c96-7809-4f95-bb1c-e513254289d8)

`GraphManualLayoutStrategy` is for complete manual control of node positions.
While node positions can be manually specified in any strategy, this strategy allows more detailed control.

### Custom Layout

To implement your own layout algorithm, create your own strategy by inheriting from `GraphCustomLayoutStrategy`.

### Directly Specifying Node Positions

Individual nodes can be manually positioned with any layout strategy.
Manually positioned nodes are excluded from layout algorithm calculations.

Node positions can be directly specified with `nodePositions` in each strategy's constructor.
Here's an example of arranging three nodes in a triangle:

```dart
// Define node positions
final basePositions = {
  nodeA.id: Offset(0.0, 0.0),      // Top
  nodeB.id: Offset(-1.0, 1.732),   // Bottom left
  nodeC.id: Offset(1.0, 1.732),    // Bottom right
};

// Create node positions
final nodePositions = GraphNodeLayoutPosition.fromMap(
  Map.fromEntries(
    basePositions.entries.map(
              (entry) => MapEntry(entry.key, entry.value.scale(scale, scale)),
    ),
  ),
);

// Apply layout
// Can be specified with any strategy
final layoutStrategy = GraphManualLayoutStrategy(
  nodePositions: nodePositions,
  origin: GraphLayoutPositionOrigin.alignCenter,
);
```

## Animation

When animation is enabled, nodes smoothly move from initial to final positions during first render.
Animation settings can be specified with `GraphView.animationEnabled`.
See API reference for details.

## TODO

- Layout strategies
  - Circular
  - Grid
  - Layered
- Layout saving and restoration
- Layout import and export
- Weight reflection in layouts

## License

Apache License 2.0

## Author

SUZUKI Tetsuya <tetsuya.suzuki@gmail.com>