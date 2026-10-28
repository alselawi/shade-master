import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:shadesmaster/orders/lab_order.dart';
import 'package:shadesmaster/orders/shade_guide.dart';

/// A made-up order: no real patient, clinic or laboratory.
LabOrder demoOrder({bool hasPhoto = true}) => LabOrder(
      id: '20261028-101500',
      createdAt: DateTime(2026, 10, 28, 10, 15),
      caseCode: 'DEMO-001',
      dentistName: 'د. طبيب تجريبي',
      clinicName: 'عيادة تجريبية',
      clinicPhone: '+000 0000 0000',
      labName: 'مخبر تجريبي',
      teeth: const [11, 21],
      restorationType: RestorationType.crown,
      material: RestorationMaterial.lithiumDisilicate,
      shadeGuide: ShadeGuide.classical,
      bodyShade: 'A2',
      incisalShade: 'A1',
      stumpShade: 'ND2',
      analysis: const [
        ShadeMatch(name: 'A2', delta: 0.62, colorArgb: 0xFFE3D6BD),
        ShadeMatch(name: 'A1', delta: 2.41, colorArgb: 0xFFF0E8D8),
        ShadeMatch(name: 'A3', delta: 4.95, colorArgb: 0xFFD2BA92),
      ],
      toothAnalysis: const [
        ToothMatch(area: 1, shade: ShadeMatch(name: 'A2', delta: 0.71, colorArgb: 0xFFE3D6BD)),
        ToothMatch(area: 2, shade: ShadeMatch(name: 'A2', delta: 0.93, colorArgb: 0xFFE3D6BD)),
      ],
      notes: 'ملاحظة تجريبية: شفافية خفيفة في الحافة القاطعة.',
      dueDate: DateTime(2026, 11, 4),
      hasPhoto: hasPhoto,
    );

/// A small generated "photo" (gum colored background with tooth shaped boxes).
Uint8List demoJpeg() {
  final photo = img.Image(width: 400, height: 300);
  img.fill(photo, color: img.ColorRgb8(122, 46, 53));
  img.fillRect(photo, x1: 60, y1: 40, x2: 160, y2: 180, color: img.ColorRgb8(226, 213, 188));
  img.fillRect(photo, x1: 200, y1: 40, x2: 300, y2: 180, color: img.ColorRgb8(226, 213, 188));
  img.fillRect(photo, x1: 80, y1: 210, x2: 130, y2: 290, color: img.ColorRgb8(227, 214, 189));
  return img.encodeJpg(photo);
}
