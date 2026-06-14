# B2: デバッグサーバー群の分離 設計メモ(着手前合意用)

作成日: 2026-06-14
ブランチ: `feature/redesign`
対象タスク: `doc/design_review_plan.md` の **B2(debug 別パッケージ化)**
リスク: **高**(配置方針・公開 API・import グラフに波及)。本メモは**実装前の合意用**。
方針: モノレポ化(`packages/` 下に分割)で確定(ユーザー合意済み)。

---

## ゴール(受け入れ基準・計画より)

- `flutter test -p chrome`(web)で本体が import エラーを出さない
  (= `dart:io` が公開 import グラフから外れる)。
- 本体 `pubspec.yaml` から `http`(可能なら `logger`)が消える。
- デバッグ機能(外部サーバーへのログ送信・監視サーバー)は別パッケージで引き続き使える。

---

## 現状の食い込み(調査で確定)

### `dart:io` / `http` の発生源(本体内 2 ファイルのみ)
- `lib/src/debug/debug_server.dart` … `dart:io`(`PloughMonitorServer`、HTTP サーバー)
- `lib/src/debug/external_debug_client.dart` … `package:http`(`ExternalDebugClient`、
  ログを外部サーバーへ POST。グローバルシングルトン `externalDebugClient`)

### 本体コードが debug 配下を参照する箇所(3 経路)
| 参照元 | 参照先 | 使っている API |
| --- | --- | --- |
| `lib/src/manager.dart:2,164-216` | `debug_manager.dart`(→ `debug_server.dart` で `dart:io`) | `debugManager.isServerRunning` / `serverUrl` / `serverPort` / `generateDebugReport()` |
| `lib/src/utils/logger.dart:98-104` | `external_debug_client.dart`(`http`) | `externalDebugClient.enabled` / `sendLog(category, level, message)` |
| `lib/src/interactive/gesture_manager.dart`(8 箇所: 470/493/594/686/751/772/799/879) | `external_debug_client.dart`(`http`) | `externalDebugClient.sendLog(...)` |

### 公開 export
- `lib/plough.dart` は `src/interactive/gesture_debug.dart` を export(計装の公開面)。
  debug_manager/debug_server/external_debug_client 自体は直接 export していないが、
  `manager.dart` 経由(`plough.dart → manager.dart → debug_manager.dart → debug_server.dart`)で
  **`dart:io` が公開 import グラフに乗る**(計画の問題意識どおり)。

---

## 設計: `DebugSink` インターフェースで注入点を 1 つに

本体には**抽象だけ**を残し、`dart:io`/`http` を持つ実装は別パッケージへ。

### 本体に残すもの(`lib/src/debug/debug_sink.dart` 新設・仮)

```dart
/// Sink for debug telemetry. The package core only knows this interface;
/// the concrete server/HTTP implementation lives in `plough_devtools`.
abstract interface class DebugSink {
  bool get enabled;
  void sendLog({
    required LogCategory category,
    required String level,
    required String message,
  });
  // debug_manager 経由で manager.dart が使う面(サーバー状態・レポート):
  bool get isServerRunning;
  String? get serverUrl;
  int? get serverPort;
  String generateDebugReport();
}

/// Default no-op sink: web-safe, zero deps. Active unless a real sink is
/// attached via Plough().attachDebugSink(...).
class NoopDebugSink implements DebugSink {
  const NoopDebugSink();
  @override bool get enabled => false;
  @override void sendLog({required category, required level, required message}) {}
  @override bool get isServerRunning => false;
  @override String? get serverUrl => null;
  @override int? get serverPort => null;
  @override String generateDebugReport() => '';
}
```

- 本体の `externalDebugClient.sendLog(...)` 呼び出し(logger / gesture_manager)を
  `_debugSink.sendLog(...)` に差し替え。`enabled` ガードはそのまま(無効時ゼロコスト)。
- `manager.dart` の `debugManager.isServerRunning` 等を `_debugSink` の対応 getter に差し替え。
- `Plough().attachDebugSink(DebugSink)` で実装注入(デフォルトは `NoopDebugSink`)。

