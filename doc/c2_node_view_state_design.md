# 設計メモ: GraphNode から NodeViewState を分離(C2)

ステータス: **ドラフト(着手前・実装なし・着手前再レビュー必須)**
作成日: 2026-06-14
対象タスク: `doc/design_review_plan.md` の **C2**(リスク最高)
依存: **D1 従属**(`doc/rfc_render_graph_view.md` 参照)。C1 完了済み。

---

## 1. 背景と問題(課題 2-4)

`GraphNode`(モデル)に **View 状態**が同居している:
- `node.dart:63-75` 付近の `ValueNotifier` 群: `_geometry`、`_animatedPosition`、
  `_isAnimating`、`_isAnimationCompleted`、`_animationStartPosition`、`_logicalPosition`、
  `_stackOrder`。
- `isArranged`、`animatedPosition`、`stackOrder` 等。

これらは「ある Graph をある GraphView でどう描くか」という **View 固有の状態**で、純粋な
グラフデータ(id、properties、weight、canSelect …)とは別物。同居の結果:

- **1 つの Graph を 2 つの GraphView に同時表示できない**(geometry 等が 1 ノードに 1 つしか
  持てず、2 つの View で取り合いになる)。
- モデルと描画状態が密結合し、テスト・再利用が難しい。

> 注: C1 で選択状態(`isSelected`)は既に `GraphData.selectedNodeIds` 由来の derived に
> 分離済み([[graph-selection-single-source]])。選択は「Graph に属する状態」なのでモデル側
> 単一ソースで正しい。C2 が扱うのは「View に属する状態」(geometry/animation/stackOrder)で
> 方向が逆(モデルから出して View 側に置く)。

---

## 2. 提案する分離

1. `GraphNode` を**純データ**に縮約(id、properties、weight、canSelect、canDrag、visible、
   isEnabled 等のモデル属性のみ)。
2. `GraphView` 側に `Map<GraphId, NodeViewState>` を持つ。`NodeViewState` =
   geometry、animatedPosition、isAnimating、animationStartPosition、logicalPosition、
   stackOrder、isArranged。
3. レイアウト/レンダリング/ジェスチャの geometry 参照を**すべて View 側状態へ付け替える**。
4. C1 と同様、reverseLink まわりの不変化(A3 で通知/インデックス対応済み)と整合を取る。

---

## 3. 受け入れ基準

- **同一 `Graph` を 2 つの `GraphView` に並べる widget テスト**を新設し、片方の操作
  (ドラッグ等)がもう片方の geometry を壊さないことを確認。
- 既存のレイアウト/ジェスチャ/golden テストが緑のまま。

---

## 4. なぜ D1 従属か(着手順序)

geometry の**保持場所・座標系・ヒットテスト経路**は D1(RenderObject 化)が規定する:
- D1 ではノード位置を `ParentData` に持ちうる。その場合 `NodeViewState` の geometry は
  ParentData と二重持ちになりかねない。
- **D1 で「geometry を誰が持つか」を決め、その器に C2 が `NodeViewState` を流し込む**順が
  正しい。C2 を先に切り出すと、D1 で保持構造を作り直す際に二度手間になる。

したがって着手は **C1 完了(済) + D1 方針確定後**。

---

## 5. リスクと既知 gotcha

リスク: **非常に高**。geometry 同期は以下の既知 gotcha 群に直撃する:
- [[node-geometry-no-scale-divide]]: geometry の座標系(logical/physical)を取り違えると
  ヒットテスト/リンク端点が壊れる。
- [[viewport-hittest-ownership]]: pointer 受け取りと scene 変換の責務。
- [[drag-end-spatial-index-refresh]]: ドラッグ後の geometry 再構築タイミング。

`Map<GraphId, NodeViewState>` 化で geometry の所有が View に移ると、これらの経路すべてを
付け替える必要があり、回帰の影響が広い。

---

## 6. 結論(現時点)

C2 は最高リスクで **D1 従属・着手前再レビュー必須**。本セッションでは設計メモのみ作成し、
実装は行わない。D1 の PoC で geometry 保持構造が確定してから、本メモを更新して着手可否を
再レビューする。
