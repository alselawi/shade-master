// Generates the screenshots in docs/images from the synthetic demo photo:
//
//   flutter test tool/screenshots_test.dart --update-goldens
//
// Not part of `flutter test` (it lives outside test/) because it needs the
// fonts of the Flutter SDK and only produces pictures.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadesmaster/app/app_settings.dart';
import 'package:shadesmaster/main.dart';
import 'package:shadesmaster/orders/order_form_page.dart';
import 'package:shadesmaster/orders/order_repository.dart';
import 'package:shadesmaster/utils/image_fit.dart';
import 'package:shadesmaster/widget_shade_master.dart';

import '../test/shade_master_test.dart' show drawLoop, waitUntil;
import '../test/support/demo_order.dart';
import '../test/support/test_app.dart';

const demoPhoto = 'docs/images/demo-photo.jpg';
const phone = Size(1080, 2340);
const pixelRatio = 2.75;

Future<void> loadFonts() async {
  await loadAppFonts();
  // flutter_tester lives in bin/cache/artifacts/engine/<platform>/ of the SDK.
  final artifacts = File(Platform.resolvedExecutable).parent.parent.parent.path;
  final icons = File('$artifacts/material_fonts/MaterialIcons-Regular.otf').readAsBytesSync();
  await (FontLoader('MaterialIcons')..addFont(Future.value(ByteData.sublistView(icons)))).load();
  await (FontLoader('packages/hugeicons/HgiStrokeRounded')
        ..addFont(rootBundle.load('packages/hugeicons/lib/fonts/hugeicons-stroke-rounded.ttf')))
      .load();
}

void usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = phone;
  tester.view.devicePixelRatio = pixelRatio;
  addTearDown(tester.view.reset);
}

/// Closed loop inside [rect] given in demo photo pixels.
List<Offset> loopInside(Rect rect, ImageFit fit) {
  final inner = rect.deflate(rect.shortestSide * 0.15);
  return [
    inner.topLeft,
    inner.topRight,
    inner.bottomRight,
    inner.bottomLeft,
    inner.topLeft + const Offset(0, 4),
  ].map(fit.imageToBox).toList();
}

void main() {
  setUpAll(() async => await loadFonts());

  testWidgets('home', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(MyApp(settings: AppSettings(), orders: OrderRepository(tempStorage())));
    await tester.runAsync(
        () => precacheImage(const AssetImage('assets/icon/app_icon.png'), tester.element(find.byType(Scaffold))));
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('../docs/images/screen-home.png'));
  });

  testWidgets('results', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(testApp(
      Scaffold(body: ShadeMaster(img: XFile(demoPhoto), onClose: () {}, onCreateOrder: (_, __) async {})),
      language: 'ar',
    ));
    await waitUntil(tester, () => find.byType(CircularProgressIndicator).evaluate().isEmpty);
    await tester.runAsync(() => precacheImage(FileImage(File(demoPhoto)), tester.element(find.byType(Scaffold))));
    await tester.pump();

    final box = phone / pixelRatio;
    final fit = ImageFit(const Size(1200, 1600), box);
    await tester.tap(find.text('حدّد الأسنان'));
    await tester.pump();
    await drawLoop(tester, loopInside(const Rect.fromLTRB(290, 320, 560, 780), fit));
    await drawLoop(tester, loopInside(const Rect.fromLTRB(640, 320, 910, 780), fit));

    await tester.tap(find.text('حدّد الألوان'));
    await tester.pump();
    const names = ['A1', 'A2', 'A3', 'A3.5'];
    for (var i = 0; i < names.length; i++) {
      await drawLoop(tester, loopInside(Rect.fromLTWH(150.0 + i * 250, 1150, 180, 270), fit));
    }
    for (var i = 0; i < names.length; i++) {
      await tester.tap(find.text('اللون ${String.fromCharCode(65 + i)}'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, names[i]));
      await tester.pumpAndSettle();
    }
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('../docs/images/screen-workspace.png'));

    await tester.tap(find.text('حلّل'));
    await waitUntil(tester, () => find.text('الأقرب').evaluate().isNotEmpty);
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('../docs/images/screen-results.png'));
  });

  testWidgets('order form', (tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(testApp(OrderFormPage(order: demoOrder(hasPhoto: false)), language: 'ar'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -560));
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('../docs/images/screen-order.png'));
  });
}
