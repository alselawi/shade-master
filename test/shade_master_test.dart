import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:shadesmaster/analysis/analyze.dart';
import 'package:shadesmaster/widget_shade_master.dart';

import 'support/test_app.dart';

/// Writes a demo photo (no patient data): gum background, one tooth and two
/// shade tabs, the right one matching the tooth.
File writeDemoPhoto() {
  final photo = img.Image(width: 300, height: 400);
  img.fill(photo, color: img.ColorRgb8(122, 46, 53));
  img.fillRect(photo, x1: 50, y1: 50, x2: 149, y2: 149, color: img.ColorRgb8(226, 213, 188));
  img.fillRect(photo, x1: 30, y1: 250, x2: 89, y2: 329, color: img.ColorRgb8(240, 232, 216));
  img.fillRect(photo, x1: 180, y1: 250, x2: 239, y2: 329, color: img.ColorRgb8(227, 214, 189));
  final file = File('${Directory.systemTemp.createTempSync('shade_master_test').path}/demo.png');
  file.writeAsBytesSync(img.encodePng(photo));
  return file;
}

Future<void> drawLoop(WidgetTester tester, List<Offset> points) async {
  final gesture = await tester.startGesture(points.first);
  for (final point in points.skip(1)) {
    for (var step = 1; step <= 4; step++) {
      await gesture.moveTo(Offset.lerp(points[points.indexOf(point) - 1], point, step / 4)!);
    }
  }
  await gesture.up();
  await tester.pump();
}

/// Lets real asynchronous work (image decoding, the analysis isolate) run
/// until [done] holds.
Future<void> waitUntil(WidgetTester tester, bool Function() done) async {
  for (var i = 0; i < 300 && !done(); i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump();
  }
  expect(done(), isTrue);
}

void main() {
  testWidgets('regions drawn on a letterboxed photo sample the pixels under the finger', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final file = writeDemoPhoto();
    await tester.pumpWidget(testApp(Scaffold(body: ShadeMaster(img: XFile(file.path), onClose: () {}))));
    // The 300x400 photo fills the width of the 400x800 screen: 400x533 at y = 133.
    await waitUntil(tester, () => find.byType(CircularProgressIndicator).evaluate().isEmpty);

    await tester.tap(find.text('Draw Teeth'));
    await tester.pump();
    await drawLoop(
        tester, const [Offset(90, 215), Offset(180, 215), Offset(180, 320), Offset(90, 320), Offset(90, 222)]);

    await tester.tap(find.text('Draw Shades'));
    await tester.pump();
    await drawLoop(
        tester, const [Offset(50, 478), Offset(112, 478), Offset(112, 562), Offset(50, 562), Offset(50, 484)]);
    await drawLoop(
        tester, const [Offset(250, 478), Offset(312, 478), Offset(312, 562), Offset(250, 562), Offset(250, 484)]);
    expect(find.text('Shade A'), findsOneWidget);
    expect(find.text('Shade B'), findsOneWidget);

    await tester.tap(find.text('Start Analyze'));
    await waitUntil(tester, () => find.text('Winner').evaluate().isNotEmpty);

    final winnerTile = find.ancestor(of: find.text('Winner'), matching: find.byType(ListTile));
    expect(find.descendant(of: winnerTile, matching: find.text('Shade B')), findsOneWidget);
    expect(find.textContaining('Excellent match'), findsOneWidget);
  });

  testWidgets('a shade named from the guide is reported by name and can start a lab order', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    AnalysisResult? orderedFrom;
    Uint8List? orderPhoto;
    await tester.pumpWidget(testApp(Scaffold(
      body: ShadeMaster(
        img: XFile(writeDemoPhoto().path),
        onClose: () {},
        onCreateOrder: (result, jpeg) async {
          orderedFrom = result;
          orderPhoto = jpeg;
        },
      ),
    )));
    await waitUntil(tester, () => find.byType(CircularProgressIndicator).evaluate().isEmpty);

    await tester.tap(find.text('Draw Teeth'));
    await tester.pump();
    await drawLoop(
        tester, const [Offset(90, 215), Offset(180, 215), Offset(180, 320), Offset(90, 320), Offset(90, 222)]);
    await tester.tap(find.text('Draw Shades'));
    await tester.pump();
    await drawLoop(
        tester, const [Offset(250, 478), Offset(312, 478), Offset(312, 562), Offset(250, 562), Offset(250, 484)]);

    await tester.tap(find.text('Shade A'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A2'));
    await tester.pumpAndSettle();
    expect(find.text('Shade A2'), findsOneWidget);

    await tester.tap(find.text('Start Analyze'));
    await waitUntil(tester, () => find.text('Winner').evaluate().isNotEmpty);
    expect(find.text('Shade A2'), findsWidgets);

    await tester.tap(find.text('Create lab order'));
    await waitUntil(tester, () => orderPhoto != null);
    expect(orderedFrom!.winner.name, 'A2');
    // A JPEG starts with FF D8.
    expect(orderPhoto!.sublist(0, 2), [0xFF, 0xD8]);
  });
}
