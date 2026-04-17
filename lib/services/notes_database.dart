import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/notes_model.dart';

class NotesDatabase {
  NotesDatabase._();

  static final NotesDatabase instance = NotesDatabase._();

  static const _dbName = 'keep_note.db';
  static const _dbVersion = 2;

  static const tableNotes = 'notes';

  Database? _db;

  Future<Database> get database async {
    final existing = _db;
    if (existing != null) return existing;
    _db = await _open();
    return _db!;
  }

  Future<void> init() async {
    await database;
  }

  Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE $tableNotes(
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  color INTEGER NOT NULL,
  updatedAt INTEGER NOT NULL,
  bold INTEGER NOT NULL,
  italic INTEGER NOT NULL,
  underline INTEGER NOT NULL,
  heading TEXT NOT NULL,
  fontFamily TEXT NOT NULL,
  textColor INTEGER NOT NULL,
  images TEXT NOT NULL,
  isPinned INTEGER NOT NULL,
  isDeleted INTEGER NOT NULL,
  isArchived INTEGER NOT NULL,
  deletedAt INTEGER,
  reminderAt INTEGER
)
''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE $tableNotes ADD COLUMN updatedAt INTEGER NOT NULL DEFAULT 0',
          );
        }
      },
    );
  }

  Future<List<NotesModel>> getAllNotes() async {
    final db = await database;
    final rows = await db.query(tableNotes);
    return rows.map((e) => NotesModel.fromMap(e)).toList();
  }

  Future<void> upsert(NotesModel note) async {
    final db = await database;
    await db.insert(
      tableNotes,
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> upsertMany(List<NotesModel> notes) async {
    final db = await database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final note in notes) {
        batch.insert(
          tableNotes,
          note.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Future<void> deleteByIds(Set<String> ids) async {
    if (ids.isEmpty) return;
    final db = await database;
    final placeholders = List.filled(ids.length, '?').join(',');
    await db.delete(
      tableNotes,
      where: 'id IN ($placeholders)',
      whereArgs: ids.toList(),
    );
  }
}

