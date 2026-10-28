import 'package:flutter/painting.dart';

/// Maps between the pixels of an image and the box it is shown in.
///
/// The photo is displayed with [BoxFit.contain] and [Alignment.center], so
/// unless the photo and the screen have the same aspect ratio there are empty
/// margins on two sides. Drawings are stored in image pixel coordinates, so
/// they keep pointing at the same pixels whatever the screen size, margins or
/// zoom level are.
class ImageFit {
  final Size imageSize;
  final Size boxSize;

  /// The rectangle (in box coordinates) that the image is painted into.
  final Rect imageRect;

  ImageFit(this.imageSize, this.boxSize) : imageRect = _containRect(imageSize, boxSize);

  /// How many image pixels one box (logical) pixel covers.
  double get imagePixelsPerBoxPixel => imageRect.width == 0 ? 1 : imageSize.width / imageRect.width;

  Offset boxToImage(Offset boxPoint) {
    if (imageRect.isEmpty) return Offset.zero;
    return Offset(
      (boxPoint.dx - imageRect.left) * imageSize.width / imageRect.width,
      (boxPoint.dy - imageRect.top) * imageSize.height / imageRect.height,
    );
  }

  Offset imageToBox(Offset imagePoint) {
    if (imageSize.isEmpty) return imageRect.topLeft;
    return Offset(
      imageRect.left + imagePoint.dx * imageRect.width / imageSize.width,
      imageRect.top + imagePoint.dy * imageRect.height / imageSize.height,
    );
  }

  static Rect _containRect(Size imageSize, Size boxSize) {
    if (imageSize.isEmpty || boxSize.isEmpty) return Rect.zero;
    final fitted = applyBoxFit(BoxFit.contain, imageSize, boxSize);
    return Alignment.center.inscribe(fitted.destination, Offset.zero & boxSize);
  }
}
