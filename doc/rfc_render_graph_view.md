# RFC: GraphView の RenderObject 化(D1)

ステータス: **ドラフト(着手前・実装なし)**
作成日: 2026-06-14
対象タスク: `doc/design_review_plan.md` の **D1**(リスク最大)
前提: フェーズ A/B 完了済み。本 RFC は PoC 着手判断のための設計文書であり、
実装は本ドキュメントの承認後に別途行う。

---

## 1. 背景と問題

現状の `GraphView` は Flutter の標準ウィジェット合成 + post-frame コールバックで
レイアウト→geometry 読み戻し→再描画を行っている。これにより:

- **post-frame ブートストラップ**(課題 1): `performLayout` 後に geometry を post-frame で
  読み戻し、`GlobalKey` で子のサイズ/位置を取得、3 相 `_buildState`、
  `refreshAllNodeGeometry` でヒットテスト用 spatial index を再構築する多段構造。
  1 フレーム遅延・タイミング依存のバグ温床。
- **性能上限**(課題 5): `AnimatedBuilder` が全ツリーを包み毎フレーム全 rebuild、
  `_markSortDirty` 毎フレーム呼びで sort キャッシュ無効化、空間グリッドがリンク非対応。
- **座標変換の手書き**: viewport の Transform に対し `screenToScene`/`globalToScene`/
  `dragDeltaTransform` を手書きで合わせており、ズーム時の delta 補正など既知 gotcha が多い。

### 関連する既知 gotcha(memory 由来)
- [[drag-end-spatial-index-refresh]]: `handleDragEnd` の post-frame
  `refreshAllNodeGeometry` は削除不可(ドラッグ後ヒットテストが壊れる)。
- [[node-geometry-no-scale-divide]]: Transform 内でも `renderBox.size` は logical。
  ズーム中 rebuild で bounds が縮みヒットテスト/リンク端点が壊れる。
- [[viewport-drag-delta-and-handler-swap]]: ズーム中ドラッグは delta を scale で割る等。
- [[viewport-hittest-ownership]]: pointer を Transform の外で受け `screenToScene` で
  scene 変換。

これらはいずれも「レイアウト/geometry/座標変換/ヒットテストを手書きで多段に組んでいる」
ことの帰結。RenderObject 化で**原理的に解消されうる**かを PoC で検証するのが D1。

---

## 2. 提案する構造

`MultiChildRenderObjectWidget` + カスタム `RenderBox`(仮 `RenderGraph`)へ移行する。

### 2.1 レイアウト
- `performLayout` 内で各子(ノードウィジェット)に
  `child.layout(constraints, parentUsesSize: true)` を呼び、**同一フレームで子サイズを取得**。
  → post-frame の geometry 読み戻し・`GlobalKey`・3 相 `_buildState`・
  `refreshAllNodeGeometry` を不要化。
- ノード位置はレイアウト戦略(`GraphLayoutStrategy.performLayout`)が決めた logical 座標を
  `BoxParentData`(または専用 ParentData)に保持。

### 2.2 描画
- リンクは `RenderGraph.paint()` 内で直接描画(現在の `CustomPainter` 群を統合)。
  ノードは子 RenderBox として `context.paintChild`。
- スタックオーダー(z-order)は paint 順で表現。

### 2.3 ヒットテスト
- `hitTestChildren` でノードのヒットテストを RenderObject 機構に委譲。
  → 手書き spatial index の一部を置換できるか PoC で評価(リンクのヒットテストは要検討)。

### 2.4 viewport / Transform
- viewport のズーム/パンは `applyPaintTransform` + `hitTest` の Matrix4 機構に乗せ、
  手書きの `screenToScene`/`globalToScene`/`dragDeltaTransform` を縮約。
  → [[node-geometry-no-scale-divide]] / [[viewport-drag-delta-and-handler-swap]] が
  RenderObject の座標変換で自然に解決するかを PoC で確認。

---

## 3. PoC のスコープと受け入れ基準

**PoC**: 数ノード + 1 リンクの最小 `RenderGraph` 試作。

受け入れ基準:
- post-frame なしで geometry が取れる(同一フレームで子サイズ確定)。
- tap / drag / zoom が既存と同等に動く(characterization テスト
  `gesture_manager_characterization_test.dart` を流用・拡張)。
- **リンクの `hitTestSelf` が線分距離判定でヒットすること**(ノードは `hitTestChildren`
  で済むが、リンクは子でない描画のため `hitTestSelf` + 線分距離判定が別途必要。
  これが PoC で最も不確実な点であり、「リンクのヒットテストが当たる」を明示の
  受け入れ基準に加える)。
- 上記 4 つの既知 gotcha が PoC 構造で再現しない(または解消する)ことを確認。

**no-go 条件**: 上記いずれかで RenderObject 機構が既存手書きより複雑化する、
または gotcha が形を変えて残る場合は段階移行を保留し、F3+(rebuild 範囲縮小・
sort キャッシュ)のみを単独で先行する。

PoC で原理確認できたら**段階移行**(ノード描画 → リンク描画 → ヒットテスト → viewport)。

---

## 4. リスクと検証項目

リスク: **最大**。以下を PoC で潰す:
1. ドラッグ後ヒットテスト([[drag-end-spatial-index-refresh]]): RenderObject の
   `hitTestChildren` がドラッグ後も最新の子位置で当たるか。
2. ズーム中の bounds/端点([[node-geometry-no-scale-divide]]): logical vs physical の
   座標系が `applyPaintTransform` で一貫するか。
3. ドラッグ delta のズーム補正([[viewport-drag-delta-and-handler-swap]]): hitTest の
   Matrix4 逆変換で delta が自然に scene 座標になるか。
4. ヒットテスト所有権([[viewport-hittest-ownership]]): pointer 受け取り位置と scene 変換の
   責務が RenderObject 機構で整理されるか。
5. リンクのヒットテスト: ノードは `hitTestChildren` で済むが、リンク(子でない描画)の
   ヒットテストは別途(`hitTestSelf` + 線分距離判定)が要る。

---

## 5. 依存・順序

- フェーズ A/B 完了後に着手(完了済み)。**C と並行設計**。
- **C2(NodeViewState 分離)は D1 従属**: geometry の保持場所(ParentData か別マップか)を
  D1 が規定し、その器に C2 が `NodeViewState` を流し込む([[c2-node-view-state-design]] 参照)。
- **F3+(rebuild 範囲縮小・sort キャッシュ)は D1 に統合**: `AnimatedBuilder` 全包み廃止・
  sort キャッシュ・空間グリッドのリンク対応は RenderObject 化と同時に設計する(本 RFC の
  §2.2/§2.3 に含まれる)。

---

## 6. 結論(現時点)

D1 は最大リスクで、**実装着手前に本 RFC のレビューと PoC 計画の合意が必須**。本セッションでは
RFC ドラフトのみ作成し、実装は行わない。次段は「PoC を別ブランチで試作 → 4 gotcha の
再現/解消を計測 → 段階移行の可否判断」。
