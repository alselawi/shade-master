/// The shade guides a dentist can name the drawn shade tabs from.
///
/// Only the shade names are listed: the comparison is always made against
/// the physical tabs in the photo, never against stored reference colors.
enum ShadeGuide {
  classical([
    'A1', 'A2', 'A3', 'A3.5', 'A4', //
    'B1', 'B2', 'B3', 'B4',
    'C1', 'C2', 'C3', 'C4',
    'D2', 'D3', 'D4',
  ]),
  threeDMaster([
    '0M1', '0M2', '0M3', //
    '1M1', '1M2',
    '2L1.5', '2L2.5', '2M1', '2M2', '2M3', '2R1.5', '2R2.5',
    '3L1.5', '3L2.5', '3M1', '3M2', '3M3', '3R1.5', '3R2.5',
    '4L1.5', '4L2.5', '4M1', '4M2', '4M3', '4R1.5', '4R2.5',
    '5M1', '5M2', '5M3',
  ]);

  final List<String> shades;
  const ShadeGuide(this.shades);

  static ShadeGuide fromName(String? name) =>
      ShadeGuide.values.firstWhere((guide) => guide.name == name, orElse: () => ShadeGuide.classical);
}
