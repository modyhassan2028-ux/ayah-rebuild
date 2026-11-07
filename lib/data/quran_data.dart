import 'dart:convert';
import 'package:flutter/services.dart';

class Surah {
  final int n;
  final String name;
  final int page;
  const Surah(this.n, this.name, this.page);
}

class VerseRef {
  final int surah;
  final int ayah;
  final int page;
  final int id;
  const VerseRef(this.surah, this.ayah, this.page, this.id);
}

/// بيانات فهرس المصحف مستخرجة من assets/databases/quran-text.db الأصلي
class QuranData {
  static List<Surah> surahs = const [];
  static List<VerseRef> verses = const [];
  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString('assets/data/surahs.json');
    final m = json.decode(raw) as Map<String, dynamic>;
    surahs = (m['surahs'] as List)
        .map((e) => Surah(e['n'] as int, e['name'] as String, e['page'] as int))
        .toList();
    verses = (m['verses'] as List)
        .map((e) => VerseRef(e['s'] as int, e['a'] as int, e['p'] as int, e['id'] as int))
        .toList();
    _loaded = true;
  }

  static const totalPages = 604;

  /// السورة التي تبدأ في هذه الصفحة أو قبلها
  static Surah surahOfPage(int page) {
    var cur = surahs.first;
    for (final s in surahs) {
      if (s.page <= page) {
        cur = s;
      } else {
        break;
      }
    }
    return cur;
  }

  static List<Surah> search(String q) {
    q = q.trim();
    if (q.isEmpty) return surahs;
    return surahs.where((s) => s.name.contains(q) || '${s.n}'.contains(q)).toList();
  }
}
