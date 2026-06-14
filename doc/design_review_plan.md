# Plough 設計レビュー 実行計画

策定日: 2026-06-13
ベース: `doc/design_review.md`(実施日 2026-06-10, HEAD 4f579bc)
対象ブランチ: `feature/redesign`

このドキュメントは `doc/design_review.md` の指摘を**検証可能・着手可能な作業単位**に分解し、
依存関係・受け入れ基準・リスクを明示した実行計画である。
末尾に**別セッションへのレビュー依頼**を記載している。

> **更新 2026-06-13**: 別セッションのレビュー(`doc/design_review_plan_feedback.md`)を
> 反映済み。追加された主な変更:
> - 新タスク **A7**(死にファイル `enhanced_client.dart` 削除)、**A8**(`removeLink` の
>   通知欠落)、**F1/F2**(性能の単独修正)を追加。
> - **A4** を「全クリア」ではなく「state とノードフラグの乖離」と精緻化し、C1 で吸収される
>   暫定対処と位置づけ。
> - **B1** に `intersections.first`(順不同 Set)依存の排除を追加。
> - **B2** の依存に **E1** を追加(注入点集約が前提)、配置方針を (c) 別パッケージ化に確定。
> - **C2** を D1 従属と明記、**E1** に状態読取の副作用確認手順を追記。
> - レビューで `http` が 2 ファイル使用・`removeLink` の通知欠落・view マップのリークが
>   実コードで追確認された。
>
> **更新 2026-06-13(第2ラウンド)**: 再レビュー(進行可)を反映。**E1 の実装方式を
> オーバーロード折衷案に確定**:ログ API を `Object message`(String と
> `String Function()` 両受け)にして既存 約 268 箇所を無改修のまま残し、ホットパスだけ
> `() =>` 化する。全箇所一括 lazy 化はスコープ外。`sendLog` の enabled ガードは呼び出し側へ。
> ランタイムでは案A も重くならず、ボトルネックは改修コスト(268 箇所)という整理。

---

## 0. 前提と進め方

- 各タスクは「挙動を変えない(リファクタ/修正)」ものから着手し、設計変更は後段に置く。
- すべてのタスクで完了条件に `flutter analyze` 無警告・`flutter test` グリーン・
  `dart format --set-exit-if-changed .` 0 を含める(CLAUDE.md の Git Workflow に準拠)。
- 1 タスク = 1 ブランチ = 1 PR を原則とする(`main` から派生。Conventional Commits)。
- 「挙動を変えない」タスクは**変更前に回帰テストを追加**してから着手する(セーフティネット先行)。
- 計画策定時点で `design_review.md` の主要指摘は実コードと一致を確認済み:
  - `removeNode` が links map を掃除していない(`graph_base.dart:300-319`)
  - `_nodeDependencies` は populate されない死にフィールド(`graph_base.dart:316,370`)
  - `reverseLink` が通知なし mutate(`graph_base.dart:377-384`)
  - `deselectNode` が単一選択時に全クリア相当(`graph_base.dart:457-469`)
  - `flame` 依存は `shape.dart` のみ、`dart:io` は `debug_server.dart` のみ
  - `KeyedSubtree(key: ValueKey(_graph.hashCode))`(`graph.dart:684`)
  - build 中(`AnimatedBuilder` builder 内)で `_performLayout` / `_markSortDirty`
    (`graph.dart:559,575`)

---

## フェーズ A: バグ修正(設計と独立・即実施)

挙動是正が目的。各々が独立しており並行可能。**まず再現テストを書いてから直す。**

### A1. `removeNode` が接続リンクを links map から削除しない
- 箇所: `lib/src/graph/graph_base.dart:300-319`
- 現状: 隣接インデックスからは除去するが `state.value.links` に残り、削除済みノードを
  参照するリンクが描画対象として残留。ドキュメントの "automatically removes any links"
  と矛盾。
- 対応:
  1. 失敗する回帰テストを追加(ノード削除後 `links` に接続リンクが残らないこと、
     描画/`getIncomingLinks`/`getOutgoingLinks` の整合)。
  2. `affectedLinks` の各リンクを `state.value.links.remove(link.id)` で除去してから
     `copyWith`。インデックス除去と map 除去を 1 つの `setState` にまとめる。
- 受け入れ基準: 削除ノードを端点に持つリンクが `getAllLinks()`/描画から消える。
  既存テスト緑。
- リスク: 低。`removeLink` のロジックと重複させず共通化を検討。

### A2. 死にフィールド `_nodeDependencies` の削除
- 箇所: `graph_base.dart:220 付近(宣言), 316, 370-372`
- 現状: 書き込み(削除)のみで populate されず、`removeLink` 内 `removeWhere` 条件
  (`state.value.links.containsKey(key)`)も意味を成さない。
