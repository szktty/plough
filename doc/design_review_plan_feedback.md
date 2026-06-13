# 設計レビュー実行計画 フィードバック

レビュー日: 2026-06-13
対象: `doc/design_review_plan.md`(ベース: `doc/design_review.md`)
レビュー方針: コードは変更せず、計画の妥当性と原レビューの事実確認を追検証する。

> **更新 2026-06-13(第2ラウンド)**: 第1ラウンドの指摘は計画書に反映済みであることを
> 確認(A7/A8/F1/F2 追加、A4 精緻化、B1 first 依存、B2 の E1 前提・(c)案、C2 の D1 従属、
> E1 副作用確認)。着手前の最終確認で **E1 の実装方式に関する補足**が新たに出たため、
> 末尾「10. E1 の実装方式(第2ラウンド追補)」に記載。**計画を止める問題はなく、進行可。**

## 総評

計画は粒度・順序・依存・受け入れ基準・リスクが揃っており、実行可能な水準にある。
特に「セーフティネット先行(挙動不変タスクは回帰テストを先に書く)」と
「E1 を番号に関わらず最初に置く」判断は妥当。

一方で、**追検証の結果いくつかの事実誤認・取りこぼし**が見つかった。下記 1 と 5 は
計画に反映が必要。設計判断 4 項目には末尾で推奨を出す。

---

## 1. 原レビューの事実確認(追検証結果)

| 指摘 | 判定 | 補足 |
|---|---|---|
| `removeNode` が `state.value.links` を掃除しない(`graph_base.dart:300-319`) | ✅ 正しい | インデックスのみ除去、links map に残留。確定。 |
| `_nodeDependencies` が死にフィールド | ✅ 正しい | populate 箇所なし。`removeLink` の `removeWhere` 条件も無意味。確定。 |
| `reverseLink` が通知なし mutate(`377-384`) | ✅ 正しい | `_notifyLayoutChange` も `setState` もなし。確定。 |
| `deselectNode` 単一選択時全クリア(`457-469`) | ⚠️ 正しいが**記述が不正確** | 下記「2. A4 の追補」参照。実害の本質が計画の説明とずれる。 |
| `flame` は `shape.dart` のみ | ✅ 正しい | line 2-4, 31, 78-103 のみ。確定。 |
| `dart:io` は `debug_server.dart` のみ | ⚠️ **不完全** | 下記「3. B2 の追補」参照。`http` は **2 ファイル**で使用。 |
| `KeyedSubtree(ValueKey(_graph.hashCode))`(`graph.dart:684`) | ✅ 正しい | 確定。 |
| build 中で `_performLayout`/`_markSortDirty`(`559,575`) | ✅ 正しい | 確定。 |

---

## 2. A4 の追補:本質は「全クリア」ではなく「state とノードフラグの乖離」

計画は「対象 id に関係なく `selectedNodeIds` を空集合に置換」と書くが、より正確には:

```dart
void deselectNode(GraphId id) {
  node.isSelected = false;                       // ← まず対象だけ false
  if (!allowMultiSelection) {
    selectedNodeIds = const IListConst([]);      // ← state は全消去
  } else { selectedNodeIds.remove(id); }
}
```

単一選択モードで `deselectNode(別id)` を呼ぶと:
- **対象ノードの `isSelected`** は false(本来触るべきでないノード)
- **実際に選択中のノードの `isSelected`** は true のまま残る
- **`selectedNodeIds`** は空

つまり「全クリア」というより **3 つの状態(対象フラグ・他ノードフラグ・state リスト)が
相互に矛盾する**のが実害。これは課題 2-3(選択の二重管理)の典型的な症状であり、
**A4 と C1 は同じ病根**。計画は A4→C1 の順としているが、A4 の修正は
「`selectedNodeIds.remove(id)` に統一し、`node.isSelected` は対象が選択中のときのみ false」
という暫定対処になる。C1(単一ソース化)が入れば A4 の分岐自体が消えるので、
**A4 は「C1 で解消される暫定バグ修正」と位置づけ、受け入れ基準に
「state とノードフラグの整合(乖離しない)」を明示**すべき。

→ 計画への反映: A4 の現状説明を上記の「乖離」に書き換え、受け入れ基準に整合性チェックを追加。

---

## 3. B2 の追補:`http` は 2 ファイル、`enhanced_client.dart` は死にファイル

計画は `external_debug_client.dart`(`http`)/`debug_server.dart`(`dart:io`)を挙げるが、
追検証で **`lib/src/debug/enhanced_client.dart` も `package:http` を import** している。
さらに `enhanced_client` は **lib 内のどこからも import されていない**(grep 0 件)。

