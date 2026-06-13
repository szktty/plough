# E1 ログ計装方式の決定記録

決定日: 2026-06-14
対象タスク: E1(ログの lazy 化・ホットパス計装除去)
関連: `doc/design_review.md`(課題3)、`doc/design_review_plan.md`(E1)、
`doc/design_review_plan_feedback.md`(10. E1 の実装方式)

このファイルは E1 の実装方式について行った検討と最終決定を独立して記録するもの。
計画・フィードバック側からは本ファイルを参照する。

> **ステータス: 実装済み(2026-06-14, commit 2d6c4c0)**。本 ADR の決定どおり実装した。
> 差異・補足:
> - `enabled` 判定は留意点で「getter 無し」とあったが、実装では
>   **`PloughLogger.enabled(LogCategory)`**(`_levels[category] != Level.off`)を追加して解決。
> - オーバーロードは ADR の三項演算子 1 行ではなく、`_resolve(category, message)` ヘルパに
>   切り出し、**無効カテゴリではログ呼び出し自体をスキップ**(空文字 `''` を渡さず `null`
>   返しで早期 return)する形にした。出力に空ログが混じらない。
> - ホットパスは `handlePointerMove`(毎フレーム)の `TAP_DEBUG_STATE` ブロックを
>   `isGestureDebugEnabled` で早期ガード。`handlePointerDown`/`Up` 等のポインタ毎経路の
>   `() =>` 化は**スコープ外**(ユーザー判断で「最ホットのみ」)とし、以降のタスクへ。
> - `sendLog` の引数 Map 構築は `_sendToExternalDebug` 冒頭で
>   `externalDebugClient.enabled` ガード。
> 実装レビュー依頼は `doc/review_request_E1.md`(結果は `doc/review_feedback_E1.md`)。

---

## 背景

`gesture_manager.dart`(1722 行)の過半がログとデバッグメタデータ構築で、
`logDebug(cat, '...${id.value.substring(0,4)}...')` はログ無効時も毎回文字列補間を
実行する。ポインタイベント毎・ドラッグ中は毎フレーム走るため、無効時のコストを
ゼロにしたい、というのが課題3 → E1 の動機。

現状(`lib/src/utils/logger.dart:100-110`):

- `logDebug`/`logInfo`/`logWarning`/`logError` は `(LogCategory, String message)` の
  **String 固定シグネチャ**。
- lib 全体から **273 箇所**(`logGestureDebug` 含む)呼ばれている。
- `externalDebugClient.sendLog(metadata: {...})` は `_enabled` チェックが関数内のため、
  **引数 Map は無効時も構築される**。

---

## 検討した案

### 案A: ログ API を `String Function()`(lazy)に変更

- 273 箇所すべてに `() =>` を付与する。

### 案B: 呼び出し側ホットパスを `if (enabled)` でガード

- `gesture_manager.dart` の `handlePointerDown`/drag 等、毎フレーム経路に限定。

---

## 「重さ」を 2 軸に分けた評価

当初「案A は実行が重くなるのでは」という懸念があったが、**ランタイムコストと改修コストを
分けると評価が逆転する**。

| 観点 | 案A(API を lazy 化) | 案B(ホットパス限定ガード) |
|---|---|---|
| ランタイム(ログ無効時) | ◎ 全 273 箇所で文字列構築ゼロ | ○ ホットパスのみゼロ、他は据え置き |
| 改修範囲 | 大(273 箇所に `() =>` 付与) | 小(gesture_manager 中心の数十箇所) |
| diff/レビュー負荷 | 大 | 小 |
| 回帰リスク | 機械的だが箇所多 | 限定的 |

### ランタイムでは案A は重くならない(懸念は杞憂)

- Dart のクロージャは**何もキャプチャしなければ static 化**され、毎回のアロケーションは
  発生しない。キャプチャがあっても小さなオブジェクト 1 つ。
- 回避できる文字列構築(`substring`/`map`/`join`/`DateTime.now().toIso8601String()` 等)の
  コストの方が桁違いに大きい。
