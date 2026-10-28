import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ar'), Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Dental Case'**
  String get appTitle;

  /// No description provided for @homeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Shade card and lab order'**
  String get homeHeadline;

  /// No description provided for @homeHint.
  ///
  /// In en, this message translates to:
  /// **'Start with a photo that shows both the teeth and the closest shades'**
  String get homeHint;

  /// No description provided for @useCamera.
  ///
  /// In en, this message translates to:
  /// **'Use Camera'**
  String get useCamera;

  /// No description provided for @pickImage.
  ///
  /// In en, this message translates to:
  /// **'Pick Image'**
  String get pickImage;

  /// No description provided for @labOrders.
  ///
  /// In en, this message translates to:
  /// **'Lab orders'**
  String get labOrders;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @basedOn.
  ///
  /// In en, this message translates to:
  /// **'Based on Shade Master by Dr. Ali A. Saleem (MIT License)'**
  String get basedOn;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appVersion(String version);

  /// No description provided for @drawTeeth.
  ///
  /// In en, this message translates to:
  /// **'Draw Teeth'**
  String get drawTeeth;

  /// No description provided for @drawShades.
  ///
  /// In en, this message translates to:
  /// **'Draw Shades'**
  String get drawShades;

  /// No description provided for @startAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Start Analyze'**
  String get startAnalyze;

  /// No description provided for @closeImage.
  ///
  /// In en, this message translates to:
  /// **'Close image'**
  String get closeImage;

  /// No description provided for @toothLabel.
  ///
  /// In en, this message translates to:
  /// **'Tooth {number}'**
  String toothLabel(int number);

  /// No description provided for @shadeLabel.
  ///
  /// In en, this message translates to:
  /// **'Shade {name}'**
  String shadeLabel(String name);

  /// No description provided for @nameShadeHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a shade to give it the name printed on its tab'**
  String get nameShadeHint;

  /// No description provided for @shadeNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Name of shade {letter}'**
  String shadeNameTitle(String letter);

  /// No description provided for @useLetter.
  ///
  /// In en, this message translates to:
  /// **'Keep the letter'**
  String get useLetter;

  /// No description provided for @showAreas.
  ///
  /// In en, this message translates to:
  /// **'Show areas'**
  String get showAreas;

  /// No description provided for @hideAreas.
  ///
  /// In en, this message translates to:
  /// **'Hide areas'**
  String get hideAreas;

  /// No description provided for @resultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Color Matches'**
  String get resultsTitle;

  /// No description provided for @winner.
  ///
  /// In en, this message translates to:
  /// **'Winner'**
  String get winner;

  /// No description provided for @perTooth.
  ///
  /// In en, this message translates to:
  /// **'Per tooth'**
  String get perTooth;

  /// No description provided for @toothResult.
  ///
  /// In en, this message translates to:
  /// **'Tooth {tooth}: closest is {shade}'**
  String toothResult(int tooth, String shade);

  /// No description provided for @deltaWithCategory.
  ///
  /// In en, this message translates to:
  /// **'ΔE00 {value} · {category}'**
  String deltaWithCategory(String value, String category);

  /// No description provided for @noPixels.
  ///
  /// In en, this message translates to:
  /// **'No pixels in this area'**
  String get noPixels;

  /// No description provided for @matchExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent match'**
  String get matchExcellent;

  /// No description provided for @matchAcceptable.
  ///
  /// In en, this message translates to:
  /// **'Clinically acceptable'**
  String get matchAcceptable;

  /// No description provided for @matchModeratelyUnacceptable.
  ///
  /// In en, this message translates to:
  /// **'Moderately unacceptable'**
  String get matchModeratelyUnacceptable;

  /// No description provided for @matchClearlyUnacceptable.
  ///
  /// In en, this message translates to:
  /// **'Clearly unacceptable'**
  String get matchClearlyUnacceptable;

  /// No description provided for @matchExtremelyUnacceptable.
  ///
  /// In en, this message translates to:
  /// **'Extremely unacceptable'**
  String get matchExtremelyUnacceptable;

  /// No description provided for @deltaExplanation.
  ///
  /// In en, this message translates to:
  /// **'ΔE00 is the CIEDE2000 color difference. Up to 0.8 is hard to see, up to 1.8 is clinically acceptable.'**
  String get deltaExplanation;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @createOrder.
  ///
  /// In en, this message translates to:
  /// **'Create lab order'**
  String get createOrder;

  /// No description provided for @emptyTeeth.
  ///
  /// In en, this message translates to:
  /// **'The teeth areas don\'t cover any pixels of the photo'**
  String get emptyTeeth;

  /// No description provided for @emptyShades.
  ///
  /// In en, this message translates to:
  /// **'The shade areas don\'t cover any pixels of the photo'**
  String get emptyShades;

  /// No description provided for @newOrder.
  ///
  /// In en, this message translates to:
  /// **'New lab order'**
  String get newOrder;

  /// No description provided for @editOrder.
  ///
  /// In en, this message translates to:
  /// **'Edit lab order'**
  String get editOrder;

  /// No description provided for @newOrderWithoutPhoto.
  ///
  /// In en, this message translates to:
  /// **'New order without photo'**
  String get newOrderWithoutPhoto;

  /// No description provided for @sectionCase.
  ///
  /// In en, this message translates to:
  /// **'Case'**
  String get sectionCase;

  /// No description provided for @caseCode.
  ///
  /// In en, this message translates to:
  /// **'Case code'**
  String get caseCode;

  /// No description provided for @caseCodeHelp.
  ///
  /// In en, this message translates to:
  /// **'Use a code instead of the patient\'s name'**
  String get caseCodeHelp;

  /// No description provided for @patientName.
  ///
  /// In en, this message translates to:
  /// **'Patient name (optional)'**
  String get patientName;

  /// No description provided for @sectionClinic.
  ///
  /// In en, this message translates to:
  /// **'Clinic and laboratory'**
  String get sectionClinic;

  /// No description provided for @dentistName.
  ///
  /// In en, this message translates to:
  /// **'Dentist'**
  String get dentistName;

  /// No description provided for @clinicName.
  ///
  /// In en, this message translates to:
  /// **'Clinic'**
  String get clinicName;

  /// No description provided for @clinicPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get clinicPhone;

  /// No description provided for @labName.
  ///
  /// In en, this message translates to:
  /// **'Laboratory'**
  String get labName;

  /// No description provided for @sectionTeeth.
  ///
  /// In en, this message translates to:
  /// **'Teeth (FDI)'**
  String get sectionTeeth;

  /// No description provided for @teethRequired.
  ///
  /// In en, this message translates to:
  /// **'Select at least one tooth'**
  String get teethRequired;

  /// No description provided for @upperJaw.
  ///
  /// In en, this message translates to:
  /// **'Upper'**
  String get upperJaw;

  /// No description provided for @lowerJaw.
  ///
  /// In en, this message translates to:
  /// **'Lower'**
  String get lowerJaw;

  /// No description provided for @patientRight.
  ///
  /// In en, this message translates to:
  /// **'Patient\'s right'**
  String get patientRight;

  /// No description provided for @patientLeft.
  ///
  /// In en, this message translates to:
  /// **'Patient\'s left'**
  String get patientLeft;

  /// No description provided for @sectionRestoration.
  ///
  /// In en, this message translates to:
  /// **'Restoration'**
  String get sectionRestoration;

  /// No description provided for @restorationType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get restorationType;

  /// No description provided for @restorationCrown.
  ///
  /// In en, this message translates to:
  /// **'Crown'**
  String get restorationCrown;

  /// No description provided for @restorationVeneer.
  ///
  /// In en, this message translates to:
  /// **'Veneer'**
  String get restorationVeneer;

  /// No description provided for @restorationBridge.
  ///
  /// In en, this message translates to:
  /// **'Bridge'**
  String get restorationBridge;

  /// No description provided for @restorationImplantCrown.
  ///
  /// In en, this message translates to:
  /// **'Implant crown'**
  String get restorationImplantCrown;

  /// No description provided for @restorationInlayOnlay.
  ///
  /// In en, this message translates to:
  /// **'Inlay / onlay'**
  String get restorationInlayOnlay;

  /// No description provided for @restorationOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get restorationOther;

  /// No description provided for @material.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get material;

  /// No description provided for @materialZirconia.
  ///
  /// In en, this message translates to:
  /// **'Zirconia'**
  String get materialZirconia;

  /// No description provided for @materialLithiumDisilicate.
  ///
  /// In en, this message translates to:
  /// **'Lithium disilicate (e.max)'**
  String get materialLithiumDisilicate;

  /// No description provided for @materialPfm.
  ///
  /// In en, this message translates to:
  /// **'Porcelain fused to metal'**
  String get materialPfm;

  /// No description provided for @materialPmma.
  ///
  /// In en, this message translates to:
  /// **'PMMA (temporary)'**
  String get materialPmma;

  /// No description provided for @materialComposite.
  ///
  /// In en, this message translates to:
  /// **'Composite'**
  String get materialComposite;

  /// No description provided for @materialOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get materialOther;

  /// No description provided for @sectionShade.
  ///
  /// In en, this message translates to:
  /// **'Shade'**
  String get sectionShade;

  /// No description provided for @shadeGuide.
  ///
  /// In en, this message translates to:
  /// **'Shade guide'**
  String get shadeGuide;

  /// No description provided for @shadeGuideClassical.
  ///
  /// In en, this message translates to:
  /// **'Classical (A1–D4)'**
  String get shadeGuideClassical;

  /// No description provided for @shadeGuide3dMaster.
  ///
  /// In en, this message translates to:
  /// **'3D-Master'**
  String get shadeGuide3dMaster;

  /// No description provided for @shadeBody.
  ///
  /// In en, this message translates to:
  /// **'Body shade'**
  String get shadeBody;

  /// No description provided for @shadeBodyRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose the body shade'**
  String get shadeBodyRequired;

  /// No description provided for @shadeCervical.
  ///
  /// In en, this message translates to:
  /// **'Cervical third'**
  String get shadeCervical;

  /// No description provided for @shadeIncisal.
  ///
  /// In en, this message translates to:
  /// **'Incisal third'**
  String get shadeIncisal;

  /// No description provided for @shadeStump.
  ///
  /// In en, this message translates to:
  /// **'Stump shade'**
  String get shadeStump;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @photoAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Photo analysis'**
  String get photoAnalysis;

  /// No description provided for @analysisSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Suggested by the photo: {shade}'**
  String analysisSuggestion(String shade);

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes for the laboratory'**
  String get notes;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Required by'**
  String get dueDate;

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get pickDate;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @orderSaved.
  ///
  /// In en, this message translates to:
  /// **'Order saved'**
  String get orderSaved;

  /// No description provided for @noOrders.
  ///
  /// In en, this message translates to:
  /// **'No saved orders yet'**
  String get noOrders;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Teeth {teeth} · {shade}'**
  String orderSummary(String teeth, String shade);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteOrderQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete this order and its photo?'**
  String get deleteOrderQuestion;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @previewPdf.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewPdf;

  /// No description provided for @sharePdf.
  ///
  /// In en, this message translates to:
  /// **'Share PDF'**
  String get sharePdf;

  /// No description provided for @printPdf.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get printPdf;

  /// No description provided for @createdOn.
  ///
  /// In en, this message translates to:
  /// **'Created {date}'**
  String createdOn(String date);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @defaultsSection.
  ///
  /// In en, this message translates to:
  /// **'Defaults for new orders'**
  String get defaultsSection;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Open source licenses'**
  String get licenses;

  /// No description provided for @pdfTitle.
  ///
  /// In en, this message translates to:
  /// **'Dental lab order'**
  String get pdfTitle;

  /// No description provided for @pdfOrderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order no.'**
  String get pdfOrderNumber;

  /// No description provided for @pdfDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get pdfDate;

  /// No description provided for @pdfPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo with the analysed areas'**
  String get pdfPhoto;

  /// No description provided for @patient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patient;

  /// No description provided for @pdfTooth.
  ///
  /// In en, this message translates to:
  /// **'Tooth'**
  String get pdfTooth;

  /// No description provided for @pdfShade.
  ///
  /// In en, this message translates to:
  /// **'Shade'**
  String get pdfShade;

  /// No description provided for @pdfAssessment.
  ///
  /// In en, this message translates to:
  /// **'Assessment'**
  String get pdfAssessment;

  /// No description provided for @pdfDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'The shade analysis is an estimate from a photo. Confirm the shade visually under standard lighting.'**
  String get pdfDisclaimer;

  /// No description provided for @pdfSignature.
  ///
  /// In en, this message translates to:
  /// **'Dentist signature'**
  String get pdfSignature;

  /// No description provided for @pdfPage.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {total}'**
  String pdfPage(int page, int total);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError('AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
