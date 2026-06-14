# E2 + E3: ログ lazy 化の次段 実装レビュー依頼

依頼日: 2026-06-14
対象ブランチ: `feature/redesign`
対象コミット:
- `40eb44c`(perf(log): level-aware enabled + guard hot-path debug map builds — E2/E3)
対象タスク: `doc/design_review_plan.md` の **E2** / **E3**
レビュー方針: **挙動不変(出力内容)・ガード移動の副作用なし・スコープ**。
結果は末尾の指定先に書き出してほしい。

---

## 背景

E1 でクロージャ受けオーバーロードの土台を導入済み。その次段:
- **E2**: `PloughLogger.enabled(category)` が `Level.off` 以外で一律 true を返すため、
  サブ閾値(例:warning 設定カテゴリの debug クロージャ)でも無駄評価されうる。
- **E3**: `handlePointerDown`/`handlePointerUp` の毎ポインタ `debugSink.sendLog(metadata)` /
  `logGestureDebug(data)` の map 構築がガードなしで走る。

---

## 変更点

### E2 — `lib/src/utils/logger.dart`
- `enabled(category, [Level? level])` に拡張。`level` 指定時は、設定レベルが `off` でなく
  **かつ** `level.value >= configured.value`(その重大度が実際に出力される)のときのみ true。
- `_resolve(category, message, Level level)` にレベルを渡し、`logDebug`→`Level.debug`、
  `logInfo`→`Level.info`、`logWarning`→`Level.warning`、`logError`→`Level.error`。
  クロージャは `enabled(category, level)` が true のときだけ評価。
- 公開ガードヘルパ `logEnabled(category, [Level?])` を追加し `plough.dart` で export
  (ログ呼び出しの外で重いペイロードを組む前のガード用)。

### E3 — `lib/src/interactive/gesture_manager.dart`
- `handlePointerDown`/`handlePointerUp` 内の **`debugSink.sendLog(metadata:{...})` 8 箇所**を
  `if (debugSink.enabled) { ... }` で囲む(map と `DateTime.now()` の構築を無効時スキップ)。
- 同 2 メソッド内の **`logGestureDebug(data:{...})` 3 箇所**(TAP_STATE_DOWN / TAP_STATE_UP /
  TAP_RECOGNITION_FAILED)を `if (isGestureDebugEnabled) { ... }` で囲む。
  - ガード内に取り込んだ読み取り(`getState`/`getTapStateDebugInfo`/`states.length`/
    `isDragging`/`failureReason` 構築)は**副作用なし**であることを確認済み
    (`getTapStateDebugInfo` は `getState` + map 構築のみ、`tap_state.dart:79-90`)。
  - **ログの後でも使う値**(`tapState`、`isStillDraggingAfterUp`、`isTapCompletedAfterUp`)は
    **ガード外に残した**(ガードに入れると後続ロジックが壊れるため)。

---

## 必ず確認してほしい論点

1. **E2 の出力不変**: String 直渡しの既存呼び出しは `_resolve` が素通しし、実際の出力可否は
   従来どおり `logger` パッケージのレベルフィルタが決める。E2 が効くのは**クロージャ評価の
   スキップのみ**で出力内容は変わらない、という理解で正しいか。`enabled(cat, level)` の
   不等号向き(`level.value >= configured.value`)が `logger` の `Level` 順序意味論と合うか。
2. **E3 の副作用なし(必須確認)**: ガード内に移した読み取りがすべて副作用なしか。特に
   `getTapStateDebugInfo`/`getState`/`states`/`isDragging`/`failureReason`。状態を変える
   呼び出しがガードに紛れていないか(計画 E1 注意点の踏襲)。
3. **E3 のスコープ外に残した値**: `tapState`/`isStillDraggingAfterUp`/`isTapCompletedAfterUp`
   をガード外に残した判断。これらがログ後の tap 完了判定・selection toggle に使われるため。
   ガード境界が正しいか(ログだけが無効化され、判定ロジックは不変)。
4. **E3 のスコープ**: 計画では E3 のスコープは `handlePointerDown/Up`。`handlePanStart` 内の
   `logGestureDebug`(PAN_START_RECEIVED / NODE_PAN_READY_CREATED / LINK_PAN_READY_CREATED)は
   **スコープ外として未変更**。この線引きは妥当か(パン開始はポインタ毎ではなく頻度低)。
5. **挙動不変**: gesture テスト緑のまま、golden 失敗集合不変。デフォルト(Noop sink /
   gestureDebug 無効)で全テストが通る = ガードの無効パスが正しいことの担保。

---

## 検証状況(実装者報告)

- `flutter analyze`(logger / gesture_manager): error/warning なし(既存 info のみ)。
- `dart format --set-exit-if-changed lib/ test/`: 0。
- 非 golden テスト: 72 passed / 2 skipped(E2 新規 5 件含む)。
- E2 セーフティネット `test/logger_enabled_level_test.dart`: レベル階層・サブ閾値での
  クロージャ非評価を検証(緑)。
- golden: 11 failed でベースライン同一(描画不変)。

---

## 期待する成果物

- 5 論点への所見(問題なし/要修正、根拠付き)。特に**論点 2(副作用なし)**の追検証。
- ガード境界(スコープ外に残した値)の正しさ。
- E3 のスコープ(handlePanStart 除外)の妥当性、次段で拾うべきか。

レビュー結果は **`doc/review_feedback_20260614_09_E2E3.md`** に書き出してほしい。
