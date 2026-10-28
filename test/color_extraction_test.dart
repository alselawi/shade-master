import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadesmaster/analysis/color_extraction.dart';

import 'support/synthetic_photo.dart';

/// Reference implementation: test every pixel centre with ray casting.
int bruteForceCount(List<Offset> polygon, int width, int height) {
  bool inside(double px, double py) {
    var isInside = false;
    for (var i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final a = polygon[i], b = polygon[j];
      if ((a.dy > py) != (b.dy > py) && px < b.dx + (a.dx - b.dx) * (py - b.dy) / (a.dy - b.dy)) {
        isInside = !isInside;
      }
    }
    return isInside;
  }

  var count = 0;
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      if (inside(x + 0.5, y + 0.5)) count++;
    }
  }
  return count;
}

void main() {
  final photo = SyntheticPhoto(60, 40)..fillRect(const Rect.fromLTWH(10, 10, 20, 10), const Color(0xFFE8DCC0));
  final img = photo.toUnit8Img();

  test('a rectangle around a patch returns exactly its pixels', () {
    final colors = getAllColorsFromRegion(img, polygonOf(const Rect.fromLTWH(10, 10, 20, 10)));
    expect(colors.length, 200);
    expect(colors.toSet(), {const Color(0xFFE8DCC0)});
  });

  test('matches a brute force point-in-polygon test for convex, concave and self-crossing shapes', () {
    final random = math.Random(7);
    final shapes = <List<Offset>>[
      const [Offset(5, 5), Offset(50, 8), Offset(30, 35)],
      const [Offset(5, 5), Offset(55, 5), Offset(55, 35), Offset(30, 15), Offset(5, 35)],
      const [Offset(5, 5), Offset(55, 35), Offset(55, 5), Offset(5, 35)],
      for (var n = 0; n < 20; n++)
        [
          for (var k = 0; k < 3 + random.nextInt(8); k++)
            Offset(random.nextDouble() * 70 - 5, random.nextDouble() * 50 - 5)
        ],
    ];
    for (final shape in shapes) {
      expect(getAllColorsFromRegion(img, shape).length, bruteForceCount(shape, 60, 40), reason: '$shape');
    }
  });

  test('regions partly outside the image are clipped', () {
    final colors = getAllColorsFromRegion(img, polygonOf(const Rect.fromLTWH(-10, -10, 30, 30)));
    expect(colors.length, 20 * 20);
  });

  test('degenerate regions return nothing', () {
    expect(getAllColorsFromRegion(img, const [Offset(1, 1), Offset(9, 9)]), isEmpty);
    expect(getAllColorsFromRegion(img, polygonOf(const Rect.fromLTWH(100, 100, 5, 5))), isEmpty);
  });

  test('big regions are subsampled on an even grid', () {
    final colors = getAllColorsFromRegion(img, polygonOf(const Rect.fromLTWH(0, 0, 60, 40)), maxSamples: 600);
    expect(colors.length, lessThanOrEqualTo(600));
    expect(colors.length, greaterThan(600 ~/ 4));
  });
}
