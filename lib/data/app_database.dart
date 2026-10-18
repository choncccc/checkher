import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Owns the single on-device SQLite database. Everything is stored locally;
/// the app never talks to a server.
class AppDatabase {
  AppDatabase._(this.db);

  final Database db;

  static const _version = 2;

  static const defaultReminders = [
    'Morning Medication',
    'Drink Water',
    'Follow Up Check Up',
    'Yoga',
    'Prepare Your Meal',
  ];

  /// Opens (creating if needed) the database. [factory] and [path] are
  /// overridable so tests can use an in-memory FFI database.
  static Future<AppDatabase> open({
    DatabaseFactory? factory,
    String? path,
  }) async {
    final f = factory ?? databaseFactory;
    final dbPath = path ?? p.join(await f.getDatabasesPath(), 'checkher.db');
    final db = await f.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: _version,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: _create,
        onUpgrade: _upgrade,
      ),
    );
    return AppDatabase._(db);
  }

  static Future<void> _create(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE COLLATE NOCASE,
        display_name TEXT NOT NULL,
        password_hash TEXT NOT NULL,
        salt TEXT NOT NULL,
        address TEXT NOT NULL,
        last_period_start TEXT,
        cycle_length INTEGER NOT NULL DEFAULT 28,
        period_length INTEGER NOT NULL DEFAULT 5,
        created_at TEXT NOT NULL
      )
    ''');
    // Single-row table remembering who is logged in on this device.
    await db.execute('''
      CREATE TABLE session (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        title TEXT NOT NULL,
        sort_order INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE reminder_checks (
        reminder_id INTEGER NOT NULL REFERENCES reminders(id) ON DELETE CASCADE,
        day TEXT NOT NULL,
        PRIMARY KEY (reminder_id, day)
      )
    ''');
    await _createAssessments(db);
  }

  static Future<void> _upgrade(Database db, int from, int to) async {
    if (from < 2) await _createAssessments(db);
  }

  /// PMOS Risk Assessment results; the latest row is the user's result.
  static Future<void> _createAssessments(DatabaseExecutor db) => db.execute('''
        CREATE TABLE assessments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
          score REAL NOT NULL,
          level TEXT NOT NULL,
          taken_at TEXT NOT NULL
        )
      ''');

  Future<void> close() => db.close();
}
