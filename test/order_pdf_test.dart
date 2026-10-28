import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadesmaster/l10n/app_localizations.dart';
import 'package:shadesmaster/orders/order_pdf.dart';

import 'support/demo_order.dart';

int pageCount(List<int> pdf) => RegExp(r'/Type\s*/Page[^s]').allMatches(latin1.decode(pdf)).length;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final language in ['ar', 'en']) {
    test('builds a one page A4 order sheet in $language', () async {
      final fonts = await OrderPdfFonts.load();
      final pdf = await buildOrderPdf(
        demoOrder(),
        l10n: lookupAppLocalizations(Locale(language)),
        fonts: fonts,
        photoJpeg: demoJpeg(),
      );

      final out = Platform.environment['PDF_PREVIEW_DIR'];
      if (out != null) File('$out/order_$language.pdf').writeAsBytesSync(pdf);

      expect(latin1.decode(pdf.sublist(0, 5)), '%PDF-');
      expect(pageCount(pdf), 1);
      // The fonts are embedded, so the sheet prints the same everywhere.
      expect(latin1.decode(pdf), contains('IBMPlexSansArabic'));
    });
  }

  test('an order without photo or analysis still builds', () async {
    final pdf = await buildOrderPdf(
      demoOrder(hasPhoto: false).copyWith(notes: '', bodyShade: ''),
      l10n: lookupAppLocalizations(const Locale('ar')),
      fonts: await OrderPdfFonts.load(),
    );
    expect(pageCount(pdf), 1);
  });
}
