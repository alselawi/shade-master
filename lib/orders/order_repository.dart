import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:shadesmaster/orders/lab_order.dart';

/// Keeps lab orders on the device only: one folder per order holding
/// `order.json` and, when the order came from a photo, `photo.jpg` (the
/// annotated photo used in the PDF). Nothing is uploaded anywhere.
class OrderRepository {
  final Directory root;
  OrderRepository(this.root);

  Directory _folder(String id) => Directory('${root.path}/$id');
  File _orderFile(String id) => File('${_folder(id).path}/order.json');
  File photoFile(String id) => File('${_folder(id).path}/photo.jpg');

  /// All saved orders, newest first. Unreadable files are skipped.
  Future<List<LabOrder>> list() async {
    if (!await root.exists()) return [];
    final orders = <LabOrder>[];
    await for (final entity in root.list()) {
      if (entity is! Directory) continue;
      final file = File('${entity.path}/order.json');
      try {
        orders.add(LabOrder.fromJson(jsonDecode(await file.readAsString()) as Map<String, Object?>));
      } on Object {
        continue;
      }
    }
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  /// Saves [order] (and [photoJpeg] when given) and returns it as stored.
  Future<LabOrder> save(LabOrder order, {Uint8List? photoJpeg}) async {
    await _folder(order.id).create(recursive: true);
    if (photoJpeg != null) await photoFile(order.id).writeAsBytes(photoJpeg, flush: true);
    final saved = order.copyWith(hasPhoto: order.hasPhoto && await photoFile(order.id).exists());
    // Write to a temporary file first so a crash never leaves half an order.
    final temporary = File('${_orderFile(order.id).path}.tmp');
    await temporary.writeAsString(const JsonEncoder.withIndent('  ').convert(saved.toJson()), flush: true);
    await temporary.rename(_orderFile(order.id).path);
    return saved;
  }

  Future<Uint8List?> loadPhoto(LabOrder order) async {
    final file = photoFile(order.id);
    if (!order.hasPhoto || !await file.exists()) return null;
    return file.readAsBytes();
  }

  Future<void> delete(String id) async {
    final folder = _folder(id);
    if (await folder.exists()) await folder.delete(recursive: true);
  }
}
