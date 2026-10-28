import 'package:flutter/material.dart';
import 'package:shadesmaster/app/app_scope.dart';
import 'package:shadesmaster/l10n/app_localizations.dart';
import 'package:shadesmaster/orders/shade_guide.dart';
import 'package:shadesmaster/orders/shade_guide_labels.dart';

/// What the dentist picked for a shade area. A null [name] means: keep the
/// letter drawn on the photo.
class ShadeNameChoice {
  final String? name;
  const ShadeNameChoice(this.name);
}

/// Lets the dentist give a drawn shade area the name printed on the tab.
/// Resolves to null when the sheet is dismissed without a choice.
Future<ShadeNameChoice?> showShadeNamePicker(BuildContext context, {required String letter, String? current}) {
  return showModalBottomSheet<ShadeNameChoice>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _ShadeNamePicker(letter: letter, current: current),
  );
}

class _ShadeNamePicker extends StatefulWidget {
  final String letter;
  final String? current;
  const _ShadeNamePicker({required this.letter, this.current});

  @override
  State<_ShadeNamePicker> createState() => _ShadeNamePickerState();
}

class _ShadeNamePickerState extends State<_ShadeNamePicker> {
  late ShadeGuide _guide = _initialGuide();

  ShadeGuide _initialGuide() {
    final current = widget.current;
    final fallback = AppScope.of(context).settings.defaults.shadeGuide;
    if (current == null || fallback.shades.contains(current)) return fallback;
    return ShadeGuide.values.firstWhere((guide) => guide.shades.contains(current), orElse: () => fallback);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.shadeNameTitle(widget.letter), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SegmentedButton<ShadeGuide>(
              segments: [
                for (final guide in ShadeGuide.values) ButtonSegment(value: guide, label: Text(guide.label(l10n))),
              ],
              selected: {_guide},
              onSelectionChanged: (selection) {
                setState(() => _guide = selection.first);
                final settings = AppScope.of(context).settings;
                settings.defaults = settings.defaults.copyWith(shadeGuide: selection.first);
              },
            ),
            const SizedBox(height: 12),
            // Shade names read left to right in every language.
            Directionality(
              textDirection: TextDirection.ltr,
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final shade in _guide.shades)
                    ChoiceChip(
                      label: Text(shade),
                      selected: shade == widget.current,
                      onSelected: (_) => Navigator.of(context).pop(ShadeNameChoice(shade)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(const ShadeNameChoice(null)),
                child: Text(l10n.useLetter),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
