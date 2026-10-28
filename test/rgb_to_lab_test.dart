import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadesmaster/utils/rgb_to_lab.dart';
import 'package:shadesmaster/utils/simple_average_color.dart';

void expectLab(LabColor actual, double l, double a, double b) {
  expect(actual.l, closeTo(l, 0.01), reason: 'L of $actual');
  expect(actual.a, closeTo(a, 0.01), reason: 'a of $actual');
  expect(actual.b, closeTo(b, 0.01), reason: 'b of $actual');
}

void main() {
  test('rgbToLab gives the standard D65 values on the 0-100 lightness scale', () {
    expectLab(rgbToLab(const Color(0xFFFFFFFF)), 100, 0, 0);
    expectLab(rgbToLab(const Color(0xFF000000)), 0, 0, 0);
    expectLab(rgbToLab(const Color(0xFFFF0000)), 53.241, 80.092, 67.203);
    expectLab(rgbToLab(const Color(0xFF00FF00)), 87.735, -86.183, 83.179);
    expectLab(rgbToLab(const Color(0xFF0000FF)), 32.297, 79.188, -107.86);
    expectLab(rgbToLab(const Color(0xFF808080)), 53.585, 0, 0);
    expectLab(rgbToLab(const Color(0xFFE8DCC0)), 88.04, -0.414, 15.245);
  });

  test('simpleAverageColor averages each channel', () {
    final average = simpleAverageColor(const [Color(0xFFE8DCC0), Color(0xFFD9C8A0)]);
    expect(average.a, 1);
    expect((average.r * 255).round(), (0xE8 + 0xD9) ~/ 2 + 1);
    expect((average.g * 255).round(), (0xDC + 0xC8) ~/ 2);
    expect((average.b * 255).round(), (0xC0 + 0xA0) ~/ 2);
  });

  test('simpleAverageColor of nothing is transparent', () {
    expect(simpleAverageColor(const []).a, 0);
  });
}
