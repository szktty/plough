# フェーズ A 残バグ修正 実装レビュー結果(A7/A3/A4/A5/A6)

レビュー日: 2026-06-14
対象: `doc/review_request_20260614_03_phaseA.md`
対象コミット: `2fad4b2`(A7) / `bcce23d`(A3/A4/A5) / `e56b4e3`(A6)
レビュー方針: 実装の正しさ・副作用・スコープ妥当性。コードは変更していない。

## 総評

**承認(マージ可)。** A7/A3/A4/A5/A6 すべて修正は正しく、テストはセーフティネットとして
妥当。self-loop の reverseLink・graph swap・selection invariance も実コード/実挙動で確認。

必須対応はなし。**1 件、A4 の周辺で既存の乖離バグを発見した([R1])** が、これは A4 の
スコープ外(今回の変更が作ったものではない)で、C1(選択単一ソース化)で吸収すべき
ものとして記録する。

---

## 6 論点への所見

### 1. A3 のインデックス張替の正しさ → 問題なし(self-loop も実挙動確認)

- mutate **前**に現 endpoint で `_outgoingIndex[source.id].remove(link)` /
  `_incomingIndex[target.id].remove(link)`、swap **後**に新 endpoint で
  `putIfAbsent(...).add(link)`(`graph_base.dart:386-405`)。順序が正しい。
- 重複登録の懸念: 除去を先に行うため、`putIfAbsent(...).add` で同一リンクが二重登録される
  ことはない。**self-loop を一時テストで確認**: `a->a` を reverseLink しても
  `getOutgoingLinks(a)`/`getIncomingLinks(a)` は各 1 本のまま(重複なし)。
- 同一ペアに複数リンクがある場合も、`remove`/`add` は個別の `link` インスタンス単位なので
  他のリンクに影響しない。
- A3 テスト(swap / notify / index 張替)で担保。修正を外すと落ちることを実装者が確認済み。

### 2. A3 と既存不変条件 → 問題なし

- `graph_model_reverse_link_selection_invariance_test.dart` を実行し **緑**を確認。
  今回の mutate+通知+張替は選択不変条件を壊していない。
- 最小修正に留め、不変化(新リンク置換)は C2 に送る方針どおり。スコープ遵守。

### 3. A4 の早期 return → 問題なし(toggle 経路と整合)

- `deselectNode`/`deselectLink` は「対象 id が選択中でなければ早期 return」
  (`graph_base.dart:480-483`, `544-547`)。
- `toggleSelectNode`/`toggleSelectLink`(494-501, 556-563)は **`isSelected` が true の
  ときだけ** `deselect*` を呼ぶ。よって toggle 経路は早期 return に到達せず、従来の
  「選択中 → 解除」挙動が維持される。
- multi 選択時に特定 id だけ外す挙動: 旧 multi 分岐も `selectedNodeIds.remove(id)` で
  あり、新コードも同じ(分岐を廃止して常に `remove(id)`)。**multi 時の挙動は不変**。
- single 選択時の**バグ挙動**(対象でない id を渡すと全消去)が正されたのが A4 の本体。
  非選択 id では何も変えない方が正しい。

### 4. A4 のフラグ整合 → 担保できている(対象 id 経路)

- 対象 id が選択中の場合、`node.isSelected = false` と `selectedNodeIds.remove(id)` を
  **両方**実行(486-489)。`isSelected` と state リストが一致して落ちる。
- 非選択 id の場合は両方とも触らない(早期 return)。よって
  「`isSelected(id) == selectedNodeIds.contains(id)`」の不変条件は deselect 経路では保たれる。
  テスト `state list and node flags do not diverge` で担保。
- → ただし deselect 経路**以外**に既存の乖離源がある。下記 [R1]。

### 5. A5 の差し替え → 問題なし

- `KeyedSubtree(key: ValueKey(_graph.id))`(`graph.dart:691`)。`GraphId` は Freezed で
  `==`/`hashCode` 実装済みなので `ValueKey` の同一性判定が安定。
- `didUpdateWidget` の再 init 経路(`graph.dart:312-319`: `widget.graph != oldWidget.graph`
  で `_initBehavior`)とは独立。KeyedSubtree のキーは「サブツリーの同一性」を制御するもので、
  graph が変われば `graph.id` が変わり subtree が作り直される。再 init とキー差し替えが
  二重に効くが、いずれも graph 変更時に走るので整合。
