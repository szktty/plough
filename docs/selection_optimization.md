# グラフ選択解除の最適化

## 問題の背景

グラフの選択解除操作を行うと、グラフ全体が点滅する問題が発生していました。これは、選択解除時にグラフ全体が再描画されることが原因でした。

## 原因分析

### 元の実装

元の実装では、以下の流れで選択解除が行われていました：

1. `AppState.clearAllSelections()`メソッドが呼び出される
2. `graph.clearSelection()`が実行される
3. `notifyListeners()`が呼び出され、AppStateを監視しているすべてのウィジェットが再構築される
4. その結果、グラフ全体が再描画され、点滅が発生する

### 状態管理の仕組み

Ploughライブラリでは、状態管理に以下の仕組みを使用しています：

1. **Signal**: 値の変更を監視し、変更があった場合に依存するコンポーネントに通知するリアクティブな値
2. **ListenableSignalStateMixin**: Signalを使用した状態管理を提供するミックスイン
3. **GraphEntityImpl**: エンティティの状態を管理するベースクラス
4. **GraphImpl**: グラフ全体の状態を管理するクラス

### 問題の特定

問題は以下の2点にありました：

1. `clearSelection()`メソッドでグラフの状態を更新する際に、`state.value = ...`を使用していたため、グラフ全体の再描画が発生していた
2. `AppState.clearAllSelections()`メソッドで`notifyListeners()`を呼び出していたため、AppStateを監視しているすべてのウィジェットが再構築されていた

## 解決策

### 1. GraphImpl.clearSelection()の最適化

```dart
@override
void clearSelection() {
  // 現在選択されているノードとリンクのIDを保存
  final selectedNodeIds = state.value.selectedNodeIds.toList();
  final selectedLinkIds = state.value.selectedLinkIds.toList();
  
  // 選択されているノードをすべて選択解除（個別に状態更新）
  for (final nodeId in selectedNodeIds) {
    final node = getNodeOrThrow(nodeId) as GraphNodeImpl;
    node.overrideWith(isSelected: false);
  }
  
  // 選択されているリンクをすべて選択解除（個別に状態更新）
  for (final linkId in selectedLinkIds) {
    final link = getLinkOrThrow(linkId) as GraphLinkImpl;
    link.overrideWith(isSelected: false);
  }
  
  // グラフの選択状態をクリア（一括更新を避けるためにoverrideWithを使用）
  state.overrideWith(state.value.copyWith(
    selectedNodeIds: const IListConst([]),
    selectedLinkIds: const IListConst([]),
  ));
}
```

変更点：
- 選択されているノードとリンクのIDを先に取得して保存
- 各エンティティの選択状態を個別に更新（`overrideWith`を使用）
- グラフの選択状態を更新する際に`state.value = ...`ではなく`state.overrideWith(...)`を使用

### 2. AppState.clearAllSelections()の最適化

```dart
/// 選択中のエンティティをすべて選択解除する
void clearAllSelections() {
  // グラフの選択をクリア（個別のエンティティ更新を使用）
  _selectedData.graph.clearSelection();
  
  // AppStateの変更通知は送らない（グラフ全体の再描画を避けるため）
  // 個々のエンティティの状態変更は、Signalを通じて自動的に伝播される
}
```

変更点：
- `notifyListeners()`の呼び出しを削除
- 個々のエンティティの状態変更は、Signalを通じて自動的に伝播されるため、AppState全体の変更通知は不要

## シグナルの仕組み

### Signalとは

Signalは、値の変更を監視し、変更があった場合に依存するコンポーネントに通知するリアクティブな値です。Ploughライブラリでは、`signals_flutter`パッケージを使用しています。

### 主要なSignalの種類

1. **Signal<T>**: 単一の値を保持するSignal
2. **MapSignal<K, V>**: マップを保持するSignal
3. **ListSignal<T>**: リストを保持するSignal

### ListenableSignalStateMixin

このミックスインは、Signalを使用した状態管理を提供します。主要なメソッドは以下の通りです：

```dart
mixin ListenableSignalStateMixin<T> implements Listenable {
  Signal<T> get state;

  void setState(T value, {bool force = false}) {
    if (useOverrideState) {
      overrideState(value);
    } else {
      state.set(value, force: force);
    }
  }

  void overrideState(T value) {
    state.overrideWith(value);
  }
}
```

### setState vs overrideWith

- **setState**: 値を設定し、依存するすべてのコンポーネントに変更を通知します。これにより、グラフ全体の再描画が発生する可能性があります。
- **overrideWith**: 値を設定しますが、変更通知の範囲が限定されます。これにより、必要な部分のみが再描画されます。

## 最適化の効果

この最適化により、以下の効果が得られます：

1. 選択解除時の点滅が解消される
2. 選択解除操作のパフォーマンスが向上する
3. 必要な部分のみが再描画されるため、UIの応答性が向上する

## 教訓

1. 状態更新は、必要な範囲に限定することが重要
2. Signalのような細粒度の状態管理システムを活用することで、パフォーマンスを最適化できる
3. 全体の再描画を避けるために、`notifyListeners()`の使用は慎重に行う
