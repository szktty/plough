# 削除パス整理 実装レビュー依頼(A1/A2/A8/F1)

依頼日: 2026-06-14
対象ブランチ: `feature/redesign`
対象コミット: `e63c302`(fix(graph): clean up node/link removal paths)
対象タスク: `doc/design_review_plan.md` の **A1 / A2 / A8 / F1**(削除パス整理)
レビュー方針: **実装の正しさ・副作用・スコープ妥当性**。結果は末尾の指定先に書き出してほしい。

---

## 背景

`doc/design_review.md` のバグ指摘のうち、ノード/リンク削除パスに集中した 4 件を
「削除時のクリーンアップ漏れ」という共通文脈で 1 コミットにまとめた
(`design_review_plan_feedback.md` §5 の推奨)。テストは項目別。

- **A1**: `removeNode` が接続リンクを links map から削除しない(隣接インデックスのみ除去)。
- **A2**: `_nodeDependencies` 死にフィールド + `removeLink` の無意味な `removeWhere`。
- **A8**: `removeLink` が `_notifyLayoutChange()` を呼ばない(`addLink` と非対称)。
- **F1**: `_nodeKeys`/`_linkKeys`/`_nodeViews` が削除時に掃除されず GlobalKey/widget リーク。

---

## 変更点

### `lib/src/graph/graph_base.dart`
- `removeNode`(A1): 接続リンクを **unique set** で集約(self-loop で incoming/outgoing
  両方に入る重複を排除)、隣接インデックスと `state.value.links` の両方から除去。
  `nodes`/`links` を 1 つの `copyWith` で更新。
- `removeLink`(A8): 末尾に `_notifyLayoutChange()` を追加。
- A2: `_nodeDependencies` 宣言・`removeNode` 内 `.remove(id)`・`removeLink` 内
  `removeWhere` ブロックを削除。

### `lib/src/graph_view/widget/graph.dart`
- `_pruneRemovedEntityCaches()` を新設(`_buildLinkView` の手前)。ビルダーの
  **ソート後・widget 構築前**に呼び、現存ノード/リンク id に無い
  `_nodeKeys`/`_nodeViews`/`_linkKeys` を `removeWhere`。
- 誤った `// TODO(user): Not used`(`_linkKeys` は実際は使用中)を削除。
- `@visibleForTesting int get debugCachedEntityCount` を追加(テスト用、キャッシュ合計件数)。

### テスト
- `test/graph_model_removal_test.dart`: A1(links map 掃除・隣接インデックス整合・
  無関係リンク保持)/ A8(`layoutChangeListenable` 発火)。
- `test/graph_view_removal_cache_test.dart`: F1(削除ノードが描画から消える・同 id 再追加で
  クラッシュしない・add/remove を 10 回繰り返しても `debugCachedEntityCount` がベースラインに
  戻る)。

---

## 必ず確認してほしい論点

1. **A1 の self-loop / 重複リンク処理**: `affectedLinks` を set 化したことで、
   source==target の自己ループや同一ノードに複数リンクがある場合も漏れ・二重除去なく
   処理できているか。
2. **A8 の通知の二重発火**: `removeLink` 単体での通知は 1 回か。`removeNode`(A1)が内部で
   links を除去する経路では `removeLink` を呼んでおらず `_notifyLayoutChange()` は
   removeNode 末尾の 1 回のみ、という理解で正しいか(意図せぬ多重通知がないか)。
3. **F1 の prune コスト**: `_pruneRemovedEntityCaches()` を**毎ビルド**で呼び、
   `_graph.nodes`/`_graph.links` から set を毎回構築する(O(nodes+links))。大規模グラフで
   許容範囲か。removeWhere との合算コストの評価。
4. **F1 の呼び出し位置**: ソート後・widget 構築前という位置は妥当か。
   `_buildState == initialize`(links 無し)のフレームで `_linkKeys` を消しても、
   次フレームで再生成されるため問題ないという理解で正しいか。
5. **`debugCachedEntityCount` の是非**: `@visibleForTesting` だが公開 state クラス
   (`GraphViewState`)に getter を生やしている。テスト専用 API を本番クラスに置く是非、
   別手段(prune ロジックの切り出し等)の方が良いか。
6. **スコープ**: A1/A2/A8/F1 を 1 コミットにまとめた粒度は妥当か。

---

## 検証状況(実装者報告)

- `dart format --set-exit-if-changed lib/ test/`: 0 changes。
- `flutter analyze lib/`: 新規 error/warning なし。
  - `graph.dart:437,451` の `unnecessary_cast` は **HEAD(4f579bc)から存在する既存 warning**
    (`getNode` 戻り型が既に `GraphNodeImpl?`)。今回の変更外でスコープ外として未修正。
- 非 golden テスト(全 16 ファイル): 28 passed / 2 skipped。
- 各テストは**対応する修正を外すと失敗**することを確認済み(セーフティネットが有効)。
  - F1: `_pruneRemovedEntityCaches()` をコメントアウトすると
    「cached entity count does not grow」が失敗。
- golden 失敗はベースラインでも出る環境差(本変更は描画に触れていない)。

---

## 期待する成果物

- 6 論点への所見(問題なし/要修正、根拠付き)。
- 見落とした副作用・回帰リスクがあれば `file:line` 付きで指摘。
- スコープ・粒度の妥当性。

レビュー結果は **`doc/review_feedback_20260614_02_removal.md`** に書き出してほしい。
