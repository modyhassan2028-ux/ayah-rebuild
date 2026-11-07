import 'package:shared_preferences/shared_preferences.dart';

/// حفظ آخر صفحة والعلامات وتقدّم الختمة (نفس مفاهيم التطبيق الأصلي)
class Storage {
  static SharedPreferences? p;
  static Future<void> init() async => p = await SharedPreferences.getInstance();

  static int get lastPage => p?.getInt('last_page') ?? 1;
  static Future<void> setLastPage(int v) async => p?.setInt('last_page', v);

  static Set<int> get bookmarks => (p?.getStringList('bookmarks') ?? []).map(int.parse).toSet();
  static Future<void> toggleBookmark(int page) async {
    final s = bookmarks;
    s.contains(page) ? s.remove(page) : s.add(page);
    await p?.setStringList('bookmarks', s.map((e) => '$e').toList());
  }

  static bool get darkMode => p?.getBool('dark') ?? false;
  static Future<void> setDark(bool v) async => p?.setBool('dark', v);
}
