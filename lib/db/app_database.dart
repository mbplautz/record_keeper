// lib/db/app_database.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  static Database? _database;

  AppDatabase._internal();

  factory AppDatabase() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'record_keeper.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE albums (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        artist TEXT NOT NULL,
        sort_artist TEXT,
        release_year INTEGER,
        release_month INTEGER,
        release_day INTEGER,
        wiki_url TEXT,
        cover_image_path TEXT,
        cover_thumbnail_path TEXT,
        tag_summary TEXT
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_albums_title ON albums(title COLLATE NOCASE)');
    await db.execute(
        'CREATE INDEX idx_albums_artist ON albums(artist COLLATE NOCASE)');
    await db.execute(
        'CREATE INDEX idx_albums_sort_artist ON albums(sort_artist COLLATE NOCASE)');
    await db.execute(
        'CREATE INDEX idx_albums_release_date ON albums(release_year, release_month, release_day)');

    await db.execute('''
      CREATE TABLE tracks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        album_id TEXT NOT NULL,
        title TEXT NOT NULL,
        FOREIGN KEY(album_id) REFERENCES albums(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_tracks_album_id ON tracks(album_id)');
    await db
        .execute('CREATE INDEX idx_tracks_title ON tracks(title COLLATE NOCASE)');

    await db.execute('''
      CREATE TABLE tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        album_id TEXT NOT NULL,
        tag TEXT NOT NULL,
        FOREIGN KEY(album_id) REFERENCES albums(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_tags_album_id ON tags(album_id)');
    await db.execute('CREATE INDEX idx_tags_tag ON tags(tag COLLATE NOCASE)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration handling will go here (see migrations.dart).
    // For now, nothing to migrate since v1 is the initial schema.
  }

  /// Closes the database connection (useful for testing or app shutdown).
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
