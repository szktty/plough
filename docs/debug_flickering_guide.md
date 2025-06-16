# ちらつき問題デバッグガイド

## 問題の概要
Gesture Passthrough Demoでノードをタップやドラッグした際にグラフがちらつく問題があります。

## デバッグログの確認方法

### 1. サンプルアプリの起動
```bash
cd example
flutter run -d macos
```

### 2. Gesture Passthrough Demoページに移動
アプリのメニューから「Gesture Passthrough Demo」を選択

### 3. テストシナリオ
1. **nodeEdgeOnly**モードが選択されていることを確認
2. ノードをクリック/タップする
3. ノードをドラッグする
4. 背景をクリック/ドラッグする

### 4. ログの確認ポイント

#### A. バックグラウンドコールバックの呼び出し
以下のログを探してください：
- `[GESTURE] handlePanStart: Calling background callback` - 背景コールバックが呼ばれている
- `[GESTURE] handlePanStart: Skipping background callback` - 背景コールバックがスキップされている
- `[GESTURE] handlePanUpdate: Calling background callback`
- `[GESTURE] handlePanEnd: Calling background callback`

**期待される動作**: nodeEdgeOnlyモードでノードを操作した時は「Skipping」が表示されるべき

#### B. Demo画面のsetState呼び出し
以下のログを探してください：
- `[DEMO] onBackgroundTapped called`
- `[DEMO] onBackgroundPanStart called`
- `[DEMO] onBackgroundPanUpdate called`
- `[DEMO] onBackgroundPanEnd called`
- `[DEMO] setState called from _scheduleUpdate`
- `[DEMO] setState from onBackground*`

**期待される動作**: ノード操作時にはこれらのログが出力されないべき

#### C. GraphViewの更新
以下のログを探してください：
- `[GRAPHVIEW] PostFrameCallback in initialize phase`
- `[GRAPHVIEW] PostFrameCallback in performLayout phase`

### 5. 問題の特定

#### ケース1: ノード操作時にバックグラウンドコールバックが呼ばれている
- `[GESTURE]`ログで「Calling background callback」が出力される
- その後`[DEMO]`ログでsetStateが呼ばれる
→ GraphGestureManagerの問題

#### ケース2: バックグラウンドコールバックは呼ばれていないがちらつく
- `[GRAPHVIEW]`ログが頻繁に出力される
→ GraphView自体の再描画問題

#### ケース3: 特定の操作でのみちらつく
- ドラッグ中のみちらつく場合は`handlePanUpdate`の問題
- タップ時のみの場合は`handlePointerDown/Up`の問題

## トラブルシューティング

### 1. ログが多すぎる場合
```bash
flutter run -d macos | grep -E "\[GESTURE\]|\[DEMO\]|\[GRAPHVIEW\]"
```

### 2. 特定の操作のログだけ見たい場合
例：ノードドラッグ時のログ
```bash
flutter run -d macos | grep -E "handlePan|setState"
```

### 3. スタックトレースを確認したい場合
Demo画面のsetState呼び出し時にスタックトレースが出力されるので、
どこから呼ばれているか確認できます。

## 修正確認方法

1. nodeEdgeOnlyモードでノードをタップ/ドラッグ
   - バックグラウンドコールバックが呼ばれない
   - Demo画面のsetStateが呼ばれない
   - ちらつかない

2. nodeEdgeOnlyモードで背景をタップ/ドラッグ
   - バックグラウンドコールバックが呼ばれる
   - Demo画面のsetStateが呼ばれる
   - これは正常動作

3. exclusiveモードでの動作
   - すべての操作でバックグラウンドコールバックが呼ばれる
   - これも正常動作