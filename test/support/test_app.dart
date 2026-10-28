import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadesmaster/app/app_scope.dart';
import 'package:shadesmaster/app/app_settings.dart';
import 'package:shadesmaster/l10n/app_localizations.dart';
import 'package:shadesmaster/main.dart';
import 'package:shadesmaster/orders/order_repository.dart';

/// A fresh temporary folder for settings and orders.
Directory tempStorage() => Directory.systemTemp.createTempSync('dental_case_test');

/// Wraps [child] like the app does, with the given language.
Widget testApp(Widget child, {String language = 'en', AppSettings? settings, OrderRepository? orders}) {
  final appSettings = settings ?? AppSettings(locale: Locale(language));
  return AppScope(
    settings: appSettings,
    orders: orders ?? OrderRepository(tempStorage()),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      locale: appSettings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: child,
    ),
  );
}

/// Loads the bundled Arabic font so screenshots taken in tests show real text.
Future<void> loadAppFonts() async {
  final loader = FontLoader('IBMPlexSansArabic')
    ..addFont(rootBundle.load('assets/fonts/IBMPlexSansArabic-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/IBMPlexSansArabic-Bold.ttf'));
  await loader.load();
  await (FontLoader('NotoSansDelta')..addFont(rootBundle.load('assets/fonts/NotoSans-Delta.ttf'))).load();
}

AppLocalizations l10nOf(WidgetTester tester, Type widgetType) =>
    AppLocalizations.of(tester.element(find.byType(widgetType).first));
