# Ayah — نسخة مبنية (com.ayah.rebuild)

نسخة مبنية من أصول وبيانات تطبيق **Ayah** (com.ayah، الإصدار 7.8.2) بعد فكّ الـAPK.

## الهوية
- اسم الحزمة: `com.ayah.rebuild` (تُثبَّت جنبًا إلى جنب مع التطبيق الأصلي).
- مفتاح توقيع مستقل: `ayah_rebuild.jks` (alias: `ayahrebuild`، صلاحية 30 سنة) — غير مرفوع للمستودع.

## الشاشات المنفَّذة
| الشاشة | المصدر |
|---|---|
| الرئيسية | متابعة القراءة + تقدّم الختمة + فهرس 114 سورة بالبحث |
| المصحف | 604 صفحة، كل صفحة 15 سطرًا بصور `assets/quran-images` الأصلية |
| التفسير | «المختصر في التفسير» من `ar-mokhtasar.db` الأصلي (لكل صفحة) |
| العلامات | صفحات محفوظة محليًا |
| الإعدادات | الوضع الداكن + إعادة ضبط التقدّم + عن التطبيق |
| الأيقونة | `ic_launcher.png` الأصلي بكل المقاسات |

## البيانات المستخدمة (كما هي من الـAPK)
- `assets/data/quran-text.db` — جدول `bookEntry`: 114 سورة، 6236 آية، أرقام الصفحات.
- `assets/data/ar-mokhtasar.db` — 15,991 صفًا (3.7MB) تفسير المختصر.
- `assets/data/surahs.json` — مُولَّد من `quran-text.db` + `values-ar/arrays.xml` (`sura_names`).
- `assets/images/pages/<1..604>/<1..15>.png` — 9,060 صورة سطر (98MB) غير مرفوعة للمستودع؛ تُستخرج بالأمر:
  `unzip ayah.apk "assets/quran-images/*" -d tmp && mv tmp/assets/quran-images assets/images/pages`
- `assets/fonts/` — `hafs_smart_08.ttf` · `quran_titles.ttf` · `quran_numbers.ttf`.

## البناء
```
flutter pub get
flutter build apk --release
```

## ما لم يُنقل بعد
- مشغّل الصوت للقراء (`audio.realm`) وقائمة القراء.
- التذكيرات وختمة بجدول أيام، والملاحظات، والمشاركة.
- تعدد اللغات (31 لغة في الأصل) — النسخة الحالية عربية.
- التفسير معروض على مستوى الصفحة كما في قاعدة الأصل، لا لكل آية منفصلة.
