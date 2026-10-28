import 'package:shadesmaster/analysis/analyze.dart';
import 'package:shadesmaster/l10n/app_localizations.dart';
import 'package:shadesmaster/orders/lab_order.dart';
import 'package:shadesmaster/orders/shade_guide.dart';

/// Translated names of the enums shown to the user.

extension ShadeGuideLabel on ShadeGuide {
  String label(AppLocalizations l10n) => switch (this) {
        ShadeGuide.classical => l10n.shadeGuideClassical,
        ShadeGuide.threeDMaster => l10n.shadeGuide3dMaster,
      };
}

extension MatchCategoryLabel on MatchCategory {
  String label(AppLocalizations l10n) => switch (this) {
        MatchCategory.excellent => l10n.matchExcellent,
        MatchCategory.acceptable => l10n.matchAcceptable,
        MatchCategory.moderatelyUnacceptable => l10n.matchModeratelyUnacceptable,
        MatchCategory.clearlyUnacceptable => l10n.matchClearlyUnacceptable,
        MatchCategory.extremelyUnacceptable => l10n.matchExtremelyUnacceptable,
      };
}

extension RestorationTypeLabel on RestorationType {
  String label(AppLocalizations l10n) => switch (this) {
        RestorationType.crown => l10n.restorationCrown,
        RestorationType.veneer => l10n.restorationVeneer,
        RestorationType.bridge => l10n.restorationBridge,
        RestorationType.implantCrown => l10n.restorationImplantCrown,
        RestorationType.inlayOnlay => l10n.restorationInlayOnlay,
        RestorationType.other => l10n.restorationOther,
      };
}

extension RestorationMaterialLabel on RestorationMaterial {
  String label(AppLocalizations l10n) => switch (this) {
        RestorationMaterial.zirconia => l10n.materialZirconia,
        RestorationMaterial.lithiumDisilicate => l10n.materialLithiumDisilicate,
        RestorationMaterial.porcelainFusedToMetal => l10n.materialPfm,
        RestorationMaterial.pmma => l10n.materialPmma,
        RestorationMaterial.composite => l10n.materialComposite,
        RestorationMaterial.other => l10n.materialOther,
      };
}
