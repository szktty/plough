import 'package:example/app_state.dart';
import 'package:example/widget/main_page.dart';
import 'package:example/widget/gesture_test_page.dart';
import 'package:example/widget/comparison_demo_page.dart';
import 'package:example/widget/gesture_passthrough_demo_page.dart';
import 'package:example/widget/custom_gesture_demo_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/debug/external_debug_client.dart';
import 'package:provider/provider.dart';

void main() async {
  // 基本的なログ設定
  Plough()
    ..enableLogCategories({
      LogCategory.gesture: Level.debug,
      LogCategory.rendering: Level.info,
      LogCategory.layout: Level.debug,
      LogCategory.performance: Level.debug,
      LogCategory.debug: Level.info,
    })
    ..debugLogEnabled = true
    //..debugViewEnabled = true
    ..debugSignalsEnabled = false;

  // 高度なデバッグ機能を有効化（開発時のみ）
  // デバッグサーバーが http://localhost:8080 で起動します
  await Plough().initializeDebugFeatures(
    enableServer: true,
    enablePerformanceMonitoring: true,
    serverPort: 8080,
  );

  // 🚀 Dartデバッグサーバーへの接続設定
  if (kDebugMode) {
    // 外部デバッグクライアントを設定（ポート8081のDartサーバー）
    externalDebugClient.setServerUrl('http://localhost:8081');
    externalDebugClient.enable();
    
    // 接続テストを実行
    Future.delayed(const Duration(seconds: 1), () async {
      final connected = await externalDebugClient.testConnection();
      if (connected) {
        print('✅ Connected to Dart Debug Server at http://localhost:8081');
        print('🔍 Web Console: Open browser and go to http://localhost:8081');
      } else {
        print('⚠️  Dart Debug Server not available at http://localhost:8081');
        print('💡 To start the server:');
        print('   cd debug_server');
        print('   dart run bin/debug_server.dart');
      }
    });
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Graph View Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        /*
        scrollbarTheme: const ScrollbarThemeData(
          thickness: WidgetStatePropertyAll(8),
          thumbColor: WidgetStatePropertyAll(Colors.green),
        ),
         */
      ),
      home: const MyHomePage(title: 'Plough Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.title, super.key});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const Center(
        child: MainPage(),
        //child: GraphArea(),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "custom_gesture",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CustomGestureDemoPage(),
                ),
              );
            },
            tooltip: 'Custom Gesture Demo',
            backgroundColor: Colors.purple.shade600,
            child: const Icon(Icons.tune),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "gesture_passthrough",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GesturePassthroughDemoPage(),
                ),
              );
            },
            tooltip: 'Gesture Pass-through Demo',
            backgroundColor: Colors.green.shade600,
            child: const Icon(Icons.pan_tool),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "comparison",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ComparisonDemoPage(),
                ),
              );
            },
            tooltip: '問題と改善案の比較',
            backgroundColor: Colors.blue.shade600,
            child: const Icon(Icons.compare_arrows),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "gesture_test",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GestureTestPage(),
                ),
              );
            },
            tooltip: 'ジェスチャーテスト',
            child: const Icon(Icons.touch_app),
          ),
        ],
      ),
    );
  }
}
