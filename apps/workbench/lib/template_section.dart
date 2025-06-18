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
        return '4つのノードの基本的な循環グラフ';
      case 'Small Network':
        return '6-8ノードの小規模ネットワーク';
      case 'Large Network':
        return '20-30ノードの大規模ネットワーク';
      case 'Tree Structure':
        return '階層的なツリー構造';
      case 'Complex Graph':
        return '複雑な接続を持つグラフ';
      default:
        return 'カスタムグラフ構造';
    }
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
                      onTap: () => onDataPresetChanged(preset),
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