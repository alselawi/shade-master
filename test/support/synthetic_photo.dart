import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:shadesmaster/utils/unit_8_img.dart';

/// A fake intraoral photo built pixel by pixel: no real patient data.
class SyntheticPhoto {
  final int width;
  final int height;
  final Uint8List pixels;
  final math.Random _random;

  SyntheticPhoto(this.width, this.height, {Color background = const Color(0xFF7A2E35), int seed = 1})
      : pixels = Uint8List(width * height * 4),
        _random = math.Random(seed) {
    fillRect(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), background);
  }

  /// Fills [rect] with [color], adding up to [noise] levels of random sensor noise.
  void fillRect(Rect rect, Color color, {int noise = 0}) {
    final r = (color.r * 255).round(), g = (color.g * 255).round(), b = (color.b * 255).round();
    for (var y = rect.top.floor(); y < rect.bottom.ceil(); y++) {
      for (var x = rect.left.floor(); x < rect.right.ceil(); x++) {
        if (x < 0 || y < 0 || x >= width || y >= height) continue;
        final i = (y * width + x) * 4;
        final n = noise == 0 ? 0 : _random.nextInt(2 * noise + 1) - noise;
        pixels[i] = (r + n).clamp(0, 255);
        pixels[i + 1] = (g + n).clamp(0, 255);
        pixels[i + 2] = (b + n).clamp(0, 255);
        pixels[i + 3] = 255;
      }
    }
  }

  Unit8Img toUnit8Img() => Unit8Img(pixels, height, width);
}

/// The corners of [rect] as a polygon, like a region drawn around it.
List<Offset> polygonOf(Rect rect) => [rect.topLeft, rect.topRight, rect.bottomRight, rect.bottomLeft];