- 対応: フィールドと全参照を削除。`removeLink` の `removeWhere` ブロックを除去。
- 受け入れ基準: フィールド全削除後も全テスト緑、analyze 無警告。
- リスク: 低(未使用確認済み)。A1 と同ファイルなので**順序付けて連続実施**推奨。

### A3. `reverseLink` の変更通知欠落
- 箇所: `graph_base.dart:377-384`
- 現状: `GraphLinkImpl.source/target` を直接 mutate するだけで `state` 通知も
  layout 通知もない → UI が更新されない。加えて Freezed immutable な map の中身を
  可変オブジェクトとして書き換えている設計上の歪み。
- 対応(2 段階):
  1. **最小修正(挙動是正)**: mutate 後に `_notifyLayoutChange()` 相当を呼び、
     隣接インデックス(`_incomingIndex`/`_outgoingIndex`)も source/target 反転に
     合わせて張り替える(現状インデックスが古いまま)。回帰テストを追加。
  2. **設計是正(フェーズ C と連動)**: `reverseLink` を「新リンクで置換」する不変更新に
     変更する案を C2 で検討。まずは 1 を入れる。
- 受け入れ基準: `reverseLink` 後に向きが反転し UI/インデックスが更新される回帰テスト緑。
  **反転後にインデックスが新 source/target を指す**ことを必須テスト化。
- 推奨(レビュー反映): A3 は最小修正(mutate+通知+インデックス張替)で止める。
  即不変化は `GraphLinkImpl` の可変前提に依存する他箇所との整合作業が膨らむため、
  不変化は C2(NodeViewState/不変リンク)で一括する方が費用対効果が高い。
- 関連: **A8(`removeLink` の通知欠落)と同種の問題なので同じ PR でまとめて直す**。
- リスク: 中(インデックス張り替え漏れ)。テスト必須。

### A4. `deselectNode` の state とノードフラグの乖離(C1 で吸収される暫定修正)
- 箇所: `graph_base.dart:457-469`(`deselectLink` も同型: 518-531)
- 現状(レビュー追補で精緻化): 単に「全クリア」ではなく、単一選択モードで
  `deselectNode(別id)` を呼ぶと **3 つの状態が相互矛盾**する:
  - 対象ノードの `isSelected` は false(本来触るべきでないノード)
  - 実際に選択中のノードの `isSelected` は true のまま残る
  - `selectedNodeIds` は空に置換
  これは課題 2-3(選択の二重管理)の典型症状で、**A4 と C1 は同じ病根**。
- 対応: 対象 id が現在選択されている場合のみ除去するよう統一
  (multi/single で分岐せず `selectedNodeIds.remove(id)` を基本に、
  `node.isSelected` は対象が選択中のときのみ false)。node/link 両方を修正。回帰テスト追加。
- 受け入れ基準: 非選択 id に対する `deselectNode` が既存選択を変えないテスト緑。
  **state リストとノードフラグが乖離しない**ことを検証。
- 位置づけ: **C1(単一ソース化)が入れば A4 の分岐自体が消える暫定対処**。
  「先に薄く直して出血を止め、C1 で恒久化」という順序(A4→C1)を維持。
- リスク: 低〜中。選択 API の他箇所(`toggleSelectNode` 等)との整合を確認。

### A5. `KeyedSubtree` のキーを `graph.hashCode` から `graph.id` に
- 箇所: `lib/src/graph_view/widget/graph.dart:684`
- 現状: `ValueKey(_graph.hashCode)` は衝突・不安定の元。
- 対応: `ValueKey(_graph.id)`(`GraphId` が一意)に変更。
- 受け入れ基準: グラフ差し替え時のリビルドが従来同様に動く widget テスト緑。
- リスク: 低。ただし「graph 差し替え時に旧 overlay が pointerHandlers を奪わない」
  という既知 gotcha([[viewport-drag-delta-and-handler-swap]])に触れるため、
  差し替えシナリオの widget テストを必ず通す。

### A6. `behavior.dart` の小さな TODO・契約の歪み
- 箇所: `lib/src/graph_view/behavior.dart:139`(thickness=30 ハードコード TODO)、
  `195/276`(`abstract interface class` なのに `isEquivalentTo` が実装持ち)
- 対応(小):
  - thickness の TODO はマジックナンバーを名前付き定数化し、TODO の意図を確認。
  - `isEquivalentTo` の実装は `implements` 利用者へ再実装を強制するため、
    インターフェース分割は**フェーズ C(中期)に送る**。ここではコメントで現状を明文化
    するに留め、破壊的変更はしない。
- 受け入れ基準: 定数化のみ。挙動不変。
- リスク: 低。

### A7. 死にファイル `enhanced_client.dart` の削除(レビュー追加)
- 箇所: `lib/src/debug/enhanced_client.dart`
- 現状(追検証で確認): `package:http` を import しているが **lib 内のどこからも
  import されていない**(参照 0 件)。A2 の死にコード削除と同類。
