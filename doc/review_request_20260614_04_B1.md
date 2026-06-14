# B1: flame 依存を自前幾何コードに置換 実装レビュー依頼

依頼日: 2026-06-14
対象ブランチ: `feature/redesign`
対象コミット:
- `31d8d07`(refactor(shape): replace flame dependency with self-contained geometry — B1)
対象タスク: `doc/design_review_plan.md` の **B1**
レビュー方針: **実装の正しさ(幾何計算)・挙動不変性・スコープ妥当性・pub 品質**。
結果は末尾の指定先に書き出してほしい。

---

## 背景

`pubspec.yaml` の `flame: ^1.23.0` は **ゲームエンジン一式**だが、実際の用途は
`lib/src/graph_view/shape.dart` の **線分交差計算のみ**(線分 × 円、線分 × 軸平行矩形)。
依存の重さ・web 安全性(pub 品質)に直結するため、~130 行の自前幾何コードに置換した。

旧実装は flame の `intersections`(順不同 `Set`)に対し呼び出し側で
`intersections.first` を取っていた。これは反復順が未規定で、自前実装で順序が変わると
リンク端点が変わりうる(計画 B1 の受け入れ基準)。**`first` 依存を排除**した。

---

## 変更点

### 新設 — `lib/src/utils/geometry_intersect.dart`
自己完結・web 安全な交差ヘルパー 2 つ(いずれも入出力は `Offset`、線分は `[start,end]` 有限):
- `segmentCircleIntersections(start, end, center, radius)`:
  線分を `P(t)=start+t·d, t∈[0,1]` でパラメータ化し `|P(t)-center|²=r²` の 2 次方程式を解く。
  退化線分(start==end)は点テスト。許容誤差 `1e-9`。0/1(接線)/2 点を返す。
- `segmentRectIntersections(start, end, bounds)`:
  Liang–Barsky パラメトリッククリップで入口 `tEnter`・出口 `tExit` を求め、
  **境界交差に該当する点のみ**返す(矩形内に完全に含まれる線分は 0 点)。
  始点が矩形内のときは入口を返さず出口のみ、終点が内側なら入口のみ。

### `lib/src/graph_view/shape.dart`(flame 撤去)
- import から `package:flame/{components,experimental,geometry}.dart` を除去。
- `GraphLine.flameLineSegment`(`@internal`)と `_vector2SetToOffsetSet` を削除。
- `GraphCircle.getLineIntersections` → `segmentCircleIntersections` に委譲。
- `GraphRectangle.getLineIntersections` → `segmentRectIntersections` に委譲。
- **公開シグネチャ `getLineIntersections(Rect, GraphLine) -> Set<Offset>` は不変**(後方互換)。

### `lib/src/graph_view/behavior.dart` `_getLineIntersections`(`first` 排除)
- 線分は `source.center -> target.center`。source.center は形状内部にあるため、
  接続点は**始点(source.center)に最も近い境界交差**。`reduce` で
  `distanceSquared` 最小の点を明示選択(`Set` の反復順に依存しない)。
- doc コメントを「first を返す」から実態に合わせて更新。

### `pubspec.yaml`
- `flame: ^1.23.0` を削除。`example/pubspec.yaml` には元々 flame なし(確認済み)。

### テスト
- `test/geometry_intersect_test.dart`(恒久): 手計算した既知期待値に対する assert。
  円(中心貫通の水平/垂直弦、始点=中心、接線、ミス、退化点)、
  矩形(水平/垂直貫通、対角=2 隅、始点内側=出口のみ、終点内側=入口のみ、ミス)。
- `test/geometry_intersect_parity_test.dart`(**削除済み**): flame がある間に
  flame 版と自前版の数値一致を並走確認するための一時テスト。flame 撤去で呼べなくなるため、
  確認完了後に削除した(下記「検証状況」参照)。

---

## 必ず確認してほしい論点

1. **円交差の正しさ**: 2 次方程式の解・許容誤差 `1e-9` の置き方。判別式 `≈0`(接線)で
   1 点に潰れるか、`t∈[-ε,1+ε]` のクランプで端点付近の取りこぼし/誤検出がないか。
   退化線分(start==end)分岐の妥当性。
2. **矩形交差(Liang–Barsky)の正しさ**: `p[i]≈0`(線分が辺と平行)の扱い、
   `tEnter>ε` / `tExit<1-ε` の境界判定。**辺と完全に重なる線分**で自前版は入口・出口の
   2 点を返す(flame は 3 点を返していた既知差異 — パリティテストで除外・コメント済み)。
   この差異が center-to-center のリンク経路で実害ないという判断は妥当か。
3. **`first` 排除の等価性(挙動不変)**: 「始点に最も近い交差を選ぶ」が、従来 flame の
   `first` が(実用上)返していた接続点と一致するか。source.center が形状内部にある前提が
   崩れるケース(ノードが極端に重なる等)で端点が飛ばないか。
   これは [[link-endpoint-gap-followup]](リンク端点のすき間)と同じ幾何コードに触れるが、
   **B1 ではすき間の本格調査はせず挙動不変に留める**方針。その線引きは妥当か。
4. **公開 API 後方互換**: `GraphLine`/`GraphCircle`/`GraphRectangle`/`GraphShape` の
   公開シグネチャ不変を確認。`flameLineSegment`(`@internal`)削除が外部に影響しないか。
5. **flame 完全撤去**: `grep -rn package:flame lib/` 0 件、`pubspec.yaml`・`pubspec.lock`
   から flame 消失を確認済み。推移的依存に flame 由来の取りこぼしがないか。
6. **スコープ/粒度**: 実装+テストを 1 コミット、パリティテストを撤去と同時に削除した判断。

---

## 検証状況(実装者報告)

- `grep -rn "package:flame" lib/`: **0 件**。`pubspec.yaml`/`pubspec.lock` から flame 消失。
- `dart format --set-exit-if-changed lib/ test/`: **0 changes**。
- `flutter analyze lib/`: 新規 error/warning なし(残る info は HEAD から存在する既存・スコープ外)。
  変更 3 ファイル単体 analyze も新規指摘なし。
- **パリティ確認(flame がある間に実施)**: 円・矩形の代表線分で flame 版と自前版が
  許容誤差 `1e-6` 内で一致することを確認(辺完全重なりの 1 ケースのみ既知差異として除外)。
  確認後、parity テストを削除し恒久テスト(既知期待値)に置換。
- 非 golden テスト(全 48 ファイル相当): **passed / 2 skipped**。新規交差テスト緑。
- **golden 失敗集合**: flame 撤去前後で **完全一致(11 件、同一集合)** を
  `git stash`(flame 版へ一時復帰)→ 失敗名 diff で確認。リンク端点描画は不変。
  既知のとおり golden はベースラインでも環境差で数件失敗する(CI 環境での撮り直しは別タスク)。

---

## 期待する成果物

- 6 論点への所見(問題なし/要修正、根拠付き)。
- 幾何計算の境界条件(接線・退化・辺重なり・始点内側)で見落としがあれば `file:line` 付きで。
- `first` 排除が挙動不変であることの追検証観点(反例の有無)。
- スコープ・粒度の妥当性。

レビュー結果は **`doc/review_feedback_20260614_04_B1.md`** に書き出してほしい。
