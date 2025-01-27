import 'package:example/sample_data/base.dart';
import 'package:example/sample_data/force_directed.dart';
import 'package:example/sample_data/manual.dart';
import 'package:example/sample_data/random.dart';
import 'package:example/sample_data/tree.dart';

export 'base.dart';

List<SampleData> createSampleDataList() => [
      forceDirectedSample(),
      treeSample(),
      randomSample(),
      manualSample(),
    ];
