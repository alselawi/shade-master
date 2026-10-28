# تقرير الفحص والتجهيز

> هذا تقرير مرحلة الفحص الأولى كما كُتب قبل التطوير. بعده نُفّذت كل مراحل `docs/roadmap.md`، وحالة كل مشكلة في القسم الأخير "المشاكل المتبقية" محدّثة.

المرحلة: فحص المشروع وتجهيز البناء قبل تطويره إلى "بطاقة لون وطلب مخبري".
الفرع: `claude/sharp-meitner-t7996e`.
لم يُغيَّر أي سلوك في التطبيق. التغييرات محصورة في ملفات البناء والاختبارات والتوثيق.

## ملخص

| البند | النتيجة |
| --- | --- |
| الكود الأصلي على `Flutter 3.27.0` | التحليل بلا أخطاء (25 ملاحظة أسلوبية)، والاختبار الوحيد فاشل لأنه اختبار القالب الافتراضي |
| الكود على `Flutter 3.47.8` قبل التعديل | إعدادات `Gradle` أقدم من الحد الأدنى الذي يقبله `Flutter` |
| بعد التعديل محلياً | التحليل بلا أخطاء، وثمانية اختبارات ناجحة، وترجمة كود `Dart` إلى ملف `ARM64` لأندرويد ناجحة |
| بناء `APK` داخل الحاوية | متعذر: سياسة الشبكة تحجب `dl.google.com` الذي يُنزَّل منه `Android SDK` |
| بناء `APK` على `GitHub Actions` | نجح: ملف `app-release.apk` بحجم 47 ميغابايت، `minSdk 24` و `targetSdk 36` |

## بنية المشروع

| المسار | المحتوى |
| --- | --- |
| `lib/main.dart` | نقطة البداية وشاشة الترحيب واختيار الصورة |
| `lib/widget_shade_master.dart` | مساحة العمل: عرض الصورة والرسم والأدوات ونافذة النتائج |
| `lib/widget_selection_painter.dart` | رسم المناطق وترقيمها فوق الصورة |
| `lib/drawings.dart` | الأصناف `GlobalOffset` و `Stroke` و `Region` مع التخزين المؤقت للألوان |
| `lib/analysis/` | خوارزمية التحليل واستخراج البكسلات ومعادلة `CIEDE2000` |
| `lib/utils/` | التحويل إلى `Lab` ومتوسط اللون وفك ترميز الصورة وأدوات صغيرة |
| `lib/widget_pill.dart` وأخواتها | مكوّنات واجهة صغيرة |
| `test/` | الاختبارات |
| `android/` | مشروع أندرويد، وهو المنصة المستهدفة الوحيدة حسب `README` |
| `ios/` و `macos/` و `linux/` و `windows/` و `web/` | ملفات مولّدة لم تُختبر، والويب لن يعمل بسبب `dart:io` |
| `release/app-release.apk` | نسخة مبنية جاهزة من المؤلف الأصلي (20 ميغابايت تقريباً) |
| `index.html` و `screenshot.png` | صفحة تعريفية للمشروع الأصلي |

شرح الشاشات والخوارزمية في `docs/how-it-works.md`.

## الاعتماديات

| الحزمة | الاستخدام | النسخة قبل | النسخة بعد | الترخيص |
| --- | --- | --- | --- | --- |
| `image_picker` | الكاميرا والمعرض | 1.1.2 | 1.2.4 | `BSD-3-Clause` |
| `convex_hull` | دمج الخطوط في منطقة واحدة | 1.1.2 | دون تغيير | `BSD-3-Clause` |
| `vector_math` | نقاط الغلاف المحدّب | 2.1.4 | 2.4.4 (مثبتة من `Flutter`) | `BSD-3-Clause` |
| `hugeicons` | أيقونات شريط الأدوات | 0.0.11 | دون تغيير | `MIT` |
| `image` | غير مستخدمة حالياً | 4.5.4 | دون تغيير | `MIT` |
| `cupertino_icons` | غير مستخدمة حالياً | 1.0.8 | دون تغيير | `MIT` |
| `flutter_launcher_icons` | توليد أيقونات التطبيق | 0.14.3 | دون تغيير | `MIT` |
| `flutter_lints` | قواعد التحليل | 5.0.0 | دون تغيير | `BSD-3-Clause` |