→ 計画への反映:
- B2 のスコープに `enhanced_client.dart` を追加。
- ただし未参照のため、**B2 とは独立に「死にファイル削除」として A 群に追加**できる
  (A2 の死にコード削除と同類、リスク極小)。**新タスク A7 を提案**。

公開 import graph も追検証で確定:
`plough.dart` → `manager.dart`(`import debug_manager.dart`)→ `debug_manager.dart`
(`import debug_server.dart` = `dart:io`)。**`dart:io` は確かに公開 import graph に乗っている**。
B2 の問題意識は正当。

---

## 4. 計画が取りこぼしている独立バグ(新規)

### 4-1. `removeLink` が `_notifyLayoutChange()` を呼ばない(新規・要タスク化)

`addLink`(`328`)は `_notifyLayoutChange()` するが、**`removeLink`(`363-374`)は通知しない**。
リンク削除が UI/レイアウトに反映されない可能性が高い。`reverseLink`(A3)の通知欠落と
同種の問題で、**A3 と同じ PR でまとめて直すのが自然**。

→ **新タスク A8 を提案**(または A3 のスコープに含める)。受け入れ基準:
リンク削除後に描画から消える widget テスト。

### 4-2. 課題 5 の性能項目がタスク化されていない

計画の「別セッターへの依頼」5 で自己申告しているとおり、以下が**トラッキング表に無い**:
- `_nodeViews`/`_nodeKeys`/`_linkKeys` のリーク(ノード削除時に掃除されない。
  追検証で `clear()` は `_initBehavior` のみ、個別 `remove` 無しを確認)
- `_BaseLinkRendererPainter.shouldRepaint => true`
- 空間グリッドがリンク非対応(リンクは常に線形走査)
- `AnimatedBuilder` 全体包みによる全ツリー rebuild
- `_markSortDirty` 毎フレーム呼びで sort キャッシュ無効化

これらは D1(RenderObject 化)で**まとめて解消される**ものと、D1 以前に単独で直せる
ものが混在する。後者(リーク掃除、`shouldRepaint`)は低リスクの短期タスクにできる。

→ **新タスク群 F(性能・単独修正可能なもの)を提案**:
- F1: ノード/リンク削除時の `_nodeViews`/`_nodeKeys`/`_linkKeys` 掃除(低リスク)
- F2: `shouldRepaint` をジオメトリ/スタイル比較に(中リスク、golden で担保)
- F3〜(rebuild 範囲縮小・sort キャッシュ)は **D1 と統合**(単独では費用対効果低)

リーク(F1)は A1(removeNode)と同じ「削除時のクリーンアップ漏れ」系なので、
**A1 と近い時期に実施**すると文脈共有できる。

---

## 5. タスク分割の粒度・順序への所見

- **A1→A2 連続**: 妥当。同ファイル・同じ「削除時クリーンアップ」文脈。A1 で
  `removeLink` ロジックと共通化する際に A2 の死にコードも自然に視界に入る。
  むしろ A1・A2・A8(removeLink 通知)・F1(view リーク)を
  **「削除パスの整理」1 PR にまとめる**選択肢も検討に値する(粒度を上げる方向)。
  ただし回帰テストの切り分けが PR を跨ぐと追いにくくなるので、
  **テストは項目ごと、実装は 1 PR** が現実的。
- **E1 を最初**: 妥当。低リスクかつ D2 の前提。ただし注意点を 6 に記載。
- **C1 を A4 の後**: 方向は正しいが、上記 2 のとおり A4 は C1 の部分集合。
  「A4 を C1 に吸収して飛ばす」案も成立するが、C1 は高リスクで着手が後ろ。
  **A4 を先に薄く直して出血を止め、C1 で恒久化**という計画の順序を支持する。

---

## 6. リスク評価への所見(「挙動不変」分類の検証)

- **E1(ログ lazy 化)**: 「挙動不変」は概ね正しいが、**1 点だけ要注意**。
  現状 `logDebug` の文字列は副作用を持たない前提だが、`gesture_manager.dart` の
  デバッグ補間内で `_nodeTapManager.states` 走査や `getTapStateDebugInfo()` 等
  **状態を読む呼び出し**が引数式に紛れている箇所がある。lazy 化(クロージャ化)で
  評価タイミングがズレても副作用は無いはずだが、`externalDebugClient.sendLog` の
  enabled ガード移動と合わせ、**「引数式が状態を変更しない」ことをレビューで確認**
  してから移動する、という but を E1 の手順に追記すべき。
