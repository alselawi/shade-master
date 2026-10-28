// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Dental Case';

  @override
  String get homeHeadline => 'Shade card and lab order';

  @override
  String get homeHint => 'Start with a photo that shows both the teeth and the closest shades';

  @override
  String get useCamera => 'Use Camera';

  @override
  String get pickImage => 'Pick Image';

  @override
  String get labOrders => 'Lab orders';

  @override
  String get settings => 'Settings';

  @override
  String get basedOn => 'Based on Shade Master by Dr. Ali A. Saleem (MIT License)';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get drawTeeth => 'Draw Teeth';

  @override
  String get drawShades => 'Draw Shades';

  @override
  String get startAnalyze => 'Start Analyze';

  @override
  String get closeImage => 'Close image';

  @override
  String toothLabel(int number) {
    return 'Tooth $number';
  }

  @override
  String shadeLabel(String name) {
    return 'Shade $name';
  }

  @override
  String get nameShadeHint => 'Tap a shade to give it the name printed on its tab';

  @override
  String shadeNameTitle(String letter) {
    return 'Name of shade $letter';
  }

  @override
  String get useLetter => 'Keep the letter';

  @override
  String get showAreas => 'Show areas';

  @override
  String get hideAreas => 'Hide areas';

  @override
  String get resultsTitle => 'Color Matches';

  @override
  String get winner => 'Winner';

  @override
  String get perTooth => 'Per tooth';

  @override
  String toothResult(int tooth, String shade) {
    return 'Tooth $tooth: closest is $shade';
  }

  @override
  String deltaWithCategory(String value, String category) {
    return 'ΔE00 $value · $category';
  }

  @override
  String get noPixels => 'No pixels in this area';

  @override
  String get matchExcellent => 'Excellent match';

  @override
  String get matchAcceptable => 'Clinically acceptable';

  @override
  String get matchModeratelyUnacceptable => 'Moderately unacceptable';

  @override
  String get matchClearlyUnacceptable => 'Clearly unacceptable';

  @override
  String get matchExtremelyUnacceptable => 'Extremely unacceptable';

  @override
  String get deltaExplanation =>
      'ΔE00 is the CIEDE2000 color difference. Up to 0.8 is hard to see, up to 1.8 is clinically acceptable.';

  @override
  String get close => 'Close';

  @override
  String get createOrder => 'Create lab order';

  @override
  String get emptyTeeth => 'The teeth areas don\'t cover any pixels of the photo';

  @override
  String get emptyShades => 'The shade areas don\'t cover any pixels of the photo';

  @override
  String get newOrder => 'New lab order';

  @override
  String get editOrder => 'Edit lab order';

  @override
  String get newOrderWithoutPhoto => 'New order without photo';

  @override
  String get sectionCase => 'Case';

  @override
  String get caseCode => 'Case code';

  @override
  String get caseCodeHelp => 'Use a code instead of the patient\'s name';

  @override
  String get patientName => 'Patient name (optional)';

  @override
  String get sectionClinic => 'Clinic and laboratory';

  @override
  String get dentistName => 'Dentist';

  @override
  String get clinicName => 'Clinic';

  @override
  String get clinicPhone => 'Phone';

  @override
  String get labName => 'Laboratory';

  @override
  String get sectionTeeth => 'Teeth (FDI)';

  @override
  String get teethRequired => 'Select at least one tooth';

  @override
  String get upperJaw => 'Upper';

  @override
  String get lowerJaw => 'Lower';

  @override
  String get patientRight => 'Patient\'s right';

  @override
  String get patientLeft => 'Patient\'s left';

  @override
  String get sectionRestoration => 'Restoration';

  @override
  String get restorationType => 'Type';

  @override
  String get restorationCrown => 'Crown';

  @override
  String get restorationVeneer => 'Veneer';

  @override
  String get restorationBridge => 'Bridge';

  @override
  String get restorationImplantCrown => 'Implant crown';

  @override
  String get restorationInlayOnlay => 'Inlay / onlay';

  @override
  String get restorationOther => 'Other';

  @override
  String get material => 'Material';

  @override
  String get materialZirconia => 'Zirconia';

  @override
  String get materialLithiumDisilicate => 'Lithium disilicate (e.max)';

  @override
  String get materialPfm => 'Porcelain fused to metal';

  @override
  String get materialPmma => 'PMMA (temporary)';

  @override
  String get materialComposite => 'Composite';

  @override
  String get materialOther => 'Other';

  @override
  String get sectionShade => 'Shade';

  @override
  String get shadeGuide => 'Shade guide';

  @override
  String get shadeGuideClassical => 'Classical (A1–D4)';

  @override
  String get shadeGuide3dMaster => '3D-Master';

  @override
  String get shadeBody => 'Body shade';

  @override
  String get shadeBodyRequired => 'Choose the body shade';

  @override
  String get shadeCervical => 'Cervical third';

  @override
  String get shadeIncisal => 'Incisal third';

  @override
  String get shadeStump => 'Stump shade';

  @override
  String get notSet => 'Not set';

  @override
  String get photoAnalysis => 'Photo analysis';

  @override
  String analysisSuggestion(String shade) {
    return 'Suggested by the photo: $shade';
  }

  @override
  String get notes => 'Notes for the laboratory';

  @override
  String get dueDate => 'Required by';

  @override
  String get pickDate => 'Pick a date';

  @override
  String get clear => 'Clear';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get required => 'Required';

  @override
  String get orderSaved => 'Order saved';

  @override
  String get noOrders => 'No saved orders yet';

  @override
  String orderSummary(String teeth, String shade) {
    return 'Teeth $teeth · $shade';
  }

  @override
  String get delete => 'Delete';

  @override
  String get deleteOrderQuestion => 'Delete this order and its photo?';

  @override
  String get edit => 'Edit';

  @override
  String get previewPdf => 'Preview';

  @override
  String get sharePdf => 'Share PDF';

  @override
  String get printPdf => 'Print';

  @override
  String createdOn(String date) {
    return 'Created $date';
  }

  @override
  String get language => 'Language';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get defaultsSection => 'Defaults for new orders';

  @override
  String get licenses => 'Open source licenses';

  @override
  String get pdfTitle => 'Dental lab order';

  @override
  String get pdfOrderNumber => 'Order no.';

  @override
  String get pdfDate => 'Date';

  @override
  String get pdfPhoto => 'Photo with the analysed areas';

  @override
  String get patient => 'Patient';

  @override
  String get pdfTooth => 'Tooth';

  @override
  String get pdfShade => 'Shade';

  @override
  String get pdfAssessment => 'Assessment';

  @override
  String get pdfDisclaimer =>
      'The shade analysis is an estimate from a photo. Confirm the shade visually under standard lighting.';

  @override
  String get pdfSignature => 'Dentist signature';

  @override
  String pdfPage(int page, int total) {
    return 'Page $page of $total';
  }
}
