import 'package:flutter/material.dart';
import 'package:plough/plough.dart';
import 'template_section.dart';

class LeftSidebar extends StatelessWidget {
  final Graph graph;
  final double uiScale;
  final String currentDataPreset;
  final Function(String?) onDataPresetChanged;

  const LeftSidebar({
    super.key,
    required this.graph,
    required this.uiScale,
    required this.currentDataPreset,
    required this.onDataPresetChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(right: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          TemplateSection(
            currentDataPreset: currentDataPreset,
            onDataPresetChanged: onDataPresetChanged,
            uiScale: uiScale,
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                const Icon(Icons.list, size: 16),
                const SizedBox(width: 8),
                Text('Graph Entities',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16 * uiScale)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  NodesSection(graph: graph, uiScale: uiScale),
                  LinksSection(graph: graph, uiScale: uiScale),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NodesSection extends StatelessWidget {
  final Graph graph;
  final double uiScale;

  const NodesSection({
    super.key,
    required this.graph,
    required this.uiScale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue[50],
      child: ExpansionTile(
        title: Text('Nodes (${graph.nodes.length})',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * uiScale)),
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 8),
        childrenPadding: EdgeInsets.zero,
        backgroundColor: Colors.blue[50],
        collapsedBackgroundColor: Colors.blue[50],
        iconColor: Colors.blue[700],
        collapsedIconColor: Colors.blue[700],
        shape: const Border(),
        collapsedShape: const Border(),
        controlAffinity: ListTileControlAffinity.leading,
        children: [
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: graph.nodes.length,
              itemBuilder: (context, index) {
                final node = graph.nodes.elementAt(index);
                final label =
                    node.properties['label']?.toString() ?? 'Node ${index + 1}';
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.blue[200]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                  fontSize: 16 * uiScale, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'ID: ${node.id.toString().substring(0, 8)}...',
                              style: TextStyle(
                                  fontSize: 16 * uiScale, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LinksSection extends StatelessWidget {
  final Graph graph;
  final double uiScale;

  const LinksSection({
    super.key,
    required this.graph,
    required this.uiScale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.orange[50],
      child: ExpansionTile(
        title: Text('Links (${graph.links.length})',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * uiScale)),
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 8),
        childrenPadding: EdgeInsets.zero,
        backgroundColor: Colors.orange[50],
        collapsedBackgroundColor: Colors.orange[50],
        iconColor: Colors.orange[700],
        collapsedIconColor: Colors.orange[700],
        shape: const Border(),
        collapsedShape: const Border(),
        controlAffinity: ListTileControlAffinity.leading,
        children: [
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: graph.links.length,
              itemBuilder: (context, index) {
                final link = graph.links.elementAt(index);
                final sourceLabel =
                    link.source.properties['label']?.toString() ?? 'Node';
                final targetLabel =
                    link.target.properties['label']?.toString() ?? 'Node';
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.orange[200]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$sourceLabel → $targetLabel',
                              style: TextStyle(
                                  fontSize: 16 * uiScale, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'ID: ${link.id.toString().substring(0, 8)}...',
                              style: TextStyle(
                                  fontSize: 16 * uiScale, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}