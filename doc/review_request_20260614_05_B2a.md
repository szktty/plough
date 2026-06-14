# B2-a: debug ログ経路の DebugSink 集約 実装レビュー依頼

依頼日: 2026-06-14
対象ブランチ: `feature/redesign`
対象コミット:
- `493f209`(refactor(debug): route core logging through injectable DebugSink — B2-a)
対象タスク: `doc/design_review_plan.md` の **B2** の第1段階(B2-a)
関連設計メモ: `doc/b2_debug_separation_design.md`
レビュー方針: **挙動不変性・注入点設計の妥当性・B2-b への布石として十分か**。
結果は末尾の指定先に書き出してほしい。

---

## 背景

B2 は「デバッグサーバー群(`dart:io`/`http`)を本体から分離し、本体を web 安全・
依存軽量にする」高リスクタスク。リスク低減のため **2 段階**に分割した(合意済み):

- **B2-a(本コミット)**: 本体内で `DebugSink` 注入点を導入し、ログ送信経路を 1 箇所に
  集約する。**単一パッケージ内・挙動不変**。デフォルト実装は既存 `externalDebugClient` へ委譲。
- **B2-b(別タスク)**: モノレポ(Dart pub workspace)化して `debug_server`/
  `external_debug_client` を `plough_devtools` へ移動、本体 `pubspec.yaml` から `http` 除去、
  デフォルトを no-op 化(web 安全達成)。

調査で確定した本体への食い込みは 3 経路:
`logger.dart`(http)/ `gesture_manager.dart`(http, 8 箇所)/ `manager.dart`(dart:io)。
**B2-a のスコープは http の sendLog 経路(logger + gesture_manager)の集約のみ**(合意済み)。
`manager.dart` の `dart:io` サーバー経路は `manager.dart` 内に閉じており B2-b でまとめて扱う。

---

## 変更点

### 新設 — `lib/src/debug/debug_sink.dart`
- `@internal abstract interface class DebugSink`: `enabled` / `sendLog({category, level,
  message, metadata})` の最小面(本体が実際に使う面のみ)。
- `ExternalClientDebugSink implements DebugSink`: 既存 `externalDebugClient` へ委譲する
  デフォルト実装。`metadata` も透過。
- `DebugSink debugSink = const ExternalClientDebugSink();`: 差し替え可能なグローバル注入点。

### `lib/src/utils/logger.dart`
- import を `external_debug_client.dart` → `debug_sink.dart` に変更。
- `_sendToExternalDebug` の `externalDebugClient.enabled`/`.sendLog(...)` を
  `debugSink.enabled`/`.sendLog(...)` に変更(enabled ガードは維持)。

### `lib/src/interactive/gesture_manager.dart`
- import を `external_debug_client.dart` → `debug_sink.dart` に変更。
- `externalDebugClient.sendLog(...)` 8 箇所(470/493/594/686/751/772/799/879)を
  `debugSink.sendLog(...)` に置換。**`metadata:` 引数はそのまま維持**。

### テスト — `test/debug_sink_test.dart`(新規)
- 差し替えた `DebugSink` が `logDebug` 由来のログを受け取る(注入点が機能する)。
- `enabled=false` の sink には届かない(ガードのショートサーキット)。
- デフォルトが `ExternalClientDebugSink` であること。

---

## 必ず確認してほしい論点

1. **挙動不変**: デフォルト `ExternalClientDebugSink` が `externalDebugClient` へ
   そのまま委譲しており、`metadata` も含め送信内容・タイミング(バッチング)が変わらないこと。
   `gesture_manager` 8 箇所の置換が `sendLog` の引数(`metadata` 含む)を一字一句保っているか。
2. **注入点の妥当性**: `debugSink` を可変グローバルにした設計。`@internal` でパッケージ外へ
   漏れないこと。B2-b で `Plough().attachDebugSink(...)` に発展させる土台として十分か
   (グローバル変数 → セッター/フィールド化の余地)。
3. **DebugSink の面の最小性**: 本体が使うのは `enabled` と `sendLog` のみ。
   `setServerUrl`/`enable`/`disable`/`testConnection`/`getServerInfo` 等は本体非依存で
   `external_debug_client` 側に残した。この切り分けが B2-b の移動を阻害しないか。
4. **依存の整理状況**: `grep -rn external_debug_client lib/` が `debug_sink.dart` の
   1 箇所(デフォルト実装の委譲)のみになったこと。`http`/`dart:io` はまだ本体に残る
   (B2-a は集約のみで除去は B2-b)という線引きが妥当か。
5. **スコープ**: `manager.dart` の `debugManager`(dart:io)経路を B2-a に含めず B2-b へ
   送った判断。B2-a を sendLog 経路に絞ったことで、注入点が 2 系統(sink と server)に
   分かれる懸念はないか(B2-b で server 側も DebugSink/別 IF に寄せる前提)。

---

## 検証状況(実装者報告)

- `grep -rn "externalDebugClient" lib/`: `external_debug_client.dart`(定義)と
  `debug_sink.dart`(委譲)のみ。本体ロジックからの直参照は 0 件。
- `flutter analyze`(変更 3 ファイル): 新規 error/warning なし(残る info は既存・スコープ外)。
- `dart format --set-exit-if-changed lib/ test/`: 0 changes。
- 非 golden テスト(全 49+2skip): 緑。新規 `debug_sink_test.dart` 3 件緑。
- golden: 16 passed / 11 failed で **B1 時点のベースライン(11 failed)と同一**。
  B2-a はログ送信経路のみで描画に一切関与しないため失敗集合は不変。

---

## 期待する成果物

- 5 論点への所見(問題なし/要修正、根拠付き)。
- 挙動不変の追検証観点(送信内容・バッチング・metadata の保存)。
- B2-b(モノレポ移動・http 除去・no-op 化)に向けて、この注入点設計で
  詰まる点があれば `file:line` 付きで。
- スコープ・粒度(2 段階分割、sendLog 経路への絞り込み)の妥当性。

レビュー結果は **`doc/review_feedback_20260614_05_B2a.md`** に書き出してほしい。
