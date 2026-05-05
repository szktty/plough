import 'package:example/widget/graph_area.dart';
import 'package:example/widget/toolbar.dart';
import 'package:flutter/material.dart';
import 'package:plough/plough.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _viewportController = GraphViewportController();

  @override
  void dispose() {
    _viewportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MainPageToolbar(viewportController: _viewportController),
        Expanded(child: GraphArea(viewportController: _viewportController)),
      ],
    );
  }
}
