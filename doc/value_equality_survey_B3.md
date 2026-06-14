# B3: 値等価性の流儀 棚卸しレポート

調査日: 2026-06-14
ブランチ: `feature/redesign`
対象タスク: `doc/design_review_plan.md` の **B3(値等価性の流儀統一・調査タスク)**
スコープ: **調査のみ**(実コード変更なし)。利用箇所一覧と移行/削除可否の判断を残す。

---

## 背景(レビュー指摘)

`pubspec.yaml` に値等価性まわりのライブラリが 3 つ併存していた:

```yaml
collection: ^1.18.0
equatable: ^2.0.5
fast_immutable_collections: ^11.0.0
freezed_annotation: ^3.1.0
```

「`equatable` 利用箇所を洗い出し、Freezed へ寄せられるか調査」が当初の問い。
実態を grep で棚卸ししたところ、**問いの前提(equatable が値クラスの等価性に使われている)
自体が成立していなかった**。以下に各ライブラリの実利用をまとめる。

---

## 調査結果(grep ベース)

検索対象: `lib/`・`test/`・`example/`(生成物 `*.freezed.dart` / `*.g.dart`、
`build/`、`.dart_tool/` は除外)。

### 1. `equatable` — **実利用 0 件(未使用の直接依存)**

| 検索 | 結果 |
| --- | --- |
| `import 'package:equatable'`(lib) | **0 件** |
| `extends Equatable` / `with EquatableMixin`(lib/test/example) | **0 件** |
| `List<Object?> get props` / `stringify` 等 | **0 件**(`debug_server.dart:512` のヒットは JS の `JSON.stringify`、無関係) |

`pubspec.lock` 上 `equatable` は `dependency: "direct main"`(直接依存・version 2.0.7)で、
**他パッケージの推移的依存ではない**。つまり誰も使っていない直接宣言。

→ **結論: 安全に削除可能。** Freezed への「移行」は不要(そもそも使われていない)。
   削除は依存軽量化に直結し、B1(flame 撤去)と同質の pub 品質改善。

### 2. `fast_immutable_collections`(FIC) — **実利用あり・必要**

| ファイル | 用途 |
| --- | --- |
| `lib/src/graph/graph_data.dart` | `IList` / `IMap` でノード・リンク等の不変コレクション保持 |
| `lib/src/graph/graph_base.dart` | 同上(隣接インデックス等) |

`IList`(24 箇所)・`IMap`(20 箇所)を実利用。これは**コレクションの不変性**という
別目的のライブラリで、値クラスの等価性(equatable/freezed の領分)とは役割が異なる。
Freezed では代替できない。

→ **結論: 維持。** 「等価性の流儀統一」の対象外(コレクション不変性は別レイヤ)。

### 3. `freezed_annotation`(Freezed) — **値クラスの等価性の正規の担い手**

`@freezed` / `@Freezed` 注釈は以下 8 ファイル:

- `lib/src/graph/id.dart`
- `lib/src/graph/graph_data.dart`
- `lib/src/graph_view/data.dart`
- `lib/src/graph_view/geometry.dart`
- `lib/src/renderer/style/link.dart`
- `lib/src/renderer/style/node.dart`
- `lib/src/interactive/tap_state.dart`
- `lib/src/debug/diagnostics.dart`

値クラスの `==`/`hashCode` は Freezed 生成に一本化されている。
graph entities に**手書きの `bool operator ==` / `int get hashCode` は 0 件**で、
独自等価性の流儀が併存している事実はなかった。

→ **結論: 維持(これが単一の流儀)。**

### 4. `collection` — 参考

`pubspec.yaml` に `collection: ^1.18.0`。Flutter/Dart エコシステムで広く使われる
ユーティリティ(`ListEquality` 等)。本調査の主眼(値クラス等価性の重複)とは別で、
今回は調査対象外(必要なら別途棚卸し)。

---

## 判断まとめ

| ライブラリ | 役割 | 実利用 | 判断 |
| --- | --- | --- | --- |
| `equatable` | 値クラス等価性 | **0 件** | **削除可**(未使用の直接依存) |
| `freezed_annotation` | 値クラス等価性(生成) | 8 ファイル | 維持(単一の流儀) |
| `fast_immutable_collections` | コレクション不変性 | `graph_data`/`graph_base` | 維持(目的が別) |
| `collection` | 汎用ユーティリティ | 調査外 | 今回判断なし |

**「流儀統一」は実質すでに達成されている**:値クラスの等価性は Freezed 一本で、
equatable は使われていない。`fast_immutable_collections` は等価性ライブラリではなく
不変コレクションのためのもので、併存は重複ではない。

---

## 実施したアクション

1. **`equatable` を `pubspec.yaml` から削除**(B1 同様の依存軽量化)→ **実施済み**。
   - 手順: `pubspec.yaml` の `equatable: ^2.0.5` 行を削除 → `flutter pub get` →
     `flutter analyze lib/`(新規指摘なし・既存 info のみ)→ 非 golden 全テスト緑(48 passed /
     2 skipped)。`pubspec.lock` からも `equatable` が消えたことを確認。
   - リスク: 低。コンパイル参照が 0 件のため挙動不変。削除前後でテスト結果に差なし。
2. それ以外の移行(FIC → 別物 等)は**不要**。

> 当初 B3 は「調査のみ」の想定だったが、調査の結論が「未使用の直接依存の削除」という
> 低リスクかつ B1 と同質の軽量化であったため、ユーザー合意のうえ本タスク内で削除まで実施した。

---

## 受け入れ基準の充足

- [x] `equatable` 利用箇所の一覧(= 0 件であることの確証)。
- [x] FIC / Freezed の利用箇所と役割の切り分け。
- [x] 移行/削除可否の判断メモ(`equatable` 削除可・他は維持)を `doc/` に記録。
