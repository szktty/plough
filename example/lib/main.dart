import 'package:example/app_state.dart';
import 'package:example/widget/infinite_scene_page.dart';
import 'package:example/widget/main_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
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
      debugShowCheckedModeBanner: false,
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Layout samples'),
              Tab(text: 'Infinite scene'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MainPage(),
            InfiniteScenePage(),
          ],
        ),
      ),
    );
  }
}
