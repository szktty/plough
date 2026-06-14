# F2: リンクペインタの shouldRepaint 最適化 実装レビュー依頼

依頼日: 2026-06-14
対象ブランチ: `feature/redesign`
対象コミット:
- `47615aa`(perf(renderer): compare-based shouldRepaint for link painter — F2)
対象タスク: `doc/design_review_plan.md` の **F2**
レビュー方針: **比較漏れ(再描画不足)がないか・挙動不変(描画結果不変)**。
結果は末尾の指定先に書き出してほしい。

---

## 背景

`_BaseLinkRendererPainter.shouldRepaint`(`lib/src/renderer/widget/link.dart`)が
**常に `true`** を返しており、毎フレーム再描画されていた(課題 5 の性能項目)。
`paint()` が実際に読む値だけを比較する `shouldRepaint` に変更し、不要再描画を削減する。

---

## 変更点

### `lib/src/renderer/widget/link.dart`
- `shouldRepaint(oldDelegate)` を `=> true` から比較ベースに変更。
  - `oldDelegate is! _BaseLinkRendererPainter` なら `true`(型不一致は安全側)。
  - 以降、両者の `renderer` の以下を `!=` 比較:
    `geometry`(@freezed) / `style`(@freezed) / `color` / `lineWidth` / `lineStyle` /
    `arrowStyle` / `arrowSize` / `thickness` / `routing` / `link.direction`(enum)。
- 除外:`sourceView`/`targetView`/`child`(Widget)。**`paint()` で読まれない**ため
  比較不要(参照比較は誤再描画/再描画漏れの両方を招くので意図的に除外)。

### テスト — `test/link_painter_should_repaint_test.dart`(新規)
- `GraphDefaultLinkRenderer` を実際に `pumpWidget` し、`CustomPaint.painter` を取り出して
  `shouldRepaint` を検証(private painter クラスを実ビルド経路で行使)。
- 同値レンダラ → `false`、`geometry`/`color`/`lineWidth`/`arrowSize`/`thickness` を
  1 つ変えたレンダラ → `true`。

---

## 必ず確認してほしい論点

1. **比較漏れ(再描画不足)**: `paint()`/`paintArrows()`/`drawArrow()` が読む値が
   比較対象に**全て**含まれているか。具体的に paint は
   `renderer.geometry`(connectionPoints), `color`, `lineWidth`, `lineStyle`,
   `arrowStyle`, `arrowSize`, `link.direction`、サブクラスの `calculatePoints`/
   `paintPath`(geometry と size から決定的)を使う。`thickness` は hit-test 用で
   paint には現状効かないが、将来差分検知のため含めた。過不足の判定をしてほしい。
2. **サブクラス差分**: `_StraightLinkRendererPainter` と `_OrthogonalLinkRendererPainter`
   は同じ入力(geometry, size)に対し決定的に描く。基底の値比較だけで十分か、
   サブクラス固有の状態が漏れていないか。
3. **`==` の妥当性**: `geometry`(GraphConnectionGeometry)/`style`
   (GraphDefaultLinkRendererStyle)は @freezed で値等価。`color`(Color)/enum 群の
   `!=` が期待通りか。
4. **挙動不変**: 描画結果は変わらず再描画頻度のみ削減であること。
   golden 失敗集合が増えないことで担保(下記)。

---

## 検証状況(実装者報告)

- `flutter analyze lib/src/renderer/widget/link.dart`: 新規 error/warning なし
  (`link.dart:350` の cascade_invocations は既存・スコープ外)。
- `dart format --set-exit-if-changed lib/ test/`: 0 changes。
- 新規テスト 6 件緑。**セーフティネット有効性確認済み**: `shouldRepaint` を旧 `=> true`
  に戻すと「identical renderers do not trigger repaint」が落ちる(1 failed)。
- golden: 16 passed / 11 failed で **ベースライン(11 failed)と同一**。描画結果不変。

---

## 期待する成果物

- 4 論点への所見(問題なし/要修正、根拠付き)。
- 比較対象の過不足(特に再描画漏れにつながる欠落)を `file:line` 付きで。
- スコープ・粒度の妥当性。

レビュー結果は **`doc/review_feedback_20260614_06_F2.md`** に書き出してほしい。