- 対応: ファイルを削除。`http` 利用ファイルが `external_debug_client.dart` のみになり、
  B2(debug 分離)の前さばきになる。
- 受け入れ基準: 削除後も全テスト緑・analyze 無警告。
- リスク: 極小(未参照確認済み)。

### A8. `removeLink` の `_notifyLayoutChange()` 欠落(レビュー追加)
- 箇所: `graph_base.dart:362-374`
- 現状(追検証で確認): `addLink`(328)は `_notifyLayoutChange()` を呼ぶが、
  **`removeLink` は呼ばない**(非対称)。リンク削除が UI/レイアウトに反映されない。
  `reverseLink`(A3)の通知欠落と同種。
- 対応: `copyWith` 後に `_notifyLayoutChange()` を追加。**A3 と同じ PR でまとめる**。
  なお A2 でこの関数内の `_nodeDependencies.removeWhere` ブロックも除去される。
- 受け入れ基準: リンク削除後に描画から消える widget テスト緑。
- リスク: 低〜中。

---

## フェーズ B: 依存の軽量化(pub 品質・web 安全性)

公開 API の import graph から重量級・プラットフォーム依存を外す。

### B1. `flame` 依存を自前幾何コードに置換
- 箇所: `lib/src/graph_view/shape.dart`(flame 利用は本ファイルのみ確認済み)
  - `LineSegment`(flame), `CircleComponent.lineSegmentIntersections`,
    `Rectangle.fromRect(...).intersections(...)` を使用(line 2-4, 31, 78-103)
- 対応:
  1. 線分×円・線分×矩形(軸平行)の交差を行う ~50 行の自前ユーティリティを
     `lib/src/utils/geometry_intersect.dart` 等に新設。
  2. 既存の交差結果と**数値一致を検証する単体テスト**を先に書く
     (flame 版と自前版を並走させ同値確認 → 確認後 flame 除去)。
  3. `pubspec.yaml` から `flame` を削除。
- 受け入れ基準: 交差計算の単体テストが flame 撤去後も緑。リンク端点描画が目視/golden で不変。
- **重要(レビュー追補)**: flame の `intersections` は **Set(順不同)** を返し、
  現状 `behavior.dart:379` は `intersections.first` を使っている。自前版で `first` が
  別の点を返すとリンク端点が変わりうる。受け入れ基準に
  **「`first` 依存を排除し、最近点を選ぶ等の明示的選択に変更」**を追加。
  これは [[link-endpoint-gap-followup]] とも接続する。
- リスク: 中(浮動小数の境界・接線ケース・順序依存)。golden と数値テストで担保。
- 補足: [[link-endpoint-gap-followup]] の調査はこの幾何コード整備と相性が良いが、
  本タスクでは挙動を変えない(別タスク化)。

### B2. デバッグサーバー群(`dart:io`/`http`)を本体から分離
- 箇所: `lib/src/debug/debug_server.dart`(`dart:io`)、
  `external_debug_client.dart`(`http`)、`debug_manager.dart`/`structured_logger.dart`
  が `debug_server.dart` を import。`gesture_manager.dart:7` が
  `external_debug_client.dart` を import。
- 公開 import graph(追検証で確定):
  `plough.dart → manager.dart → debug_manager.dart → debug_server.dart(dart:io)`。
  **`dart:io` は確かに公開 import graph に乗っている**。問題意識は正当。
- 現状の問題: `dart:io` と `http`・`logger` がパッケージ本体の import graph に入り、
  web 安全性と依存の軽さを損なう。`http` 利用は `external_debug_client.dart` と
  `enhanced_client.dart`(A7 で先に削除)の 2 ファイル。
- 方針(レビュー推奨): **(c) 別パッケージ化(段階的)**。`plough_devtools`(仮)を
  別パッケージにし、本体は **no-op の `DebugSink` インターフェース**だけ持ち、
  `Plough().attachDebugSink(...)` でデバッグ時のみ実装を注入する。
  - (a) 条件付き import(`dart.library.io` stub)は `http`/`logger`/workbench
    プロトコルまで本体に残り「依存の軽さ」目標を達成できない。
  - (b) example 移設は、デバッグ計装が `gesture_manager` 内部に食い込む現状では
    結合を切りにくい。
- 対応(段階):
  1. A7 で `enhanced_client.dart` 削除済み前提。
  2. 計装の注入点を 1 インターフェース(`DebugSink`)に集約(**E1 が前提**)。
  3. `debug_server`/`external_debug_client`/workbench 連携を別パッケージへ移し、
     本体デフォルトを no-op に。
  4. `http` を本体 `pubspec.yaml` から削除。
- 受け入れ基準: `flutter test -p chrome`(web)で本体が import エラーを出さない。
  本体 `pubspec.yaml` から `http`(と可能なら `logger`)が消える。
- リスク: 高(配置方針の決定が必要)。
- 依存: **E1(注入点集約)完了後**。

