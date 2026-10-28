import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shadesmaster/utils/unit_8_img.dart';

/// Extracts the colors of the pixels within a polygonal region.
///
/// The polygon is given in image pixel coordinates. A pixel belongs to the
/// region when its centre is inside the polygon (even-odd rule, so the
/// self-intersecting shapes a finger can draw behave like the original
/// ray-casting implementation).
///
/// The region is filled one row at a time (scanline): for each row the
/// crossings with the polygon edges are computed once, and every pixel between
/// a pair of crossings is inside. This is O(h * n + k) instead of testing every
/// pixel of the bounding box against every edge.
///
/// When the region holds more than [maxSamples] pixels, an evenly spaced grid
/// of them is taken instead, which keeps big regions on big photos fast
/// without changing their color distribution.
///
/// [unit8Img] RGBA pixel data in row-major order (4 bytes per pixel: R,G,B,A)
/// [polygon] List of vertices defining the polygonal region
///
/// Returns a list of Color objects found within the region
List<Color> getAllColorsFromRegion(Unit8Img unit8Img, List<Offset> polygon, {int maxSamples = 20000}) {
  final pixels = unit8Img.pixels;
  final width = unit8Img.width;
  final height = unit8Img.height;

  // Early returns for invalid input
  if (polygon.length < 3 || pixels.isEmpty) return [];
  if (width <= 0 || height <= 0) return [];

  // Ensure we have enough pixel data (4 bytes per pixel for RGBA)
  if (pixels.length < width * height * 4) return [];

  final spans = _scanlineSpans(polygon, width, height);

  int total = 0;
  for (int i = 0; i < spans.length; i += 3) {
    total += spans[i + 2] - spans[i + 1] + 1;
  }
  if (total == 0) return [];

  // Keep every `step`-th row and column when the region is too big.
  final step = total > maxSamples ? math.sqrt(total / maxSamples).ceil() : 1;

  final List<Color> extractedColors = <Color>[];
  for (int i = 0; i < spans.length; i += 3) {
    final y = spans[i];
    if (y % step != 0) continue;
    final startX = spans[i + 1];
    final firstX = startX + (step - startX % step) % step;
    for (int x = firstX; x <= spans[i + 2]; x += step) {
      extractedColors.add(_extractColorAtPixel(pixels, x, y, width));
    }
  }

  return extractedColors;
}

/// Returns the horizontal runs of pixels inside [polygon] as a flat list of
/// `y, firstX, lastX` triplets, clamped to the image.
Int32List _scanlineSpans(List<Offset> polygon, int width, int height) {
  final boundingBox = _calculateBoundingBox(polygon);
  final startY = math.max(0, (boundingBox.top - 0.5).floor());
  final endY = math.min(height - 1, (boundingBox.bottom - 0.5).ceil());

  final spans = <int>[];
  final crossings = <double>[];
  final vertexCount = polygon.length;

  for (int y = startY; y <= endY; y++) {
    final double centreY = y + 0.5;
    crossings.clear();

    int prevIndex = vertexCount - 1;
    for (int currentIndex = 0; currentIndex < vertexCount; currentIndex++) {
      final Offset currentVertex = polygon[currentIndex];
      final Offset prevVertex = polygon[prevIndex];

      // Edge must straddle the horizontal line through the pixel centres.
      // Using > for both ends avoids double-counting shared vertices.
      if ((currentVertex.dy > centreY) != (prevVertex.dy > centreY)) {
        crossings.add(
          prevVertex.dx +
              (currentVertex.dx - prevVertex.dx) * (centreY - prevVertex.dy) / (currentVertex.dy - prevVertex.dy),
        );
      }
      prevIndex = currentIndex;
    }

    crossings.sort();
    for (int i = 0; i + 1 < crossings.length; i += 2) {
      // Pixel x is inside when its centre x + 0.5 lies in [left, right).
      final first = math.max(0, (crossings[i] - 0.5).ceil());
      final last = math.min(width - 1, (crossings[i + 1] - 0.5).ceil() - 1);
      if (last >= first) spans.addAll([y, first, last]);
    }
  }

  return Int32List.fromList(spans);
}

/// Calculates the axis-aligned bounding box of a list of points.
///
/// [points] List of points to calculate bounding box for
///
/// Returns a Rect representing the bounding box
Rect _calculateBoundingBox(List<Offset> points) {
  if (points.isEmpty) return Rect.zero;

  double minX = points.first.dx;
  double maxX = points.first.dx;
  double minY = points.first.dy;
  double maxY = points.first.dy;

  // Skip the first point since we already used it for initialization
  for (int i = 1; i < points.length; i++) {
    final point = points[i];
    minX = math.min(minX, point.dx);
    maxX = math.max(maxX, point.dx);
    minY = math.min(minY, point.dy);
    maxY = math.max(maxY, point.dy);
  }

  return Rect.fromLTRB(minX, minY, maxX, maxY);
}

/// Extracts the RGB color at a specific pixel coordinate.
///
/// [pixels] RGBA pixel data array
/// [x] X coordinate of the pixel
/// [y] Y coordinate of the pixel
/// [width] Width of the image
Color _extractColorAtPixel(Uint8List pixels, int x, int y, int width) {
  final pixelIndex = (y * width + x) * 4;
  return Color.fromARGB(
    255, // Full opacity - we're only extracting RGB values
    pixels[pixelIndex], // Red
    pixels[pixelIndex + 1], // Green
    pixels[pixelIndex + 2], // Blue
  );
}
