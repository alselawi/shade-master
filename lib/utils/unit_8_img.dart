import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

/// Given an image path it would return a unit8List
/// of all the pixels. With height and width.
/// This is useful to extract colors out of an image.
///
/// Photos larger than [maxDimension] on their longest side are scaled down
/// first: a 12+ megapixel photo would otherwise take hundreds of megabytes,
/// and the averaging done by the scaling only reduces sensor noise.
///
/// - [imgPath]: a [String] of image path.
///
/// returns: [Unit8Img] as a future.
///
Future<Unit8Img> loadUnit8Img(String imgPath, {int maxDimension = 2400}) async {
  final bytes = await File(imgPath).readAsBytes();
  return decodeUnit8Img(bytes, maxDimension: maxDimension);
}

/// Same as [loadUnit8Img] but for already loaded (encoded) image bytes.
Future<Unit8Img> decodeUnit8Img(Uint8List bytes, {int maxDimension = 2400}) async {
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  codec.dispose();
  var image = frame.image;

  final longest = math.max(image.width, image.height);
  if (longest > maxDimension) {
    final scale = maxDimension / longest;
    final width = math.max(1, (image.width * scale).round());
    final height = math.max(1, (image.height * scale).round());
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawImageRect(
      image,
      ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      ui.Paint()..filterQuality = ui.FilterQuality.medium,
    );
    final picture = recorder.endRecording();
    final scaled = await picture.toImage(width, height);
    picture.dispose();
    image.dispose();
    image = scaled;
  }

  final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  final result = byteData == null
      ? Unit8Img(Uint8List(0), 0, 0)
      : Unit8Img(byteData.buffer.asUint8List(), image.height, image.width);
  image.dispose();
  return result;
}

class Unit8Img {
  final Uint8List pixels;
  final int height;
  final int width;
  Unit8Img(this.pixels, this.height, this.width);

  ui.Size get size => ui.Size(width.toDouble(), height.toDouble());

  /// Turns the pixels back into a [ui.Image], e.g. to draw on top of them.
  Future<ui.Image> toImage() {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(pixels, width, height, ui.PixelFormat.rgba8888, completer.complete);
    return completer.future;
  }
}
