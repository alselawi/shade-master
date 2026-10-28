import 'package:flutter/material.dart';
import 'package:shadesmaster/analysis/analyze.dart';
import 'package:shadesmaster/l10n/app_localizations.dart';
import 'package:shadesmaster/orders/shade_guide_labels.dart';

String analysisProblemMessage(AppLocalizations l10n, AnalysisProblem problem) {
  switch (problem) {
    case AnalysisProblem.emptyTeeth:
      return l10n.emptyTeeth;
    case AnalysisProblem.emptyShades:
      return l10n.emptyShades;
  }
}

Color matchCategoryColor(MatchCategory category) {
  switch (category) {
    case MatchCategory.excellent:
      return Colors.green.shade700;
    case MatchCategory.acceptable:
      return Colors.lightGreen.shade800;
    case MatchCategory.moderatelyUnacceptable:
      return Colors.orange.shade800;
    case MatchCategory.clearlyUnacceptable:
    case MatchCategory.extremelyUnacceptable:
      return Colors.red.shade700;
  }
}

/// Shows the ranking. Resolves to true when the dentist chose to create a
/// lab order from it (only offered when [canCreateOrder]).
Future<bool?> showResultsDialog(BuildContext context, AnalysisResult results, {bool canCreateOrder = false}) {
  final l10n = AppLocalizations.of(context);
  return showDialog<bool>(
    barrierDismissible: false,
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.resultsTitle),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final shade in results.shades) ShadeResultTile(shade: shade),
            if (results.teeth.length > 1) ...[
              const SizedBox(height: 12),
              Text(l10n.perTooth, style: Theme.of(context).textTheme.titleSmall),
              for (final tooth in results.teeth)
                ListTile(
                  dense: true,
                  leading: ColorSwatchBox(color: tooth.averageColor),
                  title: Text(l10n.toothResult(tooth.index + 1, tooth.winner.name)),
                  subtitle: Text(deltaText(l10n, tooth.winner)),
                ),
            ],
            const SizedBox(height: 12),
            Text(l10n.deltaExplanation, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.close),
        ),
        if (canCreateOrder)
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.assignment_outlined),
            label: Text(l10n.createOrder),
          ),
      ],
    ),
  );
}

String deltaText(AppLocalizations l10n, ShadeResult shade) {
  if (!shade.hasPixels) return l10n.noPixels;
  return l10n.deltaWithCategory(shade.delta.toStringAsFixed(2), shade.category.label(l10n));
}

class ShadeResultTile extends StatelessWidget {
  final ShadeResult shade;
  const ShadeResultTile({super.key, required this.shade});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: ListTile(
        selected: shade.winner,
        selectedColor: Colors.green,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorSwatchBox(color: shade.averageColor),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward),
          ],
        ),
        title: Text(l10n.shadeLabel(shade.name)),
        subtitle: Text(
          deltaText(l10n, shade),
          style: TextStyle(color: shade.hasPixels ? matchCategoryColor(shade.category) : null),
        ),
        trailing: shade.winner ? Text(l10n.winner) : SizedBox.shrink(),
      ),
    );
  }
}

class ColorSwatchBox extends StatelessWidget {
  final Color color;
  final double size;
  const ColorSwatchBox({super.key, required this.color, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.grey),
      ),
    );
  }
}
