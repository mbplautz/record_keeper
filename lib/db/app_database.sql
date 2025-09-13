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
);

CREATE INDEX idx_albums_title ON albums(title COLLATE NOCASE);
CREATE INDEX idx_albums_artist ON albums(artist COLLATE NOCASE);
CREATE INDEX idx_albums_sort_artist ON albums(sort_artist COLLATE NOCASE);
CREATE INDEX idx_albums_release_date ON albums(release_year, release_month, release_day);

CREATE TABLE tracks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  album_id TEXT NOT NULL,
  title TEXT NOT NULL,
  FOREIGN KEY(album_id) REFERENCES albums(id) ON DELETE CASCADE
);

CREATE INDEX idx_tracks_album_id ON tracks(album_id);
CREATE INDEX idx_tracks_title ON tracks(title COLLATE NOCASE);

CREATE TABLE tags (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  album_id TEXT NOT NULL,
  tag TEXT NOT NULL,
  FOREIGN KEY(album_id) REFERENCES albums(id) ON DELETE CASCADE
);

CREATE INDEX idx_tags_album_id ON tags(album_id);
CREATE INDEX idx_tags_tag ON tags(tag COLLATE NOCASE);
