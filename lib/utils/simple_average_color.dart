import 'package:flutter/material.dart';

/// Finds the average color in a list of colors
///
/// This is an over-simplification and not used in the comparison logic
/// However, we're using it in the widget to show which tooth is closest to
/// which shade.
///
/// - [colors]: A list of [Color].
///
/// Returns single [Color]
Color simpleAverageColor(List<Color> colors) {
  if (colors.isEmpty) {
    return Colors.transparent; // Return transparent if the list is empty
  }

  double red = 0;
  double green = 0;
  double blue = 0;
  double alpha = 0;

  for (Color color in colors) {
    red += color.r;
    green += color.g;
    blue += color.b;
    alpha += color.a;
  }

  // Calculate the average of each component
  int avgRed = (red / colors.length).round();
  int avgGreen = (green / colors.length).round();
  int avgBlue = (blue / colors.length).round();
  int avgAlpha = (alpha / colors.length).round();

  return Color.fromARGB(avgAlpha, avgRed, avgGreen, avgBlue);
}
