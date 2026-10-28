import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shadesmaster/analysis/color_extraction.dart';
import 'package:shadesmaster/analysis/comparison.dart';
import 'package:shadesmaster/utils/int_to_letter.dart';
import 'package:shadesmaster/utils/rgb_to_lab.dart';
import 'package:shadesmaster/utils/simple_average_color.dart';
import 'package:shadesmaster/utils/unit_8_img.dart';

/// Analysis algorithm:
///
/// Let's say the user selected multiple regions of shade, and they
/// selected multiple regions of teeth.
///
/// Goal: to find out which shade region is the most visually similar
/// to the selected teeth. i.e. we must have one winner.
///
/// 1.  Extract all colors from all regions (polygons in image pixels)
/// 2.  The colors of each region is converted to CIELAB
/// 3.  erroneous colors that are way out of the median color of the region
///     (glare, shadows, gums caught at the edge) are pruned: the
///     [keepFraction] of pixels closest to the median color are kept
/// 4.  They are then sorted according to their lightness
/// 5.  the regions in all teeth are merged into a single region
/// 6.  every group is resampled to the same size by taking evenly spaced
///     samples of the sorted colors, i.e. the same lightness quantiles
/// 7.  A special function is then used to calculate DeltaE2000
///     (which represent visual distance) for groups
///     visual distance for groups is done by aligning the two
///     regions to each other, and comparing colors that are on
///     the same order of lightness.
///
/// The same comparison is also done for every tooth on its own.
///
/// The result is a CIEDE2000 difference: 0 means identical, and the dental
/// thresholds in [MatchCategory] tell how visible a difference is.
AnalysisResult analyzeImage(
  Unit8Img unit8Img,
  List<List<Offset>> teethRegions,
  List<List<Offset>> shadesRegions, {
  List<String?> shadeNames = const [],
}) {
  final teeth = teethRegions.map((polygon) => _RegionColors.extract(unit8Img, polygon)).toList();
  final shades = shadesRegions.map((polygon) => _RegionColors.extract(unit8Img, polygon)).toList();

  if (teeth.every((tooth) => tooth.isEmpty)) {
    throw const AnalysisException(AnalysisProblem.emptyTeeth);
  }
  if (shades.every((shade) => shade.isEmpty)) {
    throw const AnalysisException(AnalysisProblem.emptyShades);
  }

  // extract all dental colors into a single palette, then sort this one palette
  final dentalColors = [for (final tooth in teeth) ...tooth.prunedLabs]..sort(_byLightness);

  String? nameOf(int i) => i < shadeNames.length ? shadeNames[i] : null;

  final combined = _rankShades(dentalColors, shades, nameOf);
  final perTooth = <ToothResult>[
    for (var i = 0; i < teeth.length; i++)
      if (!teeth[i].isEmpty)
        ToothResult(
          index: i,
          averageColor: teeth[i].averageColor,
          shades: _rankShades(teeth[i].prunedLabs, shades, nameOf),
        ),
  ];

  return AnalysisResult(
    shades: combined,
    teeth: perTooth,
    teethAverageColor: simpleAverageColor([for (final tooth in teeth) ...tooth.colors]),
  );
}

/// Runs [analyzeImage] on a background isolate so the UI keeps responding.
Future<AnalysisResult> analyzeInBackground(
  Unit8Img unit8Img,
  List<List<Offset>> teethRegions,
  List<List<Offset>> shadesRegions, {
  List<String?> shadeNames = const [],
}) {
  return compute(
    (_) => analyzeImage(unit8Img, teethRegions, shadesRegions, shadeNames: shadeNames),
    null,
    debugLabel: 'shade analysis',
  );
}

/// Shades ranked from the closest (lowest delta) to the farthest.
List<ShadeResult> _rankShades(
  List<LabColor> sortedDentalColors,
  List<_RegionColors> shades,
  String? Function(int) nameOf,
) {
  final deltas = [
    for (final shade in shades) shade.isEmpty ? double.infinity : _deltaSorted(sortedDentalColors, shade.prunedLabs),
  ];
  final winner = deltas.reduce(math.min);

  final results = [
    for (var i = 0; i < shades.length; i++)
      ShadeResult(
        index: i,
        label: intToLetter(i + 1),
        shadeName: nameOf(i),
        delta: deltas[i],
        averageColor: shades[i].averageColor,
        winner: deltas[i] == winner,
      ),
  ];
  results.sort((a, b) => a.delta.compareTo(b.delta));
  return results;
}

/// Compares two groups of colors sorted by lightness, quantile by quantile.
double _deltaSorted(List<LabColor> sortedA, List<LabColor> sortedB) {
  final size = math.min(_comparisonSamples, math.min(sortedA.length, sortedB.length));
  return deltaGroups(_evenlySample(sortedA, size), _evenlySample(sortedB, size));
}

/// How many lightness quantiles of each group are compared.
const _comparisonSamples = 256;

