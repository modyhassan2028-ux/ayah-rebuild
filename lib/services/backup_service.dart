import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notes_service.dart';
import 'storage.dart';

/// نسخة احتياطية للعلامات والملاحظات (مقابل pref_backup / pref_restore في الأصل)
class BackupService {
  static const _ver = 1;

  static Future<Map<String, dynamic>> collect() async {
    final notes = await NotesService.all();
    final p = await SharedPreferences.getInstance();
    return {
      'app': 'ayah',
      'version': _ver,
      'created': DateTime.now().toIso8601String(),
      'bookmarks': Storage.bookmarks.toList()..sort(),
      'last_page': Storage.lastPage,
      'notes': notes.map((n) => {'page': n.page, 'body': n.body, 'created': n.created}).toList(),
      'prefs': {
        'dark': Storage.darkMode,
        'khatmah': p.getString('khatmah_state'),
      },
    };
  }

  /// يكتب الملف ويعيد مساره لمشاركته
  static Future<String> writeFile() async {
    final data = await collect();
    final dir = await getTemporaryDirectory();
    final f = File('${dir.path}/ayah-backup-${DateTime.now().toIso8601String().substring(0, 10)}.json');
    await f.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    return f.path;
  }


  static Future<int> restoreFromPath(String path) async {
    final f = File(path.trim());
    if (!await f.exists()) return -1;
    return restoreJson(await f.readAsString());
  }

  static Future<int> restoreJson(String raw) async {
    final m = json.decode(raw) as Map<String, dynamic>;
    final p = await SharedPreferences.getInstance();
    final bm = (m['bookmarks'] as List?)?.map((e) => '$e').toList() ?? [];
    await p.setStringList('bookmarks', bm);
    if (m['last_page'] is int) await p.setInt('last_page', m['last_page'] as int);
    final prefs = m['prefs'] as Map<String, dynamic>?;
    if (prefs != null) {
      await p.setBool('dark', prefs['dark'] == true);
      if (prefs['khatmah'] is String) await p.setString('khatmah_state', prefs['khatmah'] as String);
    }
    final notes = (m['notes'] as List?) ?? [];
    for (final n in notes) {
      final mm = n as Map<String, dynamic>;
      await NotesService.add(mm['page'] as int, mm['body'] as String);
    }
    return notes.length;
  }
}
