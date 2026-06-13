# 削除パス整理 実装レビュー結果(A1/A2/A8/F1)

レビュー日: 2026-06-14
対象: `doc/review_request_20260614_02_removal.md`
対象コミット: `e63c302`(fix(graph): clean up node/link removal paths)
レビュー方針: 実装の正しさ・副作用・スコープ妥当性。コードは変更していない。

> 依頼文は結果を `doc/review_feedback_removal.md` に指定していたが、リポジトリの命名規約
> (`review_feedback_20260614_NN_*`)に合わせて本ファイル名とした。

## 総評

**承認(マージ可)。** A1/A2/A8/F1 の 4 件すべて、修正内容・テスト・副作用を実コードで
確認し問題なし。self-loop / 重複リンクの扱いは Set 化で正しく、A8 の通知は単発、F1 の
prune は機能する。テストは「修正を外すと落ちる」セーフティネットとして妥当。

必須対応はなし。**留意点 2 件(下記 [R1] prune 位置の含意、[R2] テストに self-loop 欠落)**
を次段メモとして残すことを推奨。

---

## 6 論点への所見

### 1. A1 の self-loop / 重複リンク処理 → 問題なし(実挙動も確認)

- `affectedLinks` を **`{...}`(Set)** に変えたことで、self-loop(source==target で
  incoming/outgoing 両方に同一リンクが入る)や同一ノードへの複数リンクでも、
  ループでの `remove` が**重複・漏れなく**走る(`graph_base.dart:303-321`)。
- links map 除去も同じ Set を反復するため `links.remove(link.id)` が冪等。二重除去で
  壊れない。
- **実挙動を一時テストで確認**: self-loop リンクを 1 本張ったノードを `removeNode` すると
  `links` 空・`nodes` 空・隣接インデックスも空になることを確認(クラッシュ無し)。
- 旧コードは `[...]`(List)で、self-loop の場合 `affectedLinks` に同一リンクが 2 回入り、
  2 回目の隣接 `remove` は no-op で実害は無かったが、Set 化の方が意図が明確で正しい。

### 2. A8 の通知の二重発火 → 問題なし(理解は正しい)

- `removeLink` 末尾に `_notifyLayoutChange()` を 1 回追加(`graph_base.dart:378`)。
  単体呼び出しで通知は **1 回**。
- `removeNode`(A1)は links を**内部で直接** `state.value.links.remove(...)` して除去し、
  `removeLink` を呼ばない。よって `_notifyLayoutChange()` は **removeNode 末尾の 1 回のみ**。
  依頼文の理解どおり、意図せぬ多重通知はない。
- テスト `removeLink fires layoutChangeListenable` / `removeNode also fires ...` で
  発火を担保(回数までは見ていないが `greaterThan(0)`。多重発火を検出する目的ではないので可)。

### 3. F1 の prune コスト → 現スコープでは許容(留意点あり)

- `_pruneRemovedEntityCaches()` は毎ビルドで `_graph.nodes`/`links` から live id の Set を
  構築(O(n+m))し、3 マップを `removeWhere`(O(キャッシュサイズ))。合算 O(n+m)。
- これは **既存のビルド構造と同じオーダー**。同じ builder は既に毎ビルドで
  `elements = [..._graph.nodes, ..._graph.links]` の生成と sort(O((n+m)log(n+m)))を
  行っており(`graph.dart:597-607`)、prune の O(n+m) は**支配項にならない**。大規模でも
  相対的な追加コストは小さく、現スコープで許容。
- 留意([R1]): 本質的には「毎ビルド全走査」が `design_review.md` 課題5 の
  `_markSortDirty` 毎フレーム呼び問題と同根。prune も sort も**削除イベント時だけ**走れば
  十分だが、それは D1/F3+ の rebuild 範囲縮小と一体で設計すべき。今回の prune を
  そこに巻き取る前提で OK。

### 4. F1 の呼び出し位置 → 妥当(理解は正しい)

- 位置は「`elements` 確定後・widget 構築前」(`graph.dart:609`)。
- 重要な前提: builder 冒頭で **`_markSortDirty()` が毎回呼ばれる**(`graph.dart:563`)ため
  `_sortDirty` は常に true → `elements` は**毎ビルド `_graph.nodes/links` から再構築**される
  (601-604 を必ず通り、606 のキャッシュ経路は実質使われない)。したがって prune が消す
  id と `elements` が参照する id は**同一の最新 graph 状態**で、ズレない。
