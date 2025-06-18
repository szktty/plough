# Gesture Pass-through Demo バグ解析レポート

## 問題の概要

"Gesture Pass-through Demo" 画面でグラフをタップするとリンクの描画位置が崩れたり、予期せぬリビルドでグラフが点滅状態になる問題が報告されている。ただし、最初の画面では再現しない。

## 調査結果

### 1. Example コードの分析

`example/lib/widget/gesture_passthrough_demo_page.dart` のコードを分析した結果、**exampleのコード自体は適切に実装されている**ことが判明した。

#### 主な発見事項：

1. **デバウンス機能の実装**
   - `_scheduleUpdate()` メソッドで `addPostFrameCallback` を使用したデバウンス処理を実装
   - 背景ジェスチャーコールバックから直接 `setState` を呼ばない設計
   - 頻繁な更新を防ぐ仕組みが既に組み込まれている

2. **setState の使用箇所（3箇所のみ）**
   - ジェスチャーモード変更時（問題なし）
   - Reset Viewボタン押下時（問題なし）
   - `_scheduleUpdate()` 内の `addPostFrameCallback` 内（デバウンス済み）

### 2. 問題の真の原因

exampleコードが適切に実装されているにも関わらず問題が発生することから、**問題はPloughパッケージ内部のジェスチャー処理実装にある**可能性が高い。

#### 考えられる原因：

1. **GraphView内部での不要なリビルド**
   - ジェスチャーマネージャーが内部的に状態変更を引き起こしている
   - レイアウト計算やアニメーションフレームごとの更新
   - ValueNotifier の通知が過剰に発生している可能性

2. **InteractiveViewerとの相互作用**
   - InteractiveViewerの変換マトリックスが更新されるたびにGraphViewがリビルドされる
   - ジェスチャー競合により、予期せぬイベントが発生

3. **ジェスチャー処理の複雑な条件分岐**
   - `gesture_manager.dart` 内の nodeEdgeOnly モードの「ダブルチェック」ロジック
   - 複数の早期リターンパスが一貫性のない動作を引き起こしている
   - 背景コールバックが必要以上に呼び出されている

### 3. 主な相違点（通常画面 vs Gesture Pass-through Demo）

| 項目 | 通常画面 | Gesture Pass-through Demo |
|------|----------|---------------------------|
| ジェスチャーモード | `GraphGestureMode.exclusive`（デフォルト） | `GraphGestureMode.nodeEdgeOnly` |
| InteractiveViewer | なし | exclusive以外のモードで使用 |
| 背景ジェスチャー | 処理されない | コールバックが発火 |
| リビルド頻度 | 低い | 高い（背景操作時） |

### 4. ワークベンチでの再現方法

ワークベンチアプリに以下の機能を追加し、バグ再現環境を構築：

1. ジェスチャーモードセレクター（Exclusive/NodeEdgeOnly/Transparent）
2. InteractiveViewerトグル
3. 背景ジェスチャー表示（黄色いボックスで表示）
4. デバウンス機能（100msタイマー）

### 5. 推奨される修正アプローチ

1. **ジェスチャーマネージャーの簡素化**
   - 複雑な条件分岐を整理
   - ダブルチェックパターンの見直し
   - 一貫性のあるコールバック処理

2. **内部状態更新の最適化**
   - 不要な ValueNotifier 通知の削減
   - レイアウト更新のバッチ処理改善
   - アニメーションフレーム同期の見直し

3. **InteractiveViewer統合の改善**
   - ジェスチャー競合の適切な解決
   - カスタムジェスチャーレコグナイザーの調整

## 結論

点滅問題は example コードの問題ではなく、Plough パッケージ内部のジェスチャー処理とリビルド管理の問題である可能性が高い。特に nodeEdgeOnly モードでの背景ジェスチャー処理と、InteractiveViewer との統合部分に注目して調査を続ける必要がある。

## 関連ファイル

- `/lib/src/interactive/gesture_manager.dart` - ジェスチャー処理の中核
- `/lib/src/graph_view/graph_view.dart` - GraphView ウィジェット
- `/lib/src/graph_view/hit_test.dart` - ヒットテスト処理
- `/example/lib/widget/gesture_passthrough_demo_page.dart` - 問題が発生するデモページ

作成日: 2025-06-16