### B3. 値等価性の流儀統一(調査タスク)
- 箇所: `equatable` + `freezed` + `fast_immutable_collections` が併存(`pubspec.yaml:17-19`)
- 対応: `equatable` 利用箇所を洗い出し、Freezed へ寄せられるか調査
  (まずは grep ベースの棚卸しレポートのみ。実変更は別タスク)。
- 受け入れ基準: 利用箇所一覧と移行可否の判断メモを `doc/` に残す。
- リスク: 低(調査のみ)。

---

## フェーズ C: 状態管理の整理(中期・設計変更)

### C1. 選択状態の単一ソース化
- 対象指摘: 課題 2-3(`node._isSelected` と `GraphData.selectedNodeIds` の二重管理、
  `force: true` ハック)
- 対応:
  1. `GraphData.selectedNodeIds`/`selectedLinkIds` を**唯一の真実**とする。
  2. `node.isSelected` / `link.isSelected` を `selectedIds` 由来の derived getter に変更
     (個別 `ValueNotifier<bool> _isSelected` を廃止、または selectedIds 変更を購読)。
  3. `selectNode`/`deselectNode`/`clearSelection` から二重同期と `force: true` を除去。
  4. レンダリングが選択変更で更新されることを widget/golden テストで担保。
  5. **`set canSelect(false)` の選択解除も単一ソース経由にする**(下記 [R1])。
- 受け入れ基準: 選択系の全テスト緑。`_isSelected` の手動同期コードが消える。
  **`canSelect=false` 後に `isSelected` と `selectedNodeIds` が乖離しない**ことを検証。
- **申し送り(phaseA レビュー [R1])**: `node.dart:172-179` の `set canSelect(bool)` は
  選択中ノードを `canSelect=false` にすると `_isSelected.value=false` でフラグだけ落とし、
  `GraphData.selectedNodeIds` を更新しない(A4 が正した deselect 経路とは逆向きの乖離)。
  A4 はあくまで deselect 経路の修正で、この `canSelect` 経路の乖離は残っている。
  `isSelected` を derived 化すれば原理的に消えるため、C1 で吸収する(個別パッチは
  二度手間になるので当てない)。
- リスク: 高(レンダリング購読経路の変更)。A4 修正後に着手。
- 依存: A4 完了後(完了済み)。

### C2. `GraphNode` から View 状態(`NodeViewState`)を分離
- 対象指摘: 課題 2-4(`geometry`/`animatedPosition`/`isArranged`/
  `animationStartPosition`/`stackOrder` がモデルに同居 → 1 Graph を 2 View に
  同時表示不可)。`node.dart:63-75` に該当 `ValueNotifier` 群。
- 対応:
  1. `GraphNode` を純データ(id, properties, weight, canSelect …)に縮約。
  2. `GraphView` 側に `Map<GraphId, NodeViewState>`(geometry, animation, stackOrder)。
  3. レイアウト/レンダリング/ジェスチャの geometry 参照を View 側状態へ付け替え。
  4. C1 の reverseLink 不変化(A3-2)もここで整合。
- 受け入れ基準: 同一 `Graph` を 2 つの `GraphView` に並べる widget テストを新設し、
  片方の操作がもう片方の geometry を壊さないことを確認。
- リスク: 非常に高(geometry 同期・[[node-geometry-no-scale-divide]]・
  [[viewport-hittest-ownership]] 等の既知 gotcha 群に直撃)。
- 依存・根拠(レビュー反映): **D1 従属**。geometry の保持場所・座標系・ヒットテスト経路は
  D1(RenderObject)が規定する。C2 で `NodeViewState` を先に切り出しても、D1 で
  保持構造を作り直すなら二度手間。**D1 の RFC/PoC で「geometry を誰が持つか」を決め、
  その器に C2 が `NodeViewState` を流し込む**順とする。C1 完了 + D1 方針確定後に着手し、
  **着手前に再レビュー必須**。

---

## フェーズ D: ジェスチャ/レンダリングの構造改善(長期・v2)

### D1. `MultiChildRenderObjectWidget` + カスタム `RenderBox` への移行
- 対象指摘: 課題 1(post-frame ブートストラップ)・課題 5(性能上限)
- 概要: `performLayout` 内で `child.layout(constraints, parentUsesSize: true)` し
  同一フレームで子サイズを取得 → post-frame geometry 読み戻し・`GlobalKey`・
  3 相 `_buildState`・`refreshAllNodeGeometry` を不要化。リンクは `paint()`、
  ヒットテストは `hitTestChildren`、viewport Transform は
  `applyPaintTransform`/`hitTest` に乗せ、手書きの `screenToScene`/`globalToScene`/
  `dragDeltaTransform` を縮約。
- 進め方: **大型のため設計 RFC を別途起票**(`doc/rfc_render_graph_view.md`)。
  小さな PoC(数ノード+1リンクの RenderObject 試作)で原理確認 → 段階移行。
