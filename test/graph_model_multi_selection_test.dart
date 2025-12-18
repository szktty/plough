import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/graph/graph_base.dart' show GraphImpl;
import 'package:plough/src/graph/graph_data.dart' show GraphNodeData;
import 'package:plough/src/graph/node.dart' show GraphNodeImpl;

void main() {
  test('GraphImpl allowMultiSelection=true keeps multiple nodes selected', () {
    final graph = Graph();
    final gi = graph as GraphImpl;
    final a = GraphNodeImpl(
      GraphNodeData(id: GraphId.unique(GraphIdType.node)),
    );
    final b = GraphNodeImpl(
      GraphNodeData(id: GraphId.unique(GraphIdType.node)),
    );
    graph
      ..addNode(a)
      ..addNode(b);

    // enable multi-selection on graph state
    gi.state.value = gi.state.value.copyWith(allowMultiSelection: true);

    graph.selectNode(a.id);
    expect(graph.selectedNodeIds, contains(a.id));
    expect(graph.selectedNodeIds.length, 1);

    graph.selectNode(b.id);
    expect(graph.selectedNodeIds, containsAll([a.id, b.id]));
    expect(graph.selectedNodeIds.length, 2);
  });
}
