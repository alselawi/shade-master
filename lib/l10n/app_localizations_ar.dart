// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'بطاقة الحالة';

  @override
  String get homeHeadline => 'بطاقة لون وطلب مخبري';

  @override
  String get homeHint => 'ابدأ بصورة تُظهر الأسنان وأقرب ألسنة دليل الألوان إليها';

  @override
  String get useCamera => 'الكاميرا';

  @override
  String get pickImage => 'المعرض';

  @override
  String get labOrders => 'طلبات المخبر';

  @override
  String get settings => 'الإعدادات';

  @override
  String get basedOn => 'مبني على Shade Master للدكتور علي أ. سليم (رخصة MIT)';

  @override
  String appVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get drawTeeth => 'حدّد الأسنان';

  @override
  String get drawShades => 'حدّد الألوان';

  @override
  String get startAnalyze => 'حلّل';

  @override
  String get closeImage => 'إغلاق الصورة';

  @override
  String toothLabel(int number) {
    return 'سن $number';
  }

  @override
  String shadeLabel(String name) {
    return 'اللون $name';
  }

  @override
  String get nameShadeHint => 'اضغط على لون لتسميه بالاسم المطبوع على لسانه';

  @override
  String shadeNameTitle(String letter) {
    return 'اسم اللون $letter';
  }

  @override
  String get useLetter => 'إبقاء الحرف';

  @override
  String get showAreas => 'إظهار المناطق';

  @override
  String get hideAreas => 'إخفاء المناطق';

  @override
  String get resultsTitle => 'نتائج المطابقة';

  @override
  String get winner => 'الأقرب';

  @override
  String get perTooth => 'لكل سن';

  @override
  String toothResult(int tooth, String shade) {
    return 'السن $tooth: الأقرب $shade';
  }

  @override
  String deltaWithCategory(String value, String category) {
    return 'ΔE00 $value · $category';
  }

  @override
  String get noPixels => 'المنطقة لا تغطي أي بكسل';

  @override
  String get matchExcellent => 'تطابق ممتاز';

  @override
  String get matchAcceptable => 'مقبول سريرياً';

  @override
  String get matchModeratelyUnacceptable => 'غير مقبول بدرجة متوسطة';

  @override
  String get matchClearlyUnacceptable => 'غير مقبول بوضوح';

  @override
  String get matchExtremelyUnacceptable => 'غير مقبول إطلاقاً';

  @override
  String get deltaExplanation =>
      'ΔE00 هو فرق اللون بمعادلة CIEDE2000. حتى 0.8 يصعب تمييزه بالعين، وحتى 1.8 مقبول سريرياً.';

  @override
  String get close => 'إغلاق';

  @override
  String get createOrder => 'إنشاء طلب مخبري';

  @override
  String get emptyTeeth => 'مناطق الأسنان لا تغطي أي بكسل من الصورة';

  @override
  String get emptyShades => 'مناطق الألوان لا تغطي أي بكسل من الصورة';

  @override
  String get newOrder => 'طلب مخبري جديد';

  @override
  String get editOrder => 'تعديل الطلب';

  @override
  String get newOrderWithoutPhoto => 'طلب جديد بدون صورة';

  @override
  String get sectionCase => 'الحالة';

  @override
  String get caseCode => 'رمز الحالة';

  @override
  String get caseCodeHelp => 'استخدم رمزاً بدل اسم المريض';

  @override
  String get patientName => 'اسم المريض (اختياري)';

  @override
  String get sectionClinic => 'العيادة والمخبر';

  @override
  String get dentistName => 'الطبيب';

  @override
  String get clinicName => 'العيادة';

  @override
  String get clinicPhone => 'الهاتف';

  @override
  String get labName => 'المخبر';

  @override
  String get sectionTeeth => 'الأسنان (ترقيم FDI)';

  @override
  String get teethRequired => 'اختر سناً واحداً على الأقل';

  @override
  String get upperJaw => 'الفك العلوي';

  @override
  String get lowerJaw => 'الفك السفلي';

  @override
  String get patientRight => 'يمين المريض';

  @override
  String get patientLeft => 'يسار المريض';

  @override
  String get sectionRestoration => 'التعويض';

  @override
  String get restorationType => 'النوع';

  @override
  String get restorationCrown => 'تاج';

  @override
  String get restorationVeneer => 'قشرة';

  @override
  String get restorationBridge => 'جسر';

  @override
  String get restorationImplantCrown => 'تاج على زرعة';

  @override
  String get restorationInlayOnlay => 'حشوة مخبرية Inlay أو Onlay';

  @override
  String get restorationOther => 'أخرى';

  @override
  String get material => 'المادة';

  @override
  String get materialZirconia => 'زركونيا';

  @override
  String get materialLithiumDisilicate => 'ليثيوم ديسيليكات (e.max)';

  @override
  String get materialPfm => 'خزف على معدن';

  @override
  String get materialPmma => 'PMMA (مؤقت)';

  @override
  String get materialComposite => 'كومبوزيت';

  @override
  String get materialOther => 'أخرى';

  @override
  String get sectionShade => 'اللون';

  @override
  String get shadeGuide => 'دليل الألوان';

  @override
  String get shadeGuideClassical => 'الكلاسيكي (A1–D4)';

  @override
  String get shadeGuide3dMaster => '3D-Master';

  @override
  String get shadeBody => 'اللون الأساسي';

  @override
  String get shadeBodyRequired => 'اختر اللون الأساسي';

  @override
  String get shadeCervical => 'الثلث العنقي';

  @override
  String get shadeIncisal => 'الثلث القاطع';

  @override
  String get shadeStump => 'لون الدعامة';

  @override
  String get notSet => 'غير محدد';

  @override
  String get photoAnalysis => 'تحليل الصورة';

  @override
  String analysisSuggestion(String shade) {
    return 'اقتراح التحليل: $shade';
  }

  @override
  String get notes => 'ملاحظات للمخبر';

  @override
  String get dueDate => 'تاريخ التسليم المطلوب';

  @override
  String get pickDate => 'اختر التاريخ';

  @override
  String get clear => 'مسح';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get required => 'مطلوب';

  @override
  String get orderSaved => 'حُفظ الطلب';

  @override
  String get noOrders => 'لا توجد طلبات محفوظة بعد';

  @override
  String orderSummary(String teeth, String shade) {
    return 'الأسنان $teeth · $shade';
  }

  @override
  String get delete => 'حذف';

  @override
  String get deleteOrderQuestion => 'حذف هذا الطلب مع صورته؟';

  @override
  String get edit => 'تعديل';

  @override
  String get previewPdf => 'معاينة';

  @override
  String get sharePdf => 'مشاركة PDF';

  @override
  String get printPdf => 'طباعة';

  @override
  String createdOn(String date) {
    return 'أُنشئ في $date';
  }

  @override
  String get language => 'اللغة';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get defaultsSection => 'البيانات الافتراضية للطلبات الجديدة';

  @override
  String get licenses => 'تراخيص البرمجيات المفتوحة';

  @override
  String get pdfTitle => 'طلب مخبر أسنان';

  @override
  String get pdfOrderNumber => 'رقم الطلب';

  @override
  String get pdfDate => 'التاريخ';

  @override
  String get pdfPhoto => 'الصورة مع المناطق المحللة';

  @override
  String get patient => 'المريض';

  @override
  String get pdfTooth => 'السن';

  @override
  String get pdfShade => 'اللون';

  @override
  String get pdfAssessment => 'التقييم';

  @override
  String get pdfDisclaimer => 'تحليل اللون تقدير مأخوذ من صورة. يجب تأكيد اللون بالنظر تحت إضاءة قياسية.';

  @override
  String get pdfSignature => 'توقيع الطبيب';

  @override
  String pdfPage(int page, int total) {
    return 'صفحة $page من $total';
  }
}
