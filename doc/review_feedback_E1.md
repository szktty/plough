# E1 実装レビュー結果

レビュー日: 2026-06-14
対象: `doc/review_request_E1.md`(E1: ログ API オーバーロード + ホットパス lazy 化)
対象コミット: `2d6c4c0`(perf(logging): defer hot-path log construction (E1))
レビュー方針: 実装の正しさ・副作用・スコープ妥当性。コードは変更していない。

## 総評

**承認(マージ可)。** 実装は ADR(`e1_logging_decision.md`)どおりで、6 論点すべてに重大な
問題なし。既存 String 呼び出しの無改修性・クロージャ評価のセマンティクス・ホットパスガードの
副作用なし、を実コードで確認した。golden 失敗は E1 と無関係(後述)。

ただし**スコープに関する重要な事実**が 1 点ある(下記 6・指摘 [S1])。
E1 で追加したオーバーロードは**今回どこからも使われていない**(クロージャ渡しの
呼び出しが lib 内に 0 件)。これは「土台だけ作って実利用は次段」という設計判断であり
誤りではないが、依頼文の表現とずれるため明示する。

---

## 6 論点への所見

### 1. 既存 String 呼び出しの無改修性 → 問題なし

- `logDebug` 等は `(LogCategory, Object message)` に変わったが、`_resolve` の非クロージャ
  経路は `return message as String;`。**String を渡せば従来と完全に同一経路**。
- 旧実装(`4f579bc`)は `_logger.d(category, message)` に無条件で渡していた。新実装も
  String なら同じく無条件で渡る(空文字 `''` も含めスキップされない)。**挙動差なし**。
- 型推論の懸念: `Object` 引数なので String リテラル/補間はそのまま String として渡る。
  `toString` 経由の暗黙変換は `_resolve` に無く、String 以外・クロージャ以外を渡すと
  `message as String` で **実行時例外**になる(コンパイルは通る)。現状そのような呼び出しは
  無いが、型安全性は `String` 固定時より下がっている。→ 指摘 [S2]。

### 2. クロージャ評価のセマンティクス → 問題なし

- `_resolve`: `message is String Function()` のとき `_logger.enabled(category) ? message() : null`。
  **無効カテゴリではクロージャは一度も評価されない**(`null` を返し、各 `logX` が
  `if (resolved != null)` でスキップ)。意図どおり。
- 有効カテゴリでは `message()` を評価し従来同様 `_logger.d/i/w/e` へ。`null` 返しは
  クロージャ無効時のみで、**正常ログの欠落は起きない**。
- ADR で「空文字を渡さず null 返し」とした判断は妥当(空ログが出力に混じらない)。

### 3. `enabled` 判定の正しさ → 概ね正しい(1 点留意)

- `PloughLogger.enabled`: `_levels[category]` が `null`(未 `configure`)なら false、
  `Level.off` なら false、それ以外 true。**デフォルト無効の従来挙動と矛盾しない**。
- 依頼文 3 の自己申告どおり、**レベル階層との齟齬は残る**: 例えばカテゴリが `Level.error`
  のとき `logDebug` にクロージャを渡すと `enabled` は true なので**クロージャを評価して
  しまう**(最終的に `Logger` 側で DEBUG 出力は抑制されるため、出力は正しいが
  **無駄評価**が残る)。
  - 今回ホットパスで lazy 化したのは `logGestureDebug`(`LogCategory.gesture`)であり、
    かつ実際にクロージャ渡しが 0 件(指摘 [S1])なので**現時点で実害なし**。
  - 将来クロージャ渡しを増やす段で、`enabled(category)` を「`logDebug` なら `Level.debug`
    以上か」までレベル比較する精緻化を検討する価値あり。→ 指摘 [S3](次段)。

### 4. `handlePointerMove` ガードの副作用 → 問題なし

- ガード `if (isGestureDebugEnabled && draggedEntityId != null)` が囲うのは
  **`logGestureDebug(...)` 送出ブロックのみ**(`gesture_manager.dart:1460-1518`)。
- drag 処理の本筋 `_nodeDragManager.handlePointerMove(event)`(1453)は**ガードの外**。
  hit-test(`findNodeAt`/`findLinkAt`)も外。**ジェスチャ処理に影響なし**。
- ブロック内の `getTapStateDebugInfo()`(`tap_state.dart:79-91`)は `getState` で読み
  map を組むだけ、`getState`/`isDragging`/`states`/`selectedEntityIds` も読み取りのみ。
  **副作用なし**(状態を変更しない)を確認。計画の E1 注意点クリア。
- 旧コードは `draggedEntityId != null` だけで毎フレーム巨大 map + `getTapStateDebugInfo` +
  `DateTime.now().toIso8601String()` を構築していた。`isGestureDebugEnabled` 前置で
  無効時はゼロに。目的達成。

### 5. `_sendToExternalDebug` の早期ガード → 問題なし(意図どおり)

- `logger.dart` の `_sendToExternalDebug` 冒頭に `if (!externalDebugClient.enabled) return;`。
  `external_debug_client.dart:22` に `bool get enabled => _enabled;` を追加。
