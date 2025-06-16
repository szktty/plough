import 'package:flutter/material.dart';
import 'package:plough/plough.dart';
import 'package:example/widget/proposed_gesture_test_page.dart';

/// ジェスチャー処理のテストページ
/// 
/// 背景ジェスチャーの透過とInteractiveViewerとの統合をテストします。
class GestureTestPage extends StatefulWidget {
  const GestureTestPage({super.key});

  @override
  State<GestureTestPage> createState() => _GestureTestPageState();
}

class _GestureTestPageState extends State<GestureTestPage> {
  late Graph _graph;
  final TransformationController _transformationController =
      TransformationController();
  String _statusMessage = 'タップまたはドラッグしてテスト';
  bool _isBackgroundDragging = false;
  
  // 背景タップの試行回数を記録
  int _backgroundTapAttempts = 0;

  @override
  void initState() {
    super.initState();
    _initGraph();
  }

  void _initGraph() {
    _graph = Graph();

    // サンプルノードを作成
    final node1 = GraphNode(properties: {
      'label': 'Node 1',
      'description': 'ドラッグ可能なノード',
    });
    final node2 = GraphNode(properties: {
      'label': 'Node 2',
      'description': 'もう一つのノード',
    });
    final node3 = GraphNode(properties: {
      'label': 'Node 3',
      'description': '三番目のノード',
    });

    // リンクを作成
    final link1 = GraphLink(
      source: node1,
      target: node2,
      direction: GraphLinkDirection.outgoing,
      properties: {'label': 'Link 1'},
    );
    final link2 = GraphLink(
      source: node2,
      target: node3,
      direction: GraphLinkDirection.outgoing,
      properties: {'label': 'Link 2'},
    );

    // グラフに追加
    _graph
      ..addNode(node1)
      ..addNode(node2)
      ..addNode(node3)
      ..addLink(link1)
      ..addLink(link2);
  }

