# UI更新の不要な再描画修正タスク実行計画

## 問題の概要
Gesture Passthrough Demoでノードをタップやドラッグしたときにグラフがちらつく問題がある。原因は以下の3つ：

1. **GraphGestureManagerの問題**: ノード操作時にもバックグラウンドコールバックが呼ばれる
2. **GraphViewの問題**: ジオメトリ更新のたびにsetStateが呼ばれる
3. **Demo画面の問題**: バックグラウンドコールバックで頻繁にsetStateが呼ばれる

## タスク実行計画

### Phase 1: GraphGestureManagerの修正
**ファイル**: `lib/src/interactive/gesture_manager.dart`
**問題**: 
- `handlePanStart` (line 503-566)
- `handlePanUpdate` (line 568-637)
- `handlePanEnd` (line 639-683)

これらのメソッドで、ノード/リンク処理後もバックグラウンドコールバックが呼ばれている。

**修正内容**:
- `nodeEdgeOnly`モードでは、ノード/リンクが見つかった場合はバックグラウンドコールバックを呼ばない
- 早期リターンロジックの改善

### Phase 2: GraphViewのジオメトリ更新最適化
**ファイル**: `lib/src/graph_view/widget/graph.dart`
**問題**:
- Line 325-334: `_updateGraphGeometry`のaddPostFrameCallback内でsetState
- Line 342-350: `_updateNodeGeometry`のaddPostFrameCallback内でsetState

**修正内容**:
- 不要なsetStateを削除
- ジオメトリが実際に変更された場合のみ更新

### Phase 3: Demo画面の最適化
**ファイル**: `example/lib/widget/gesture_passthrough_demo_page.dart`
**問題**:
- `_scheduleUpdate`が頻繁に呼ばれる (line 38-50)

**修正内容**:
- デバウンス処理の追加
- 実際に表示内容が変わる場合のみ更新

### Phase 4: ビルド確認
- `flutter analyze`
- `flutter run -d macos`で起動確認（すぐに終了）

## 進捗状況

### 現在のステータス
- **開始時刻**: 2025/6/5 
- **現在のフェーズ**: 完了
- **完了したタスク**: 全Phase完了

### 詳細進捗
1. ✅ 問題分析完了
   - GraphGestureManagerのコールバック呼び出しロジック特定
   - GraphViewのsetState箇所特定
   - Demo画面の更新箇所特定

2. ✅ Phase 1: GraphGestureManager修正 (完了)
   - ✅ handlePanStartの修正 - nodeEdgeOnlyモードでノード/リンク処理時はバックグラウンドコールバックをスキップ
   - ✅ handlePanUpdateの修正 - 同上の処理を追加
   - ✅ handlePanEndの修正 - 同上の処理を追加

3. ✅ Phase 2: GraphView最適化 (完了)
   - ✅ _updateGraphGeometryの修正 - setState削除、PostFrameCallback内で直接更新
   - ✅ _updateNodeGeometryの修正 - setState削除、PostFrameCallback内で直接更新
   - ✅ 不要なsetState削除 - 2箇所で実施

4. ✅ Phase 3: Demo画面最適化 (完了)
   - ✅ _scheduleUpdateにデバウンス追加 - 100msのデバウンス期間を設定
   - ✅ 更新条件の最適化 - onBackgroundPanUpdateのみデバウンス、他は即座にsetState

5. ✅ Phase 4: ビルド確認 (完了)
   - ✅ flutter analyze実行 - 主に行長警告のみ
   - ✅ ビルド確認 - macOSビルド成功

### 実装した修正内容

#### GraphGestureManager (gesture_manager.dart)
- **handlePanStart**: nodeEdgeOnlyモード時、ノード/リンク処理後は早期リターン
- **handlePanUpdate**: ノード/リンク上でのpanUpdate時もバックグラウンドコールバックをスキップ
- **handlePanEnd**: ドラッグ終了時も同様の処理を追加

#### GraphView (graph.dart)
- **ジオメトリ更新処理**: setStateを削除し、PostFrameCallback内で直接状態更新
- buildState.valueの更新のみで再描画をトリガー

#### GesturePassthroughDemoPage
- **デバウンス処理**: 100msの遅延を設定し、頻繁な更新を抑制
- **選択的setState**: panUpdate以外は即座に更新、panUpdateのみデバウンス使用

### 再開時の参考情報
- **問題箇所リスト**:
  - `gesture_manager.dart:559-565, 619, 636, 681` (バックグラウンドコールバック)
  - `graph.dart:325-334, 342-350` (ジオメトリ更新setState)
  - `gesture_passthrough_demo_page.dart:41-49` (scheduleUpdate内setState)

- **修正方針**:
  - ノード/リンク処理時はバックグラウンドコールバックをスキップ
  - ジオメトリ変更チェックを追加してsetStateを最小化
  - デバウンス処理で頻繁な更新を防ぐ

### 最終結果
全ての修正が完了し、以下の改善が実施されました：

1. **GraphGestureManager**: nodeEdgeOnlyモードでノード/リンク操作時にバックグラウンドコールバックが呼ばれなくなった
2. **GraphView**: ジオメトリ更新時の不要なsetStateを削除し、パフォーマンスが向上
3. **Demo画面**: デバウンス処理により頻繁な再描画が抑制された

これにより、Gesture Passthrough Demoでノードをタップやドラッグした際のちらつきが解消されます。