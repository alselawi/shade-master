# إصدار التطبيق ونشره

هذا الدليل يشرح توقيع نسخة الإصدار وبناءها، ونشرها على `Google Play` أو توزيعها مباشرة.

## 1. مفتاح التوقيع

بدون مفتاح خاص تُوقَّع نسخة الإصدار بمفتاح التصحيح، وتصلح للتجربة فقط. أنشئ المفتاح مرة واحدة واحفظه مع كلمتي المرور في مكان آمن، لأن فقدانه يمنع تحديث التطبيق لاحقاً:

```bash
keytool -genkeypair -v -keystore ~/dental-case-release.jks -storetype JKS \
  -keyalg RSA -keysize 4096 -validity 10000 -alias dental-case
```

## 2. البناء على جهازك

أنشئ الملف `android/key.properties` (مستثنى من `git` في `android/.gitignore`):

```properties
storeFile=/home/you/dental-case-release.jks
storePassword=كلمة مرور المخزن
keyAlias=dental-case
keyPassword=كلمة مرور المفتاح
```

ثم:

```bash
flutter pub get
flutter test
flutter build appbundle --release   # للنشر على Google Play
flutter build apk --release         # للتوزيع المباشر
```

الملفات الناتجة:

```text
build/app/outputs/bundle/release/app-release.aab
build/app/outputs/flutter-apk/app-release.apk
```

ملف `APK` الشامل يقارب 60 ميغابايت لأنه يحمل مكتبات ثلاثة معالجات بلا ضغط. `Google Play` يرسل من ملف `AAB` الجزء المناسب لكل جهاز فقط. للتوزيع المباشر يمكن بناء ملف لكل معالج، ومعظم الهواتف الحديثة تحتاج ملف `arm64-v8a`:

```bash
flutter build apk --release --split-per-abi
```

## 3. البناء على GitHub Actions

سير العمل `.github/workflows/android-build.yml` يبني الملفين عند كل دفع. ليوقّعهما بمفتاحك أضف أربعة أسرار في إعدادات المستودع ضمن `Settings` ثم `Secrets and variables` ثم `Actions`:

| السر | القيمة |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | محتوى ملف المفتاح بترميز `base64` |
| `ANDROID_KEYSTORE_PASSWORD` | كلمة مرور المخزن |
| `ANDROID_KEY_ALIAS` | `dental-case` |
| `ANDROID_KEY_PASSWORD` | كلمة مرور المفتاح |

لتحويل الملف إلى `base64`:

```bash
base64 -w0 ~/dental-case-release.jks
```

بدون هذه الأسرار يستمر البناء موقّعاً بمفتاح التصحيح. تجنّب الشرطة المائلة العكسية في كلمات المرور لأنها تُفسَّر داخل ملف `key.properties`.

## 4. رقم الإصدار

يُقرأ من السطر `version` في `pubspec.yaml`، مثل `1.0.0+1`. الجزء بعد `+` هو `versionCode` ويجب أن يزيد مع كل رفع إلى `Google Play`. حدّث أيضاً `appVersion` في `lib/main.dart` ليظهر الرقم نفسه في الشاشة الرئيسية.

## 5. قبل النشر على Google Play

1. معرّف التطبيق `com.alkazem.dentalcase` ثابت بعد أول رفع ولا يمكن تغييره.
2. سياسة الخصوصية: استخدم `docs/privacy-policy.md` وانشرها على رابط عام.
3. نموذج `Data safety`: التطبيق لا يجمع بيانات ولا يرسلها. الصور والطلبات تبقى على الجهاز، وما يشاركه الطبيب يرسله بنفسه عبر تطبيق يختاره.
4. لقطات الشاشة في `docs/images` مأخوذة من صورة تجريبية مولّدة، ويمكن استخدامها في صفحة المتجر.
5. التطبيق أداة مساعدة وليس جهازاً طبياً لقياس اللون. التنبيه نفسه موجود في ملف `PDF`، ويستحسن ذكره في وصف المتجر.
6. مسألة الترخيص المذكورة في `docs/prep-report.md`: يستحسن الحصول على تأكيد المؤلف الأصلي لسطر حقوق النشر قبل النشر العام.

## 6. توليد الأيقونة ولقطات الشاشة

الأيقونة مرسومة في `assets/icon/app_icon.svg`. بعد تعديل ملفات `PNG` المشتقة منها:

```bash
dart run flutter_launcher_icons
```

لقطات الشاشة تُولَّد من الصورة التجريبية `docs/images/demo-photo.jpg`:

```bash
flutter test tool/screenshots_test.dart --update-goldens
```
