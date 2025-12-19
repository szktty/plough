import 'package:example/sample_data/base.dart';
import 'package:flutter/material.dart';
import 'package:plough/plough.dart';

// ignore_for_file: avoid_redundant_argument_values

SampleData manualSample() {
  final graph = Graph();

  // Nodes and links representing the Big Dipper
  final dubhe =
      GraphNode(properties: {'label': 'Dubhe', 'description': 'Dubhe'});
  final merak =
      GraphNode(properties: {'label': 'Merak', 'description': 'Merak'});
  final phecda =
      GraphNode(properties: {'label': 'Phecda', 'description': 'Phecda'});
  final megrez =
      GraphNode(properties: {'label': 'Megrez', 'description': 'Megrez'});
  final alioth =
      GraphNode(properties: {'label': 'Alioth', 'description': 'Alioth'});
  final mizar =
      GraphNode(properties: {'label': 'Mizar', 'description': 'Mizar'});
  final alkaid =
      GraphNode(properties: {'label': 'Alkaid', 'description': 'Alkaid'});

  // Create links between nodes
  final links = [
    GraphLink(
      source: dubhe,
      target: merak,
      direction: GraphLinkDirection.none,
    ),
    GraphLink(
      source: dubhe,
      target: megrez,
      direction: GraphLinkDirection.none,
    ),
    GraphLink(
      source: merak,
      target: phecda,
      direction: GraphLinkDirection.none,
    ),
    GraphLink(
      source: phecda,
      target: megrez,
      direction: GraphLinkDirection.none,
    ),
    GraphLink(
      source: megrez,
      target: alioth,
      direction: GraphLinkDirection.none,
    ),
    GraphLink(
      source: alioth,
      target: mizar,
      direction: GraphLinkDirection.none,
    ),
    GraphLink(
      source: mizar,
      target: alkaid,
      direction: GraphLinkDirection.none,
    ),
  ];

  graph
    ..addNodes([dubhe, merak, phecda, megrez, alioth, mizar, alkaid])
    ..addLinks(links);

  // Node positions
  // Arranged in the shape of the Big Dipper
  const scale = 120.0;
  final basePositions = {
    dubhe.id: const Offset(0, 0), // Dubhe (α star)
    merak.id: const Offset(-1, 0), // Merak (β star)
    phecda.id: const Offset(-0.8, 1.2), // Phecda (γ star)
    megrez.id: const Offset(0, 1), // Megrez (δ star)
    alioth.id: const Offset(0.2, 2.2), // Alioth (ε star)
    mizar.id: const Offset(0.5, 3), // Mizar (ζ star)
    alkaid.id: const Offset(1, 3.8), // Alkaid (η star)
  };
  // Apply scale transformation
  final nodePositions = GraphNodeLayoutPosition.fromMap(
    Map.fromEntries(
      basePositions.entries.map(
        (entry) => MapEntry(
          entry.key,
          entry.value.scale(scale, scale),
        ),
      ),
    ),
  );

  return SampleData(
    name: 'Manual layout',
    graph: graph,
    layoutStrategy: GraphManualLayoutStrategy(
      nodePositions: nodePositions,
      origin: GraphLayoutPositionOrigin.alignCenter,
    ),
    nodeRendererBuilder: _createNodeRenderer,
  );
}

GraphDefaultNodeRenderer _createNodeRenderer(
  BuildContext context,
  GraphNode node,
  Widget? child,
) {
  final label = node['label']! as String;
  const width = 20.0;
  const height = 20.0;

  final row = <Widget>[];
  final merak = label == 'Merak';
  final left = merak || label == 'Phecda';
  const effect = GlowingDotEffect(
    color: Colors.orange,
    blurRadius: 5,
    spreadRadius: 10,
  );
  if (left) {
    row
      ..add(SizedBox(width: merak ? 161.0 : 152.0))
      ..add(Text(label))
      ..add(const SizedBox(width: 16))
      ..add(effect);
  } else {
    row
      ..add(effect)
      ..add(const SizedBox(width: 16))
      ..add(Text(label));
  }

  return GraphDefaultNodeRenderer(
    node: node,
    style: const GraphDefaultNodeRendererStyle(
      color: Colors.transparent,
      width: width,
      height: height,
    ),
    builder: (context, graph, node, child) => OverflowBox(
      alignment: left ? Alignment.centerRight : Alignment.centerLeft,
      minWidth: width,
      maxWidth: width + 200,
      minHeight: height,
      maxHeight: height + 200,
      child: Row(children: row),
    ),
  );
}

class GlowingDotEffect extends StatefulWidget {
  const GlowingDotEffect({
    required this.color,
    required this.blurRadius,
    required this.spreadRadius,
    super.key,
  });
  final Color color;

  final double blurRadius;
  final double spreadRadius;

  @override
  State<GlowingDotEffect> createState() => _GlowingDotEffectState();
}

class _GlowingDotEffectState extends State<GlowingDotEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: 0.3 * _animation.value),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.5 * _animation.value),
                blurRadius: widget.blurRadius,
                spreadRadius: widget.spreadRadius * _animation.value,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
