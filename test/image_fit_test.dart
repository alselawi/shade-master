import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadesmaster/utils/image_fit.dart';

void main() {
  test('a portrait photo in a taller box is letterboxed top and bottom', () {
    final fit = ImageFit(const Size(3000, 4000), const Size(400, 800));
    expect(fit.imageRect.left, 0);
    expect(fit.imageRect.width, 400);
    expect(fit.imageRect.height, closeTo(533.33, 0.01));
    expect(fit.imageRect.top, closeTo(133.33, 0.01));

    final topLeft = fit.boxToImage(Offset(0, fit.imageRect.top));
    expect(topLeft.dx, closeTo(0, 1e-9));
    expect(topLeft.dy, closeTo(0, 1e-9));

    final bottomCentre = fit.boxToImage(Offset(200, fit.imageRect.bottom));
    expect(bottomCentre.dx, closeTo(1500, 1e-9));
    expect(bottomCentre.dy, closeTo(4000, 1e-9));
  });

  test('a landscape photo in a tall box is letterboxed and mapping round-trips', () {
    final fit = ImageFit(const Size(4000, 3000), const Size(390, 844));
    const point = Offset(1234, 567);
    final back = fit.boxToImage(fit.imageToBox(point));
    expect(back.dx, closeTo(point.dx, 1e-9));
    expect(back.dy, closeTo(point.dy, 1e-9));
    expect(fit.imagePixelsPerBoxPixel, closeTo(4000 / 390, 1e-9));
  });

  test('an empty box does not divide by zero', () {
    final fit = ImageFit(const Size(100, 100), Size.zero);
    expect(fit.boxToImage(const Offset(5, 5)), Offset.zero);
  });
}
