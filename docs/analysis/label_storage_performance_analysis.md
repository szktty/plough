# ラベルストレージ性能分析

## 想定データ規模

### 基本想定
- **エンティティ数**: 100,000
- **ラベル数**: 1,000〜5,000
- **平均ラベルメタデータサイズ**: 200バイト

### ファイルサイズ推定

```
1,000ラベル: 200KB
3,000ラベル: 600KB  
5,000ラベル: 1MB
10,000ラベル: 2MB
```

## ストレージ方式比較

### 1. JSONファイル方式

#### メリット
- **人間可読性**: テキストエディタで直接編集可能
- **デバッグ容易性**: 内容を直接確認可能
- **バックアップ簡単**: テキストファイルとして管理
- **Git管理**: バージョン管理が容易
- **実装シンプル**: 標準ライブラリで処理可能

#### デメリット
- **全体読み込み**: 部分更新時も全体をメモリに読み込み
- **パース時間**: JSON解析のオーバーヘッド
- **メモリ使用量**: 全データをメモリに保持

#### 性能測定（推定値）

```dart
// 5,000ラベル（1MB）の場合
読み込み時間: 10-50ms
パース時間: 5-20ms
メモリ使用量: 2-5MB（オブジェクト展開後）
保存時間: 20-100ms
```

### 2. SQLite方式

#### メリット
- **部分読み込み**: 必要なラベルのみ取得可能
- **インデックス**: 高速検索が可能
- **トランザクション**: データ整合性保証
- **スケーラビリティ**: 大量データに対応

#### デメリット
- **複雑性**: スキーマ管理、マイグレーション
- **可読性**: バイナリファイルで内容確認困難
- **オーバーヘッド**: 小規模データでは過剰

#### 性能測定（推定値）

```dart
// 5,000ラベルの場合
単一ラベル読み込み: 1-5ms
全ラベル読み込み: 5-20ms
検索（インデックス使用）: 1-3ms
挿入/更新: 1-10ms
```

### 3. ハイブリッド方式

#### 設計
- **メタデータ**: JSONファイル（名前、説明、色など）
- **統計情報**: RinneGraphから動的取得
- **キャッシュ**: メモリ内で管理

#### メリット
- **最適化**: 用途に応じた最適なストレージ
- **リアルタイム**: 統計情報は常に最新
- **シンプル**: メタデータ管理は簡単

## 実測ベンチマーク設計

### テストケース

```dart
class LabelStorageBenchmark {
  static Future<void> runBenchmarks() async {
    await _testJsonPerformance();
    await _testSqlitePerformance();
    await _testHybridPerformance();
  }
  
  static Future<void> _testJsonPerformance() async {
    final labels = _generateTestLabels(5000);
    
    // 保存性能
    final saveStart = DateTime.now();
    await _saveToJson(labels);
    final saveTime = DateTime.now().difference(saveStart);
    
    // 読み込み性能
    final loadStart = DateTime.now();
    final loadedLabels = await _loadFromJson();
    final loadTime = DateTime.now().difference(loadStart);
    
    // 検索性能
    final searchStart = DateTime.now();
    final results = _searchLabels(loadedLabels, 'test');
    final searchTime = DateTime.now().difference(searchStart);
    
    print('JSON方式:');
    print('  保存: ${saveTime.inMilliseconds}ms');
    print('  読み込み: ${loadTime.inMilliseconds}ms');
    print('  検索: ${searchTime.inMicroseconds}μs');
  }
}
```

## 推奨判定基準

### JSONファイル方式が適している場合
- **ラベル数**: 1,000未満
- **更新頻度**: 低〜中程度
- **検索要件**: 単純な部分一致検索
- **開発優先度**: 実装の簡単さを重視

### SQLite方式が適している場合
- **ラベル数**: 5,000以上
- **更新頻度**: 高頻度
- **検索要件**: 複雑な条件検索
- **性能要件**: 高速アクセスが必要

### ハイブリッド方式が適している場合
- **ラベル数**: 1,000〜5,000
- **リアルタイム要件**: 統計情報の即座反映
- **バランス重視**: 性能と実装コストのバランス

## 結論

### 現在の要件（数千ラベル）に対する推奨

**第1推奨: ハイブリッド方式**
- JSONファイル（メタデータ） + RinneGraphイベント（統計）
- 実装コストと性能のバランスが最適
- 段階的な移行が可能

**第2推奨: SQLite方式**
- 将来的な拡張性を重視する場合
- 複雑な検索要件がある場合

**非推奨: 純粋JSONファイル方式**
- 数千ラベルでは性能問題が発生する可能性
- 特に頻繁な更新がある場合は不適切

### 実装戦略

1. **初期実装**: JSONファイル方式（プロトタイプ）
2. **中期実装**: ハイブリッド方式（推奨）
3. **長期実装**: SQLite方式（必要に応じて）

### 性能監視指標

- **読み込み時間**: 100ms以下を目標
- **検索時間**: 50ms以下を目標
- **メモリ使用量**: 10MB以下を目標
- **ファイルサイズ**: 5MB以下を目標