- 受け入れ基準(PoC): post-frame なしで geometry が取れ、tap/drag/zoom が既存と同等。
- リスク: 最大。既知 gotcha([[drag-end-spatial-index-refresh]],
  [[node-geometry-no-scale-divide]], [[viewport-drag-delta-and-handler-swap]],
  [[viewport-hittest-ownership]])が原理的に解消されるかを PoC で検証。
- 依存: フェーズ A/B 完了後に着手。C と並行設計。

### D2. GestureManager をポインタ単位 FSM へ集約
- 対象指摘: 課題 4(10 個の state manager / node・link 二重実装 / enum 分岐 /
  無駄な二重 `findNodeAt` / `GraphGestureMode` 分岐散在)
- 対応:
  1. ポインタごとの明示 FSM(idle → pressed → panReady → dragging / tapped)を
     1 オブジェクトに集約。
  2. `GraphId` は entity 横断で一意なので node/link でクラスを分けず統合。
  3. `handlePointerUp` の node(~230 行)/link(~60 行)コピーを共通化。
  4. 「Double-check to prevent race conditions」の二重 `findNodeAt`
     (`gesture_manager.dart:634,1178` 他)を 1 回に。同期コードに race はない。
  5. `GraphGestureMode` を mode 別 Strategy に集約。
- 受け入れ基準: gesture テスト(simulated pointer)が全緑のまま行数大幅減。
- リスク: 高(回帰の宝庫)。gesture テスト網を厚くしてから着手。
- 依存: フェーズ A(ログ lazy 化 = E1)後。D1 とは独立着手可能。

### E1. ログ API のクロージャ受けオーバーロード追加 + ホットパス lazy 化
- 対象指摘: 課題 3(`logDebug(cat, '...substring...')` が無効時も文字列補間/Map 構築、
  ポインタ/フレーム毎に走る)
- 前提(第2ラウンドで確定): `logDebug`/`logInfo`/`logWarning`/`logError`/`logGestureDebug`
  は現在 `(LogCategory, String)` の **String 固定シグネチャ**(`utils/logger.dart:100-110`)で、
  lib 全体から **約 268 箇所**呼ばれている(追検証で確認)。
- 「重さ」は 2 軸で評価する:**ランタイムでは案A(全 API lazy 化)は重くならない**
  (キャプチャ無しクロージャは static 化されアロケーションなし、回避できる
  `substring`/`map`/`join`/`DateTime.now().toIso8601String()` のコストが桁違いに大きい)。
  重いのは**改修コスト(268 箇所)**であり、これが「即効・低リスク」と噛み合わない。
- **採用方針(折衷案)**: オーバーロードで段階移行する。
  ```dart
  // 例: Object で String と String Function() の両方を受ける
  void logDebug(LogCategory category, Object message) => _logger.d(
        category,
        message is String Function() ? (enabled ? message() : '') : message,
      );
  ```
  - **既存 268 箇所は無改修のまま動く**(String をそのまま渡せる)。
  - **ホットパス(`gesture_manager` の `handlePointerDown`/drag 等の毎フレーム経路)だけ
    `() => '...'` に書き換え**、そこだけ無効時の文字列構築をゼロに。
  - 案A のランタイム利点を案B の小さな改修範囲で段階取り込み。残りは以降のタスクで順次。
  - 注: `Object message` 化しても**既存 String 呼び出し側の補間は呼び出し時点で評価済み**
    なので、改善が効くのは `() =>` 化したホットパスのみ(=スコープを絞る根拠)。
- スコープ: 「ログ API にクロージャ受けオーバーロード追加 + ホットパスのみ `() =>` 化」。
  **全 268 箇所の一括 lazy 化は対象外**。
- 加えて `externalDebugClient.sendLog(metadata: {...})` は **`if (enabled)` ガードを
  `sendLog` の外(呼び出し側)へ出す**(現状 `_enabled` チェックが関数内で、引数 Map は
  無効時も構築される)。これも E1 に含める。
- **注意(レビュー追補)**: `gesture_manager.dart` のデバッグ補間内に
  `_nodeTapManager.states` 走査や `getTapStateDebugInfo()` 等 **状態を読む呼び出し**が
  引数式に紛れている箇所がある。クロージャ化・ガード移動の前に
  **「引数式が状態を変更しない(読み取りのみ)」ことをレビューで確認**してから移す。
- 受け入れ基準:
  - クロージャ受けオーバーロードを追加し、**既存 String 呼び出しが無改修でコンパイル・動作**。
  - `() =>` 化対象が「ポインタ/フレーム毎に走る経路」に限定されていることをレビューで確認。
  - ガード式・移動した引数式が **状態を変更しない(読み取りのみ)**。
  - **ログ有効時の出力内容が従来と一致**(ガード/オーバーロードが出力を欠落させない)。
  - ログ無効時にホットパスで文字列補間/Map 構築が走らない(コード検査 or ベンチ)。挙動不変。
