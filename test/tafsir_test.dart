import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() => sqfliteFfiInit());
  test('تفسير الصفحة 1 موجود في قاعدة الأصل', () async {
    final db = await databaseFactoryFfi.openDatabase(Directory.current.path + '/assets/data/ar-mokhtasar.db', options: OpenDatabaseOptions(readOnly: true));
    final rows = await db.query('bookEntry',
        columns: ['text'],
        where: 'kind = ? AND pageNumber = ? AND length(text) > 20',
        whereArgs: ['body', 1]);
    expect(rows.length, greaterThan(0));
    final txt = rows.map((r) => r['text'].toString()).join(' ');
    expect(txt.length, greaterThan(200));
    final pages = await db.rawQuery("SELECT COUNT(DISTINCT pageNumber) c FROM bookEntry WHERE kind='body'");
    expect(pages.first['c'], greaterThanOrEqualTo(604));
    stdout.writeln('صفحات التفسير: ${pages.first['c']} · صفوف الصفحة 1: ${rows.length}');
    await db.close();
  });
}
