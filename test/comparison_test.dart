import 'package:flutter_test/flutter_test.dart';
import 'package:shadesmaster/analysis/comparison.dart';
import 'package:shadesmaster/utils/rgb_to_lab.dart';

/// Reference pairs from Sharma, Wu & Dalal (2005),
/// "The CIEDE2000 Color-Difference Formula: Implementation Notes,
/// Supplementary Test Data, and Mathematical Observations".
const _sharmaPairs = <(LabColor, LabColor, double)>[
  (LabColor(50.0000, 2.6772, -79.7751), LabColor(50.0000, 0.0000, -82.7485), 2.0425),
  (LabColor(50.0000, 3.1571, -77.2803), LabColor(50.0000, 0.0000, -82.7485), 2.8615),
  (LabColor(50.0000, 2.8361, -74.0200), LabColor(50.0000, 0.0000, -82.7485), 3.4412),
  (LabColor(50.0000, -1.3802, -84.2814), LabColor(50.0000, 0.0000, -82.7485), 1.0000),
  (LabColor(50.0000, 0.0000, 0.0000), LabColor(50.0000, -1.0000, 2.0000), 2.3669),
  (LabColor(50.0000, 2.4900, -0.0010), LabColor(50.0000, -2.4900, 0.0009), 7.1792),
  (LabColor(50.0000, 2.4900, -0.0010), LabColor(50.0000, -2.4900, 0.0011), 7.2195),
  (LabColor(50.0000, 2.5000, 0.0000), LabColor(73.0000, 25.0000, -18.0000), 27.1492),
  (LabColor(50.0000, 2.5000, 0.0000), LabColor(61.0000, -5.0000, 29.0000), 22.8977),
  (LabColor(50.0000, 2.5000, 0.0000), LabColor(56.0000, -27.0000, -3.0000), 31.9030),
  (LabColor(50.0000, 2.5000, 0.0000), LabColor(58.0000, 24.0000, 15.0000), 19.4535),
  (LabColor(60.2574, -34.0099, 36.2677), LabColor(60.4626, -34.1751, 39.4387), 1.2644),
  (LabColor(63.0109, -31.0961, -5.8663), LabColor(62.8187, -29.7946, -4.0864), 1.2630),
];

void main() {
  group('deltaE (CIEDE2000)', () {
    test('matches the Sharma et al. reference values', () {
      for (final (a, b, expected) in _sharmaPairs) {
        expect(deltaE(a, b), closeTo(expected, 0.0001), reason: '$a vs $b');
      }
    });

    test('is symmetric and zero for identical colors', () {
      for (final (a, b, _) in _sharmaPairs) {
        expect(deltaE(a, b), closeTo(deltaE(b, a), 1e-9));
        expect(deltaE(a, a), 0);
      }
    });
  });

  group('deltaGroups', () {
    const group = [LabColor(40, 1, 10), LabColor(50, 2, 12), LabColor(60, 3, 14)];

    test('is zero for identical groups', () {
      expect(deltaGroups(group, group), 0);
    });

    test('aligns the shorter group on the middle of the longer one', () {
      const longer = [LabColor(10, 0, 0), ...group, LabColor(90, 0, 0)];
      expect(deltaGroups(group, longer), 0);
      expect(deltaGroups(longer, group), 0);
    });

    test('ranks a closer group lower than a farther one', () {
      const near = [LabColor(41, 1, 10), LabColor(51, 2, 12), LabColor(61, 3, 14)];
      const far = [LabColor(70, 5, 30), LabColor(80, 6, 32), LabColor(90, 7, 34)];
      expect(deltaGroups(group, near), lessThan(deltaGroups(group, far)));
    });
  });
}