- `sendLog` 内部にも `if (!_enabled) return;`(58)があり**二重ガード**だが、
  呼び出し側ガードにより**無効時に `logEntry` map 構築すら走らない**。意図どおり。
  二重ガードは冗長ではなく、各々が別レイヤ(map 構築回避 / API 防御)を担う。

### 6. スコープの妥当性 → 妥当だが「実利用 0 件」を明示すべき(指摘 [S1])

- 「最ホットのみ = `handlePointerMove` の 1 ブロック」に限定した判断は妥当。
  `handleMouseHover`(ログ無し)・`findNodeAt`/`findLinkAt`(ログ無し)は確認済み。
- ただし `handlePointerDown`/`handlePointerUp` には**毎ポインタ毎に大量の
  `externalDebugClient.sendLog(metadata: {...})` と `logGestureDebug(data: {...})`** が残る
  (`gesture_manager.dart` 462-656, 658-1063)。これらは「毎フレーム」ではないが
  ドラッグ開始/終了・タップ毎に走り、map 構築コストは小さくない。次段の有力候補。→ [S4]。

---

## 指摘一覧

### [S1] オーバーロードのクロージャ経路は今回 0 件使用(要・依頼文との整合)

`logDebug(() => ...)` 等の**クロージャ渡しは lib 内に 1 件も無い**(grep 0 件)。
今回の実ランタイム改善は **`handlePointerMove` の `isGestureDebugEnabled` 前置ガード**
(これは `logGestureDebug` であって新オーバーロードは経由しない)による。
- 評価: 誤りではない。オーバーロードは「次段で使う土台」。ただし依頼文 §背景の
  「ホットパスを `() =>` に書き換える」という記述と実装の実態(土台のみ追加)がずれる。
- 推奨: ADR/計画に「**E1 はオーバーロード API の導入 + 最ホット 1 経路のガード。
  クロージャ実利用は次段**」と 1 行明記し、誤読を防ぐ。

### [S2] `Object message` は String/クロージャ以外で実行時例外(型安全性の低下)

`_resolve` の `return message as String;` は、String でもクロージャでもない値を渡すと
実行時 `CastError`。コンパイルは通るため、`@internal` とはいえ将来の事故源。
- 推奨(任意・低優先): dartdoc に「String か `String Function()` のみ」を明記済みだが、
  `assert(message is String || message is String Function())` を `_resolve` 冒頭に入れると
  デバッグビルドで早期検出できる。

### [S3] `enabled` がレベル階層を見ず、無効でないだけで true(無駄評価の余地)

論点 3 のとおり。現時点で実害なし(クロージャ 0 件 + 対象が gesture カテゴリ)。
次段でクロージャ渡しを増やす前に、`logDebug` 用 `enabled` を `Level.debug` 以上判定へ
精緻化するか検討。→ 次段タスクのメモに残すこと。

### [S4] 次段 lazy 化の有力候補: `handlePointerDown`/`Up` の sendLog/logGestureDebug

論点 6 のとおり。毎ポインタ毎の `metadata: {...}`/`data: {...}` 構築が残存。
E1 の枠を超えるので別タスク化(計画の「以降のタスクで段階的に」に合致)。

---

## golden 失敗の独立確認 → E1 と無関係(報告を支持)

- E1 の変更 3 ファイル(`logger.dart`/`external_debug_client.dart`/`gesture_manager.dart`)は
  **描画経路に一切触れていない**。`gesture_manager` の変更はログ送出ブロックのガードのみで、
  ノード位置・geometry・paint には影響しない。
- 実装者報告の「ベースライン(`4f579bc`)でも同数 golden 失敗・0.01〜1.36% のピクセル差」は
  フォント/レンダリング環境差として整合的。**E1 に起因しないと判断**。
- 念のための条件: 今後 E1 由来でないことを担保するなら、CI と同一環境で golden を
  撮り直す(別タスク)。本レビューのブロッカーではない。

---

## 検証(レビュー側で再現)

- `dart format --set-exit-if-changed`(変更 3 ファイル): **0 changed**。
- `flutter analyze`(変更 3 ファイル): 新規エラー・警告なし。info のみ
  (`gesture_manager.dart:713` の `avoid_dynamic_calls` は既存、`logger.dart:105` の
  `avoid_catches_without_on_clauses` は E1 で移動した既存 catch)。**E1 起因の新規指摘なし**。
- 非 golden テスト: 実装者報告(20 passed / 2 skipped)を支持。skip は
  `graph_selection_multi_test.dart` / `graph_view_gesturemode_custom_background_pan_test.dart`
  に既存の `skip:` があり、E1 とは無関係。

---

## 結論

- **6 論点すべて問題なし。マージ可。**
- 必須対応: なし。
- 推奨(ドキュメント): [S1] を ADR/計画に 1 行明記(オーバーロードは土台、実利用は次段)。
- 次段へ送る: [S3](enabled のレベル精緻化)、[S4](`handlePointerDown`/`Up` の lazy 化)。
- 任意・低優先: [S2](`_resolve` に assert)。
