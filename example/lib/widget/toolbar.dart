import 'package:example/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// lib/widget/toolbar.dart
class MainPageToolbar extends StatelessWidget {
  const MainPageToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: state.selectedData.name,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: state.sampleDataList.map((item) {
                        return DropdownMenuItem(
                          value: item.name,
                          child: Text(item.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          state.selectSampleData(value);
                        }
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: state.reloadSampleDataList,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Reload',
                  ),
                  IconButton(
                    onPressed: state.clearAllSelections,
                    icon: const Icon(Icons.deselect),
                    tooltip: 'Clear Selection',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
