import 'package:flutter/material.dart';
import 'workbench_state.dart';

class TemplateSection extends StatelessWidget {
  final String currentDataPreset;
  final Function(String?) onDataPresetChanged;
  final double uiScale;

  const TemplateSection({
    super.key,
    required this.currentDataPreset,
    required this.onDataPresetChanged,
    required this.uiScale,
  });

  String _getPresetDescription(String preset) {
    switch (preset) {
      case 'Default':
        return 'Basic cyclic graph with 4 nodes';
      case 'Small Network':
        return 'Small network with 6 nodes';
      case 'Large Network':
        return 'Large network with 25 nodes';
      case 'Tree Structure':
        return 'Hierarchical tree structure (10 nodes)';
      case 'Complex Graph':
        return 'Hub-spoke complex graph (18 nodes)';
      default:
        return 'Custom graph structure';
    }
  }

  void _showLoadConfirmationDialog(BuildContext context, String preset) {
    // Don't show dialog if the same preset is already selected
    if (preset == currentDataPreset) {
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Load Graph Template',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Do you want to overwrite the current graph data and load a new template?',
                style: TextStyle(fontSize: 16 * uiScale),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preset,
                      style: TextStyle(
                        fontSize: 16 * uiScale,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getPresetDescription(preset),
                      style: TextStyle(
                        fontSize: 14 * uiScale,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16 * uiScale,
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDataPresetChanged(preset);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Load',
                style: TextStyle(
                  fontSize: 16 * uiScale,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green[50],
      child: ExpansionTile(
        title: Text('Graph Template',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * uiScale)),
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.symmetric(horizontal: 8),
        childrenPadding: EdgeInsets.zero,
        backgroundColor: Colors.green[50],
        collapsedBackgroundColor: Colors.green[50],
        iconColor: Colors.green[700],
        collapsedIconColor: Colors.green[700],
        shape: const Border(),
        collapsedShape: const Border(),
        controlAffinity: ListTileControlAffinity.leading,
        children: [
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: dataPresets.length,
              itemBuilder: (context, index) {
                final preset = dataPresets[index];
                final isSelected = preset == currentDataPreset;
                final description = _getPresetDescription(preset);
                
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                  child: Material(
                    color: isSelected ? Colors.green[100] : Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: () => _showLoadConfirmationDialog(context, preset),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? Colors.green[400]! : Colors.green[200]!,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? Colors.green[700] : Colors.green[400],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    preset,
                                    style: TextStyle(
                                      fontSize: 16 * uiScale,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected ? Colors.green[800] : Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    description,
                                    style: TextStyle(
                                      fontSize: 14 * uiScale,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Colors.green[700],
                              ),
                          ],
                        ),
                      ),
                    ),
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