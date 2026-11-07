import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// تفسير «المختصر في التفسير» من assets/data/ar-mokhtasar.db (بيانات التطبيق الأصلية)
class TafsirService {
  static Database? _db;

  static Future<Database> _open() async {
    if (_db != null) return _db!;
    final dir = await getDatabasesPath();
    final path = p.join(dir, 'ar-mokhtasar.db');
    if (!await File(path).exists()) {
      final data = await rootBundle.load('assets/data/ar-mokhtasar.db');
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
    }
    _db = await openDatabase(path, readOnly: true);
    return _db!;
  }

  /// نص تفسير صفحة كاملة (صفوف body المرتبطة برقم الصفحة في قاعدة الأصل)
  static Future<String> forPage(int page) async {
    final db = await _open();
    final rows = await db.query(
      'bookEntry',
      columns: ['text'],
      where: 'kind = ? AND pageNumber = ? AND length(text) > 20',
      whereArgs: ['body', page],
      orderBy: 'id ASC',
    );
    return rows
        .map((r) => (r['text'] ?? '').toString().trim())
        .where((t) => t.isNotEmpty)
        .join('\n\n');
  }
}