  void _updateStatus(String message) {
    setState(() {
      _statusMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ジェスチャー処理テスト'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade100,
            child: Text(
              _statusMessage,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                // 背景のドットグリッド
                _DotGridBackground(
                  onTap: () {
                    // 実際には反応しない
                    setState(() {
                      _backgroundTapAttempts++;
                    });
                    _updateStatus('❌ 背景タップは検出されません（試行: $_backgroundTapAttempts回）');
                  },
                  onDragStart: () {
                    // 実際には反応しない
                    setState(() {
                      _isBackgroundDragging = true;
                    });
                    _updateStatus('❌ 背景ドラッグは検出されません');
                  },
                  onDragEnd: () {
                    setState(() {
                      _isBackgroundDragging = false;
                    });
                    _updateStatus('❌ 背景ドラッグ終了は検出されません');
                  },
                ),
                // InteractiveViewerでラップしたGraphView
                InteractiveViewer(
                  transformationController: _transformationController,
                  boundaryMargin: const EdgeInsets.all(100),
                  minScale: 0.5,
                  maxScale: 3.0,
                  onInteractionStart: (details) {
                    // GraphViewがジェスチャーを消費するため、実際には呼ばれない
                    _updateStatus('❌ InteractiveViewer: 操作開始（実際には呼ばれません）');
                  },
                  onInteractionUpdate: (details) {
                    // GraphViewがジェスチャーを消費するため、実際には呼ばれない
                    _updateStatus('❌ InteractiveViewer: パン中（実際には呼ばれません）');
                  },
                  onInteractionEnd: (details) {
                    // GraphViewがジェスチャーを消費するため、実際には呼ばれない
                    _updateStatus('❌ InteractiveViewer: 操作終了（実際には呼ばれません）');
                  },
                  child: _buildGraphView(),
                ),
              ],
            ),
          ),
          _buildControlPanel(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Colors.blue.shade700,
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProposedGestureTestPage(),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward, color: Colors.white),
              label: const Text(
                '提案された改善案のデモを見る',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraphView() {
    return GraphView(
      graph: _graph,
      layoutStrategy: GraphForceDirectedLayoutStrategy(
        springLength: 150,
        springConstant: 0.1,
        coulombConstant: 1000,
      ),
      behavior: _TestGraphBehavior(
        graph: _graph,
        onNodeTap: (node) => _updateStatus('✅ ノード「${node['label']}」がタップされました'),
        onLinkTap: (link) => _updateStatus('✅ リンクがタップされました'),
        onNodeDragStart: (node) =>
            _updateStatus('✅ ノード「${node['label']}」のドラッグ開始'),
        onNodeDragEnd: (node) =>
            _updateStatus('✅ ノード「${node['label']}」のドラッグ終了'),
        onBackgroundTap: () {
          // GraphViewがすべてのイベントを消費するため、ここには来ない
          _updateStatus('❌ GraphView内の背景タップ（実際には検出されません）');
        },
      ),
      animationEnabled: true,
      allowSelection: true,
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        border: Border(
          top: BorderSide(color: Colors.grey.shade400),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '現在の問題点:',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          const Text('• GraphViewが全てのジェスチャーを消費してしまう', style: TextStyle(color: Colors.red)),
          const Text('• 背景のGestureDetectorにイベントが届かない', style: TextStyle(color: Colors.red)),
          const Text('• InteractiveViewerのパン・ズーム操作が機能しない', style: TextStyle(color: Colors.red)),
          const SizedBox(height: 8),
          Text(
            '※ 背景（ドットの部分）をタップ/ドラッグしても反応しません',
            style: TextStyle(fontSize: 12, color: Colors.red.shade700, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            '期待される動作:',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          const Text('• ノード上: GraphViewがジェスチャーを処理'),
          const Text('• 背景上: 背景のGestureDetectorが反応'),
          const Text('• 背景ドラッグ: InteractiveViewerでパン操作'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }
}

/// カスタムGraphViewBehavior
class _TestGraphBehavior extends GraphViewDefaultBehavior {
  _TestGraphBehavior({
    this.onNodeTap,
    this.onLinkTap,
    this.onNodeDragStart,
    this.onNodeDragEnd,
    this.onBackgroundTap,
    required this.graph,
  });

  final void Function(GraphNode)? onNodeTap;
  final void Function(GraphLink)? onLinkTap;
  final void Function(GraphNode)? onNodeDragStart;
  final void Function(GraphNode)? onNodeDragEnd;
  final VoidCallback? onBackgroundTap;
  final Graph graph;

  @override
  void onTap(GraphTapEvent event) {
    if (event.entityIds.isNotEmpty) {
      final entityId = event.entityIds.first;
      final node = graph.getNode(entityId);
      if (node != null) {
        onNodeTap?.call(node);
      } else {
        final link = graph.getLink(entityId);
        if (link != null) {
          onLinkTap?.call(link);
        }
      }
    } else {
      // 背景タップ - 現在のploughではここには来ない
      onBackgroundTap?.call();
    }
  }

  @override
  void onDragStart(GraphDragStartEvent event) {
    if (event.entityIds.isNotEmpty) {
      final entityId = event.entityIds.first;
      final node = graph.getNode(entityId);
      if (node != null) {
        onNodeDragStart?.call(node);
      }
    }
  }

  @override
  void onDragEnd(GraphDragEndEvent event) {
    if (event.entityIds.isNotEmpty) {
      final entityId = event.entityIds.first;
      final node = graph.getNode(entityId);
      if (node != null) {
        onNodeDragEnd?.call(node);
      }
    }
  }
}

/// ドットグリッドの背景ウィジェット
class _DotGridBackground extends StatelessWidget {
  const _DotGridBackground({
    this.onTap,
    this.onDragStart,
    this.onDragEnd,
  });

  final VoidCallback? onTap;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onPanStart: (_) => onDragStart?.call(),
      onPanEnd: (_) => onDragEnd?.call(),
      child: CustomPaint(
        painter: _DotGridPainter(),
        child: Container(
          color: Colors.transparent,
        ),
      ),
    );
  }
}

/// ドットグリッドを描画するPainter
class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1.0;

    const spacing = 20.0;
    const dotRadius = 1.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}