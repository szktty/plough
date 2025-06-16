import 'package:flutter/material.dart';
import 'package:example/widget/gesture_test_page.dart';
import 'package:example/widget/proposed_gesture_test_page.dart';

/// 現在の問題と改善案を比較するページ
class ComparisonDemoPage extends StatefulWidget {
  const ComparisonDemoPage({super.key});

  @override
  State<ComparisonDemoPage> createState() => _ComparisonDemoPageState();
}

class _ComparisonDemoPageState extends State<ComparisonDemoPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('現在の問題 vs 改善案'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.error_outline, color: Colors.red),
              text: '現在の問題',
            ),
            Tab(
              icon: Icon(Icons.check_circle_outline, color: Colors.green),
              text: '改善案',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 現在の問題を示すタブ
          Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.red.shade100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.error, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Text(
                          '現在の問題点',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('• GraphViewが全てのジェスチャーを消費'),
                    const Text('• 背景タップが検出されない'),
                    const Text('• InteractiveViewerのパン・ズーム操作が効かない'),
                    const SizedBox(height: 8),
                    Text(
                      '⚠️ 下の画面で背景（ドット部分）をタップしても反応しません',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: GestureTestPage(),
              ),
            ],
          ),
          // 改善案を示すタブ
          Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.green.shade100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        Text(
                          '改善案（期待される動作）',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('• ノード/エッジのみGraphViewが処理'),
                    const Text('• 背景タップが正常に検出される'),
                    const Text('• InteractiveViewerとの統合'),
                    const SizedBox(height: 8),
                    Text(
                      '✅ 下の画面で背景（ドット部分）をタップすると反応します！',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: ProposedGestureTestPage(),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('使用方法'),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('1. 「現在の問題」タブ:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('   • 背景（ドット部分）をタップ → 反応しない'),
                  Text('   • ノードをタップ → 正常に反応'),
                  SizedBox(height: 16),
                  Text('2. 「改善案」タブ:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('   • 背景（ドット部分）をタップ → 正常に反応'),
                  Text('   • ノードをタップ → 正常に反応'),
                  Text('   • 背景ドラッグ → InteractiveViewerでパン'),
                  SizedBox(height: 16),
                  Text('違いを確認して、改善案の効果を体感してください！',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('閉じる'),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.help_outline),
        label: const Text('使用方法'),
      ),
    );
  }
}