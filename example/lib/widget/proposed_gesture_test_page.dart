import 'package:flutter/material.dart';
import 'package:plough/plough.dart';

/// 提案された改善案を実装した場合の動作イメージ
/// 
/// このページは、PLOUGH_REQUIREMENTS.mdで提案された改善が
/// 実装された場合の期待される動作を示します。
class ProposedGestureTestPage extends StatefulWidget {
  const ProposedGestureTestPage({super.key});

  @override
  State<ProposedGestureTestPage> createState() =>
      _ProposedGestureTestPageState();
}

class _ProposedGestureTestPageState extends State<ProposedGestureTestPage> {
  late Graph _graph;
  final TransformationController _transformationController =
      TransformationController();
  String _statusMessage = 'タップまたはドラッグしてテスト';
  
  // 提案された新しいプロパティ
  bool _allowBackgroundGestures = true;
  GraphGestureMode _gestureMode = GraphGestureMode.nodeEdgeOnly;

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
        title: const Text('提案された改善案のデモ'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green.shade100,
            child: Column(
              children: [
                Text(
                  _statusMessage,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  '※これは提案された機能が実装された場合の動作イメージです',
                  style: TextStyle(fontSize: 12, color: Colors.green),
                ),
              ],
            ),
          ),
          Expanded(
            child: InteractiveViewer(
              transformationController: _transformationController,
              boundaryMargin: const EdgeInsets.all(100),
              minScale: 0.5,
              maxScale: 3.0,
              onInteractionStart: (details) {
                _updateStatus('背景パン操作開始');
              },
              onInteractionUpdate: (details) {
                // 背景でのドラッグがInteractiveViewerに伝わる
              },
              onInteractionEnd: (details) {
                _updateStatus('背景パン操作終了');
              },
              child: Stack(
                children: [
                  // 背景のドットグリッド
                  CustomPaint(
                    painter: _DotGridPainter(),
                    child: Container(),
                  ),
                  // 提案されたAPIを使用したGraphView
                  _buildProposedGraphView(),
                ],
              ),
            ),
          ),
          _buildControlPanel(),
        ],
      ),
    );
  }

  Widget _buildProposedGraphView() {
    // 提案されたAPIの使用例
    return Container(
      color: Colors.transparent,
      child: Column(
        children: [
          Expanded(
            child: GraphView(
              graph: _graph,
              layoutStrategy: GraphForceDirectedLayoutStrategy(
                springLength: 150,
                springConstant: 0.1,
                coulombConstant: 1000,
              ),
              behavior: _ProposedGraphBehavior(
                graph: _graph,
                onNodeTap: (node) =>
                    _updateStatus('ノード「${node['label']}」がタップされました'),
                onLinkTap: (link) => _updateStatus('リンクがタップされました'),
                onBackgroundTap: (position) =>
                    _updateStatus('背景がタップされました: $position'),
              ),
              animationEnabled: true,
              allowSelection: true,
              // 以下は提案されたAPIの例
              // allowBackgroundGestures: _allowBackgroundGestures,
              // gestureMode: _gestureMode,
              // shouldConsumeGesture: (localPosition, hitResult) {
              //   // ノードやエッジがヒットした場合のみジェスチャーを消費
              //   return hitResult.hasNode || hitResult.hasEdge;
              // },
              // delegatePanToParent: true,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.yellow.shade100,
            child: const Text(
              '// 提案されたAPI: allowBackgroundGestures: true',
              style: TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ),
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
            '提案されたジェスチャーモード:',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildGestureModeChip(
                GraphGestureMode.exclusive,
                '全て消費（現在の動作）',
              ),
              _buildGestureModeChip(
                GraphGestureMode.nodeEdgeOnly,
                'ノード/エッジのみ',
              ),
              _buildGestureModeChip(
                GraphGestureMode.transparent,
                '全て透過',
              ),
              _buildGestureModeChip(
                GraphGestureMode.custom,
                'カスタム',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              border: Border.all(color: Colors.green.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                CheckboxListTile(
                  title: const Text('allowBackgroundGestures'),
                  subtitle: const Text('背景ジェスチャーを透過する'),
                  value: _allowBackgroundGestures,
                  onChanged: (value) {
                    setState(() {
                      _allowBackgroundGestures = value ?? false;
                    });
                  },
                ),
                Text(
                  '✅ 有効: 背景タップが正常に動作します',
                  style: TextStyle(fontSize: 12, color: Colors.green.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGestureModeChip(GraphGestureMode mode, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _gestureMode == mode,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _gestureMode = mode;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }
}

/// 提案されたGraphGestureMode enum
enum GraphGestureMode {
  /// 現在の動作：全てのジェスチャーをGraphViewが処理
  exclusive,

  /// ノード/エッジのみGraphViewが処理、背景は透過
  nodeEdgeOnly,

  /// 全てのジェスチャーを透過（親のInteractiveViewerが処理）
  transparent,

  /// カスタムロジックで制御
  custom,
}

/// 提案されたGraphHitTestResult
class GraphHitTestResult {
  final bool hasNode;
  final bool hasEdge;
  final GraphNode? node;
  final GraphLink? edge;
  final Offset localPosition;
  final bool isBackground;

  const GraphHitTestResult({
    required this.hasNode,
    required this.hasEdge,
    this.node,
    this.edge,
    required this.localPosition,
    required this.isBackground,
  });
}

/// 提案されたAPIを想定したカスタムBehavior
class _ProposedGraphBehavior extends GraphViewDefaultBehavior {
  _ProposedGraphBehavior({
    this.onNodeTap,
    this.onLinkTap,
    this.onBackgroundTap,
    required this.graph,
  });

  final void Function(GraphNode)? onNodeTap;
  final void Function(GraphLink)? onLinkTap;
  final void Function(Offset)? onBackgroundTap;
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
      // 提案: 背景タップのコールバック
      final details = event.details;
      onBackgroundTap?.call(details.localPosition);
    }
  }
}

/// ドットグリッドを描画するPainter（共通）
class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
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