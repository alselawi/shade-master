import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shadesmaster/l10n/app_localizations.dart';
import 'package:shadesmaster/orders/lab_order.dart';
import 'package:shadesmaster/orders/shade_guide_labels.dart';
import 'package:shadesmaster/orders/tooth_chart.dart';
import 'package:shadesmaster/utils/format.dart';

/// The fonts embedded in exported PDFs. IBM Plex Sans Arabic covers Arabic
/// and Latin; the tiny Noto Sans subset adds the Δ of "ΔE00".
class OrderPdfFonts {
  final pw.Font regular;
  final pw.Font bold;
  final pw.Font symbols;

  const OrderPdfFonts({required this.regular, required this.bold, required this.symbols});

  static Future<OrderPdfFonts> load([AssetBundle? bundle]) async {
    final assets = bundle ?? rootBundle;
    return OrderPdfFonts(
      regular: pw.Font.ttf(await assets.load('assets/fonts/IBMPlexSansArabic-Regular.ttf')),
      bold: pw.Font.ttf(await assets.load('assets/fonts/IBMPlexSansArabic-Bold.ttf')),
      symbols: pw.Font.ttf(await assets.load('assets/fonts/NotoSans-Delta.ttf')),
    );
  }
}

const _accent = PdfColor.fromInt(0xFF0078D4);
const _muted = PdfColor.fromInt(0xFF5F6368);
const _border = PdfColor.fromInt(0xFFDADCE0);
const _headerFill = PdfColor.fromInt(0xFFF1F3F4);

final _arabic = RegExp('[؀-ۿݐ-ݿࢠ-ࣿﭐ-﷿ﹰ-﻿]');

/// The pdf package only shapes Arabic inside right to left text, so every
/// text gets the direction of its own content: Arabic names stay readable
/// in an English sheet, and codes, phone numbers and "ΔE00" stay in order
/// in an Arabic one.
pw.Widget _text(String text, {pw.TextStyle? style}) => pw.Directionality(
      textDirection: _arabic.hasMatch(text) ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      child: pw.Text(text, style: style),
    );

/// Builds the lab order sheet sent to the laboratory, in the language of
/// [l10n] (right to left for Arabic).
Future<Uint8List> buildOrderPdf(
  LabOrder order, {
  required AppLocalizations l10n,
  required OrderPdfFonts fonts,
  Uint8List? photoJpeg,
  PdfPageFormat pageFormat = PdfPageFormat.a4,
}) {
  final direction = l10n.localeName.startsWith('ar') ? pw.TextDirection.rtl : pw.TextDirection.ltr;
  final document = pw.Document(
    title: '${l10n.pdfTitle} ${order.id}',
    author: order.dentistName.isEmpty ? null : order.dentistName,
    creator: l10n.appTitle,
  );

  pw.Widget label(String text) => _text(text, style: const pw.TextStyle(color: _muted, fontSize: 9));
  pw.Widget value(String text, {double fontSize = 11, bool bold = false}) => _text(
        text.isEmpty ? '—' : text,
        style: pw.TextStyle(fontSize: fontSize, fontWeight: bold ? pw.FontWeight.bold : null),
      );
  pw.Widget field(String title, String content) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [label(title), value(content)]),
      );
  pw.Widget heading(String text) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 10, bottom: 5),
        child: _text(text, style: pw.TextStyle(color: _accent, fontSize: 12, fontWeight: pw.FontWeight.bold)),
      );

  final bodyMatch = order.analysis.where((match) => match.name == order.bodyShade).firstOrNull;
  final analysis = <pw.Widget>[
    if (order.analysis.isNotEmpty) ...[
      heading(l10n.photoAnalysis),
      _matchTable(l10n, [for (final match in order.analysis.take(6)) (null, match)]),
    ],
    if (order.toothAnalysis.length > 1) ...[
      heading(l10n.perTooth),
      _matchTable(l10n, [for (final tooth in order.toothAnalysis) (l10n.toothLabel(tooth.area), tooth.shade)]),
    ],
  ];

  document.addPage(
    pw.MultiPage(
      pageFormat: pageFormat,
      theme: pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold, fontFallback: [fonts.symbols]),
      textDirection: direction,
      margin: const pw.EdgeInsets.all(28),
      header: (context) => pw.Container(
        padding: const pw.EdgeInsets.only(bottom: 6),
        margin: const pw.EdgeInsets.only(bottom: 8),
        decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: _accent, width: 2))),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _text(l10n.pdfTitle, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  for (final line in [order.clinicName, order.dentistName, order.clinicPhone])
                    if (line.isNotEmpty) value(line, fontSize: 10),
                ],
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                label(l10n.pdfOrderNumber),
                value(order.id, bold: true),
                label(l10n.pdfDate),
                value(formatDate(order.createdAt)),
              ],
            ),
          ],
        ),
      ),
      footer: (context) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [label(l10n.appTitle), label(l10n.pdfPage(context.pageNumber, context.pagesCount))],
      ),
      build: (context) => [
        pw.Table(
          border: pw.TableBorder.all(color: _border),
          children: [
            pw.TableRow(children: [
              field(l10n.caseCode, order.caseCode),
              field(l10n.patient, order.patientName),
              field(l10n.labName, order.labName),
            ]),
            pw.TableRow(children: [
              field(l10n.restorationType, order.restorationType.label(l10n)),
              field(l10n.material, order.material.label(l10n)),
              field(l10n.dueDate, order.dueDate == null ? l10n.notSet : formatDate(order.dueDate!)),
            ]),
          ],
        ),
        heading(l10n.sectionTeeth),
        _toothChart(order.teeth.toSet(), l10n, label),
        heading(l10n.sectionShade),
        _shadeBlock(order, l10n, bodyMatch, label, value),
        if (photoJpeg != null)
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    heading(l10n.pdfPhoto),
                    pw.Container(
                      height: 200,
                      alignment: pw.Alignment.center,
                      decoration: pw.BoxDecoration(border: pw.Border.all(color: _border)),
                      child: pw.Image(pw.MemoryImage(photoJpeg), fit: pw.BoxFit.contain),
                    ),
                  ],
                ),
              ),
              if (analysis.isNotEmpty) ...[
                pw.SizedBox(width: 12),
                pw.Expanded(
                  child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: analysis),
                ),
              ],
            ],
          )
        else
          ...analysis,
        if (order.notes.isNotEmpty) ...[
          heading(l10n.notes),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: _border)),
            child: value(order.notes),
          ),
        ],
        pw.SizedBox(height: 10),
        label(l10n.pdfDisclaimer),
        pw.SizedBox(height: 26),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Column(
              children: [
                pw.Container(width: 180, height: 1, color: PdfColors.black),
                pw.SizedBox(height: 4),
                value(l10n.pdfSignature, fontSize: 10),
              ],
            ),
          ],
        ),
      ],
    ),
  );

  return document.save();
}

