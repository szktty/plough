import 'package:example/sample_data/sample_data.dart';
import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  AppState() {
    _selectedData = sampleDataList[0];
  }
  late SampleData _selectedData;

  SampleData get selectedData => _selectedData;

  List<SampleData> get sampleDataList => createSampleDataList();

  void selectSampleData(String name) {
    _selectedData =
        sampleDataList.firstWhere((element) => element.name == name);
    notifyListeners();
  }

  void reloadSampleDataList() {
    final current = _selectedData.name;
    selectSampleData(current);
  }

  /// 選択中のエンティティをすべて選択解除する
  void clearAllSelections() {
    _selectedData.graph.clearSelection();
    notifyListeners();
  }
}