كل الاعتماديات بتراخيص متساهلة تسمح بإعادة النشر بشرط إرفاق نصوص تراخيصها، و `Flutter` يجمعها تلقائياً في ملف `NOTICES` داخل التطبيق.

## الترخيص وما يحتاج توضيحاً قبل إعادة النشر

ما هو موجود:

1. ملف `README.md` ينتهي بعبارة `License MIT`.
2. ملف `index.html` يربط بموقع رخصة `MIT` ويذكر "© 2025 Shade Master - Developed by Dr. Ali A. Saleem".
3. شاشة الترحيب في التطبيق تذكر اسم المطوّر الأصلي.

ما يحتاج توضيحاً:

1. **لا يوجد ملف `LICENSE`** لا في هذا المستودع ولا في المستودع الأصلي `alselawi/shade-master` (فحصته وهو مطابق لهذا المستودع: نفس الالتزامين، ولا فروع أو وسوم أخرى). رخصة `MIT` تشترط إرفاق إشعار حقوق النشر ونص الإذن مع كل نسخة، وهنا لا يوجد نص كامل ولا اسم صريح لصاحب الحقوق.
2. **تعارض في صاحب الحقوق**: ملفات `windows/runner/Runner.rc` و `macos/Runner/Configs/AppInfo.xcconfig` تقول "Copyright (C) 2025 Apexo. All rights reserved."، بينما `index.html` ينسب العمل إلى شخص. غالباً هذه نصوص قالب، لكنها تتعارض حرفياً مع `MIT`.
3. **مصدر الصور**: `screenshot.png` صورة سريرية حقيقية لفم مريض مع ألسنة دليل ألوان، ولا يُعرف إن كان هناك إذن بنشرها. أيقونة `assets/icon/app_icon.png` مصدرها وترخيصها غير مذكورين.
4. **هوية التطبيق**: المعرّف `app.apexo.shadesmaster` يعود لنطاق المؤلف الأصلي. ملف `APK` المرفق موقّع بمفتاح تصحيح خاص بجهازه، فأي نسخة نبنيها بالمعرّف نفسه لن تُثبَّت فوق نسخته.
5. **الاسم**: "Shade Master" قد يكون مستخدماً تجارياً لدى جهات أخرى. يُستحسن فحصه قبل النشر في المتجر.

التوصية:

1. التواصل مع المؤلف الأصلي عبر مستودعه وطلب إضافة ملف `LICENSE` يحدد صاحب الحقوق والسنة.
2. إلى حين ذلك: الإبقاء على ذكر المؤلف الأصلي في `README` وفي التطبيق، وعدم حذف أي إشعار موجود.
3. عند التوزيع: إضافة ملف `LICENSE` يجمع إشعار المؤلف الأصلي وإشعار تعديلاتك، وتغيير معرّف التطبيق، وعدم إعادة استخدام `screenshot.png`.

هذه قراءة تقنية للملفات وليست رأياً قانونياً.

## البيئة ونتيجة البناء

ما جهّزته داخل الحاوية:

1. `Flutter 3.27.0` وهي النسخة الأصلية حسب `.metadata`، لقياس حالة الكود كما هو.
2. `Flutter 3.47.8` وهي آخر نسخة مستقرة حالياً، للعمل عليها.
3. `JDK 21` كان مثبتاً مسبقاً.
4. لم أستطع تثبيت `Android SDK` لأن سياسة الشبكة في البيئة تمنع الوصول إلى `dl.google.com`، وهو أيضاً المصدر الفعلي لملحقات `Android Gradle Plugin` عبر `maven.google.com`.

نتيجة النسخة الأصلية على `Flutter 3.27.0`:

```text
flutter analyze   -> 25 issues found (كلها info: أسماء متغيرات و withOpacity المهجورة)
flutter test      -> Some tests failed (اختبار العدّاد الافتراضي لا يجد الرقم 0)
flutter build apk -> No Android SDK found
```

بعد التعديلات على `Flutter 3.47.8`:

