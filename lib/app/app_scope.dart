import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shadesmaster/app/app_settings.dart';
import 'package:shadesmaster/orders/order_repository.dart';

/// Gives every screen access to the settings and the saved orders, and
/// rebuilds dependents when the settings change.
class AppScope extends InheritedNotifier<AppSettings> {
  final OrderRepository orders;

  const AppScope({super.key, required AppSettings settings, required this.orders, required super.child})
      : super(notifier: settings);

  AppSettings get settings => notifier!;

  static AppScope of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppScope>()!;
}

/// Where the app keeps its files: `settings.json` and the `orders` folder,
/// inside the app's private documents directory.
class AppStorage {
  final Directory root;
  AppStorage(this.root);

  static Future<AppStorage> open() async => AppStorage(await getApplicationDocumentsDirectory());

  File get settingsFile => File('${root.path}/settings.json');
  Directory get ordersDirectory => Directory('${root.path}/orders');
}
