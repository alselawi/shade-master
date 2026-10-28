import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadesmaster/app/app_settings.dart';
import 'package:shadesmaster/orders/shade_guide.dart';

import 'support/test_app.dart';

void main() {
  test('settings round-trip through the JSON file', () async {
    final file = File('${tempStorage().path}/settings.json');
    final settings = AppSettings(file: file)
      ..locale = const Locale('en')
      ..defaults = const OrderDefaults(
        dentistName: 'د. تجربة',
        clinicName: 'Demo Clinic',
        clinicPhone: '000',
        labName: 'Demo Lab',
        shadeGuide: ShadeGuide.threeDMaster,
      );
    await settings.save();

    final loaded = await AppSettings.load(file);
    expect(loaded.locale, const Locale('en'));
    expect(loaded.defaults.dentistName, 'د. تجربة');
    expect(loaded.defaults.labName, 'Demo Lab');
    expect(loaded.defaults.shadeGuide, ShadeGuide.threeDMaster);
  });

  test('a missing or broken settings file gives Arabic defaults', () async {
    final dir = tempStorage();
    expect((await AppSettings.load(File('${dir.path}/missing.json'))).locale, const Locale('ar'));
    final broken = File('${dir.path}/broken.json')..writeAsStringSync('{not json');
    final loaded = await AppSettings.load(broken);
    expect(loaded.locale, const Locale('ar'));
    expect(loaded.defaults.shadeGuide, ShadeGuide.classical);
  });

  test('shade guides list the standard names', () {
    expect(ShadeGuide.classical.shades, hasLength(16));
    expect(ShadeGuide.classical.shades, containsAll(['A1', 'A3.5', 'D4']));
    expect(ShadeGuide.threeDMaster.shades, hasLength(29));
    expect(ShadeGuide.threeDMaster.shades, containsAll(['0M1', '2L1.5', '5M3']));
    expect(ShadeGuide.fromName('unknown'), ShadeGuide.classical);
  });
}
