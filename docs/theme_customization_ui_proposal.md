# テーマカスタマイズUI改善案

## 概要

ユーザーがアプリ固有のカラーテーマを作成・指定できるようにするための改善案です。
現在の`core_themes`パッケージは基本的な機能を提供していますが、ユーザーが直感的にカラーテーマを作成・編集するためのUIやAPIが不足しています。

## 改善案

### 1. テーマカスタマイズ画面の追加

テーマカスタマイズ画面を追加し、ユーザーが以下の操作を行えるようにします：

- プリセットテーマの選択
- カスタムテーマの作成
- カラーパレットの編集
- フォント設定の編集
- テーマのプレビュー
- テーマの保存と共有

### 2. カラーパレットエディタ

カラーパレットエディタを追加し、ユーザーが以下の操作を行えるようにします：

- プライマリカラーの選択
- セカンダリカラーの選択
- アクセントカラーの選択
- 背景色の選択
- テキストカラーの選択
- カラーパレットのプレビュー

### 3. アプリ固有カラーエディタ

アプリ固有のカラーエディタを追加し、ユーザーが以下の操作を行えるようにします：

- アクティビティバーの色の選択
- サイドバーの色の選択
- グラフビューの色の選択
- メタデータ表示の色の選択
- 通知の色の選択
- ボーダーの色の選択

### 4. フォント設定エディタ

フォント設定エディタを追加し、ユーザーが以下の操作を行えるようにします：

- UIフォントの選択
- テキストフォントの選択
- コードブロックフォントの選択
- テーブルフォントの選択
- ラベルフォントの選択
- フォントサイズの調整
- フォントウェイトの調整
- 行間の調整

### 5. テーマプレビュー

テーマプレビューを追加し、ユーザーが以下の操作を行えるようにします：

- ライトモードとダークモードの切り替え
- 各UIコンポーネントのプレビュー
- 実際のアプリ画面のプレビュー

### 6. テーマの保存と共有

テーマの保存と共有機能を追加し、ユーザーが以下の操作を行えるようにします：

- テーマの保存
- テーマの名前付け
- テーマのエクスポート
- テーマのインポート
- テーマの共有

## 実装案

### 1. テーマカスタマイズ画面

```dart
class ThemeCustomizationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('テーマのカスタマイズ'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              // テーマを保存
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // テーマを共有
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // 左側: テーマ選択パネル
          Expanded(
            flex: 1,
            child: ThemeSelectionPanel(),
          ),
          // 右側: テーマ編集パネル
          Expanded(
            flex: 3,
            child: ThemeEditPanel(),
          ),
        ],
      ),
    );
  }
}
```

### 2. カラーパレットエディタ

```dart
class ColorPaletteEditor extends StatelessWidget {
  final ColorSchemeConfig colorScheme;
  final Function(ColorSchemeConfig) onColorSchemeChanged;

  const ColorPaletteEditor({
    Key? key,
    required this.colorScheme,
    required this.onColorSchemeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('カラーパレット', style: Theme.of(context).textTheme.headlineSmall),
        SizedBox(height: 16),
        // プライマリカラー
        ColorPickerItem(
          label: 'プライマリカラー',
          color: colorScheme.primary,
          onColorChanged: (color) {
            onColorSchemeChanged(colorScheme.copyWith(primary: color));
          },
        ),
        // セカンダリカラー
        ColorPickerItem(
          label: 'セカンダリカラー',
          color: colorScheme.secondary,
          onColorChanged: (color) {
            onColorSchemeChanged(colorScheme.copyWith(secondary: color));
          },
        ),
        // その他のカラー
        // ...
      ],
    );
  }
}
```

### 3. アプリ固有カラーエディタ

```dart
class AppColorEditor extends StatelessWidget {
  final AppColorConfig appColors;
  final Function(AppColorConfig) onAppColorsChanged;

  const AppColorEditor({
    Key? key,
    required this.appColors,
    required this.onAppColorsChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('アプリ固有カラー', style: Theme.of(context).textTheme.headlineSmall),
        SizedBox(height: 16),
        // アクティビティバー
        ExpansionTile(
          title: Text('アクティビティバー'),
          children: [
            ColorPickerItem(
              label: '背景色',
              color: appColors.activityBarBackground,
              onColorChanged: (color) {
                onAppColorsChanged(appColors.copyWith(activityBarBackground: color));
              },
            ),
            ColorPickerItem(
              label: 'アクティブアイテム',
              color: appColors.activityBarActiveItem,
              onColorChanged: (color) {
                onAppColorsChanged(appColors.copyWith(activityBarActiveItem: color));
              },
            ),
            // その他のカラー
            // ...
          ],
        ),
        // その他のカテゴリ
        // ...
      ],
    );
  }
}
```

## 今後の課題

1. **パフォーマンスの最適化**:
   - カラーピッカーの描画パフォーマンスの最適化
   - テーマプレビューの描画パフォーマンスの最適化

2. **アクセシビリティの向上**:
   - カラーコントラストの自動チェック
   - 色覚異常者向けのカラーパレット提案

3. **テーマの互換性**:
   - 異なるバージョン間でのテーマの互換性の確保
   - テーマのバージョン管理

4. **テーマの共有**:
   - テーマの共有フォーマットの標準化
   - テーマギャラリーの実装

5. **テーマのエクスポート**:
   - 他のアプリケーションとの互換性
   - 一般的なカラーパレットフォーマットへのエクスポート
