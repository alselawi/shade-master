import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

/// Given an image path it would return a unit8List
/// of all the pixels. With height and width.
/// This is useful to extract colors out of an image.
///
/// - [imgPath]: a [String] of image path.
///
/// returns: [Unit8Img] as a future.
///
Future<Unit8Img> loadUnit8Img(String imgPath) async {
  final bytes = await File(imgPath).readAsBytes();
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  final image = frame.image;
  final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (byteData == null) return Unit8Img(Uint8List(0), 0, 0);
  final pixels = byteData.buffer.asUint8List();
  return Unit8Img(pixels, image.height, image.width);
}

class Unit8Img {
  final Uint8List pixels;
  final int height;
  final int width;
  Unit8Img(this.pixels, this.height, this.width);
}
