import 'package:flutter/material.dart';
import 'package:shadesmaster/app/app_scope.dart';
import 'package:shadesmaster/l10n/app_localizations.dart';
import 'package:shadesmaster/orders/lab_order.dart';
import 'package:shadesmaster/orders/order_details_page.dart';
import 'package:shadesmaster/orders/order_form_page.dart';
import 'package:shadesmaster/utils/format.dart';

/// The saved lab orders, newest first.
class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  Future<List<LabOrder>>? _orders;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _orders ??= AppScope.of(context).orders.list();
  }

  void _reload() => setState(() => _orders = AppScope.of(context).orders.list());

  Future<void> _newOrder() async {
    final settings = AppScope.of(context).settings;
    final now = DateTime.now();
    final draft = settings.defaults.applyTo(LabOrder(id: LabOrder.newId(now), createdAt: now));
    final saved = await Navigator.of(context).push<LabOrder>(
      MaterialPageRoute(builder: (_) => OrderFormPage(order: draft)),
    );
    if (saved != null && mounted) await openOrder(saved);
  }

  Future<void> openOrder(LabOrder order) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => OrderDetailsPage(order: order)));
    if (mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.labOrders)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _newOrder,
        icon: const Icon(Icons.add),
        label: Text(l10n.newOrderWithoutPhoto),
      ),
      body: FutureBuilder<List<LabOrder>>(
        future: _orders,
        builder: (context, snapshot) {
          final orders = snapshot.data;
          if (orders == null) return const Center(child: CircularProgressIndicator());
          if (orders.isEmpty) return Center(child: Text(l10n.noOrders));
          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final order = orders[index];
              return ListTile(
                leading: Icon(order.hasPhoto ? Icons.photo_outlined : Icons.assignment_outlined),
                title: Text(order.caseCode),
                subtitle: Text(
                  '${l10n.orderSummary(formatTeeth(order.teeth), order.bodyShade)}\n'
                  '${l10n.createdOn(formatDate(order.createdAt))}',
                ),
                isThreeLine: true,
                onTap: () => openOrder(order),
              );
            },
          );
        },
      ),
    );
  }
}
