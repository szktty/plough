# B2-a: debug ログ経路の DebugSink 集約 実装レビュー結果

レビュー日: 2026-06-14
レビュー対象: コミット `493f209`(`feature/redesign`)
依頼元: `doc/review_request_20260614_05_B2a.md`

## 総評

**承認(approve)**。注入点の導入は挙動不変で、`externalDebugClient` への委譲は
metadata 含め一字一句保たれている。8 箇所の置換も純粋な識別子変更のみ。B2-b への
布石として面の切り分け・委譲構造は十分。下記の **要修正 1 件(doc リンク切れ)** は
dartdoc 上の軽微な不整合で、挙動には影響しない。

検証実施:
- `test/debug_sink_test.dart` 3 件 green(手元実行)。
- `git show` で gesture_manager 8 箇所 + logger 2 箇所が **識別子置換のみ**(引数・
  `metadata:`・enabled ガードすべて不変)であることを確認。
- `grep -rn externalDebugClient lib/`: 定義(`external_debug_client.dart:152`)と
  委譲(`debug_sink.dart` の 3 行)のみ。本体ロジックからの直参照 **0 件**。
- `ExternalDebugClient.sendLog` と `DebugSink.sendLog` のシグネチャ完全一致を確認
  (`category`/`level`/`message`/`metadata`)。

---

## 論点ごとの所見

### 1. 挙動不変 — 問題なし

- `ExternalClientDebugSink.sendLog`(`debug_sink.dart:49-61`)は引数 4 つを
  そのまま `externalDebugClient.sendLog` へ素通し。`metadata` も透過。
- **バッチングは ExternalDebugClient 内に完全に残存**(`_batchSize`/`_batchInterval`/
  `_flushLogs`、`external_debug_client.dart:60-99`)。sink は薄い委譲のみで
  キュー投入・即時フラッシュ閾値に一切触れないため、送信タイミングは不変。
- `logger._sendToExternalDebug` の `enabled` 早期ガード(`logger.dart:98`)は
  `debugSink.enabled` に置換されただけで維持。disabled 時にペイロードを組まない
  最適化も保たれる。
- gesture_manager 8 箇所(470/493/594/686/751/772/799/879)は `externalDebugClient`
  → `debugSink` の識別子置換のみ。`category`/`level`/`message`/`metadata` の
  各リテラルは diff 上で完全一致。WARNING レベル(772)も保持。

### 2. 注入点の妥当性 — 問題なし(将来注意点 1 件)

- `@internal DebugSink debugSink = const ExternalClientDebugSink();`
  (`debug_sink.dart:68-69`)。`@internal` でパッケージ外へ漏れない。
- B2-b で `Plough().attachDebugSink(...)` セッターへ発展させる土台として十分。
  可変グローバル → `Plough` のフィールド/セッター化は呼び出し側(`debugSink.xxx`)を
  アクセサ経由に差し替えるだけで済む。
- テストが `setUp`/`tearDown` で `debugSink` を退避・復元しており
  (`debug_sink_test.dart:32-43`)、グローバル可変によるテスト間汚染を防いでいる。良い。
- 将来注意点(B2-a 修正不要): 可変トップレベル変数は **並行/複数 isolate** や
  `test/concurrency` で競合しうる。B2-b で `Plough` シングルトンのフィールドに
  寄せる際、スレッド/isolate 境界の前提を design メモに一言残すと安全。

### 3. DebugSink の面の最小性 — 問題なし

- 本体が使う `enabled` / `sendLog` のみに絞り、`setServerUrl`/`enable`/`disable`/
  `testConnection`/`getServerInfo` を `external_debug_client` 側に残した切り分けは妥当。
  これらは本体ロジック非依存(debug UI/サーバー制御用)で、B2-b の移動を阻害しない。
  むしろ DebugSink を最小に保つことで no-op 実装が `enabled=>false` と空 `sendLog`
  だけで済み、B2-b の web 安全化がきれいになる。

### 4. 依存の整理状況 — 問題なし

- `externalDebugClient` 直参照が `debug_sink.dart` の委譲 1 箇所に集約された。
- `http`/`dart:io` を B2-a では残し B2-b で除去する線引きは妥当。B2-a は
  「単一パッケージ内・挙動不変の集約」というスコープ定義に忠実。

### 5. スコープ — 問題なし

- `manager.dart` の `dart:io` サーバー経路を B2-b へ送る判断は妥当。これは
  `manager.dart` 内に閉じており sendLog 経路とは別系統。
- 注入点が 2 系統(sink=ログ送信 / server=制御)に分かれる懸念について: 現状は
  ログ **送信** だけを抽象化すればよく、server 制御は本体非依存なので 1 系統で十分。
  B2-b で server 側も別 IF/パッケージへ寄せる前提が design メモに明記されており、
  この段階での 2 系統化は過剰。絞り込みは正しい。

---

## 要修正(軽微・dartdoc のみ)

- **`debug_sink.dart:11` の `[defaultDebugSink]` は存在しない識別子**。実際の
  グローバルは `debugSink`(同ファイル 69 行)、デフォルト実装クラスは
  `ExternalClientDebugSink`。このままだと dartdoc のリンクが解決されず壊れる。
  `[debugSink]` もしくは `[ExternalClientDebugSink]` に修正を。挙動影響なし。

## 任意フォローアップ(優先度低)

- `debug_sink_test.dart` は `metadata` を記録・assert していない(注入点機能の
  検証に絞った設計で妥当)。B2-b で no-op 化する前に「metadata が委譲先へ透過する」
  1 ケースを足しておくと、将来 sink 実装を差し替えた際の回帰検知になる。必須ではない。

## 結論

doc の識別子リンク 1 箇所(`debug_sink.dart:11`)を直せばそのままマージ可。
挙動不変(委譲・metadata・バッチング・enabled ガード)は満たされており、
面の最小化・スコープの絞り込みは B2-b への布石として適切。
