# E1 実装レビュー依頼: ログ API のクロージャ受けオーバーロード + ホットパス lazy 化

依頼日: 2026-06-14
対象ブランチ: `feature/redesign`
対象タスク: `doc/design_review_plan.md` の **E1**
レビュー方針: **実装の正しさ・副作用・スコープ妥当性**を確認してほしい。
このファイルの末尾に従い、結果は `doc/review_feedback_20260614_01_E1.md` に書き出してほしい。

---

## 背景

`doc/design_review.md` 課題3(デバッグ計装が本体を侵食、ログ無効時も文字列補間/Map
構築が走る)への対処。計画(`design_review_plan.md` E1)と 3 ラウンドのレビュー
(`design_review_plan_feedback.md`)で確定した**オーバーロード折衷案**を実装した。

方針:
- ログ API を `(LogCategory, Object message)` にし、`String` と `String Function()` の
  両方を受ける。既存の約 268 箇所の `String` 呼び出しは**無改修**のまま。
- クロージャ渡しの場合のみ、カテゴリ有効時に限り評価する。
- ホットパス(毎フレーム/ポインタ毎経路)のうち**最ホットのみ**を今回のスコープとする
  (全箇所一括 lazy 化はスコープ外。ユーザー判断で「最ホットのみ」を選択)。

---

## 変更点

### 1. `lib/src/utils/logger.dart`
- `PloughLogger.enabled(LogCategory)` を追加。`_levels[category]` が `Level.off` 以外かで
  判定(未 `configure` 時は false)。
- トップレベル関数 `logDebug`/`logInfo`/`logWarning`/`logError` を
  `(LogCategory, Object message)` に変更。`_resolve(category, message)` で:
  - `message is String Function()` → `enabled` 時のみ `message()`、無効時 `null` を返し
    ログ呼び出し自体をスキップ。
  - それ以外 → `message as String`。
- `_sendToExternalDebug` の冒頭に `if (!externalDebugClient.enabled) return;` を追加。

### 2. `lib/src/debug/external_debug_client.dart`
- `bool get enabled => _enabled;` を追加(呼び出し側ガード用)。

### 3. `lib/src/interactive/gesture_manager.dart`
- `handlePointerMove`(毎フレーム)の `TAP_DEBUG_STATE` 送出ブロックを
  `if (isGestureDebugEnabled && draggedEntityId != null)` で早期ガード。
  巨大な data map・`getTapStateDebugInfo()`・`DateTime.now().toIso8601String()` が
  毎フレーム構築されるのを防ぐ。

---

## 必ず確認してほしい論点

1. **既存 String 呼び出しの無改修性**
   - `Object message` 化で約 268 箇所が無改修でコンパイル・動作するか。型推論や
     `toString` 経由の意図しない挙動はないか。

2. **クロージャ評価のセマンティクス**
   - 無効カテゴリでクロージャが**一度も評価されない**こと(`_resolve` が `null` を返す経路)。
   - 有効カテゴリで**出力内容が従来と一致**すること(`null` 返しが正常ログを欠落させない)。

3. **`enabled` 判定の正しさ**
   - `_levels` は `configure` 実行時のみ populate される。未設定時に `enabled` が false を
     返すことで、ログがデフォルト無効である従来挙動と矛盾しないか。
   - `Level.off` 以外を「有効」とする判定で、`logger` パッケージのレベル階層
     (trace < debug < ... < fatal < off)と齟齬がないか
     (例: あるカテゴリが `Level.error` のとき `logDebug` のクロージャを評価してしまうが、
     最終的に `Logger` 側で出力は抑制される。**クロージャを無駄評価する**ケースが残る点の
     是非)。

4. **`handlePointerMove` ガードの副作用**
   - ガードで囲ったブロックが**ログ送出専用**であり、`isGestureDebugEnabled` が false でも
     ジェスチャ処理の本筋(drag 継続・hit-test)に影響しないか。
   - ブロック内の `getTapStateDebugInfo()` 等が**状態を読むだけで変更しない**こと
     (副作用がないこと)を確認。これは計画の E1 注意点。

5. **`_sendToExternalDebug` の早期ガード**
   - `sendLog` 内部にも `if (!_enabled) return;` があるため二重ガードになる。呼び出し側
     ガードで logEntry map 構築を確実に回避できているか(意図どおりか)。

6. **スコープの妥当性**
   - 「最ホットのみ」= `handlePointerMove` の1ブロックに限定した判断は妥当か。
     他に毎フレーム/ポインタ毎に走りログ構築が重い経路を見落としていないか
     (`handleMouseHover` はログ無し、`findNodeAt`/`findLinkAt` もログ無しを確認済み)。

---

## 検証状況(実装者報告)

- `flutter analyze`(変更3ファイル): 新規の警告・エラーなし(既存 info のみ)。
- 非 golden テスト 14 ファイル: **全グリーン**(20 passed, 2 skipped)。
- golden 11 件失敗: 変更を `git stash` した**ベースライン(HEAD 4f579bc)でも同じ件数失敗**。
  0.01〜1.36% のピクセル差で、フォント/レンダリングの環境差。E1 は描画に触れないため無関係。
- `dart format --set-exit-if-changed`(変更3ファイル): 0 changes。

→ レビューでは特に **golden 失敗が本当に E1 と無関係か**(描画経路に間接影響がないか)も
  独立に確認してほしい。

---

## 期待する成果物

- 上記 6 論点への所見(問題なし/要修正、根拠付き)。
- 見落とした副作用・回帰リスクがあれば該当 `file:line` 付きで指摘。
- スコープ(最ホットのみ)で十分か、次段で lazy 化すべき経路の提案。

レビュー結果は **`doc/review_feedback_20260614_01_E1.md`** に書き出してほしい。
