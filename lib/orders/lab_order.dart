import 'package:flutter/foundation.dart';
import 'package:shadesmaster/analysis/analyze.dart';
import 'package:shadesmaster/orders/shade_guide.dart';

enum RestorationType { crown, veneer, bridge, implantCrown, inlayOnlay, other }

enum RestorationMaterial { zirconia, lithiumDisilicate, porcelainFusedToMetal, pmma, composite, other }

T _enumByName<T extends Enum>(List<T> values, Object? name, T fallback) =>
    values.firstWhere((value) => value.name == name, orElse: () => fallback);

/// One shade of the photo analysis, as stored with an order.
@immutable
class ShadeMatch {
  final String name;

  /// CIEDE2000 difference to the teeth; infinite when the area had no pixels.
  final double delta;

  /// Average color of the shade tab in the photo (ARGB).
  final int colorArgb;

  const ShadeMatch({required this.name, required this.delta, required this.colorArgb});

  factory ShadeMatch.fromResult(ShadeResult result) =>
      ShadeMatch(name: result.name, delta: result.delta, colorArgb: result.averageColor.toARGB32());

  MatchCategory get category => MatchCategory.of(delta);

  Map<String, Object?> toJson() => {'name': name, 'delta': delta.isFinite ? delta : null, 'color': colorArgb};

  factory ShadeMatch.fromJson(Map<String, Object?> json) => ShadeMatch(
        name: json['name'] as String,
        delta: (json['delta'] as num?)?.toDouble() ?? double.infinity,
        colorArgb: json['color'] as int,
      );
}

/// The closest shade for one tooth area drawn on the photo.
@immutable
class ToothMatch {
  /// The number drawn on the photo (1, 2 ...), not an FDI number.
  final int area;
  final ShadeMatch shade;

  const ToothMatch({required this.area, required this.shade});

  Map<String, Object?> toJson() => {'area': area, 'shade': shade.toJson()};

  factory ToothMatch.fromJson(Map<String, Object?> json) => ToothMatch(
        area: json['area'] as int,
        shade: ShadeMatch.fromJson((json['shade'] as Map).cast<String, Object?>()),
      );
}

@immutable
class LabOrder {
  final String id;
  final DateTime createdAt;

  final String caseCode;
  final String patientName;

  final String dentistName;
  final String clinicName;
  final String clinicPhone;
  final String labName;

  /// FDI tooth numbers, e.g. 11 for the upper right central incisor.
  final List<int> teeth;
  final RestorationType restorationType;
  final RestorationMaterial material;

  final ShadeGuide shadeGuide;
  final String bodyShade;
  final String cervicalShade;
  final String incisalShade;
  final String stumpShade;

  /// The shades of the photo analysis, closest first. Empty without a photo.
  final List<ShadeMatch> analysis;
  final List<ToothMatch> toothAnalysis;

  final String notes;
  final DateTime? dueDate;

  /// Whether the annotated photo is saved next to the order.
  final bool hasPhoto;

  const LabOrder({
    required this.id,
    required this.createdAt,
    this.caseCode = '',
    this.patientName = '',
    this.dentistName = '',
    this.clinicName = '',
    this.clinicPhone = '',
    this.labName = '',
    this.teeth = const [],
    this.restorationType = RestorationType.crown,
    this.material = RestorationMaterial.zirconia,
    this.shadeGuide = ShadeGuide.classical,
    this.bodyShade = '',
    this.cervicalShade = '',
    this.incisalShade = '',
    this.stumpShade = '',
    this.analysis = const [],
    this.toothAnalysis = const [],
    this.notes = '',
    this.dueDate,
    this.hasPhoto = false,
  });

