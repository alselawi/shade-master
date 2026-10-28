import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:shadesmaster/drawings.dart';
import 'package:shadesmaster/utils/unit_8_img.dart';
import 'package:shadesmaster/widget_selection_painter.dart';

/// Draws the outlines and labels of the analysed areas on the photo and
/// returns it as a JPEG, at most [maxDimension] pixels on its longest side.
///
/// Outlines rather than filled areas keep the real colors visible for the
/// laboratory.
Future<Uint8List> renderAnnotatedJpeg(
  Unit8Img pixels,
  List<Region> teeth,
  List<Region> shades, {
  int maxDimension = 1600,
  int quality = 88,
}) async {
  final photo = await pixels.toImage();
  final scale = math.min(1.0, maxDimension / math.max(pixels.width, pixels.height));
  final width = math.max(1, (pixels.width * scale).round());
  final height = math.max(1, (pixels.height * scale).round());
  final size = Size(width.toDouble(), height.toDouble());

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawImageRect(
      photo, Offset.zero & pixels.size, Offset.zero & size, Paint()..filterQuality = FilterQuality.medium);
  SelectionPainter(
    teethRegions: teeth,
    shadesRegions: shades,
    currentStroke: Stroke([]),
    activeType: SelectionType.none,
    imageSize: pixels.size,
    scale: math.max(width, height) / 600,
    outlined: true,
  ).paint(canvas, size);

  final picture = recorder.endRecording();
  final rendered = await picture.toImage(width, height);
  final data = await rendered.toByteData(format: ui.ImageByteFormat.rawRgba);
  picture.dispose();
  rendered.dispose();
  photo.dispose();

  return compute(_encodeJpeg, (data!.buffer.asUint8List(), width, height, quality));
}

Uint8List _encodeJpeg((Uint8List, int, int, int) input) {
  final (rgba, width, height, quality) = input;
  final image = img.Image.fromBytes(
    width: width,
    height: height,
    bytes: rgba.buffer,
    numChannels: 4,
    order: img.ChannelOrder.rgba,
  );
  return img.encodeJpg(image, quality: quality);
}
