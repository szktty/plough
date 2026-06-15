// F2 regression: the link painter's shouldRepaint must compare the values that
// paint() actually reads, repainting only when one of them changes — instead of
// the previous unconditional `=> true`.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plough/plough.dart';
import 'package:plough/src/graph_view/geometry.dart';
import 'package:plough/src/renderer/widget/link.dart';

GraphConnectionGeometry _geometry({
  Rect sourceBounds = const Rect.fromLTWH(0, 0, 40, 40),
  Rect targetBounds = const Rect.fromLTWH(100, 0, 40, 40),
  Offset incoming = const Offset(20, 20),
  Offset outgoing = const Offset(120, 20),
}) {
  return GraphConnectionGeometry(
    source: GraphNodeViewGeometry(bounds: sourceBounds),
    target: GraphNodeViewGeometry(bounds: targetBounds),
    connectionPoints: GraphConnectionPoints(
      incoming: incoming,
      outgoing: outgoing,
    ),
  );
}

void main() {
  final a = GraphNode(properties: const {'label': 'a'});
  final b = GraphNode(properties: const {'label': 'b'});
  final link = GraphLink(
    source: a,
    target: b,
    direction: GraphLinkDirection.outgoing,
  );

  GraphDefaultLinkRenderer baseRenderer({
    GraphConnectionGeometry? geometry,
    Color color = Colors.black,
    double lineWidth = 2,
    double arrowSize = 15,
    double thickness = 20,
    GraphLinkRouting routing = GraphLinkRouting.straight,
  }) {
    return GraphDefaultLinkRenderer(
      link: link,
      sourceView: const SizedBox(),
      targetView: const SizedBox(),
      routing: routing,
      geometry: geometry ?? _geometry(),
      color: color,
      lineWidth: lineWidth,
      arrowSize: arrowSize,
      thickness: thickness,
    );
  }

  // Mounts a renderer and returns its CustomPainter, so the private painter
  // classes are exercised through the real widget build path.
  Future<CustomPainter> painterOf(
    WidgetTester tester,
    GraphDefaultLinkRenderer renderer,
  ) async {
    await tester.pumpWidget(
      Directionality(textDirection: TextDirection.ltr, child: renderer),
    );
    final customPaint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byWidget(renderer),
        matching: find.byType(CustomPaint),
      ),
    );
    return customPaint.painter!;
  }

  testWidgets('identical renderers do not trigger repaint', (tester) async {
    final p1 = await painterOf(tester, baseRenderer());
    final p2 = await painterOf(tester, baseRenderer());
    expect(p1.shouldRepaint(p2), isFalse);
  });

  testWidgets('changed geometry triggers repaint', (tester) async {
    final p1 = await painterOf(tester, baseRenderer());
    final p2 = await painterOf(
      tester,
      baseRenderer(
        geometry: _geometry(targetBounds: const Rect.fromLTWH(200, 0, 40, 40)),
      ),
    );
    expect(p1.shouldRepaint(p2), isTrue);
  });

  testWidgets('changed color triggers repaint', (tester) async {
    final p1 = await painterOf(tester, baseRenderer());
    final p2 = await painterOf(tester, baseRenderer(color: Colors.red));
    expect(p1.shouldRepaint(p2), isTrue);
  });

  testWidgets('changed lineWidth triggers repaint', (tester) async {
    final p1 = await painterOf(tester, baseRenderer());
    final p2 = await painterOf(tester, baseRenderer(lineWidth: 4));
    expect(p1.shouldRepaint(p2), isTrue);
  });

  testWidgets('changed arrowSize triggers repaint', (tester) async {
    final p1 = await painterOf(tester, baseRenderer());
    final p2 = await painterOf(tester, baseRenderer(arrowSize: 30));
    expect(p1.shouldRepaint(p2), isTrue);
  });

  testWidgets('changed thickness triggers repaint', (tester) async {
    final p1 = await painterOf(tester, baseRenderer());
    final p2 = await painterOf(tester, baseRenderer(thickness: 40));
    expect(p1.shouldRepaint(p2), isTrue);
  });
}