pw.Widget _toothChart(Set<int> selected, AppLocalizations l10n, pw.Widget Function(String) label) {
  pw.Widget tooth(int number) {
    final isSelected = selected.contains(number);
    return pw.Container(
      width: 28,
      height: 20,
      margin: const pw.EdgeInsets.all(1),
      alignment: pw.Alignment.center,
      decoration: pw.BoxDecoration(
        color: isSelected ? _accent : null,
        border: pw.Border.all(color: isSelected ? _accent : _border),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
      ),
      child: pw.Text(
        '$number',
        style: pw.TextStyle(
          fontSize: 9,
          color: isSelected ? PdfColors.white : PdfColors.black,
          fontWeight: isSelected ? pw.FontWeight.bold : null,
        ),
      ),
    );
  }

  pw.Widget arch(List<int> right, List<int> left) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          for (final number in right) tooth(number),
          pw.Container(
            width: 2,
            height: 20,
            color: PdfColors.grey600,
            margin: const pw.EdgeInsets.symmetric(horizontal: 3),
          ),
          for (final number in left) tooth(number),
        ],
      );

  // The chart is never mirrored: the patient's right is always on the left.
  return pw.Directionality(
    textDirection: pw.TextDirection.ltr,
    child: pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [label(l10n.patientRight), label(l10n.upperJaw), label(l10n.patientLeft)],
        ),
        arch(upperRightTeeth, upperLeftTeeth),
        pw.SizedBox(height: 3),
        arch(lowerRightTeeth, lowerLeftTeeth),
        label(l10n.lowerJaw),
      ],
    ),
  );
}

pw.Widget _shadeBlock(
  LabOrder order,
  AppLocalizations l10n,
  ShadeMatch? bodyMatch,
  pw.Widget Function(String) label,
  pw.Widget Function(String, {double fontSize, bool bold}) value,
) {
  pw.Widget item(String title, String shade) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 14),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [label(title), value(shade, fontSize: 12)],
        ),
      );

  return pw.Row(
    children: [
      if (bodyMatch != null)
        pw.Container(
          width: 36,
          height: 36,
          margin: const pw.EdgeInsets.symmetric(horizontal: 6),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromInt(bodyMatch.colorArgb),
            border: pw.Border.all(color: _border),
          ),
        ),
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          label('${l10n.shadeBody} · ${order.shadeGuide.label(l10n)}'),
          value(order.bodyShade, fontSize: 22, bold: true),
        ],
      ),
      item(l10n.shadeCervical, order.cervicalShade),
      item(l10n.shadeIncisal, order.incisalShade),
      item(l10n.shadeStump, order.stumpShade),
    ],
  );
}

/// Rows of (optional tooth label, shade match): swatch, shade, ΔE00, assessment.
pw.Widget _matchTable(AppLocalizations l10n, List<(String?, ShadeMatch)> rows) {
  final withTooth = rows.any((row) => row.$1 != null);
  pw.Widget cell(String text, {bool bold = false, PdfColor? color}) => pw.Padding(
        padding: const pw.EdgeInsets.all(3),
        child: _text(
          text,
          style: pw.TextStyle(fontSize: 9, fontWeight: bold ? pw.FontWeight.bold : null, color: color),
        ),
      );

  return pw.Table(
    border: pw.TableBorder.all(color: _border),
    defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
    columnWidths: {
      0: const pw.FixedColumnWidth(22),
      if (withTooth) 1: const pw.FlexColumnWidth(1.2),
    },
    children: [
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: _headerFill),
        children: [
          pw.SizedBox(),
          if (withTooth) cell(l10n.pdfTooth, bold: true),
          cell(l10n.pdfShade, bold: true),
          cell('ΔE00', bold: true),
          cell(l10n.pdfAssessment, bold: true),
        ],
      ),
      for (final (tooth, match) in rows)
        pw.TableRow(
          children: [
            pw.Container(height: 12, margin: const pw.EdgeInsets.all(3), color: PdfColor.fromInt(match.colorArgb)),
            if (withTooth) cell(tooth ?? ''),
            cell(match.name),
            cell(match.delta.isFinite ? match.delta.toStringAsFixed(2) : '—'),
            cell(
              match.delta.isFinite ? match.category.label(l10n) : l10n.noPixels,
              color: match.delta.isFinite && !match.category.isClinicallyAcceptable ? PdfColors.red800 : null,
            ),
          ],
        ),
    ],
  );
}
