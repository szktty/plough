import 'package:flutter/material.dart';
import 'package:plough/plough.dart';
import 'template_section.dart';

class LeftSidebar extends StatefulWidget {
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
  State<LeftSidebar> createState() => _LeftSidebarState();
}

class _LeftSidebarState extends State<LeftSidebar> {
  double _nodesSectionHeight = 200.0;
  final double _minSectionHeight = 100.0;
  final double _maxSectionHeight = 400.0;

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
            currentDataPreset: widget.currentDataPreset,
            onDataPresetChanged: widget.onDataPresetChanged,
            uiScale: widget.uiScale,
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
                        fontWeight: FontWeight.bold, fontSize: 16 * widget.uiScale)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                // Nodes section with variable height
                SizedBox(
                  height: _nodesSectionHeight,
                  child: Container(
                    color: Colors.blue[50],
                    child: Column(
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: Row(
                            children: [
                              Icon(Icons.account_tree, size: 16, color: Colors.blue[700]),
                              const SizedBox(width: 8),
                              Text(
                                'Nodes (${widget.graph.nodes.length})',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 16 * widget.uiScale,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // List
                        Expanded(
                          child: ListView.builder(
                            itemCount: widget.graph.nodes.length,
                            itemBuilder: (context, index) {
                              final node = widget.graph.nodes.elementAt(index);
                              final label = node.properties['label']?.toString() ?? 'Node ${index + 1}';
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                                              fontSize: 16 * widget.uiScale, 
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'ID: ${node.id.toString().substring(0, 8)}...',
                                            style: TextStyle(
                                              fontSize: 16 * widget.uiScale, 
                                              color: Colors.grey[600],
                                            ),
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
                  ),
                ),
                // Draggable divider
                MouseRegion(
                  cursor: SystemMouseCursors.resizeRow,
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      setState(() {
                        final newHeight = _nodesSectionHeight + details.delta.dy;
                        _nodesSectionHeight = newHeight.clamp(_minSectionHeight, _maxSectionHeight);
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      height: 8,
                      color: Colors.grey[300],
                      child: Center(
                        child: Container(
                          width: 40,
                          height: 2,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Links section takes remaining space
                Expanded(
                  child: Container(
                    color: Colors.orange[50],
                    child: Column(
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: Row(
                            children: [
                              Icon(Icons.link, size: 16, color: Colors.orange[700]),
                              const SizedBox(width: 8),
                              Text(
                                'Links (${widget.graph.links.length})',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 16 * widget.uiScale,
                                  color: Colors.orange[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // List
                        Expanded(
                          child: ListView.builder(
                            itemCount: widget.graph.links.length,
                            itemBuilder: (context, index) {
                              final link = widget.graph.links.elementAt(index);
                              final sourceLabel = link.source.properties['label']?.toString() ?? 'Node';
                              final targetLabel = link.target.properties['label']?.toString() ?? 'Node';
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                                              fontSize: 16 * widget.uiScale, 
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'ID: ${link.id.toString().substring(0, 8)}...',
                                            style: TextStyle(
                                              fontSize: 16 * widget.uiScale, 
                                              color: Colors.grey[600],
                                            ),
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
                  ),
                ),
              ],
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
          SizedBox(
            height: 150, // Fixed height for the ListView inside ExpansionTile
            child: ListView.builder(
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
          SizedBox(
            height: 150, // Fixed height for the ListView inside ExpansionTile
            child: ListView.builder(
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