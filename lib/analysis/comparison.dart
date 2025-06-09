import 'dart:math' as math;
import 'package:shadesmaster/utils/rgb_to_lab.dart';

/// DeltaE2000 comparison algorithm, gives the visual distance
/// between two colors.
/// The given colors must be CIELAB colors.
///
/// - color1 [LabColor] the first color in question
/// - color2 [LabColor] the second color in question
///
/// returns: the distance between the two colors
double deltaE(
  LabColor color1,
  LabColor color2, {
  double lightness = 1.0,
  double chroma = 1.0,
  double hue = 1.0,
}) {
  final double ksubL = lightness;
  final double ksubC = chroma;
  final double ksubH = hue;

  // Delta L Prime
  final double deltaLPrime = color2.l - color1.l;

  // L Bar
  final double LBar = (color1.l + color2.l) * 0.5;

  // C1 & C2 - use single sqrt call with pre-computed squares
  final double color1A2 = color1.a * color1.a;
  final double color1B2 = color1.b * color1.b;
  final double color2A2 = color2.a * color2.a;
  final double color2B2 = color2.b * color2.b;

  final double C1 = math.sqrt(color1A2 + color1B2);
  final double C2 = math.sqrt(color2A2 + color2B2);

  // C Bar
  final double CBar = (C1 + C2) * 0.5;
  final double CBar7 = math.pow(CBar, 7.0).toDouble();

  // Pre-compute the G factor used in both aPrime calculations
  final double G = 0.5 * (1.0 - math.sqrt(CBar7 / (CBar7 + _pow25_7)));

  // A Prime 1 & 2
  final double aPrime1 = color1.a * (1.0 + G);
  final double aPrime2 = color2.a * (1.0 + G);

  // C Prime 1 & 2
  final double CPrime1 = math.sqrt(aPrime1 * aPrime1 + color1B2);
  final double CPrime2 = math.sqrt(aPrime2 * aPrime2 + color2B2);

  // C Bar Prime
  final double CBarPrime = (CPrime1 + CPrime2) * 0.5;

  // Delta C Prime
  final double deltaCPrime = CPrime2 - CPrime1;

  // S sub L - optimize the fraction
  final double LBarMinus50 = LBar - 50.0;
  final double LBarMinus50Sq = LBarMinus50 * LBarMinus50;
  final double SsubL = 1.0 + (0.015 * LBarMinus50Sq) / math.sqrt(20.0 + LBarMinus50Sq);

  // S sub C
  final double SsubC = 1.0 + 0.045 * CBarPrime;

  // Helper function for h Prime calculation
  double gethPrime(double x, double y) {
    if (x == 0.0 && y == 0.0) {
      return 0.0;
    }
    final double hueAngle = math.atan2(x, y) * _180Pi;
    return hueAngle >= 0.0 ? hueAngle : hueAngle + 360.0;
  }

  // h Prime 1 & 2
  final double hPrime1 = gethPrime(color1.b, aPrime1);
  final double hPrime2 = gethPrime(color2.b, aPrime2);

  // Delta h Prime
  double deltahPrime;
  if (C1 == 0.0 || C2 == 0.0) {
    deltahPrime = 0.0;
  } else {
    final double diff = hPrime1 - hPrime2;
    final double absDiff = diff.abs();

    if (absDiff <= 180.0) {
      deltahPrime = -diff; // hPrime2 - hPrime1
    } else if (hPrime2 <= hPrime1) {
      deltahPrime = -diff + 360.0; // hPrime2 - hPrime1 + 360
    } else {
      deltahPrime = -diff - 360.0; // hPrime2 - hPrime1 - 360
    }
  }

  // Delta H Prime
  final double deltaHPrime = 2.0 * math.sqrt(CPrime1 * CPrime2) * math.sin(deltahPrime * _pi180 * 0.5);

  // H Bar Prime
  double HBarPrime;
  final double hPrimeDiff = (hPrime1 - hPrime2).abs();
  if (hPrimeDiff > 180.0) {
    HBarPrime = (hPrime1 + hPrime2 + 360.0) * 0.5;
  } else {
    HBarPrime = (hPrime1 + hPrime2) * 0.5;
  }

  // T - pre-compute angle conversions
  final double HBarPrimeRad = HBarPrime * _pi180;
  final double T = 1.0 -
      0.17 * math.cos(HBarPrimeRad - 30.0 * _pi180) +
      0.24 * math.cos(2.0 * HBarPrimeRad) +
      0.32 * math.cos(3.0 * HBarPrimeRad + 6.0 * _pi180) -
      0.2 * math.cos(4.0 * HBarPrimeRad - 63.0 * _pi180);

  // S sub H
  final double SsubH = 1.0 + 0.015 * CBarPrime * T;

  // R sub T
  final double CBarPrime7 = math.pow(CBarPrime, 7.0).toDouble();
  final double HBarPrimeMinus275 = (HBarPrime - 275.0) / 25.0;
  final double RsubT = -2.0 *
      math.sqrt(CBarPrime7 / (CBarPrime7 + _pow25_7)) *
      math.sin(60.0 * _pi180 * math.exp(-HBarPrimeMinus275 * HBarPrimeMinus275));

  // Final calculation
  final double lightnessComponent = deltaLPrime / (ksubL * SsubL);
  final double chromaComponent = deltaCPrime / (ksubC * SsubC);
  final double hueComponent = deltaHPrime / (ksubH * SsubH);

  return math.sqrt(
    lightnessComponent * lightnessComponent +
        chromaComponent * chromaComponent +
        hueComponent * hueComponent +
        RsubT * chromaComponent * hueComponent,
  );
}

/// Returns the visual distance using the above deltaE2000 but **for groups**
/// This is done by aligning the two groups to each other
/// then comparing color to color that are at the same order of lightness
/// Hence, this function must be given sorted groups.
double deltaGroups(List<LabColor> sortedGroupA, List<LabColor> sortedGroupB) {
  final lenA = sortedGroupA.length;
  final lenB = sortedGroupB.length;

  // Identify shorter and longer groups
  final bool aIsShorter = lenA <= lenB;
  final shorter = aIsShorter ? sortedGroupA : sortedGroupB;
  final longer = aIsShorter ? sortedGroupB : sortedGroupA;

  final lenShort = shorter.length;
  final lenLong = longer.length;

  final midShort = (lenShort / 2).floor();
  final midLong = (lenLong / 2).floor();

  final offset = midLong - midShort;

  final diffs = <double>[];

  for (int i = 0; i < lenShort; i++) {
    final longIndex = i + offset;
    if (longIndex < 0 || longIndex >= lenLong) {
      // Skip out-of-bounds
      continue;
    }
    diffs.add(deltaE(shorter[i], longer[longIndex]));
  }

  if (diffs.isEmpty) return 0.0; // shouldn't happen

  return _average(diffs);
}

// Pre-computed constants
const double _pow25_7 = 6103515625.0; // 25^7
const double _pi180 = math.pi / 180.0;
const double _180Pi = 180.0 / math.pi;

double _average(List<double> values) {
  if (values.isEmpty) return 0.0;
  return values.reduce((a, b) => a + b) / values.length;
}
