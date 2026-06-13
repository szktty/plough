# フェーズ A 残バグ修正 実装レビュー依頼(A7/A3/A4/A5/A6)

依頼日: 2026-06-14
対象ブランチ: `feature/redesign`
対象コミット:
- `2fad4b2`(chore(debug): remove dead enhanced_client.dart — A7)
- `bcce23d`(fix(graph): reverseLink notify/index, deselect divergence, subtree key — A3/A4/A5)
- `e56b4e3`(refactor(behavior): name the default link thickness constant — A6)
対象タスク: `doc/design_review_plan.md` の **A7 / A3 / A4 / A5 / A6**
レビュー方針: **実装の正しさ・副作用・スコープ妥当性**。結果は末尾の指定先に書き出してほしい。

---

## 背景

フェーズ A(設計と独立のバグ修正)の残りをまとめて処理した。削除パス整理
(A1/A2/A8/F1, `review_request_20260614_02_removal.md`)に続く分。

- **A7**: 死にファイル `enhanced_client.dart` 削除。
- **A3**: `reverseLink` が通知も隣接インデックス張替もしていなかった。
- **A4**: `deselectNode`/`deselectLink` が単一選択モードで選択リスト全体を消し、
  state とノードフラグが乖離していた。
- **A5**: `KeyedSubtree` のキーが `_graph.hashCode`(衝突・不安定)だった。
- **A6**: リンク厚み `30` のマジックナンバー + 放置 TODO。

---

## 変更点

### A7 — `lib/src/debug/enhanced_client.dart`(削除)
- `EnhancedDebugClient`/`enhancedDebugClient` は import・シンボル参照・export いずれも
  0 件。削除で `package:http` 利用は `external_debug_client.dart` のみに(B2 の前さばき)。

### A3 — `lib/src/graph/graph_base.dart` `reverseLink`
- mutate 前に**現在の**source/target で `_outgoingIndex`/`_incomingIndex` から除去し、
  swap 後に新しい source/target で再登録。末尾に `_notifyLayoutChange()`。

### A4 — `lib/src/graph/graph_base.dart` `deselectNode` / `deselectLink`
- multi/single 分岐を廃止。対象 id が選択中のときのみ
  `selectedNodeIds.remove(id)` + `isSelected = false`。非選択 id では早期 return。

### A5 — `lib/src/graph_view/widget/graph.dart`
- `KeyedSubtree(key: ValueKey(_graph.id))` に変更(`graph.id` は Freezed の `GraphId`)。

### A6 — `lib/src/graph_view/behavior.dart`
- `GraphLinkViewBehavior.defaultThickness`(`static const double = 30`)を新設し、
  デフォルト引数と `GraphViewDefaultBehavior.createLinkViewBehavior` の両方で参照。
  値は 30 のまま(挙動不変)、TODO 解消。

### テスト
- `test/graph_model_reverse_link_test.dart`: A3 の通知発火・インデックス張替を追加。
- `test/graph_model_deselect_test.dart`: A4(非選択 id で選択保持・対象 id で解除・
  state/フラグ整合・link 版)。
- `test/graph_view_graph_swap_test.dart`: A5(graph 差し替えで再描画・旧内容消去・
  例外なし)。

---

## 必ず確認してほしい論点

1. **A3 のインデックス張替の正しさ**: self-loop(source==target)や同一ペアに複数リンクが
   ある場合も、除去・再登録で漏れ/重複が起きないか。`putIfAbsent(...).add` で
   同一リンクが二重登録されないか。
2. **A3 と既存不変条件**: `reverseLink` の不変化は C2 に送る方針(最小修正に留める)で
   合意済み。今回の mutate+通知+張替が、リンク選択不変条件
   (`graph_model_reverse_link_selection_invariance_test.dart`)を壊していないか。
3. **A4 の早期 return**: 非選択 id で何もしない(通知も flag 変更もしない)挙動が、
   呼び出し側(gesture 経路・`toggleSelectNode`)の期待と整合するか。multi 選択時に
   特定 id だけ外す従来挙動が維持されているか。
4. **A4 のフラグ整合**: `isSelected` を derived にする C1 の前段として、今回の暫定修正で
   state とフラグが乖離しないことを担保できているか。
5. **A5 の差し替え**: `graph.id` キーで `didUpdateWidget` の再 init 経路
   (`graph.dart:313-`)と整合するか。既知 gotcha
   [[viewport-drag-delta-and-handler-swap]](旧 overlay が pointerHandlers を奪わない)に
   抵触しないか。
6. **A6**: 値・公開 API に変化がないこと。`defaultThickness` を public static const として
   晒す是非。

---

## 検証状況(実装者報告)

- `dart format --set-exit-if-changed lib/ test/`: 0 changes。
- `flutter analyze lib/`: 新規 error/warning なし(`graph.dart:437,451` の
  `unnecessary_cast` は HEAD から存在する既存・スコープ外)。
- 非 golden テスト(全 18 ファイル): 36 passed / 2 skipped。
- A3/A4/A5 のテストは**対応修正を外すと失敗**することを確認済み(セーフティネット有効)。
- golden 失敗はベースラインでも出る環境差。A3/A4 はモデル層、A5 は subtree キーのみで
  描画ピクセルに実質影響しない想定だが、**golden が A5 と無関係か独立確認してほしい**。

---

## 期待する成果物

- 6 論点への所見(問題なし/要修正、根拠付き)。
- 見落とした副作用・回帰リスクは `file:line` 付きで。
- スコープ・粒度(A7/A3-A5/A6 を 3 コミットに分けた判断)の妥当性。

レビュー結果は **`doc/review_feedback_20260614_03_phaseA.md`** に書き出してほしい。
