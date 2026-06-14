# C1 follow-up(選択削除バグ修正)+ D2-pre 拡充 レビュー依頼

依頼日: 2026-06-15
対象ブランチ: `feature/redesign`
対象コミット:
- `013f872`(fix(graph): remove stale selected ids when node/link is deleted — C1 follow-up)
- `d8f5449`(test(gesture): expand D2-pre characterization — link tap/drag/cancel,
  drag lifecycle, concurrent pointer)
依拠レビュー: `doc/review_feedback_20260614_08_C1.md`(論点 3 要修正)
           `doc/review_feedback_20260614_10_D2pre_longterm.md`(D2-pre 論点 2 優先度高 + D1 論点 4)

---

## 背景

前回レビュー(20260614)の承認コメントのうち、**要対応として明示された 2 点**に対応した。

1. **C1 論点 3「要修正」**: `removeNode`/`removeLink` 時に `selected*Ids` から
   stale な id が除去されず `selectedNodes`/`selectedLinks` が ArgumentError を投げるバグ。
   「C1 が "選択の単一ソース" を宣言した以上この不変条件を完成させるのは C1 の責務」
   という指摘への対応。

2. **D2-pre 論点 2「優先度高」の未カバー領域**: link tap/drag / drag ライフサイクル /
   並行 pointer の characterization が薄く、D1 PoC の合否判定に使うなら拡充が前提
   という指摘への対応。
   **D1 RFC 論点 4** で「PoC 受け入れ基準にリンク hitTestSelf を明示」も対応。

---

## 変更点

### `013f872` — C1 follow-up: stale selected id の除去

**`lib/src/graph/graph_base.dart`**

- `removeNode` 末尾: 削除ノードの id を `selectedNodeIds` から除去。
  さらに連鎖削除されるリンク群の id を `selectedLinkIds` からまとめて除去。
  (既存ループ `for (final link in affectedLinks)` を使って `selectedLinkIds` を縮小)。
- `removeLink` 末尾: 削除リンクの id を `selectedLinkIds` から除去。

いずれも `state.value.copyWith(...)` の 1 回の呼び出しに収める変更で、
余分な通知を増やさない。

**`test/graph_selection_single_source_test.dart`** — 3ケース追加(合計8件)

| テスト | 検証内容 |
|---|---|
| 選択中ノード削除 → selectedNodeIds が空 | `selectedNodes` が ArgumentError を投げない |
| 選択中リンク削除 → selectedLinkIds が空 | `selectedLinks` が ArgumentError を投げない |
| ノード削除による連鎖 → 連鎖したリンクの id も消える | cascaded link cleanup |

---

### `d8f5449` — D2-pre 拡充: link/drag/concurrent characterization テスト

**`test/gesture_manager_characterization_test.dart`** — 6ケース追加(合計14件)

新グループ「link and drag」として追加。現状挙動を descriptive に固定:

| テスト | カバー領域 |
|---|---|
| link タップで選択される | link tap (優先度高) |
| link 選択後の背景タップで例外が出ない | link 後の background tap (現状 deselect されない挙動も注記) |
| link 上の pointer cancel では選択されない | link cancel (優先度高) |
| pan でノードを動かすと drag-update が飛び tap は飛ばない | drag ライフサイクル(優先度高) |
| drag 後 up でも選択トグルが起きない | drag/tap 分岐の固定(優先度高) |
| 2本目の pointer down で例外が出ない | 並行 pointer(優先度高) |

**`doc/rfc_render_graph_view.md`** — 受け入れ基準と no-go 条件の追記

- §3 受け入れ基準に「リンクの `hitTestSelf` が線分距離判定でヒットすること」を
  明示(D1 RFC 論点 4 への対応)。
- no-go 条件(gotcha が形を変えて残る場合は F3+ 単独先行に退避)を明文化。

---

## 必ず確認してほしい論点

### C1 follow-up

1. **除去の完全性**: `removeNode` でノード自身の id と連鎖リンクの id を両方
   `copyWith` 1回にまとめた実装で抜け漏れがないか。
   特に self-loop(source/target が同一)が `affectedLinks` に1件しか入らない場合も
   正しく処理されるか(`LinkedHashSet` で重複排除済みのため問題ないはずだが確認を)。
2. **通知回数**: `copyWith` 1回にまとめたことで「ノード削除 + 選択クリア」の通知が
   1回になっている。これで UI 更新に問題がないか。
3. **テストのカバレッジ**: 「multi-selection 中に複数ノードを一括削除」のケースは
   未カバー。要否の判断を。

### D2-pre 拡充

4. **「background tap after link does not throw」のスコープ**: リンク選択後の背景タップで
   deselect が起きない(現状バグ相当)を「no-throw」のみ固定し、
   deselect 不在は注記でとどめた。この descriptive な記述は適切か、
   またはバグとして別途修正すべきか。
5. **並行 pointer テスト**: 2本目の down → up を逆順(`Offset(300,300)` 先、
   `Offset(100,100)` 後)で up している。現実の multitouch 解放順と逆だが
   例外が出ないことを確認できていれば十分か。
6. **D1 PoC の前提として**: 今回追加した6件が「tap/drag/zoom が既存と同等」の
   合否判定に使えるか。まだ足りない領域(hover lifecycle、drag delta × zoom)は
   D1 PoC 内で追加する想定で良いか。

---

## 検証状況

- 全テスト: 89 passed / 2 skipped(non-golden)。
- `dart format --set-exit-if-changed lib/ test/`: exit 0。
- `flutter analyze lib/`: error 0 / warning 2(既存)。

---

## 期待する成果物

上記論点への所見。C1 follow-up が完了とみなせるかの判断、
および D2-pre 拡充が D1 PoC の着手前提として十分かの判断。

レビュー結果は **`doc/review_feedback_20260615_11_C1fix_D2pre.md`** に書き出してほしい。
