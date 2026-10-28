import 'package:convex_hull/convex_hull.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

/// The following are the drawings that the user does.
///
/// All points are stored in image pixel coordinates (see `ImageFit`), never
/// in screen coordinates, so a drawing keeps pointing at the same pixels when
/// the photo is zoomed, panned, letterboxed or shown on another screen.

class Stroke {
  final List<Offset> points;
  Stroke(this.points);

  /// A stroke needs at least three points to enclose any pixels.
  bool get enclosesArea => points.length >= 3;
}

class Region extends Stroke {
  /// Shade guide name the dentist gave to a shade region, e.g. "A2".
  String? shadeName;

  Region(super.points, {this.shadeName});

  /// Merges a new stroke into this region, keeping the convex hull of both.
  Region mergedWith(Stroke stroke) {
    final combined = [...points, ...stroke.points].map((p) => Vector2(p.dx, p.dy)).toList();
    final hull = convexHull<Vector2>(combined, x: (v) => v.x, y: (v) => v.y);
    return Region(hull.map((v) => Offset(v.x, v.y)).toList(), shadeName: shadeName);
  }

  /// Whether any point of [stroke] comes within [threshold] of this region.
  bool isTouching(Stroke stroke, double threshold) {
    for (final pa in points) {
      for (final pb in stroke.points) {
        if ((pa - pb).distance < threshold) return true;
      }
    }
    return false;
  }

  Offset get centroid {
    if (points.isEmpty) return Offset.zero;
    final sum = points.fold(Offset.zero, (a, b) => a + b);
    return sum / points.length.toDouble();
  }
}
