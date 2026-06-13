# Plough 設計・実装レビュー

実施日: 2026-06-10
対象: `lib/` 全体(レビュー時点の `develop` ブランチ、HEAD: 4f579bc)

## 結論

設計の骨格(層分離・Strategy・Factory + 非公開 Impl)は良い。一方で、複雑さの大部分は
グラフ描画そのものではなく、次の3点から来ている。

1. post-frame コールバックに依存したレイアウト機構
2. 三重化した状態管理(Model に View 状態が混入)
3. 本体コードに浸透したデバッグ計装

「設計が悪い」のではなく、**Flutter のレイアウト/ヒットテストプロトコルの外側で
自前再実装している部分**(geometry 同期・ヒットテスト・ジェスチャ判別)に複雑さが
集中している、という構図。

---

## 良い点(維持すべき設計)

- **層分離が明確**: data model / layout strategy / rendering / interaction の分割と依存方向は正しい
- **Factory + 非公開 `*Impl`** で公開 API を絞っている
- **隣接インデックス**(`_incomingIndex` / `_outgoingIndex`)や**空間グリッド**(`_NodeSpatialGrid`)など計算量への配慮がある
- 過去の回帰(ズーム時の geometry、handler 差し替え等)に対する**経緯コメントが丁寧**で再発防止に効いている
- 4層テスト戦略(unit / gesture / widget / golden)

---

## 課題1: レイアウト機構が「ビルド→post-frame→再ビルド」の多段ブートストラップ(根本原因)

`GraphViewState`(`lib/src/graph_view/widget/graph.dart`)は
`initialize → performLayout → ready` の3相ステートマシンを持ち、
`_isGeometryUpdateScheduled` / `_layoutFinishPending` フラグ、
post-frame での RenderBox 読み取り(`_updateNodeGeometry`)、
`GlobalKey` 経由の geometry 同期で動いている。
さらに build 中(`AnimatedBuilder` の builder 内)で `_performLayout` を呼んでいる
(`graph.dart:574` 付近)。

drag-end の spatial index 再構築が消せない、geometry を scale で割ってはいけない、
といった既知の gotcha 群は、**「widget レイアウト後にしか子のサイズが分からないので
post-frame で読み戻す」というアーキテクチャの帰結**。同期タイミングのズレが構造的に
発生するため、対症療法のフラグが増え続ける。

### より良い設計: `MultiChildRenderObjectWidget` + カスタム `RenderBox`

Flutter で「子のサイズを知ってから配置したい」場合の正攻法:

- `performLayout` 内で `child.layout(constraints, parentUsesSize: true)` すれば
  **同じフレーム内で同期的に**ノードサイズが得られる
  → post-frame の geometry 読み戻し、`GlobalKey`、`_buildState` 3相、
  `refreshAllNodeGeometry` がすべて不要になる
- リンクは `paint()` で描く(または描画専用の子)。endpoint 計算はレイアウト直後に
  同期的にできるので、「リンク端点のすき間」問題もこの層で解消しやすい
- ヒットテストは `hitTestChildren` のオーバーライドに乗れる。viewport の Transform も
  `applyPaintTransform` / `hitTest` の仕組みに乗れば、現在手書きしている
  `screenToScene` / `globalToScene` / `dragDeltaTransform` の3系統の座標変換
  コールバックの大半が消える

今の複雑さに対する一番効果の大きい「根本治療」。pub の `graphview` 等もこの方式。

---

## 課題2: 状態管理の三重化と Model への View 状態混入

状態の置き場所が3系統ある。

1. `GraphData`(Freezed immutable、`ValueNotifier<GraphData>` 内)
2. ノード個々の mutable `ValueNotifier` 群
   (`lib/src/graph/node.dart:63-75`: position, geometry, isSelected, stackOrder …)
3. 選択状態は **node 側 `_isSelected` と `GraphData.selectedNodeIds` の二重管理**で、
   `selectNode` / `clearSelection`(`graph_base.dart:416-569`)が手動で両方を同期
   (`force: true` のハックも)

Freezed の不変性は実質飾り。`GraphLinkImpl.source/target` を `reverseLink` が直接
mutate し(しかも変更通知なし — `graph_base.dart:377`)、不変であるべき map の中身が
可変オブジェクトになっている。

さらに `GraphNode` に `geometry` / `animatedPosition` / `isArranged` /
`animationStartPosition` といった **View 専用状態がモデルに載っている**ため、
1つの `Graph` を2つの `GraphView` に同時表示できない(片方の geometry がもう片方を壊す)。

### 改善案

- `GraphNode` は純データ(id, properties, weight, canSelect 等)に絞り、
  `GraphView` 側に `Map<GraphId, NodeViewState>`(geometry, animation, stackOrder)を持つ
- 選択状態は `GraphData.selectedNodeIds` の**一箇所のみ**を真実とし、
  `node.isSelected` は derived getter にする

---

## 課題3: デバッグ計装が本体を侵食している(即効性のある改善)

`lib/src/interactive/gesture_manager.dart`(1722行)の**過半はログとデバッグ
メタデータ構築**。問題は量だけでなくコスト構造:

- `logDebug(cat, '...${id.value.substring(0, 4)}...')` は**ログ無効時も毎回文字列補間が
  実行される**。`handlePointerDown` 1回で substring・map/join・
  `DateTime.now().toIso8601String()`・複数の Map リテラル構築が走る。
  ポインタイベント毎・ドラッグ中は毎フレーム
- `externalDebugClient.sendLog(metadata: {...})` も `_enabled` チェックは関数内なので、
  **引数の巨大 map は無効時も構築される**

### 改善案

- ログ API を `logDebug(cat, String Function())` の lazy 形式にするか、
  `if (PloughLogger.enabled(cat))` ガードを徹底する