/// Share of the pixels of a region kept after dropping the ones farthest from
/// its median color.
const keepFraction = 0.8;

int _byLightness(LabColor a, LabColor b) => a.l.compareTo(b.l);

class _RegionColors {
  final List<Color> colors;
  final List<LabColor> prunedLabs;
  final Color averageColor;

  _RegionColors(this.colors, this.prunedLabs, this.averageColor);

  factory _RegionColors.extract(Unit8Img unit8Img, List<Offset> polygon) {
    final colors = getAllColorsFromRegion(unit8Img, polygon);
    final labs = colors.map(rgbToLab).toList();
    return _RegionColors(colors, pruneOutliers(labs), simpleAverageColor(colors));
  }

  bool get isEmpty => colors.isEmpty;
}

/// Drops the colors farthest (in CIEDE2000) from the median color of the
/// region and returns the rest sorted by lightness.
///
/// The median is taken per component (L, a and b separately) so a few
/// extreme pixels such as a glare spot cannot move it.
List<LabColor> pruneOutliers(List<LabColor> labs, {double keep = keepFraction}) {
  if (labs.isEmpty) return [];
  final median = medianLab(labs);
  final byDistance = [for (final lab in labs) (lab, deltaE(lab, median))]..sort((a, b) => a.$2.compareTo(b.$2));
  final kept = math.max(1, (byDistance.length * keep).round());
  return [for (final entry in byDistance.take(kept)) entry.$1]..sort(_byLightness);
}

/// The per-component median of [labs].
LabColor medianLab(List<LabColor> labs) {
  double median(List<double> values) {
    values.sort();
    final middle = values.length ~/ 2;
    return values.length.isOdd ? values[middle] : (values[middle - 1] + values[middle]) / 2;
  }

  return LabColor(
    median([for (final lab in labs) lab.l]),
    median([for (final lab in labs) lab.a]),
    median([for (final lab in labs) lab.b]),
  );
}

class AnalysisResult {
  /// All shades ranked against all teeth together, closest first.
  final List<ShadeResult> shades;

  /// The ranking for every tooth on its own.
  final List<ToothResult> teeth;

  final Color teethAverageColor;

  const AnalysisResult({required this.shades, required this.teeth, required this.teethAverageColor});

  ShadeResult get winner => shades.first;
}

class ToothResult {
  /// Index of the tooth region (tooth number - 1).
  final int index;
  final Color averageColor;

  /// Shades ranked for this tooth, closest first.
  final List<ShadeResult> shades;

  const ToothResult({required this.index, required this.averageColor, required this.shades});

  ShadeResult get winner => shades.first;
}

class ShadeResult {
  /// Index of the shade region (A = 0, B = 1 ...).
  final int index;

  /// The letter drawn on the photo for this shade region.
  final String label;

  /// The shade guide name the dentist gave to the region, e.g. "A2".
  final String? shadeName;

  /// CIEDE2000 difference to the teeth. Infinite when the region had no pixels.
  final double delta;
  final Color averageColor;
  final bool winner;

  const ShadeResult({
    required this.index,
    required this.label,
    required this.delta,
    required this.averageColor,
    required this.winner,
    this.shadeName,
  });

  /// The shade guide name when given, otherwise the letter on the photo.
  String get name => shadeName ?? label;

  bool get hasPixels => delta.isFinite;

  MatchCategory get category => MatchCategory.of(delta);
}

/// How visible a color difference is, using the 50:50% perceptibility (PT)
/// and acceptability (AT) thresholds for dentistry, ΔE00 0.8 and 1.8
/// (Paravina et al. 2015, J Esthet Restor Dent 27:S1-S9), with the bands of
/// ISO/TR 28642.
enum MatchCategory {
  excellent,
  acceptable,
  moderatelyUnacceptable,
  clearlyUnacceptable,
  extremelyUnacceptable;

  static const perceptibilityThreshold = 0.8;
  static const acceptabilityThreshold = 1.8;

  static MatchCategory of(double delta) {
    if (delta <= perceptibilityThreshold) return excellent;
    if (delta <= acceptabilityThreshold) return acceptable;
    if (delta <= 2 * acceptabilityThreshold) return moderatelyUnacceptable;
    if (delta <= 3 * acceptabilityThreshold) return clearlyUnacceptable;
    return extremelyUnacceptable;
  }

  bool get isClinicallyAcceptable => index <= acceptable.index;
}

enum AnalysisProblem { emptyTeeth, emptyShades }

class AnalysisException implements Exception {
  final AnalysisProblem problem;
  const AnalysisException(this.problem);

  @override
  String toString() => 'AnalysisException($problem)';
}

List<T> _evenlySample<T>(List<T> list, int targetSize) {
  if (targetSize >= list.length) return List.from(list);
  if (targetSize <= 1) return [list[list.length ~/ 2]];

  double step = (list.length - 1) / (targetSize - 1);
  return List.generate(targetSize, (i) => list[(i * step).round()]);
}