- `initialize` フレーム(`elements = [..._graph.nodes]`、links 無し)で `_linkKeys` を
  prune しても、`_buildState` が `ready` に進んだ次フレームで `_buildLinkView` が
  `_linkKeys[id] ??= GlobalKey()` で再生成するため問題なし。依頼文の理解どおり。
- 補足: 仮に将来 `_markSortDirty()` 毎回呼びをやめてキャッシュ経路(606)が生きると、
  prune は最新 graph を見るのに `elements` は古いキャッシュ、という乖離が起きうる。
  その改修(F3+/D1)を行う際は **prune と elements の供給源を一致させる**こと。→ [R1] に含む。

### 5. `debugCachedEntityCount` の是非 → 許容(現実的な選択)

- `@visibleForTesting` getter を `GraphViewState` に追加。private キャッシュの
  単調増加を widget テストから検証する手段として妥当。`@visibleForTesting` で
  公開 API を汚さない意図は明確。
- 代替(prune ロジックを別クラスに切り出して単体テスト)はより綺麗だが、F1 の
  スコープに対しては過剰。現状の getter で十分。Flutter 公式も `@visibleForTesting` を
  State に置く前例は多い。**そのままで可**。
- 1 点だけ: getter 名・dartdoc が「テスト専用」と明示されており誤用リスクは低い。

### 6. スコープ(1 コミットに集約) → 妥当

- A1/A2/A8/F1 はいずれも「削除時のクリーンアップ漏れ」で、A1 と A8 は同じ `removeLink`/
  `removeNode`、A2 は同じ関数内の死にコード、F1 は同じ削除イベントの View 側後始末。
  **文脈が一致**しており 1 コミットは妥当(`design_review_plan_feedback.md` §5 の推奨どおり)。
- テストは A1/A8(model)と F1(widget)で**ファイル分離**されており、項目別の
  セーフティネットが保たれている。粒度は適切。

---

## 留意点(次段メモ・ブロッカーではない)

### [R1] prune/elements の「毎ビルド全走査」は F3+/D1 と一体で見直す

論点 3・4 のとおり、prune が正しく動く前提は「`_markSortDirty()` 毎回呼びで elements が
毎ビルド再構築される」こと。`design_review.md` 課題5 の sort キャッシュ無効化を
F3+/D1 で直す際、**prune の供給源(`_graph.nodes/links`)と elements の供給源を一致**させ、
できれば両者を削除イベント駆動に寄せる。今回の実装は現構造では正しいが、その依存関係を
F3+/D1 のタスクメモに残すこと。

### [R2] テストに self-loop ケースが無い(論点1 の直接の担保が無い)

依頼文 論点1 で self-loop を確認してほしいとあるが、`graph_model_removal_test.dart` には
self-loop の test が無い(本レビューでは一時テストで実挙動を確認した)。
回帰防止のため、**self-loop ノードを `removeNode` して links/index が空になる test を
1 件追加**しておくと、将来 `affectedLinks` の Set 化を誰かが List に戻した時に検出できる。
低コストなので追加推奨。

---

## 検証(レビュー側で再現)

- `dart format --set-exit-if-changed`(変更 2 ファイル + テスト 2 ファイル): **0 changed**。
- 削除 2 テスト: **8 passed**(A1 3 + A8 2 + F1 3)。
- self-loop 一時テスト(レビュー側で作成・実行後削除): **pass**(links/nodes 空)。
- `flutter analyze`(変更 2 ファイル): 新規 error/warning なし。info 4 件
  (`graph.dart:536/545/552/759`)はいずれも**今回の変更行(606/738 付近)ではない既存指摘**。
  依頼文が触れる `graph.dart:437,451` の `unnecessary_cast` も既存(HEAD 由来)で、
  今回スコープ外という判断を支持。
- 非 golden テスト全体(28 passed / 2 skipped)・golden 環境差は実装者報告を支持
  (本変更は描画経路に触れていない)。

---

## 結論

- **6 論点すべて問題なし。マージ可。**
- 必須対応: なし。
- 推奨: [R2] self-loop の回帰テスト 1 件追加(低コスト)。
- 次段へ: [R1] prune/elements の毎ビルド全走査を F3+/D1 の rebuild 範囲縮小と一体で見直す。
