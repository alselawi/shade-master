import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:shadesmaster/orders/lab_order.dart';
import 'package:shadesmaster/orders/shade_guide.dart';

/// Values copied into every new lab order.
@immutable
class OrderDefaults {
  final String dentistName;
  final String clinicName;
  final String clinicPhone;
  final String labName;
  final ShadeGuide shadeGuide;

  const OrderDefaults({
    this.dentistName = '',
    this.clinicName = '',
    this.clinicPhone = '',
    this.labName = '',
    this.shadeGuide = ShadeGuide.classical,
  });

  OrderDefaults copyWith({
    String? dentistName,
    String? clinicName,
    String? clinicPhone,
    String? labName,
    ShadeGuide? shadeGuide,
  }) {
    return OrderDefaults(
      dentistName: dentistName ?? this.dentistName,
      clinicName: clinicName ?? this.clinicName,
      clinicPhone: clinicPhone ?? this.clinicPhone,
      labName: labName ?? this.labName,
      shadeGuide: shadeGuide ?? this.shadeGuide,
    );
  }

  /// Copies the clinic details and shade guide into a new order.
  LabOrder applyTo(LabOrder order) {
    return order.copyWith(
      dentistName: dentistName,
      clinicName: clinicName,
      clinicPhone: clinicPhone,
      labName: labName,
      shadeGuide: shadeGuide,
    );
  }

  Map<String, Object?> toJson() => {
        'dentistName': dentistName,
        'clinicName': clinicName,
        'clinicPhone': clinicPhone,
        'labName': labName,
        'shadeGuide': shadeGuide.name,
      };

  factory OrderDefaults.fromJson(Map<String, Object?> json) {
    return OrderDefaults(
      dentistName: json['dentistName'] as String? ?? '',
      clinicName: json['clinicName'] as String? ?? '',
      clinicPhone: json['clinicPhone'] as String? ?? '',
      labName: json['labName'] as String? ?? '',
      shadeGuide: ShadeGuide.fromName(json['shadeGuide'] as String?),
    );
  }
}

/// The user's preferences, saved as JSON in [file] after every change.
///
/// Arabic is the default language.
class AppSettings extends ChangeNotifier {
  static const supportedLanguages = ['ar', 'en'];

  final File? file;
  Locale _locale;
  OrderDefaults _defaults;

  AppSettings({Locale locale = const Locale('ar'), OrderDefaults defaults = const OrderDefaults(), this.file})
      : _locale = locale,
        _defaults = defaults;

  Locale get locale => _locale;
  OrderDefaults get defaults => _defaults;

  set locale(Locale value) {
    if (value == _locale) return;
    _locale = value;
    _changed();
  }

  /// Saves new defaults. Nothing on screen depends on them, so listeners are
  /// not notified and the app is not rebuilt on every keystroke.
  set defaults(OrderDefaults value) {
    _defaults = value;
    save();
  }

  void _changed() {
    notifyListeners();
    save();
  }

  Map<String, Object?> toJson() => {'language': _locale.languageCode, 'defaults': _defaults.toJson()};

  Future<void> _lastSave = Future.value();

  /// Writes the settings; saves are queued so quick edits never interleave.
  Future<void> save() {
    final file = this.file;
    if (file == null) return Future.value();
    final json = jsonEncode(toJson());
    return _lastSave = _lastSave.then((_) async {
      await file.parent.create(recursive: true);
      await file.writeAsString(json, flush: true);
    });
  }

  /// Reads [file]; a missing or unreadable file gives the default settings.
  static Future<AppSettings> load(File file) async {
    try {
      final json = jsonDecode(await file.readAsString()) as Map<String, Object?>;
      final language = json['language'] as String?;
      return AppSettings(
        file: file,
        locale: Locale(supportedLanguages.contains(language) ? language! : 'ar'),
        defaults: OrderDefaults.fromJson((json['defaults'] as Map?)?.cast<String, Object?>() ?? const {}),
      );
    } on Object {
      return AppSettings(file: file);
    }
  }
}