### 別パッケージ `packages/plough_devtools`(仮)へ移すもの
- `debug_server.dart`(`dart:io`)、`external_debug_client.dart`(`http`)、
  `debug_manager.dart`、`structured_logger.dart`、workbench 連携。
- これらを束ねる `PloughDevtoolsSink implements DebugSink` を提供。
- 利用側(example など)は `Plough().attachDebugSink(PloughDevtoolsSink())` で有効化。

> 注: `performance_monitor.dart` / `diagnostics.*` は `dart:io`/`http` を持たない可能性が高い。
> 移動対象かは実装段階で個別判定(本体に残せるものは残し、移動を最小化)。

---

## モノレポ化の手順(案)

現状は単一パッケージ(`plough` がリポジトリ直下)。これを分割する。

1. `packages/plough/`(本体)と `packages/plough_devtools/`(デバッグ)を作る。
   - リポジトリ直下に **pub workspace**(`pubspec.yaml` の `workspace:`、Dart 3.5+ 対応)を
     置くか、`melos` を使うか、シンプルに **path 依存**で繋ぐかを決める。
   - example は `packages/plough` と `packages/plough_devtools` を path 参照。
2. 本体から debug 実装ファイルを `plough_devtools` へ移動し、`DebugSink`/`NoopDebugSink` を本体に新設。
3. 本体の 3 経路(logger / gesture_manager / manager)を `DebugSink` 経由に差し替え。
4. 本体 `pubspec.yaml` から `http`(可能なら `logger`)を削除。`plough_devtools` 側へ移す。
5. `flutter test`(本体)/ `flutter test -p chrome`(web import 安全)/ example ビルドで検証。

### 段階分け(リスク低減のため小さく刻む)
- **B2-a**: 本体内で `DebugSink`/`NoopDebugSink` を導入し、既存の `externalDebugClient`/
  `debugManager` を **`DebugSink` 実装でラップ**して注入点を 1 つに集約(まだ移動しない・
  まだ web 安全にならない・挙動不変)。← ここまでは単一パッケージ内で完結・低〜中リスク。
- **B2-b**: モノレポ化してファイルを `plough_devtools` へ移動、本体 pubspec から http 除去
  (web 安全達成)。← ディレクトリ移動・pubspec 再編で中〜高リスク。

> B2-a だけ先に入れて B2-b を別 PR にすると、注入点集約の正しさ(挙動不変)を
> 移動前に検証でき、移動 PR は「import パスの付け替えだけ」に純化できる。

---

## 決定事項

- **段階分け**: B2-a(注入点集約・単一パッケージ内・挙動不変)→ B2-b(モノレポ移動・http 除去)
  の 2 段階で進める(合意済み)。
- **モノレポの繋ぎ方**: **Dart pub workspace**(`workspace:`)を採用。melos は不要
  (2 パッケージ規模では多数パッケージのブートストラップ/連動リリースの利点が活きず、
  スクリプト集約は既存 Makefile で充足)。実 SDK は Dart 3.11.5 で workspace 利用可。
  確定の実施は **B2-b 着手時**でよい(B2-a は単一パッケージ内のため不要)。

## 未決事項(B2-b 着手時に確定)
2. **`logger` 依存の扱い**: `logger`(コンソール整形)は本体ログでも使われている可能性。
   本体に残すか devtools へ寄せるか(B2 の受け入れ基準は「可能なら」)。実装時に利用箇所確認。
3. **公開 API の互換**: 現状 example/利用者が `Plough().enableExternalDebug(...)` 等の
   API を直接呼んでいるか。呼んでいれば `attachDebugSink` への移行で**破壊的変更**になる。
   → `plough.dart` の公開デバッグ API を棚卸しして、後方互換の必要性を判断する(次の調査)。
4. **段階 PR の粒度**: B2-a / B2-b を分けるか一括か。

---

## 提案

- **まず B2-a(注入点集約・単一パッケージ内・挙動不変)を実装**し、別セッションレビューに出す。
- B2-b(モノレポ移動)は B2-a 承認後、繋ぎ方(未決事項 1)を確定してから着手。
- これは運用ルール「セーフティネット先行・小さいコミット粒度」と、計画の「段階的」方針に沿う。
