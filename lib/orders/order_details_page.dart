import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:shadesmaster/app/app_scope.dart';
import 'package:shadesmaster/l10n/app_localizations.dart';
import 'package:shadesmaster/orders/lab_order.dart';
import 'package:shadesmaster/orders/order_form_page.dart';
import 'package:shadesmaster/orders/order_pdf.dart';

/// Shows the PDF of an order, ready to share with or print for the
/// laboratory, with actions to edit or delete the order.
class OrderDetailsPage extends StatefulWidget {
  final LabOrder order;
  const OrderDetailsPage({super.key, required this.order});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late LabOrder _order = widget.order;
  OrderPdfFonts? _fonts;
  Uint8List? _photo;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _load();
    }
  }

  Future<void> _load() async {
    final fonts = await OrderPdfFonts.load();
    if (!mounted) return;
    final photo = await AppScope.of(context).orders.loadPhoto(_order);
    if (!mounted) return;
    setState(() {
      _fonts = fonts;
      _photo = photo;
    });
  }

  Future<void> _edit() async {
    final saved = await Navigator.of(context).push<LabOrder>(
      MaterialPageRoute(builder: (_) => OrderFormPage(order: _order, isNew: false)),
    );
    if (saved != null && mounted) setState(() => _order = saved);
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.deleteOrderQuestion),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await AppScope.of(context).orders.delete(_order.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fonts = _fonts;
    return Scaffold(
      appBar: AppBar(
        title: Text(_order.caseCode),
        actions: [
          IconButton(tooltip: l10n.edit, onPressed: _edit, icon: const Icon(Icons.edit_outlined)),
          IconButton(tooltip: l10n.delete, onPressed: _delete, icon: const Icon(Icons.delete_outline)),
        ],
      ),
      body: fonts == null
          ? const Center(child: CircularProgressIndicator())
          : PdfPreview(
              // A new key rebuilds the preview after an edit.
              key: ValueKey(_order.toJson().toString()),
              build: (format) => buildOrderPdf(_order, l10n: l10n, fonts: fonts, photoJpeg: _photo, pageFormat: format),
              initialPageFormat: PdfPageFormat.a4,
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
              pdfFileName: 'lab-order-${_order.id}.pdf',
            ),
    );
  }
}