```text
flutter pub get --enforce-lockfile  -> نجح
flutter analyze --no-fatal-infos    -> 25 issues found (نفس الملاحظات الأسلوبية، بلا أخطاء أو تحذيرات)
flutter test                        -> All tests passed (8 اختبارات)
flutter assemble ... android_aot_bundle_release_android-arm64
                                    -> نجح: app.so بصيغة ELF 64-bit ARM aarch64
```

الأمر الأخير يترجم كود `Dart` إلى الملف الذي يدخل في `APK` لمعالجات `ARM64`، وهو دليل على أن الكود يُبنى، لكنه لا يختبر جزء `Gradle`.

### نتيجة البناء على GitHub Actions

أضفت سير العمل `.github/workflows/android-build.yml`، ويعمل عند كل دفع إلى `main` أو إلى فروع `claude/` وعند طلبات الدمج. يثبّت `Flutter 3.47.8` بعد التحقق من بصمة الملف، ثم ينفذ التحليل والاختبارات وبناء `APK`، ويرفع الملف الناتج كـ `artifact` لمدة أسبوعين.

نتيجة أول تشغيل على الالتزام `e9c90a6` (الرابط: https://github.com/ahmadalkazem/shade-master/actions/runs/40601483644):

```text
flutter pub get --enforce-lockfile -> نجح
flutter analyze --no-fatal-infos   -> 25 issues found (نفس الملاحظات الأسلوبية)
flutter test                       -> 8 tests passed
flutter build apk --release        -> ✓ Built build/app/outputs/flutter-apk/app-release.apk (47.0MB)
```

تفاصيل الملف كما طبعها `aapt2` في التشغيل الثاني (https://github.com/ahmadalkazem/shade-master/actions/runs/40602144611):

```text
package: name='app.apexo.shadesmaster' versionCode='1' versionName='1.0.0' compileSdkVersion='36'
minSdkVersion:'24'
targetSdkVersion:'36'
application-label:'shades'
native-code: 'arm64-v8a' 'armeabi-v7a' 'x86_64'
```

- استغرق `Gradle` ثلاث إلى أربع دقائق، منها تنزيل `NDK 28.2` تلقائياً.
- لم يطبع `Flutter` أي تحذير عن إصدارات `AGP` أو `Gradle` أو `Kotlin`.
- الملف الناتج موقّع بمفتاح التصحيح الخاص بجهاز البناء، مثل إعداد المشروع الأصلي، فهو للتجربة فقط.
- حجمه 47 ميغابايت مقابل 20 للنسخة القديمة. السبب المرجح أن `minSdk` صار 24، فيخزّن `AGP` المكتبات الأصلية بلا ضغط داخل الملف. الحجم بعد الضغط داخل `artifact` هو 22 ميغابايت تقريباً.
- ملف `APK` متاح للتنزيل من صفحة التشغيل في قسم `Artifacts` لمدة أسبوعين، ولم أستطع تنزيله داخل الحاوية لأن سياسة الشبكة تحجب مخزن ملفات `GitHub`.

## التغييرات التي أجريتها

| الملف | التغيير | السبب |
| --- | --- | --- |
| `android/settings.gradle` | `AGP` من 8.1.0 إلى 9.1.0، و `Kotlin` من 1.8.22 إلى 2.4.0 | `Flutter 3.47` يرفض `AGP` أقدم من 8.11.1 و `Kotlin` أقدم من 2.2.20 |
| `android/gradle/wrapper/gradle-wrapper.properties` | `Gradle` من 8.3 إلى 9.3.1 | `Flutter 3.47` يرفض أقدم من 8.14، و `Gradle 8.3` لا يعمل على `JDK 21` |
| `android/app/build.gradle` | `Java` و `Kotlin` من الإصدار 1.8 إلى 17، و `kotlinOptions` إلى `kotlin.compilerOptions`، وإزالة تطبيق إضافة `kotlin-android` يدوياً | `kotlinOptions` مهجورة في `Kotlin 2` وقالب `Flutter` الحالي يستخدم `compilerOptions`، و `Flutter` يطبّق إضافة `Kotlin` بنفسه |
| `android/build.gradle` | `buildDir` إلى `layout.buildDirectory` | الواجهة القديمة مهجورة منذ `Gradle 8.3` |
| `android/gradle.properties` | إضافة `android.newDsl=false` و `android.builtInKotlin=false` وحذف `android.enableJetifier` | مطابقة قالب `Flutter 3.47.8`، و `Jetifier` لا حاجة له لأن كل الاعتماديات `AndroidX` |
| `pubspec.lock` | ترقية `image_picker` ضمن القيد الموجود `^1.1.2` | النسخة المقفلة من `image_picker_android` أقدم من دعم `Gradle 9` و `AGP 9` |
| `analysis_options.yaml` | استثناء مجلدات المنصات من التحليل (أضافه `Flutter` تلقائياً)، وعرض سطر 120 للمنسّق | الكود الحالي مكتوب بعرض 120 |
| `test/widget_test.dart` | استبدال اختبار العدّاد باختبار لشاشة الترحيب | الاختبار القديم لا علاقة له بالتطبيق وكان يفشل دائماً |
| `test/comparison_test.dart` | اختبارات `deltaE` على بيانات Sharma المرجعية و `deltaGroups` | تثبيت صحة جزء المقارنة قبل أي تعديل |
| `test/int_to_letter_test.dart` | اختبارات تسمية الألوان A و B و AA | نفس السبب |
| `.github/workflows/android-build.yml` | سير عمل البناء، مع خطوة تطبع اسم الحزمة وإصدارات `SDK` والتوقيع | بناء `APK` فعلي خارج الحاوية |
| `README.md` و `docs/` | قسم قصير للتطوير وثلاثة ملفات توثيق بالعربية | توثيق الفحص والخطة |

لم يتغير أي ملف في `lib`. لم تتغير قيم `compileSdk` و `minSdk` و `targetSdk` في الملفات، لكنها تُقرأ من `Flutter`، فصارت فعلياً 36 و 24 و 36 بدلاً من 35 و 21 و 35. يعني ذلك أن الحد الأدنى صار أندرويد 7.0.

## المشاكل المتبقية

الحالة بعد تنفيذ الخطة:

1. **دقة التحليل**: أُصلحت الأخطاء الخمسة، والتفاصيل في `docs/how-it-works.md`.
2. **الترخيص**:
   - أُضيف ملف `LICENSE` بنص `MIT`. سطر حقوق المؤلف الأصلي فيه مأخوذ من `index.html` الأصلي ("Dr. Ali A. Saleem")، ويستحسن تأكيده مع المؤلف عبر مستودعه قبل النشر العام.
   - أُزيلت عبارة "All rights reserved" باسم `Apexo` من ملفات `Windows` و `macOS`.
   - حُذفت الصورة السريرية `screenshot.png` من الفرع. ما زالت موجودة في تاريخ `git` للالتزامات القديمة.
   - استُبدلت الأيقونة مجهولة المصدر بأيقونة أصلية مرسومة في `assets/icon/app_icon.svg`.
   - المعرّف صار `com.alkazem.dentalcase`، والاسم Dental Case وبالعربية بطاقة الحالة.
3. **بناء `APK` داخل الحاوية**: ما زال يحتاج السماح بالنطاق `dl.google.com`. البناء يتم على `GitHub Actions` وينجح.
4. **توقيع الإصدار**: صار يُقرأ من `android/key.properties` أو من أسرار المستودع، والخطوات في `docs/release.md`. بدون المفتاح يبقى التوقيع بمفتاح التصحيح.
5. **ملاحظات التحليل**: صفر. أسماء الرموز الرياضية في `comparison.dart` مستثناة صراحة، و `withOpacity` استُبدلت بـ `withValues`، و `CI` يفشل الآن عند أي ملاحظة أو تنسيق غير مطابق.
6. **منصات غير مختبرة**: `iOS` و `macOS` و `Linux` و `Windows` حُدّثت معرّفاتها فقط ولم تُبنَ.
7. **ملف `APK` القديم**: حُذف `release/app-release.apk`. ملفات البناء الجديدة في قسم `Artifacts` من كل تشغيل على `GitHub Actions`.
