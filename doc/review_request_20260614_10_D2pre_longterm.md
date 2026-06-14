# D2-pre(gesture テスト拡充)+ 長期 RFC レビュー依頼

依頼日: 2026-06-14
対象ブランチ: `feature/redesign`
対象コミット:
- `e5d277b`(test(gesture): characterization tests — D2-pre)
- `f2f6cda`(docs: D1 RFC + C2 design memo + plan update)
対象タスク: `doc/design_review_plan.md` の **D2(前さばき)** / **D1** / **C2** / **F3+**
レビュー方針: D2-pre は**テストの妥当性(現状挙動を正しく固定しているか)**、
RFC/メモは**設計の方向性・PoC スコープ・着手判断**。
結果は末尾の指定先に書き出してほしい。

---

## 背景

中期タスク(F2/B2-b/C1/E2/E3)完了後、計画の残りは長期(D2/D1/C2/F3+)。これらは
リスク高〜最大で、計画自身が「テスト網先行 / RFC / 再レビュー必須」を明示している。
ユーザー合意のもと:
- **D2** は FSM 化本体を止め、**テスト網拡充(D2-pre)のみ**実施。
- **D1 / C2 / F3+** は実装せず **RFC / 設計メモ**を作成。

---

## 変更点

### D2-pre — `test/gesture_manager_characterization_test.dart`(新規・8 ケース)
FSM 化(D2)前に現状挙動を固定する characterization テスト。既存 gesture スイートは
基本 tap/drag と mode 1 つしか見ておらず薄い(調査で確認)。追加:
- 背景タップで選択クリア / 2 つ目のノードタップで single-selection 移動
- 2 連タップで double tap ディスパッチ
- pointer cancel 後に選択もせず例外も出ない
- exclusive / transparent / nodeEdgeOnly の consume 判定
- canSelect=false ノードはタップで選択されない

**descriptive(現状挙動の固定)であり prescriptive ではない**。FSM 化本体は未実施。

### 長期 RFC / メモ(実装なし)
- `doc/rfc_render_graph_view.md`(D1): MultiChildRenderObjectWidget + RenderBox 移行の
  RFC。post-frame 廃止・`performLayout` で子 layout・リンク `paint()`・
  `hitTestChildren`・viewport を `applyPaintTransform`/`hitTest` に乗せる構想。
  既知 gotcha 4 件(drag-end spatial index / node-geometry-no-scale-divide /
  viewport-drag-delta / viewport-hittest-ownership)の PoC 検証項目。F3+ を統合。
- `doc/c2_node_view_state_design.md`(C2): `GraphNode` から View 状態
  (geometry/animation/stackOrder)を `Map<GraphId, NodeViewState>` へ分離する設計。
  D1 が geometry 保持場所を規定する従属関係を明記。着手前再レビュー必須。

---

## 必ず確認してほしい論点

### D2-pre
1. **現状挙動の正確な固定**: 8 ケースが現状の `GraphGestureManager` の挙動を正しく
   写しているか(誤った期待値を固定していないか)。特に double-tap の認識条件、
   pointer cancel の扱い。
2. **FSM 化への有効性**: これらが「挙動保存の FSM 化」の安全網として機能する粒度か。
   さらに足すべき未カバー領域(link tap/drag、hover lifecycle、tooltip trigger、
   並行 pointer、drag delta × zoom)があれば優先度付きで。
3. **スコープ判断**: FSM 化本体を止めてテスト網のみ先行した判断の妥当性。

### 長期 RFC / メモ
4. **D1 RFC の方向性**: RenderObject 化で 4 gotcha が原理的に解消されうるという見立ては
   妥当か。PoC スコープ(数ノード+1 リンク)で検証項目を潰せるか。リンクのヒットテスト
   (子でない描画)の扱いに穴がないか。
5. **C2 の D1 従属**: geometry 保持場所を D1 が規定するまで C2 を着手しない判断は妥当か。
6. **F3+ の D1 統合**: rebuild 範囲縮小・sort キャッシュを単独でなく D1 と同時設計にする
   判断は妥当か。

---

## 検証状況(実装者報告)

- D2-pre: 8 ケース緑。非 golden 全テスト 80 passed / 2 skipped。
- `dart format --set-exit-if-changed`(lib/test/devtools): 0。
- RFC/メモはドキュメントのみ(コード変更なし)。

---

## 期待する成果物

- D2-pre 3 論点 + 長期 3 論点への所見。
- D2-pre に足すべきテストの優先度付きリスト。
- D1 PoC 着手の可否判断(go/no-go の条件)。

レビュー結果は **`doc/review_feedback_20260614_10_D2pre_longterm.md`** に書き出してほしい。

---

## 補足: 本セッションでの完了タスク一覧(まとめレビュー用)

| タスク | コミット | レビュー依頼 |
|---|---|---|
| F2(shouldRepaint) | `47615aa` | `review_request_20260614_06_F2.md` |
| B2-b stage1(DebugBackend) | `b9c6ead` | `review_request_20260614_07_B2b.md` |
| B2-b stage2(plough_devtools 分離) | `8a56176` | 同上 |
| C1(選択単一ソース) | `8adc717` | `review_request_20260614_08_C1.md` |
| E2/E3(ログ lazy 次段) | `40eb44c` | `review_request_20260614_09_E2E3.md` |
| D2-pre(gesture テスト) | `e5d277b` | 本ファイル |
| D1/C2/F3+(RFC/メモ) | `f2f6cda` | 本ファイル |
