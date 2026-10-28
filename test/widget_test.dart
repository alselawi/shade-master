import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:shadesmaster/app/app_settings.dart';
import 'package:shadesmaster/main.dart';
import 'package:shadesmaster/orders/order_repository.dart';
import 'package:shadesmaster/widget_shade_master.dart';

import 'shade_master_test.dart' show writeDemoPhoto;

import 'support/test_app.dart';

void main() {
  testWidgets('Home screen is in Arabic and right to left by default', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(settings: AppSettings(), orders: OrderRepository(tempStorage())));

    expect(find.text('بطاقة لون وطلب مخبري'), findsOneWidget);
    expect(find.text('الكاميرا'), findsOneWidget);
    expect(find.text('المعرض'), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    expect(find.byIcon(Icons.folder), findsOneWidget);
    expect(Directionality.of(tester.element(find.text('الكاميرا'))), TextDirection.rtl);
  });

  testWidgets('Home screen in English keeps the original labels', (WidgetTester tester) async {
    await tester.pumpWidget(
      MyApp(settings: AppSettings(locale: const Locale('en')), orders: OrderRepository(tempStorage())),
    );

    expect(find.text('Use Camera'), findsOneWidget);
    expect(find.text('Pick Image'), findsOneWidget);
    expect(find.textContaining('Shade Master by Dr. Ali A. Saleem'), findsOneWidget);
    expect(Directionality.of(tester.element(find.text('Use Camera'))), TextDirection.ltr);
  });

  testWidgets('Switching the language in the settings is applied to the app', (WidgetTester tester) async {
    final settings = AppSettings();
    await tester.pumpWidget(MyApp(settings: settings, orders: OrderRepository(tempStorage())));

    await tester.tap(find.byTooltip('الإعدادات'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(settings.toJson()['language'], 'en');
  });

  testWidgets('The back button closes the photo instead of leaving the app', (WidgetTester tester) async {
    ImagePickerPlatform.instance = _FakePicker(writeDemoPhoto().path);
    await tester.pumpWidget(
      MyApp(settings: AppSettings(locale: const Locale('en')), orders: OrderRepository(tempStorage())),
    );

    await tester.tap(find.text('Use Camera'));
    // Not pumpAndSettle: the photo is still loading behind a spinning indicator.
    await tester.pump();
    await tester.pump();
    expect(find.byType(ShadeMaster), findsOneWidget);

    final popped = await tester.binding.handlePopRoute();
    await tester.pump();
    expect(popped, isTrue, reason: 'the app handled back itself');
    expect(find.byType(ShadeMaster), findsNothing);
    expect(find.text('Use Camera'), findsOneWidget);
  });
}

/// Returns a demo photo instead of opening the camera.
class _FakePicker extends ImagePickerPlatform {
  final String path;
  _FakePicker(this.path);

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async =>
      XFile(path);
}
