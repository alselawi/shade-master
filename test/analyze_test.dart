import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadesmaster/analysis/analyze.dart';
import 'package:shadesmaster/utils/rgb_to_lab.dart';

import 'support/synthetic_photo.dart';

// Demo colors only, chosen to look like enamel and shade guide tabs.
const toothColor = Color(0xFFE2D5BC);
const shadeColors = [
  Color(0xFFF0E8D8), // A: lighter
  Color(0xFFE3D6BD), // B: closest to the tooth
  Color(0xFFD2BA92), // C: darker and more yellow
  Color(0xFFC8C8C8), // D: grey
];

const toothRect = Rect.fromLTWH(20, 20, 60, 80);
const tooth2Rect = Rect.fromLTWH(100, 20, 60, 80);
List<Rect> shadeRects = [for (var i = 0; i < 4; i++) Rect.fromLTWH(20.0 + i * 45, 130, 35, 60)];

SyntheticPhoto demoPhoto({Color tooth2 = toothColor}) {
  final photo = SyntheticPhoto(200, 220)
    ..fillRect(toothRect, toothColor, noise: 4)
    ..fillRect(tooth2Rect, tooth2, noise: 4);
  for (var i = 0; i < shadeColors.length; i++) {
    photo.fillRect(shadeRects[i], shadeColors[i], noise: 4);
  }
  return photo;
}

void main() {
  test('the shade with the closest color wins and the ranking is sorted', () {
    final result = analyzeImage(
      demoPhoto().toUnit8Img(),
      [polygonOf(toothRect)],
      [for (final rect in shadeRects) polygonOf(rect)],
    );

    expect(result.winner.label, 'B');
    expect(result.winner.winner, isTrue);
    expect(result.shades.map((s) => s.label), ['B', 'A', 'C', 'D']);
    expect(result.winner.delta, lessThan(MatchCategory.perceptibilityThreshold));
    expect(result.winner.category, MatchCategory.excellent);
    expect(result.shades.last.category, MatchCategory.extremelyUnacceptable);
    expect(result.shades.where((s) => s.winner), hasLength(1));
  });

  test('a glare spot and a strip of gum inside the tooth area do not change the winner', () {
    final photo = demoPhoto()
      ..fillRect(const Rect.fromLTWH(30, 30, 15, 15), const Color(0xFFFFFFFF))
      ..fillRect(const Rect.fromLTWH(20, 20, 60, 6), const Color(0xFF7A2E35));
    final result = analyzeImage(
      photo.toUnit8Img(),
      [polygonOf(toothRect)],
      [for (final rect in shadeRects) polygonOf(rect)],
    );
    expect(result.winner.label, 'B');
    expect(result.winner.category.isClinicallyAcceptable, isTrue);
  });

  test('every tooth is also ranked on its own', () {
    final result = analyzeImage(
      demoPhoto(tooth2: shadeColors[2]).toUnit8Img(),
      [polygonOf(toothRect), polygonOf(tooth2Rect)],
      [for (final rect in shadeRects) polygonOf(rect)],
    );
    expect(result.teeth, hasLength(2));
    expect(result.teeth[0].winner.label, 'B');
    expect(result.teeth[1].winner.label, 'C');
  });

  test('shade guide names are carried to the results', () {
    final result = analyzeImage(
      demoPhoto().toUnit8Img(),
      [polygonOf(toothRect)],
      [for (final rect in shadeRects) polygonOf(rect)],
      shadeNames: ['A1', 'A2', null, 'C2'],
    );
    expect(result.winner.name, 'A2');
    expect(result.shades.firstWhere((s) => s.label == 'C').name, 'C');
  });

  test('the average color of a region is the color of its pixels', () {
    final result = analyzeImage(
      SyntheticPhoto(40, 40).toUnit8Img(),
      [polygonOf(const Rect.fromLTWH(0, 0, 10, 10))],
      [polygonOf(const Rect.fromLTWH(20, 20, 10, 10))],
    );
    expect(result.winner.averageColor.toARGB32(), 0xFF7A2E35);
    expect(result.winner.delta, 0);
  });

  test('a shade area without pixels is ranked last and never wins', () {
    final result = analyzeImage(
      demoPhoto().toUnit8Img(),
      [polygonOf(toothRect)],
      [polygonOf(const Rect.fromLTWH(500, 500, 10, 10)), polygonOf(shadeRects[3])],
    );
    expect(result.winner.label, 'B');
    expect(result.shades.last.label, 'A');
    expect(result.shades.last.hasPixels, isFalse);
    expect(result.shades.last.winner, isFalse);
  });

  test('empty teeth or shade areas are reported', () {
    final img = demoPhoto().toUnit8Img();
    final outside = polygonOf(const Rect.fromLTWH(500, 500, 10, 10));
    expect(
      () => analyzeImage(img, [outside], [polygonOf(shadeRects[0])]),
      throwsA(isA<AnalysisException>().having((e) => e.problem, 'problem', AnalysisProblem.emptyTeeth)),
    );
    expect(
      () => analyzeImage(img, [polygonOf(toothRect)], [outside]),
      throwsA(isA<AnalysisException>().having((e) => e.problem, 'problem', AnalysisProblem.emptyShades)),
    );
  });

  test('pruneOutliers keeps the colors closest to the median, sorted by lightness', () {
    final labs = [
      for (var i = 0; i < 8; i++) LabColor(70.0 + i, 1, 15),
      const LabColor(100, 0, 0), // glare
      const LabColor(20, 30, 10), // gum
    ];
    final kept = pruneOutliers(labs);
    expect(kept, hasLength(8));
    expect(kept.map((c) => c.l), [70, 71, 72, 73, 74, 75, 76, 77]);
  });

  test('medianLab is taken per component', () {
    final median = medianLab(const [LabColor(10, 5, -1), LabColor(30, -5, 3), LabColor(20, 0, 100)]);
    expect(median, const LabColor(20, 0, 3));
  });

  test('match categories follow the dental perceptibility and acceptability thresholds', () {
    expect(MatchCategory.of(0.5), MatchCategory.excellent);
    expect(MatchCategory.of(0.8), MatchCategory.excellent);
    expect(MatchCategory.of(1.8), MatchCategory.acceptable);
    expect(MatchCategory.of(3.0), MatchCategory.moderatelyUnacceptable);
    expect(MatchCategory.of(5.0), MatchCategory.clearlyUnacceptable);
    expect(MatchCategory.of(6.0), MatchCategory.extremelyUnacceptable);
  });
}