- **A5(KeyedSubtree キー変更)**: 計画は [[viewport-drag-delta-and-handler-swap]] への
  抵触を正しく警戒している。妥当。`graph.id`(`GraphId`)が `==`/`hashCode` を
  Freezed で実装済みであることは確認済み。差し替え widget テスト必須に同意。
- **B1(flame 撤去)**: 「flame 版と自前版を並走させ同値確認」は堅実。ただし
  flame の `intersections` は **集合(Set)で順不同**を返すため、現状コードは
  `intersections.first` を使っている(`behavior.dart:379`)。**順序非依存にしないと
  自前版で `first` が別の点を返し、リンク端点が変わりうる**。B1 の受け入れ基準に
  「`first` 依存を排除(最近点を選ぶ等の明示的選択に変更)」を追加すべき。
  これは [[link-endpoint-gap-followup]] とも接続する。

---

## 7. 設計判断 4 項目への推奨

### B2 の配置方針 → **(c) 別パッケージ化を推奨(段階的に)**

- (a) 条件付き import は `dart.library.io` stub を書けば本体に残せるが、
  `http`/`logger`/workbench プロトコルまで本体に残り「依存の軽さ」目標を達成できない。
- (b) example 移設は、デバッグ機構が `gesture_manager` 等の内部に計装として
  食い込んでいる現状(E1 対象)では結合を切りにくい。
- **(c)**: `plough_devtools`(仮)を別パッケージにし、本体は
  **no-op の `DebugSink` インターフェース**だけ持つ。`Plough().attachDebugSink(...)` で
  デバッグ時のみ実装を注入。本体の `pubspec` から `http` を落とせ、web 安全。
  ただし**前提が E1**(計装の注入点を 1 インターフェースに集約)。
  → 順序: **E1 → B2**。計画は E1 を D2 の前提として置いているが、
  **B2 の前提でもある**ことを依存に追記すべき。

### D1 vs C2 の順序 → **D1 の設計確定を先、C2 は D1 従属**

仮説(C2 を D1 に従属)は妥当。geometry の保持場所・座標系・ヒットテスト経路は
D1(RenderObject)が規定する。C2 で `NodeViewState` を先に切り出しても、D1 で
保持構造を作り直すなら二度手間。**D1 の RFC/PoC で「geometry を誰が持つか」を決め、
その器に C2 が `NodeViewState` を流し込む**順が正しい。
→ 計画の依存(C2 は C1+D1 後)は維持でよいが、「D1 が geometry 保持を規定 →
C2 はその器に従属」と**根拠を明記**すべき。

### A3 reverseLink → **最小修正(mutate+通知+インデックス張替)で止める**

即不変化は C1/C2 の方針と一貫するが、`reverseLink` 単体のために不変更新経路を
先行導入すると、`GraphLinkImpl` の可変前提に依存する他箇所(state_manager の
`sourceImpl.logicalPosition` 参照等)と整合を取る作業が膨らむ。
**A3 では mutate+通知+`_incomingIndex`/`_outgoingIndex` 張替の最小修正**にとどめ、
不変化は C2(NodeViewState/不変リンク)で一括が費用対効果が高い。計画の 2 段階方針を支持。
ただし A3-1 の受け入れ基準に**「反転後インデックスが新 source/target を指す」テスト**を必須化。

### (追加)A4 vs C1 → **A4 は暫定、C1 で吸収**(上記 2 のとおり)

---

## 8. トラッキング表への追加提案

| ID | 区分 | 概要 | リスク | 依存 | 備考 |
|---|---|---|---|---|---|
| A7 | バグ/死コード | `enhanced_client.dart` 削除(未参照・http 依存) | 低 | なし | B2 の前さばき |
| A8 | バグ | `removeLink` の `_notifyLayoutChange` 欠落 | 低中 | なし | A3 と同 PR 可 |
| F1 | 性能 | node/link 削除時の `_nodeViews`/`_nodeKeys`/`_linkKeys` 掃除 | 低 | A1 | 削除パス整理 |
| F2 | 性能 | `shouldRepaint` をジオメトリ/スタイル比較に | 中 | なし | golden 担保 |
| F3+ | 性能 | rebuild 範囲縮小・sort キャッシュ | 高 | D1 | D1 に統合 |

依存の追記:
- **B2 の依存に E1 を追加**(注入点集約が前提)。
- **C2 の根拠**: 「D1 が geometry 保持を規定するため D1 従属」と明記。

---

## 9. 実施順序(修正提案)

