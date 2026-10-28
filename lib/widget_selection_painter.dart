import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shadesmaster/drawings.dart';
import 'package:shadesmaster/utils/image_fit.dart';
import 'package:shadesmaster/utils/int_to_letter.dart';

const teethColor = Colors.tealAccent;
const shadesColor = Colors.purple;

enum SelectionType { none, teeth, shades }

/// Paints the teeth regions (numbered) and the shade regions (lettered, or
/// named once the dentist picked a shade guide name) on top of the photo.
///
/// Regions are in image pixels; they are mapped to the painted size with
/// [ImageFit], so the same painter draws on the screen and, with the canvas
/// the size of the image, on the annotated image exported with an order.
class SelectionPainter extends CustomPainter {
  final List<Region> teethRegions;
  final List<Region> shadesRegions;
  final Stroke currentStroke;
  final SelectionType activeType;
  final Size imageSize;

  /// Multiplies the label size, line width and dot radius, e.g. for full resolution exports.
  final double scale;

  /// Draws only the outline of the regions, so the colors inside stay
  /// visible (used for the photo sent to the laboratory).
  final bool outlined;

  SelectionPainter({
    required this.teethRegions,
    required this.shadesRegions,
    required this.currentStroke,
    required this.activeType,
    required this.imageSize,
    this.scale = 1,
    this.outlined = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fit = ImageFit(imageSize, size);

    final paintTeeth = Paint()
      ..color = outlined ? teethColor.shade700 : teethColor.withValues(alpha: 0.4)
      ..style = outlined ? PaintingStyle.stroke : PaintingStyle.fill
      ..strokeWidth = 3 * scale;

    final paintShades = Paint()
      ..color = outlined ? shadesColor : shadesColor.withValues(alpha: 0.4)
      ..style = outlined ? PaintingStyle.stroke : PaintingStyle.fill
      ..strokeWidth = 3 * scale;

    // Draw teeth regions with numbers
    for (int i = 0; i < teethRegions.length; i++) {
      _drawRegion(canvas, fit, teethRegions[i], paintTeeth, '${i + 1}');
    }

    // Draw shades regions with letters, or their shade guide name
    for (int i = 0; i < shadesRegions.length; i++) {
      final region = shadesRegions[i];
      _drawRegion(canvas, fit, region, paintShades, region.shadeName ?? intToLetter(i + 1));
    }

    // Draw current stroke
    final currentPaint = Paint()
      ..color = (activeType == SelectionType.teeth ? teethColor : shadesColor).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    for (final point in currentStroke.points) {
      canvas.drawCircle(fit.imageToBox(point), 4 * scale, currentPaint);
    }
  }

  void _drawRegion(Canvas canvas, ImageFit fit, Region region, Paint paint, String label) {
    if (region.points.isEmpty) return;
    final path = Path()..addPolygon(region.points.map(fit.imageToBox).toList(), true);
    canvas.drawPath(path, paint);
    // On an outline the label goes above the region, so it hides no color.
    final bounds = path.getBounds();
    final anchor = outlined
        ? Offset(bounds.center.dx, math.max(bounds.top - 16 * scale, 14 * scale))
        : fit.imageToBox(region.centroid);
    _drawText(canvas, label, anchor);
  }

  void _drawText(Canvas canvas, String text, Offset position) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.black,
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 20 * scale,
        fontWeight: FontWeight.bold,
        backgroundColor: outlined ? Colors.white.withValues(alpha: 0.8) : null,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, position - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