- リスク: 低〜中。**フェーズ A と並行で最初に着手して良い**(レビューが言う
  "体感半分以下" の即効性)。
- 位置づけ: 短期。番号は E だが**実施は早期**。D2 だけでなく **B2 の前提でもある**
  (計装の注入点を 1 インターフェースに集約)。
- **実装済み(2026-06-14, commit 2d6c4c0、assert は別コミット)**。実装レビュー承認
  (`doc/review_feedback_20260614_01_E1.md`)。E1 はクロージャ受けオーバーロード API の導入(土台)+
  最ホット 1 経路(`handlePointerMove` の `TAP_DEBUG_STATE` ブロック)の
  `isGestureDebugEnabled` 前置ガード + `_sendToExternalDebug` の enabled ガードまで。
  **クロージャ(`() =>`)渡しの実利用は 0 件**で、それは次段の土台という設計判断([S1])。
- **次段への申し送り(レビュー [S3]/[S4])**:
  - **[S3] `enabled` のレベル精緻化**: 現状 `enabled(category)` は `Level.off` 以外で true。
    `logDebug` 用に `Level.debug` 以上か等のレベル階層比較まで見ると、無効でないだけの
    カテゴリでのクロージャ無駄評価を防げる。クロージャ渡しを増やす前に検討。
    → **E2** として下記に新設。
  - **[S4] `handlePointerDown`/`handlePointerUp` の lazy 化**: 毎ポインタ毎の
    `externalDebugClient.sendLog(metadata: {...})` / `logGestureDebug(data: {...})` の
    map 構築が残存(`gesture_manager.dart` 462-656, 658-1063)。毎フレームではないが
    drag 開始/終了・タップ毎に走る。→ **E3** として下記に新設。

### E2. ログ `enabled` 判定のレベル階層精緻化(レビュー [S3]・次段)
- 対象: `PloughLogger.enabled(category)` が `Level.off` 以外で一律 true を返す点。
- 対応: `logDebug`/`logInfo`/... ごとに必要レベル(debug/info/...)以上かを比較する
  `enabled(category, level)` 等に拡張し、クロージャ無駄評価を抑える。
- 前提: E3(クロージャ渡しの増加)とセットで効く。単独では現状実害なし。
- リスク: 低。受け入れ基準: 出力内容不変・無効レベルでクロージャ非評価。

### E3. `handlePointerDown`/`Up` のログ map 構築の lazy 化(レビュー [S4]・次段)
- 対象: `gesture_manager.dart` 462-656 / 658-1063 の毎ポインタ毎 `sendLog`/`logGestureDebug`。
- 対応: `metadata: {...}` / `data: {...}` 構築を `isGestureDebugEnabled` /
  `externalDebugClient.enabled` ガード下に置く(handlePointerMove と同方式)、
  またはクロージャ渡しに移行。
- 依存: E2(レベル精緻化)があると無駄評価をさらに削れる。
- リスク: 中(箇所が多くポインタ毎経路)。gesture テストで担保。

---

## フェーズ F: 性能(D1 を待たず単独で直せるもの・レビュー追加)

課題 5 の性能項目のうち、D1(RenderObject 化)を待たずに単独で直せるものを切り出す。

### F1. ノード/リンク削除時の `_nodeViews`/`_nodeKeys`/`_linkKeys` 掃除
- 箇所: `lib/src/graph_view/widget/graph.dart`(`_nodeKeys:226`/`_nodeViews:227`/
  `_linkKeys:230`)
- 現状(追検証で確認): `clear()` は `_nodeViews`(344 付近)等でまとめて行うのみで、
  個別ノード/リンク削除時の `remove` がなくリーク。
- 対応: ノード/リンク削除時に対応キーを掃除。A1(removeNode)と同じ
  「削除時クリーンアップ」系なので **A1 と近い時期に実施**(文脈共有)。
- 受け入れ基準: ノード追加→削除を繰り返してもマップが単調増加しないテスト。
- リスク: 低。
- 依存: A1 と同時期が望ましい。

### F2. `_BaseLinkRendererPainter.shouldRepaint => true` の見直し
- 箇所: `lib/src/renderer/widget/link.dart:194`
- 現状: 常に true を返し、毎回再描画。
- 対応: ジオメトリ/スタイル比較に基づく `shouldRepaint` に変更。
- 受け入れ基準: golden 不変。不要再描画が減ることをコード検査で確認。
- リスク: 中(比較漏れで再描画不足)。golden で担保。

### F3+. rebuild 範囲縮小・sort キャッシュ
- 対象: `AnimatedBuilder` 全体包みによる全ツリー rebuild、`_markSortDirty` 毎フレーム
  呼び(`graph.dart:559`)による sort キャッシュ無効化、空間グリッドのリンク非対応。
