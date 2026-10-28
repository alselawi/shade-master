import 'package:flutter/material.dart';
import 'package:shadesmaster/l10n/app_localizations.dart';

/// FDI quadrants as seen when facing the patient: the patient's right is on
/// the left of the chart, whatever the language of the app.
const upperRightTeeth = [18, 17, 16, 15, 14, 13, 12, 11];
const upperLeftTeeth = [21, 22, 23, 24, 25, 26, 27, 28];
const lowerRightTeeth = [48, 47, 46, 45, 44, 43, 42, 41];
const lowerLeftTeeth = [31, 32, 33, 34, 35, 36, 37, 38];

/// Tooth picker using FDI numbers. On wide screens it shows the usual chart
/// (two arches of 16 teeth); on phones each quadrant gets its own row so the
/// buttons stay large enough to tap.
class ToothChart extends StatelessWidget {
  final Set<int> selected;
  final ValueChanged<int>? onToggle;

  const ToothChart({super.key, required this.selected, this.onToggle});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textDirection = Directionality.of(context);
    Widget label(String text) => Directionality(
          textDirection: textDirection,
          child: Text(text, style: Theme.of(context).textTheme.labelMedium),
        );

    Widget row(List<int> teeth) => Row(children: [
          for (final tooth in teeth)
            Expanded(child: _ToothButton(number: tooth, selected: selected.contains(tooth), onTap: onToggle)),
        ]);

    return Directionality(
      // Charts are never mirrored: the layout follows the patient's mouth.
      textDirection: TextDirection.ltr,
      child: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return Column(children: [
            Row(children: [
              Expanded(child: label(l10n.patientRight)),
              label(l10n.upperJaw),
              Expanded(child: Align(alignment: Alignment.centerRight, child: label(l10n.patientLeft))),
            ]),
            Row(children: [
              Expanded(child: row(upperRightTeeth)),
              const _Midline(),
              Expanded(child: row(upperLeftTeeth))
            ]),
            const Divider(height: 8),
            Row(children: [
              Expanded(child: row(lowerRightTeeth)),
              const _Midline(),
              Expanded(child: row(lowerLeftTeeth))
            ]),
            label(l10n.lowerJaw),
          ]);
        }
        Widget quadrant(String title, List<int> teeth) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [label(title), row(teeth)]),
            );
        return Column(children: [
          quadrant('${l10n.upperJaw} · ${l10n.patientRight}', upperRightTeeth),
          quadrant('${l10n.upperJaw} · ${l10n.patientLeft}', upperLeftTeeth),
          quadrant('${l10n.lowerJaw} · ${l10n.patientRight}', lowerRightTeeth),
          quadrant('${l10n.lowerJaw} · ${l10n.patientLeft}', lowerLeftTeeth),
        ]);
      }),
    );
  }
}

class _Midline extends StatelessWidget {
  const _Midline();

  @override
  Widget build(BuildContext context) => Container(width: 2, height: 36, color: Theme.of(context).dividerColor);
}

class _ToothButton extends StatelessWidget {
  final int number;
  final bool selected;
  final ValueChanged<int>? onTap;

  const _ToothButton({required this.number, required this.selected, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Semantics(
        button: true,
        selected: selected,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap == null ? null : () => onTap!(number),
          child: Container(
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? colors.primary : colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$number',
              style: TextStyle(
                color: selected ? colors.onPrimary : colors.onSurface,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
