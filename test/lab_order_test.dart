import 'dart:convert';
import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadesmaster/analysis/analyze.dart';
import 'package:shadesmaster/app/app_settings.dart';
import 'package:shadesmaster/orders/lab_order.dart';
import 'package:shadesmaster/orders/order_repository.dart';
import 'package:shadesmaster/orders/shade_guide.dart';

import 'support/demo_order.dart';
import 'support/test_app.dart';

ShadeResult result(int index, double delta, {String? name, bool winner = false}) => ShadeResult(
      index: index,
      label: String.fromCharCode(65 + index),
      shadeName: name,
      delta: delta,
      averageColor: const Color(0xFFE3D6BD),
      winner: winner,
    );

void main() {
  test('orders survive a JSON round-trip', () {
    final order = demoOrder();
    final copy = LabOrder.fromJson(jsonDecode(jsonEncode(order.toJson())) as Map<String, Object?>);
    expect(copy.toJson(), order.toJson());
    expect(copy.teeth, [11, 21]);
    expect(copy.material, RestorationMaterial.lithiumDisilicate);
    expect(copy.analysis.first.category, MatchCategory.excellent);
  });

  test('an empty shade area is stored without breaking JSON', () {
    const match = ShadeMatch(name: 'B', delta: double.infinity, colorArgb: 0);
    final copy = ShadeMatch.fromJson(jsonDecode(jsonEncode(match.toJson())) as Map<String, Object?>);
    expect(copy.delta, double.infinity);
  });

  test('an order from the analysis keeps the ranking and only uses real shade names', () {
    final analysis = AnalysisResult(
      shades: [result(1, 0.5, name: 'A2', winner: true), result(0, 2.5)],
      teeth: [
        ToothResult(index: 0, averageColor: const Color(0xFFE3D6BD), shades: [result(1, 0.6, name: 'A2')])
      ],
      teethAverageColor: const Color(0xFFE3D6BD),
    );
    final order =
        LabOrder.fromAnalysis(analysis, now: DateTime(2026, 10, 28, 9, 5, 7), shadeGuide: ShadeGuide.classical);
    expect(order.id, '20261028-090507');
    expect(order.bodyShade, 'A2');
    expect(order.analysis.map((m) => m.name), ['A2', 'A']);
    expect(order.toothAnalysis.single.area, 1);

    final unnamed = AnalysisResult(
      shades: [result(0, 0.5, winner: true)],
      teeth: const [],
      teethAverageColor: const Color(0xFFE3D6BD),
    );
    final draft = LabOrder.fromAnalysis(unnamed, now: DateTime(2026), shadeGuide: ShadeGuide.classical);
    expect(draft.bodyShade, isEmpty, reason: 'a letter drawn on the photo is not a shade guide name');
    expect(draft.suggestedShade!.name, 'A');
  });

  test('defaults fill the clinic details of a new order', () {
    const defaults = OrderDefaults(dentistName: 'Dr Demo', labName: 'Demo Lab', shadeGuide: ShadeGuide.threeDMaster);
    final order = defaults.applyTo(LabOrder(id: '1', createdAt: DateTime(2026)));
    expect(order.dentistName, 'Dr Demo');
    expect(order.labName, 'Demo Lab');
    expect(order.shadeGuide, ShadeGuide.threeDMaster);
  });

  group('OrderRepository', () {
    late Directory dir;
    late OrderRepository repository;
    setUp(() {
      dir = tempStorage();
      repository = OrderRepository(Directory('${dir.path}/orders'));
    });

    test('saves, lists newest first, loads the photo and deletes', () async {
      final older = demoOrder().copyWith(caseCode: 'OLD');
      final newer = LabOrder(id: '20261029-080000', createdAt: DateTime(2026, 10, 29, 8), caseCode: 'NEW');
      final photo = demoJpeg();

      final saved = await repository.save(older, photoJpeg: photo);
      expect(saved.hasPhoto, isTrue);
      await repository.save(newer);

      final orders = await repository.list();
      expect(orders.map((o) => o.caseCode), ['NEW', 'OLD']);
      expect(await repository.loadPhoto(orders[1]), photo);
      expect(await repository.loadPhoto(orders[0]), isNull);

      await repository.delete(older.id);
      expect((await repository.list()).map((o) => o.caseCode), ['NEW']);
    });

    test('an order claiming a photo without one is stored without it', () async {
      final saved = await repository.save(demoOrder(hasPhoto: true));
      expect(saved.hasPhoto, isFalse);
    });

    test('a corrupt order file is skipped instead of hiding every order', () async {
      await repository.save(demoOrder());
      final broken = Directory('${dir.path}/orders/broken')..createSync(recursive: true);
      File('${broken.path}/order.json').writeAsStringSync('{');
      expect(await repository.list(), hasLength(1));
    });

    test('listing before anything was saved returns nothing', () async {
      expect(await repository.list(), isEmpty);
    });
  });
}