- 方針: 単独では費用対効果が低く回帰リスクが高いため、**D1 に統合**して設計する。
- 依存: D1。
- **申し送り(removal レビュー [R1])**: F1 の `_pruneRemovedEntityCaches()` が正しく動く
  前提は「`_markSortDirty()` 毎回呼びで `elements` が毎ビルド再構築される」こと。sort
  キャッシュ無効化を直す際は、**prune の供給源(`_graph.nodes/links`)と `elements` の
  供給源を一致**させ、できれば両者を削除イベント駆動へ寄せる。供給源がズレると prune は
  最新 graph・`elements` は古いキャッシュ、という乖離が起きうる。

---

## 実施順序(推奨)

レビュー(`design_review_plan_feedback.md`)の修正提案を反映:

```
1.  E1(ログ lazy 化)                  ← 完了(2d6c4c0/b20fee2)
2.  削除パス整理: A1 + A2 + A8(+ F1)   ← 完了(e63c302)
3.  A7(死にファイル enhanced_client 削除)
4.  A3, A4, A5, A6                    ← 完了(A3/A4/A5: bcce23d, A6: e56b4e3)
5.  B1(flame 撤去 / first 依存排除) ← 完了(31d8d07), B3(棚卸し) ← 完了(equatable 削除まで実施)
6.  B2(debug 別パッケージ化)          ← E1 後・設計レビュー反映後
    - B2-a(DebugSink 注入点集約・挙動不変) ← 完了
    - B2-b(モノレポ移動・http 除去・web 安全化) ← 未着手(B2-a レビュー後)
7.  F2(shouldRepaint)
8.  C1(選択単一ソース → A4 吸収)
9.  D1 RFC + PoC / D2(FSM)           ← A/B 後、設計レビュー後
10. C2(NodeViewState、D1 従属)
```

主な変更点(レビュー反映):
- A7/A8/F1 を追加。A1 周辺を「削除パス整理」として束ねた(実装 1 PR、テスト項目別)。
- B2 の前提に E1 を明示(注入点集約)。配置方針は (c) 別パッケージ化。
- A4 を「C1 で吸収される暫定」と位置づけ。
- B1 に `intersections.first` 依存排除を追加。
- F2(shouldRepaint)を性能の単独タスクとして追加。F3+ は D1 に統合。

短期(挙動不変): E1, A1-A8(A7/A8 含む), B1, B3, F1
中期: B2, C1, F2
長期(v2): D1, D2, C2, F3+

---

## トラッキング表

| ID | 区分 | 概要 | リスク | 依存 | 状態 |
|---|---|---|---|---|---|
| E1 | 短期 | ログ API にクロージャ受けオーバーロード追加 + ホットパスのみ `() =>` 化 | 低中 | なし | 未着手 |
| A1 | バグ | removeNode の links 掃除 | 低 | なし | **完了(e63c302)** |
| A2 | バグ | 死にフィールド削除 | 低 | A1 | **完了(e63c302)** |
| A3 | バグ | reverseLink 通知/インデックス張替 | 中 | なし | **完了(bcce23d)** |
| A4 | バグ | deselectNode の state/フラグ乖離是正(暫定) | 低中 | なし | **完了(bcce23d)** |
| A5 | バグ | KeyedSubtree キー → graph.id | 低 | なし | **完了(bcce23d)** |
| A6 | 小 | thickness 定数化等 | 低 | なし | **完了(e56b4e3)** |
| A7 | 死コード | enhanced_client.dart 削除(未参照・http) | 低 | なし | **完了(2fad4b2)** |
| A8 | バグ | removeLink の `_notifyLayoutChange` 欠落 | 低中 | A1 と同 PR | **完了(e63c302)** |
| B1 | 依存 | flame 撤去 / `intersections.first` 依存排除 | 中 | なし | **完了(31d8d07)** |
| B2 | 依存 | debug 別パッケージ化 | 高 | E1 | **完了**: B2-a(DebugSink 集約 `493f209`)/ B2-b stage1(DebugBackend `b9c6ead`)/ B2-b stage2(plough_devtools 分離・http 除去・web 安全 `8a56176`) |
| B3 | 調査 | 値等価性棚卸し(+ 未使用 equatable 削除) | 低 | なし | **完了(doc/value_equality_survey_B3.md, equatable 削除)** |
| F1 | 性能 | node/link 削除時の view マップ掃除 | 低 | A1 同時期 | **完了(e63c302)** |
| F2 | 性能 | shouldRepaint をジオメトリ/スタイル比較に | 中 | なし | **完了(47615aa)** |
| C1 | 中期 | 選択状態単一ソース化(A4 吸収) | 高 | A4 | **完了(8adc717)**: isSelected を derived 化、[R1] 乖離解消、force:true 除去 |
| C2 | 長期 | NodeViewState 分離 | 最高 | C1,D1 | 設計メモ作成(`doc/c2_node_view_state_design.md`)。実装は D1 後・再レビュー必須 |
| D1 | 長期 | RenderObject 化 RFC+PoC | 最大 | A,B | RFC ドラフト作成(`doc/rfc_render_graph_view.md`)。実装は PoC 合意後 |
| D2 | 長期 | ジェスチャ FSM 集約 | 高 | E1 | テスト網拡充(D2-pre `e5d277b`)完了。FSM 化本体は未着手(テスト網先行の前提を満たした段階) |
| E1 | 短期 | ログ API lazy 化土台 + 最ホットガード | 低中 | なし | **完了(2d6c4c0)** |
| E2 | 短期 | ログ enabled のレベル階層精緻化([S3]) | 低 | E3 と併用 | **完了(40eb44c)** |
| E3 | 短期 | handlePointerDown/Up のログ map lazy 化([S4]) | 中 | E2 | **完了(40eb44c)**: handlePanStart はスコープ外 |
| F3+ | 性能 | rebuild 範囲縮小・sort キャッシュ | 高 | D1 | D1 RFC に統合(`doc/rfc_render_graph_view.md` §2.2/§2.3)。実装は D1 と同時 |

