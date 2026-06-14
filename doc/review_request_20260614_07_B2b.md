# B2-b: debug サーバー群の plough_devtools 分離 実装レビュー依頼

依頼日: 2026-06-14
対象ブランチ: `feature/redesign`
対象コミット:
- `b9c6ead`(refactor(debug): route Plough debug server through injectable DebugBackend — B2-b stage 1)
- `8a56176`(refactor(debug)!: split debug server stack into plough_devtools — B2-b stage 2)
対象タスク: `doc/design_review_plan.md` の **B2**(B2-a に続く分離本体)
関連設計メモ: `doc/b2_debug_separation_design.md`
レビュー方針: **web 安全性の達成・公開 API 後方互換・分離境界の妥当性・破壊的変更の扱い**。
結果は末尾の指定先に書き出してほしい。

---

## 背景

`plough` 本体の公開 import グラフに `dart:io`(`debug_server.dart`)と `http`
(`external_debug_client.dart`)が乗り、web 安全性・依存の軽さを損なっていた。これらは
**デバッグサーバー群専用**で本番描画には不要。B2-a で `DebugSink`(ログ送信)の注入点を
導入済み。本タスクで残りを分離する。

**方針(ユーザー合意)**: ディレクトリの大規模モノレポ移動(`packages/` 化)はせず、
同一リポジトリ内に `devtools/`(別 pubspec パッケージ `plough_devtools`)を作り、
debug 実装をそこへ移動。本体はデフォルト no-op + 公開注入 API。pub workspace 化は別タスク。

---

## 変更点

### stage 1(`b9c6ead`・単一パッケージ内・挙動不変)
- `lib/src/debug/debug_backend.dart` 新設: `DebugBackend` 抽象 + `DebugManagerBackend`
  (既存 `debugManager` へ委譲)+ 可変グローバル `debugBackend`。
- `manager.dart` の `debug_manager.dart` 直 import を撤去し、`debugBackend` 経由に
  (`initialize`/`shutdown`/`isServerRunning`/`serverUrl`/`serverPort`/`generateDebugReport`)。
- セーフティネット `test/debug_backend_test.dart`。

### stage 2(`8a56176`・分離・web 安全化・**破壊的変更**)
- **本体 `lib/src/debug/`**: 抽象だけ残す。`DebugSink`/`DebugBackend` の `@internal` を外し
  public 化、デフォルトを `NoopDebugSink`/`NoopDebugBackend`(web 安全・無依存)に。
- **本体 `Plough`**: `attachDebugSink(DebugSink)` / `attachDebugBackend(DebugBackend)` /
  `detachDebug()` を public 追加。
- **本体 export**(`plough.dart`): `DebugSink`/`NoopDebugSink`/`DebugBackend`/
  `NoopDebugBackend` と、ログ関数 `logDebug`/`logInfo`/`logWarning`/`logError` を export
  (devtools が implement/使用するため `@internal` を外した)。
- **本体 `pubspec.yaml`**: `http` 削除(`json_annotation` は `id.dart` がまだ使うので残す)。
- **新パッケージ `devtools/`(`plough_devtools`)**: `debug_server`(dart:io)/
  `external_debug_client`(http)/`debug_manager`/`structured_logger`/
  `performance_monitor`/`diagnostics`(+freezed/g)を `git mv` で移動(履歴追跡可)。
  - `ExternalClientDebugSink`(`DebugSink` 実装)/`DebugManagerBackend`(`DebugBackend` 実装)。
  - `attachPloughDevtools()` / `detachPloughDevtools()` が `Plough().attachDebugSink/Backend`
    経由で注入。`plough_devtools.dart` がエントリ。
  - `devtools/pubspec.yaml`(`plough` を path 依存、`http`/`logger`/`freezed`)、
    `analysis_options.yaml`(very_good ^10)、smoke test `test/attach_test.dart`。

---

## 必ず確認してほしい論点

1. **web 安全性の達成**: 本体 `lib/` に `dart:io`/`http` の実 import が無い
   (残るのは doc コメント内の `` `dart:io` `` 表記のみ)。`flutter test --platform chrome` で
   本体コンパイルが通る(exit 0)。この担保で十分か、他に web で割れる経路がないか。
2. **公開 API 後方互換と破壊的変更**: `Plough().initializeDebugFeatures()` 等の API は
   **シグネチャ不変**だが、デフォルトが no-op になったため**呼んでも何も起きない**
   (devtools を attach しない限り)。これを破壊的変更として CHANGELOG/メジャー扱いする
   方針で良いか。example は debug 未使用なので影響なし。
3. **`@internal` を外した範囲の妥当性**: `DebugSink`/`DebugBackend`/`Noop*` と
   ログ関数 4 つ(`logDebug`/`logInfo`/`logWarning`/`logError`)を public 化した。
   ログ関数の公開は本体 API 面を広げるが、devtools が本体ログへ流すために必要。
   過剰公開でないか(別案: devtools 専用の薄い公開ログ IF に絞る等)。
4. **注入点の安全性**: 可変グローバル `debugSink`/`debugBackend` は `@internal` のままで、
   差し替えは `Plough().attach*`/`detach*` 経由のみ。並行/isolate 前提は設計メモに記載済み
   ([[B2-a レビュー指摘]])。この公開境界で漏れがないか。
5. **分離境界**: 移動した 6 ファイルは本体(debug 配下以外)から参照ゼロだったことを確認済み。
   `diagnostics`(@freezed, part ファイル)を devtools へ移しても part 解決が壊れないこと
   (相対 part 宣言なので同一ディレクトリ移動で維持)。
6. **devtools の lint**: error/warning 0、info 54 件(cascade_invocations/discarded_futures
   等、移動した既存コード由来)。本体方針(info 許容)に合わせた判断で良いか。

---

## 検証状況(実装者報告)

- 本体 `grep -rn "package:http" lib/`: 0、`dart:io` 実 import 0(コメントのみ)。
  `pubspec.yaml`/`pubspec.lock` から `http` 消失。
- 本体 `flutter analyze lib/`: error 0、warning は既存 `unnecessary_cast`(graph.dart、無関係)のみ。
- `flutter test --platform chrome`(本体): Web SDK DL 後コンパイル通過、exit 0。
- 本体非 golden テスト: 62 passed / 2 skipped。golden: 11 failed(ベースライン同一・描画不変)。
- devtools: `flutter analyze` error/warning 0(info のみ)、`test/attach_test.dart` 緑。
- `dart format --set-exit-if-changed`(本体・devtools とも): 0。

---

## 期待する成果物

- 6 論点への所見(問題なし/要修正、根拠付き)。
- web 安全性・破壊的変更の扱いに見落としがあれば `file:line` 付きで。
- 公開面(ログ関数の public 化)の是非。
- 段階(stage 1 抽象導入 → stage 2 分離)の粒度の妥当性。

レビュー結果は **`doc/review_feedback_20260614_07_B2b.md`** に書き出してほしい。