- 既知 gotcha [[viewport-drag-delta-and-handler-swap]] への抵触: この gotcha は
  `GraphInteractiveOverlay` の `pointerHandlers` 横取り防止
  (`identical(...pointerHandlers, _publishedHandlers)` ガード)の話で、**subtree キーとは
  別レイヤ**。hashCode→id 変更は handler 横取りに影響しない。swap テストで
  `takeException() isNull` を確認しており、抵触なし。

### 6. A6 → 値・公開 API 不変、`public static const` は妥当

- `GraphLinkViewBehavior.defaultThickness = 30`(`behavior.dart:151`)を新設し、
  デフォルト引数(139)と `createLinkViewBehavior`(329)で参照。**値は 30 のまま、挙動不変**。
- `public static const` として晒す是非: `thickness` は既に public な構築パラメータであり、
  そのデフォルト値を名前付き定数で公開するのは利用者が「既定値を基準に相対調整する」用途に
  資する。dartdoc も付与済み。**公開して問題なし**(むしろ親切)。TODO 解消も適切。

---

## 指摘

### [R1] A4 スコープ外の既存乖離: `set canSelect(false)` が `selectedNodeIds` を更新しない

`node.dart:172-179` の `set canSelect`:

```dart
set canSelect(bool canSelect) {
  setState(... canSelect ...);
  if (!canSelect && isSelected) {
    _isSelected.value = false;   // ← フラグだけ false
  }
}
```

選択中ノードの `canSelect` を false にすると `isSelected` だけ false になり、
**`selectedNodeIds` には id が残る**(`isSelected=false` だが state リストに在る、という
A4 が正したのと逆向きの乖離)。

- これは**今回の A4 変更が作ったものではなく既存**。A4 は deselect 経路の乖離を正したが、
  この `canSelect` 経路の乖離は残る。
- A4 の受け入れ基準「state とフラグが乖離しない」は **deselect 経路に限れば**満たすが、
  選択状態の整合性全体としては未解決。
- 対応: **C1(選択単一ソース化)で吸収**。`isSelected` を `selectedNodeIds` 由来の derived に
  すれば、この種の乖離は原理的に消える。C1 のスコープに「`canSelect=false` 時の
  選択解除も単一ソース経由にする」を明記しておくこと。今回はブロッカーではない。

---

## 検証(レビュー側で再現)

- `dart format --set-exit-if-changed`(変更 3 ファイル): **0 changed**。
- A3/A4/A5 テスト + selection invariance: **9 passed**(reverse 3 + deselect 4 +
  swap 1 + invariance 1)。self-loop reverseLink 一時テスト: pass(重複なし)。
- A7: `enhanced_client`/`EnhancedDebugClient`/`enhancedDebugClient` の lib・test 全参照
  **0 件**を確認。削除安全。
- `flutter analyze`(変更 3 ファイル): 新規 error/warning なし。info 4 件
  (`graph.dart:536/545/552/762`)はいずれも**今回の変更行(691 付近)ではない既存指摘**。
- A6 値: `defaultThickness == 30`、参照 2 箇所とも定数経由。**値不変**を確認。
- 非 golden 全体(36 passed / 2 skipped)・golden 環境差は実装者報告を支持。

### golden が A5 と無関係か(独立確認)

- A5 の変更は `KeyedSubtree` の**キー値のみ**(hashCode→id)。キーは要素の同一性制御で、
  描画されるピクセルそのものには影響しない(同一フレーム内の描画ツリー構造は不変)。
- A3/A4 はモデル層(graph_base)で描画経路に触れない。A6 は値 30 維持で不変。
- よって **golden 失敗は本コミット群と無関係**(ベースライン環境差)と判断。実装者報告を支持。

---

## スコープ・粒度

- **A7 を独立コミット**(`2fad4b2`): 純粋な死にファイル削除で、他修正と混ぜない判断は妥当。
  B2 の前さばきという位置づけも明確。
- **A3/A4/A5 を 1 コミット**(`bcce23d`): いずれも graph_base/graph.dart の小修正だが、
  内容は別件(index 張替 / 選択整合 / subtree キー)。テストはファイル分離されており
  追跡可能。3 件を 1 コミットにするのは許容範囲だが、A3 と A4 は厳密には独立なので
  分けてもよかった。**現状でも問題なし**(コミットメッセージで 3 件を明記済み)。
- **A6 を独立コミット**(`e56b4e3`): リファクタのみ(挙動不変)で分離は妥当。

---

## 結論

- **6 論点すべて問題なし。マージ可。**
- 必須対応: なし。
- 次段へ: [R1] `set canSelect(false)` の `selectedNodeIds` 乖離を **C1 で吸収**
  (C1 のスコープに明記)。
