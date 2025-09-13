// lib/db/migrations.dart

class Migrations {
  /// Migration SQL statements
  static const List<String> all = [
    // Album table
    '''
    CREATE TABLE albums (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      artist TEXT NOT NULL,
      sort_artist TEXT,
      release_date_year INTEGER,
      release_date_month INTEGER,
      release_date_day INTEGER,
      cover_path TEXT NOT NULL
      tag_summary TEXT NOT NULL
    );
    ''',

    // Track table
    '''
    CREATE TABLE tracks (
      id TEXT PRIMARY KEY,
      album_id TEXT NOT NULL,
      track_number INTEGER NOT NULL,
      title TEXT NOT NULL,
      FOREIGN KEY (album_id) REFERENCES albums (id) ON DELETE CASCADE
    );
    ''',

    // Tag table
    '''
    CREATE TABLE tags (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      album_id TEXT NOT NULL,
      tag TEXT NOT NULL,
      FOREIGN KEY (album_id) REFERENCES albums (id) ON DELETE CASCADE
    );
    ''',

    // Indexes for efficient search/sort
    'CREATE INDEX idx_albums_title ON albums(title COLLATE NOCASE);',
    'CREATE INDEX idx_albums_artist ON albums(artist COLLATE NOCASE);',
    'CREATE INDEX idx_albums_sort_artist ON albums(sort_artist COLLATE NOCASE);',
    'CREATE INDEX idx_albums_release_date ON albums(release_date_year, release_date_month, release_date_day);',
    'CREATE INDEX idx_tracks_album_id ON tracks(album_id);',
    'CREATE INDEX idx_tags_album_id ON tags(album_id);',
    'CREATE INDEX idx_tags_tag ON tags(tag COLLATE NOCASE);',
  ];
}

// Question: earlier you said about migrations.dart that "This file will contain the SQL statements for creating tables and indexes and can be used during database initialization in app_database.dart."
// However, the source code for app_database.dart does not reference anything in this file. What then did you mean when you said it "can be used during data abse initialization in app_database.dart"?