```
1. E1(ログ lazy 化)              ← 即効・低リスク・B2/D2 の前提
2. 削除パス整理: A1 + A2 + A8(+ F1)  ← 1 PR、テストは項目別
3. A7(死にファイル削除)
4. A3, A4, A5, A6               ← 独立・並行可(A4 は暫定と明記)
5. B1(flame 撤去/ first 依存排除), B3(棚卸し)
6. B2(debug 別パッケージ化)     ← E1 後・レビュー反映後
7. F2(shouldRepaint)
8. C1(選択単一ソース → A4 吸収)
9. D1 RFC + PoC / D2(FSM)
10. C2(NodeViewState、D1 従属)
```

主な変更点:
- A8/A7/F1 を追加し、A1 周辺を「削除パス整理」として束ねた。
- B2 の前提に E1 を明示。
- A4 を「C1 で吸収される暫定」と位置づけ。
- B1 に first 依存排除を追加。

---

## 10. E1 の実装方式(第2ラウンド追補)

着手前の最終確認で判明: `logDebug`/`logInfo`/`logWarning`/`logError` は現在
`(LogCategory, String message)` の **String 固定シグネチャ**で、lib 全体から
**273 箇所**(`logGestureDebug` 含む)呼ばれている(`lib/src/utils/logger.dart:100-110`)。

### 「重さ」を 2 軸に分けて評価する

当初「案A は実行が重くなるのでは」という懸念があったが、**ランタイムコストと改修コストを
分けると評価が逆転する**。

| 観点 | 案A(API を lazy 化) | 案B(ホットパス限定ガード) |
|---|---|---|
| ランタイム(ログ無効時) | ◎ 全 273 箇所で文字列構築ゼロ | ○ ホットパスのみゼロ、他は据え置き |
| 改修範囲 | 大(273 箇所に `() =>` 付与) | 小(gesture_manager 中心の数十箇所) |
| diff/レビュー負荷 | 大 | 小 |
| 回帰リスク | 機械的だが箇所多 | 限定的 |

**ランタイムでは案A は重くならない**。クロージャは何もキャプチャしなければ Dart が
static 化し毎回のアロケーションは発生せず、回避できる文字列構築
(`substring`/`map`/`join`/`DateTime.now().toIso8601String()` 等)のコストの方が桁違いに
大きい。`logDebug` 内で `if (enabled) message()` とすればクロージャ本体は無効時に一切
実行されない。つまり**重いのは実行時ではなく改修コスト(273 箇所)**であり、これが E1 の
「即効・低リスク」という位置づけと噛み合わない、というのが案B を推した唯一の理由。
ランタイム性能の懸念ではない。

### 採用方針(折衷案)

**オーバーロードで段階移行する折衷案を採用**:

```dart
void logDebug(LogCategory category, Object message) =>
    _logger.d(
      category,
      message is String Function() ? (enabled ? message() : '') : message,
    );
```

`Object message` で `String` と `String Function()` の両方を受ける。これにより:

- **既存 273 箇所は無改修のまま動く**(String をそのまま渡せる)。
- **ホットパス(`gesture_manager` の `handlePointerDown`/drag 等、毎フレーム経路)だけ
  `() => '...'` に書き換える** → そこだけ無効時の文字列構築がゼロになる。
- 案A のランタイム利点を、案B の小さな改修範囲で段階的に取り込める。
- 将来、残りの呼び出しも順次 lazy 化していけば最終的に案A 相当に到達できる。

E1 のスコープは **「ログ API にクロージャ受けオーバーロードを追加 + ホットパスのみ
`() =>` 化」**とし、全 273 箇所の一括 lazy 化は対象外(以降のタスクで段階的に)。

なお `externalDebugClient.sendLog(metadata: {...})` の引数 Map 構築は、
**`if (enabled)` ガードを `sendLog` の外(呼び出し側)に出す**必要がある
(現状 `_enabled` チェックは関数内で、引数 Map は無効時も構築される)。これも E1 に含める。

### E1 の手順に追記すべき受け入れ基準

- ログ API にクロージャ受けオーバーロードを追加し、**既存 String 呼び出しが無改修で
  コンパイル・動作する**こと。
- ホットパスの `() =>` 化対象が「ポインタ/フレーム毎に走る経路」に限定されていることを
  レビューで確認。
- ガード式・移動した引数式が **状態を変更しない(読み取りのみ)** ことを確認(既出の注意点)。
- ログ有効時の出力内容が従来と一致(ガード/オーバーロードが出力を欠落させない)。
- ログ有効時の出力内容が従来と一致(ガードが出力を欠落させない)。