  /// A readable, sortable id such as 20261028-143205.
  static String newId(DateTime time) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${time.year}${two(time.month)}${two(time.day)}-${two(time.hour)}${two(time.minute)}${two(time.second)}';
  }

  /// A new order from the photo analysis. The body shade is filled in only
  /// when the closest tab was given a shade guide name.
  factory LabOrder.fromAnalysis(
    AnalysisResult result, {
    required DateTime now,
    required ShadeGuide shadeGuide,
    bool hasPhoto = true,
  }) {
    final winner = result.winner;
    return LabOrder(
      id: newId(now),
      createdAt: now,
      shadeGuide: shadeGuide,
      bodyShade: winner.shadeName ?? '',
      analysis: [for (final shade in result.shades) ShadeMatch.fromResult(shade)],
      toothAnalysis: [
        for (final tooth in result.teeth) ToothMatch(area: tooth.index + 1, shade: ShadeMatch.fromResult(tooth.winner)),
      ],
      hasPhoto: hasPhoto,
    );
  }

  ShadeMatch? get suggestedShade => analysis.isEmpty ? null : analysis.first;

  LabOrder copyWith({
    String? caseCode,
    String? patientName,
    String? dentistName,
    String? clinicName,
    String? clinicPhone,
    String? labName,
    List<int>? teeth,
    RestorationType? restorationType,
    RestorationMaterial? material,
    ShadeGuide? shadeGuide,
    String? bodyShade,
    String? cervicalShade,
    String? incisalShade,
    String? stumpShade,
    String? notes,
    DateTime? dueDate,
    bool clearDueDate = false,
    bool? hasPhoto,
  }) {
    return LabOrder(
      id: id,
      createdAt: createdAt,
      caseCode: caseCode ?? this.caseCode,
      patientName: patientName ?? this.patientName,
      dentistName: dentistName ?? this.dentistName,
      clinicName: clinicName ?? this.clinicName,
      clinicPhone: clinicPhone ?? this.clinicPhone,
      labName: labName ?? this.labName,
      teeth: teeth ?? this.teeth,
      restorationType: restorationType ?? this.restorationType,
      material: material ?? this.material,
      shadeGuide: shadeGuide ?? this.shadeGuide,
      bodyShade: bodyShade ?? this.bodyShade,
      cervicalShade: cervicalShade ?? this.cervicalShade,
      incisalShade: incisalShade ?? this.incisalShade,
      stumpShade: stumpShade ?? this.stumpShade,
      analysis: analysis,
      toothAnalysis: toothAnalysis,
      notes: notes ?? this.notes,
      dueDate: clearDueDate ? null : dueDate ?? this.dueDate,
      hasPhoto: hasPhoto ?? this.hasPhoto,
    );
  }

  Map<String, Object?> toJson() => {
        'version': 1,
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'caseCode': caseCode,
        'patientName': patientName,
        'dentistName': dentistName,
        'clinicName': clinicName,
        'clinicPhone': clinicPhone,
        'labName': labName,
        'teeth': teeth,
        'restorationType': restorationType.name,
        'material': material.name,
        'shadeGuide': shadeGuide.name,
        'bodyShade': bodyShade,
        'cervicalShade': cervicalShade,
        'incisalShade': incisalShade,
        'stumpShade': stumpShade,
        'analysis': [for (final shade in analysis) shade.toJson()],
        'toothAnalysis': [for (final tooth in toothAnalysis) tooth.toJson()],
        'notes': notes,
        'dueDate': dueDate?.toIso8601String(),
        'hasPhoto': hasPhoto,
      };

  factory LabOrder.fromJson(Map<String, Object?> json) {
    List<Map<String, Object?>> maps(Object? list) =>
        [for (final item in (list as List? ?? const [])) (item as Map).cast<String, Object?>()];
    final dueDate = json['dueDate'] as String?;
    return LabOrder(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      caseCode: json['caseCode'] as String? ?? '',
      patientName: json['patientName'] as String? ?? '',
      dentistName: json['dentistName'] as String? ?? '',
      clinicName: json['clinicName'] as String? ?? '',
      clinicPhone: json['clinicPhone'] as String? ?? '',
      labName: json['labName'] as String? ?? '',
      teeth: [for (final tooth in (json['teeth'] as List? ?? const [])) tooth as int],
      restorationType: _enumByName(RestorationType.values, json['restorationType'], RestorationType.crown),
      material: _enumByName(RestorationMaterial.values, json['material'], RestorationMaterial.zirconia),
      shadeGuide: ShadeGuide.fromName(json['shadeGuide'] as String?),
      bodyShade: json['bodyShade'] as String? ?? '',
      cervicalShade: json['cervicalShade'] as String? ?? '',
      incisalShade: json['incisalShade'] as String? ?? '',
      stumpShade: json['stumpShade'] as String? ?? '',
      analysis: [for (final shade in maps(json['analysis'])) ShadeMatch.fromJson(shade)],
      toothAnalysis: [for (final tooth in maps(json['toothAnalysis'])) ToothMatch.fromJson(tooth)],
      notes: json['notes'] as String? ?? '',
      dueDate: dueDate == null ? null : DateTime.parse(dueDate),
      hasPhoto: json['hasPhoto'] as bool? ?? false,
    );
  }
}