- `debug_server.dart` / `external_debug_client.dart` / workbench 連携はパッケージ本体から
  分離する(別パッケージ or example 側)。現状
  `plough.dart → manager.dart → debug_manager.dart → debug_server.dart(dart:io)` と
  **dart:io が公開 API の import graph に入っており**、`http`・`logger` 依存も
  デバッグ専用。pub パッケージとしての品質(web 安全性、依存の軽さ)に直結する
- **`flame` 依存は `shape.dart` の線分交差計算のみ**。ゲームエンジン一式を依存に持つ
  理由としては重すぎるので、50行程度の自前幾何コードで置換するのが良い

---

## 課題4: GestureManager の神クラス化と node/link 二重実装

- state manager が **tap / drag / hover / panReady / tooltip × node / link で10個**。
  基底 `GraphStateManager` は `switch (entityType)` で分岐しており
  (`state_manager.dart:141-217`)、ポリモーフィズムでなく enum 分岐 + クラス二重化
  という二重払い。`GraphId` は entity 横断で一意なので、**entity 種別でクラスを分ける
  必然性はない**
- `handlePointerUp` の node 処理(~230行)と link 処理(~60行)はほぼコピーで、
  ロジック修正が片方に入り忘れるリスクが恒常的にある
- 「Double-check to prevent race conditions」として同期関数内で `findNodeAt` を2回呼ぶ
  箇所(`gesture_manager.dart:634, 1178, 1326`)があるが、**同期コードに race はない**。
  無駄なヒットテスト2回分のコストと、不変条件への不安の表れ
- tap/drag 判別・slop・double-tap タイマー・pan-ready は **Flutter のジェスチャアリーナの
  再実装**。単一オーバーレイ + 手動ヒットテスト方式自体は(z-order・transform 対応のため)
  妥当な選択だが、それなら状態は「ポインタごとの明示的 FSM
  (idle → pressed → panReady → dragging / tapped)」として1つのオブジェクトに集約すべき。
  10個のマネージャに分散した bool フラグ + `_pendingBackgroundDeselectAt` のような
  帯域外変数の組み合わせは状態空間の把握を困難にしている
- `GraphGestureMode` の分岐が各ハンドラに散在している。mode ごとの Strategy に
  まとめると整理できる

---

## 課題5: パフォーマンスの構造的上限

- `_buildCommonProviders` が `AnimatedBuilder(animation: _graph)` で**全体を包む**ため、
  どんな状態変化でも全ツリー rebuild
- 外側の builder で毎回 `_markSortDirty()` を呼ぶため(`graph.dart:559`)、
  **sort キャッシュは実質無効**。incremental layout 中は毎フレーム O(n log n) sort +
  全要素 widget 再生成
- `_BaseLinkRendererPainter.shouldRepaint => true`(`renderer/widget/link.dart:194`)
- `_nodeViews` / `_nodeKeys` / `_linkKeys` はノード削除時に**掃除されずリーク**
- 空間グリッドはノードのみで、リンクは常に線形走査

widget-per-node 方式は数百ノードで限界が来る。大規模対応するなら
「**全ノード・リンクを単一 CustomPainter で描き、選択中・編集中のノードだけ widget を
重ねる hybrid**」が定石で、課題1の RenderObject 化とも整合する。

---

## バグ・疑わしい箇所(設計と独立に直せるもの)

| 箇所 | 内容 |
|---|---|
| `graph_base.dart:301-319` | **`removeNode` がリンクを `state.value.links` から削除していない**。隣接インデックスからは消すが links map に残り、消えたノードを参照するリンクが描画対象に残る。doc は「automatically removes any links」と謳っており不一致 |
| `graph_base.dart:220,370` | `_nodeDependencies` は書き込み(削除)のみで一度も populate されない死にフィールド。`removeLink` 内の `removeWhere` 条件も意味を成していない |
| `graph_base.dart:377` | `reverseLink` が変更通知なしで mutate(UI が更新されない) |
| `graph_base.dart:457-469` | `deselectNode` は multi-selection 無効時、対象がどれであれ選択リスト全体をクリア |
| `behavior.dart:195,276` | `GraphViewBehavior` は `abstract interface class` なのに `isEquivalentTo` が実装を持つ。`implements` するユーザーは全メソッド再実装を強制される。イベントコールバック11個 + ヒットテスト + widget 生成が1インターフェースに同居しており、分割(Renderer / HitTester / EventListener)の余地あり |
| `graph_view/widget/graph.dart:684` | `KeyedSubtree(key: ValueKey(_graph.hashCode))` — hashCode をキーにするのは衝突・不安定の元。`graph.id` を使うべき |
| `behavior.dart:322` | リンク thickness 30 のハードコード(TODO 放置) |
| 依存全般 | `equatable` + `freezed` + `fast_immutable_collections` と値等価性の流儀が3つ併存 |

---

## 推奨ロードマップ

### 短期(挙動を変えない)

- ログの lazy 化とホットパスからの計装除去
- 死にコード削除(`_nodeDependencies` 等)
- `removeNode` のリンク掃除修正
- `flame`・debug サーバー群の依存切り離し

これだけで gesture_manager は体感半分以下の行数になり、見通しが激変する。

### 中期

- 選択状態の単一ソース化
- `GraphNode` から View 状態(`NodeViewState`)の分離 → 複数ビュー同時表示が可能になる

### 長期(v2 の柱)

- `MultiChildRenderObjectWidget` ベースの `RenderGraphView` へ移行し、レイアウト・
  ヒットテスト・座標変換を Flutter のレイアウトプロトコルに乗せる
- 同時にジェスチャ状態をポインタ単位の FSM に集約
- post-frame 同期系の gotcha が原理的に消え、大規模グラフ向け canvas 描画への道も開ける
