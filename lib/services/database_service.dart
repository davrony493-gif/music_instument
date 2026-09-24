import 'package:music_intrument/models/practice_session.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';


abstract class SessionRepository {
  Future<List<PracticeSession>> all();
  Future<PracticeSession> add(PracticeSession session);
  Future<void> remove(int id);
}


/// Which notes the user has starred. Only the ids are stored — the notes
/// themselves still come from [NotesProvider]'s hardcoded list.
abstract class FavoritesRepository {
  Future<Set<String>> favoriteIds();
  Future<void> addFavorite(String noteId);
  Future<void> removeFavorite(String noteId);
}


class DatabaseService implements SessionRepository, FavoritesRepository {
  static const String _fileName = 'music_intrument.db';
  static const String _table = 'practice_sessions';
  static const String _favoritesTable = 'note_favorites';
  static const int _version = 2;

  static const String _createSessions = '''
        CREATE TABLE $_table (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          started_at INTEGER NOT NULL,
          duration_ms INTEGER NOT NULL,
          laps TEXT NOT NULL DEFAULT ''
        )
      ''';

  static const String _createFavorites = '''
        CREATE TABLE $_favoritesTable (
          note_id TEXT PRIMARY KEY
        )
      ''';


  Future<Database>? _db;

  Future<Database> get _database => _db ??= _open();

  Future<Database> _open() async {
    final path = p.join(await getDatabasesPath(), _fileName);
    return openDatabase(
      path,
      version: _version,
      onCreate: (db, version) async {
        await db.execute(_createSessions);
        await db.execute(_createFavorites);
      },
      // Installs created at v1 already have the sessions table but not this
      // one; without the upgrade they would hit "no such table".
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) await db.execute(_createFavorites);
      },
    );
  }

  @override
  Future<List<PracticeSession>> all() async {
    final db = await _database;
    final rows = await db.query(_table, orderBy: 'started_at DESC');
    return rows.map(PracticeSession.fromMap).toList();
  }

  @override
  Future<PracticeSession> add(PracticeSession session) async {
    final db = await _database;
    final id = await db.insert(_table, session.toMap());
    return session.copyWith(id: id);
  }

  @override
  Future<void> remove(int id) async {
    final db = await _database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<Set<String>> favoriteIds() async {
    final db = await _database;
    final rows = await db.query(_favoritesTable, columns: ['note_id']);
    return rows.map((row) => row['note_id'] as String).toSet();
  }

  @override
  Future<void> addFavorite(String noteId) async {
    final db = await _database;
    await db.insert(
      _favoritesTable,
      {'note_id': noteId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> removeFavorite(String noteId) async {
    final db = await _database;
    await db.delete(_favoritesTable, where: 'note_id = ?', whereArgs: [noteId]);
  }

  Future<void> close() async {
    final db = _db;
    _db = null;
    if (db != null) await (await db).close();
  }
}
