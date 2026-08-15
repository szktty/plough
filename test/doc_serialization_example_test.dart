import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';

/// Verifies the save/restore example in llms-full.txt actually round-trips.
void main() {
  test('the documented serialization round trip preserves positions', () {
    final original = Graph();
    final a = GraphNode(
      properties: {'label': 'a'},
      logicalPosition: const Offset(120, 340),
      isArranged: true,
    );
    final b = GraphNode(
      properties: {'label': 'b'},
      logicalPosition: const Offset(560, 210),
      isArranged: true,
    );
    original
      ..addNode(a)
      ..addNode(b)
      ..addLink(
        GraphLink(
          source: a,
          target: b,
          direction: GraphLinkDirection.outgoing,
        ),
      );

    final saved = {
      'nodes': [
        for (final node in original.nodes)
          {
            'id': node.id.value,
            'properties': node.properties,
            'x': node.logicalPosition.dx,
            'y': node.logicalPosition.dy,
          },
      ],
      'links': [
        for (final link in original.links)
          {
            'source': link.source.id.value,
            'target': link.target.id.value,
            'direction': link.direction.name,
          },
      ],
    };

    final graph = Graph();
    final byId = <String, GraphNode>{};
    for (final n in saved['nodes']! as List) {
      final node = GraphNode(
        properties: (n as Map)['properties'] as Map<String, Object>,
        logicalPosition: Offset(n['x'] as double, n['y'] as double),
        isArranged: true,
      );
      byId[n['id'] as String] = node;
      graph.addNode(node);
    }
    for (final l in saved['links']! as List) {
      graph.addLink(
        GraphLink(
          source: byId[(l as Map)['source']]!,
          target: byId[l['target']]!,
          direction: GraphLinkDirection.values.byName(l['direction'] as String),
        ),
      );
    }

    expect(graph.nodes.length, 2);
    expect(graph.links.length, 1);
    final positions = {
      for (final n in graph.nodes) n.properties['label']: n.logicalPosition,
    };
    expect(positions['a'], const Offset(120, 340));
    expect(positions['b'], const Offset(560, 210));
    expect(graph.links.first.direction, GraphLinkDirection.outgoing);
    expect(graph.nodes.every((n) => n.isArranged), isTrue);
  });
}
