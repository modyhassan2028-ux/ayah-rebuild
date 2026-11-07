import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class Note {
  final int id;
  final int page;
  final String body;
  final String created;
  const Note(this.id, this.page, this.body, this.created);
}

/// ملاحظاتك على صفحات المصحف (محفوظة محليًا)
class NotesService {
  static Database? _db;

  static Future<Database> _open() async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'ayah_notes.db');
    _db = await openDatabase(path, version: 1,
        onCreate: (db, v) => db.execute(
            'CREATE TABLE notes (id INTEGER PRIMARY KEY AUTOINCREMENT, page INTEGER NOT NULL, body TEXT NOT NULL, created TEXT NOT NULL)'));
    return _db!;
  }

  static Future<void> add(int page, String body) async {
    final db = await _open();
    await db.insert('notes', {
      'page': page,
      'body': body,
      'created': DateTime.now().toIso8601String().substring(0, 10),
    });
  }

  static Future<List<Note>> all() async {
    final db = await _open();
    final rows = await db.query('notes', orderBy: 'id DESC');
    return rows.map((r) => Note(r['id'] as int, r['page'] as int, r['body'] as String, r['created'] as String)).toList();
  }

  static Future<void> remove(int id) async {
    final db = await _open();
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
