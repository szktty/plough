import 'package:flutter/material.dart';
import 'package:plough/plough.dart';
import 'workbench_app.dart';

void main() {
  Plough()
    ..debugLogEnabled = true
    ..enableAllLogCategories(); // シンプルに全カテゴリを有効化
  runApp(const WorkbenchApp());
}