---

## 別セッションへのレビュー依頼

このセクションを別セッション(レビュー担当)にそのまま渡してください。

### 依頼概要

`doc/design_review.md`(原レビュー)を踏まえて作成した本実行計画
(`doc/design_review_plan.md`)を批判的にレビューしてほしい。
コードを変更する必要はなく、**計画の妥当性**を見てほしい。

### 必ず確認してほしい論点

1. **原レビューの事実確認の追検証**
   - 本計画は以下を実コードで確認済みとしている。各々を独立に再確認し、
     誤認があれば指摘してほしい:
     - `graph_base.dart:300-319` `removeNode` が `state.value.links` を掃除しない
     - `graph_base.dart` `_nodeDependencies` が死にフィールド
     - `graph_base.dart:377-384` `reverseLink` が通知なし mutate
     - `graph_base.dart:457-469` `deselectNode` の単一選択時全クリア
     - `flame` 依存は `lib/src/graph_view/shape.dart` のみか
     - `dart:io` は `lib/src/debug/debug_server.dart` のみか、本体 import graph に
       実際に乗っているか
     - `graph.dart:684` `ValueKey(_graph.hashCode)`

2. **タスク分割の粒度と順序**
   - A1→A2 を同ファイル連続で行う判断は妥当か。
   - E1(ログ)を最初に置く順序は合理的か。
   - C1(選択単一ソース化)を A4 の後に置く依存は正しいか。逆に C1 を先に
     やった方が A4 が不要になるなど、統合余地はないか。

3. **リスク評価の妥当性**
   - B2(debug 分離)を「高」、C2/D1 を「最高/最大」とした評価は妥当か。
   - 「挙動を変えない」と分類したタスク(E1, A5, B1)が本当に挙動不変か、
     見落とした副作用(特に [[viewport-drag-delta-and-handler-swap]] /
     [[node-geometry-no-scale-divide]] 等の既知 gotcha への抵触)はないか。

4. **設計判断を要する未決事項(最重要)**
   - **B2 の配置方針**: debug サーバー群を (a) 条件付き import で本体内に残す /
     (b) example 側へ移す / (c) 別パッケージ化、のどれが良いか。
     pub パッケージ品質(web 安全性・依存の軽さ)と利用者の利便性のトレードオフで
     推奨を出してほしい。
   - **D1 vs C2 の順序**: RenderObject 化(D1)と NodeViewState 分離(C2)は
     どちらを先に設計すべきか。D1 が geometry の持ち方を規定するなら C2 は
     D1 に従属させるべきでは、という仮説の当否。
   - **A3 reverseLink**: 最小修正(mutate+通知)で止めるか、即座に不変更新へ
     変えるか。後者は C1/C2 の不変化方針と一貫するが影響範囲が広がる。

5. **抜け漏れ**
   - 原レビューの指摘で本計画が拾えていないものはないか
     (特に課題 5 の「`_nodeViews`/`_nodeKeys`/`_linkKeys` のリーク」、
     `_BaseLinkRendererPainter.shouldRepaint => true`、空間グリッドがリンク非対応、
     `AnimatedBuilder` 全体包みによる全ツリー rebuild、
     `_markSortDirty` 毎フレーム呼びによる sort キャッシュ無効化 を
     独立タスクとして起こすべきか)。

### 期待する成果物

- 各論点への所見(賛成/反対/修正案)。
- 事実確認の誤りがあれば該当ファイル・行番号付きで指摘。
- 設計判断 4 項目への推奨(理由付き)。
- 計画に追加・削除・並べ替えすべきタスクの提案。

レビュー結果は `doc/design_review_plan_feedback.md` に書き出してほしい。