- `logDebug` 内で `if (enabled) message()` とすれば、**無効時にクロージャ本体は一切
  実行されない**。

→ **重いのは実行時ではなく改修コスト(273 箇所)**。これが E1 の「即効・低リスク」という
位置づけと噛み合わない、というのが案B を推していた唯一の理由。ランタイム性能の懸念ではない。

---

## 決定: 折衷案(オーバーロードで段階移行)

`Object message` で `String` と `String Function()` の両方を受けるオーバーロードを採用する:

```dart
void logDebug(LogCategory category, Object message) =>
    _logger.d(
      category,
      message is String Function() ? (enabled ? message() : '') : message,
    );
```

### 効果

- **既存 273 箇所は無改修のまま動く**(String をそのまま渡せる)。
- **ホットパス(`gesture_manager` の `handlePointerDown`/drag 等、毎フレーム経路)だけ
  `() => '...'` に書き換える** → そこだけ無効時の文字列構築がゼロになる。
- 案A のランタイム利点を、案B の小さな改修範囲で段階的に取り込める。
- 将来、残りの呼び出しも順次 lazy 化すれば最終的に案A 相当に到達できる。

### E1 のスコープ(確定)

- ログ API に**クロージャ受けオーバーロードを追加**。
- **ホットパスのみ `() =>` 化**(gesture_manager 中心)。
- `externalDebugClient.sendLog(metadata: {...})` の引数 Map 構築は
  **`if (enabled)` ガードを `sendLog` の外(呼び出し側)に出す**。
- 全 273 箇所の一括 lazy 化は**対象外**(以降のタスクで段階的に)。

### 実装後の補足(実装レビュー [S1] 反映, 2026-06-14)

E1 が実際に行ったのは **(1) クロージャ受けオーバーロード API の導入(土台)**と
**(2) 最ホット 1 経路(`handlePointerMove` の `TAP_DEBUG_STATE` ブロック)の
`isGestureDebugEnabled` 前置ガード**、および **(3) `_sendToExternalDebug` の
呼び出し側 enabled ガード**である。

- 今回の実ランタイム改善は (2)(3) によるもの。**(2) は `logGestureDebug` のガードであり、
  新オーバーロード API は経由しない。**
- 追加したオーバーロードに**クロージャ(`() =>`)を渡している呼び出しは現時点で 0 件**
  (lib 全体)。オーバーロードは「次段でクロージャ渡しを増やすための土台」であり、
  E1 時点では実利用がない。これは段階移行の設計判断であって欠陥ではない。
- 次段(別タスク)で `handlePointerDown`/`handlePointerUp` の `sendLog`/`logGestureDebug`
  などにクロージャ渡しを導入していく([S4])。その際 `enabled` 判定を
  `logDebug` ならレベル `debug` 以上かまで見る精緻化も検討する([S3])。

詳細は `doc/review_feedback_E1.md` を参照。

---

## E1 の受け入れ基準

- ログ API にクロージャ受けオーバーロードを追加し、**既存 String 呼び出しが無改修で
  コンパイル・動作する**こと。
- ホットパスの `() =>` 化対象が「ポインタ/フレーム毎に走る経路」に限定されていることを
  レビューで確認。
- ガード式・移動した引数式が **状態を変更しない(読み取りのみ)** ことを確認
  (`_nodeTapManager.states` 走査・`getTapStateDebugInfo()` 等が引数式に紛れているため)。
- ログ有効時の出力内容が従来と一致(ガード/オーバーロードが出力を欠落させない)。
- `flutter analyze` 無警告・`flutter test` グリーン・`dart format --set-exit-if-changed .` 0。

---

## 留意点

- `enabled` 判定は現状 `PloughLogger` 内部に閉じており(`Level` ベース)、公開された
  bool getter は無い。オーバーロード実装時に `enabled` 相当を `logger.dart` 内で
  参照できるようにする(カテゴリ別 `Level` を見るか、簡易フラグを設ける)。
- 本決定は E1 に閉じる。全面 lazy 化(残り呼び出しの `() =>` 化)を行うかは E1 完了後に
  別途判断する。
