# C1: 選択状態の単一ソース化 実装レビュー依頼

依頼日: 2026-06-14
対象ブランチ: `feature/redesign`
対象コミット:
- `8adc717`(refactor(graph): single source of truth for selection — C1)
対象タスク: `doc/design_review_plan.md` の **C1**(A4 を吸収・[R1] 解消)
レビュー方針: **挙動不変(選択描画・gesture)・derived 化の購読経路・乖離解消の正しさ**。
リスク: **高**(レンダリング購読経路の変更)。結果は末尾の指定先に書き出してほしい。

---

## 背景

選択状態が二重管理だった:各 node/link が `_isSelected: ValueNotifier<bool>` を持ち、
graph の選択メソッドが `GraphData.selectedNodeIds/selectedLinkIds` と手動同期。
`clearSelection` は重複通知を隠すため `force: true` を使用。さらに [R1]:
`canSelect=false` は `_isSelected` だけ落とし `selectedNodeIds` を更新せず乖離。

`selectedNodeIds`/`selectedLinkIds` を**唯一の真実**とし、`isSelected` を derived getter に。

---

## 変更点

### `lib/src/graph/node.dart` / `link.dart`
- `_isSelected: ValueNotifier<bool>` と setter・`isSelectedState` を**削除**。
- `isSelected` を derived getter に:
  - node: `graph?.selectedNodeIds.contains(id) ?? false`
  - link: `graph?.selectedLinkIds.contains(id) ?? false`
- node の `renderStateListenable` を `_isSelected` merge から **graph(Listenable)**
  merge に変更。`graph` は追加後に確定するため `onAdded` override で再構築。
- node の `canSelect=false` 時の deselect を `graph?.deselectNode(id)` 経由に([R1] 解消)。

### `lib/src/graph/graph_base.dart`
- `selectNode`/`deselectNode`/`selectLink`/`deselectLink`/`clearSelection` から
  `node.isSelected = ...`(`_isSelected` 直接操作)を**全削除**。`state.copyWith` の
  id セット更新のみに。
- `clearSelection` の `force: true` を除去(derived 化で個別通知が消え、state 変更 1 回で
  全 derived が更新・通知 1 回)。空なら早期 return。
- **`addLink` に `link.onAdded(this)` を追加**。node は `addNode` で `onAdded` 済みだが
  link は未設定で、derived getter が `graph` を参照できなかった(既存の取りこぼし修正)。

### テスト — `test/graph_selection_single_source_test.dart`(新規)
- node/link 選択で `isSelected` と `selected*Ids` が一致、deselect で両方クリア、
  `canSelect=false` で乖離なし([R1])、`clearSelection` で全クリア。

---

## 必ず確認してほしい論点

1. **再描画トリガーの接続(難所)**: `renderStateListenable` を `_isSelected` から
   `graph` へ繋ぎ替えた。NodeView(`graph_view/widget/node.dart:225`)は
   `renderStateListenable` を listen しており、選択変更で graph が notify → 再描画。
   golden 失敗集合が C1 前後で**完全一致(11 件、stash 比較で確認)**で選択描画は不変。
   この接続で、選択変更時に**過剰再描画**(graph の任意の変更で全 node が再描画)に
   ならないか? graph は selectedIds 以外(geometry/layout 等)でも notify するため、
   選択以外の変更でも renderState が発火しうる。許容範囲か、選択専用 Listenable に
   絞るべきか所見がほしい。
2. **derived getter の null 安全性**: `graph` が null(未追加)の node/link で
   `isSelected == false`。追加前に選択操作は来ない前提だが、ライフサイクル上の穴がないか。
3. **`addLink` の `onAdded` 追加**: 既存挙動への影響。二重追加(同一 link を 2 graph へ)で
   `onAdded` が `StateError` を投げる仕様だが、通常経路で問題ないか。link が graph を
   持つようになったことで他の derived/参照に副作用がないか。
4. **A4 吸収の整合**: A4 は deselect 経路を正したが、C1 で `deselectNode`/`deselectLink` は
   さらに簡潔化(`_isSelected` 操作削除)。A4 のテスト(`graph_model_deselect_test.dart`)が
   緑のままか(全非 golden テスト緑を確認済み)。
5. **`isSelected` setter 廃止の影響**: インターフェース(`entity.dart`)は `bool get isSelected`
   の read-only 仕様で、setter は impl 独自の追加だった。除去は仕様準拠だが、外部利用が
   無いことの確認(lib 内では graph_base のみが使っていた、すべて削除済み)。
6. **state_manager / gesture 経路**: `state_manager.dart:162,164` が `node.isSelected` を
   読む(derived 化後も graph 経由で正しく解決)。gesture テストが緑のままか。

---

## 検証状況(実装者報告)

- `flutter analyze lib/src/graph/`: error/warning なし(既存 info のみ)。
- `dart format --set-exit-if-changed lib/ test/`: 0。
- 非 golden テスト: 67 passed / 2 skipped(新規 C1 5 件含む)。
- **セーフティネット有効性**: `canSelect=false` ケースは C1 適用前に落ちる([R1] 乖離)。
- golden: 11 failed で**ベースライン同一**(stash 比較で失敗集合完全一致)。選択描画不変。
  `graph_view_golden_multi_selection_test` 単独実行は緑(選択ハイライト反映を確認)。

---

## 期待する成果物

- 6 論点への所見(問題なし/要修正、根拠付き)。特に**論点 1(過剰再描画の可能性)**。
- derived 化の購読経路・ライフサイクルに穴がないかの追検証。
- スコープ・粒度の妥当性。

レビュー結果は **`doc/review_feedback_20260614_08_C1.md`** に書き出してほしい。
