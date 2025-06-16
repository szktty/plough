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
    // グラフの選択をクリア（個別のエンティティ更新を使用）
    _selectedData.graph.clearSelection();

    // AppStateの変更通知は送らない（グラフ全体の再描画を避けるため）
    // 個々のエンティティの状態変更は、Signalを通じて自動的に伝播される
  }
}
