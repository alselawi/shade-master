import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadesmaster/orders/lab_order.dart';
import 'package:shadesmaster/orders/order_form_page.dart';
import 'package:shadesmaster/orders/order_repository.dart';
import 'package:shadesmaster/orders/tooth_chart.dart';

import 'support/demo_order.dart';
import 'support/test_app.dart';

/// Opens the form from a button so the page can pop with its result.
Widget launcher(LabOrder order, void Function(LabOrder?) onResult) => Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () async => onResult(
            await Navigator.of(context).push<LabOrder>(MaterialPageRoute(builder: (_) => OrderFormPage(order: order))),
          ),
          child: const Text('open'),
        ),
      ),
    );

void main() {
  testWidgets('required fields are checked before saving', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    final orders = OrderRepository(tempStorage());
    LabOrder? result;
    await tester.pumpWidget(testApp(
      launcher(LabOrder(id: '20261028-100000', createdAt: DateTime(2026, 10, 28)), (order) => result = order),
      orders: orders,
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Required'), findsOneWidget);
    expect(find.text('Select at least one tooth'), findsOneWidget);
    expect(find.text('Choose the body shade'), findsOneWidget);
    expect(result, isNull);

    await tester.enterText(find.widgetWithText(TextFormField, 'Case code'), 'DEMO-002');
    await tester.ensureVisible(find.text('11'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('11'));
    await tester.tap(find.text('21'));
    await tester.pump();

    await tester.ensureVisible(find.widgetWithText(DropdownButtonFormField<String>, 'Body shade'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(DropdownButtonFormField<String>, 'Body shade'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A3').last);
    await tester.pumpAndSettle();

    expect(find.text('Select at least one tooth'), findsNothing);
    // Saving writes files: let the real file system work while waiting.
    await tester.runAsync(() async {
      await tester.tap(find.byTooltip('Save'));
      for (var i = 0; i < 50 && result == null; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
    });
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.caseCode, 'DEMO-002');
    expect(result!.teeth, [11, 21]);
    expect(result!.bodyShade, 'A3');
    final stored = await tester.runAsync(orders.list);
    expect(stored!.single.caseCode, 'DEMO-002');
  });

  testWidgets('the tooth chart keeps the patient layout in Arabic', (tester) async {
    final selected = <int>{};
    await tester.pumpWidget(testApp(
      StatefulBuilder(
        builder: (context, setState) => Scaffold(
          body: ToothChart(selected: selected, onToggle: (tooth) => setState(() => selected.add(tooth))),
        ),
      ),
      language: 'ar',
    ));

    // 18 is on the left of 11, as when facing the patient, even right to left.
    expect(tester.getCenter(find.text('18')).dx, lessThan(tester.getCenter(find.text('11')).dx));
    expect(tester.getCenter(find.text('11')).dx, lessThan(tester.getCenter(find.text('28')).dx));
    expect(find.text('يمين المريض'), findsOneWidget);
    await tester.tap(find.text('36'));
    await tester.pump();
    expect(selected, {36});
  });

  testWidgets('an existing order opens with its values', (tester) async {
    await tester.pumpWidget(testApp(OrderFormPage(order: demoOrder(hasPhoto: false), isNew: false)));
    await tester.pumpAndSettle();
    expect(find.text('Edit lab order'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'DEMO-001'), findsOneWidget);
    expect(find.text('Suggested by the photo: A2'), findsOneWidget);
  });
}
