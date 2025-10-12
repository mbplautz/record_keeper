// lib/repositories/album_repository_impl.dart

import 'package:sqflite/sqflite.dart';
import '../../db/app_database.dart';
import '../../models/album.dart';
import '../album_repository.dart';

class AlbumRepositoryImpl implements AlbumRepository {
  final AppDatabase _db;

  AlbumRepositoryImpl(this._db);

  @override
  Future<void> insertAlbum(Album album) async {
    try {
      final db = await _db.database;
      await db.insert(
        'albums',
        album.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e) {
      throw Exception('Failed to insert album: $e');
    }
  }

  @override
  Future<void> updateAlbum(Album album) async {
    try {
      final db = await _db.database;
      await db.update(
        'albums',
        album.toMap(),
        where: 'id = ?',
        whereArgs: [album.id],
      );
    } catch (e) {
      throw Exception('Failed to update album: $e');
    }
  }

  @override
  Future<void> deleteAlbum(String albumId) async {
    try {
      final db = await _db.database;
      await db.delete(
        'albums',
        where: 'id = ?',
        whereArgs: [albumId],
      );
    } catch (e) {
      throw Exception('Failed to delete album: $e');
    }
  }

  @override
  Future<void> deleteAllAlbums() async {
    try {
      final db = await _db.database;
      await db.delete('albums');
    } catch (e) {
      throw Exception('Failed to delete all albums: $e');
    }
  }

  @override
  Future<Album?> getAlbumById(String albumId) async {
    final db = await _db.database;
    final maps = await db.query(
      'albums',
      where: 'id = ?',
      whereArgs: [albumId],
    );
    if (maps.isNotEmpty) {
      return Album.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<List<Album>> getAllAlbums() async {
    final db = await _db.database;
    final maps = await db.query('albums');
    return maps.map((m) => Album.fromMap(m, tracks: [], tags: [])).toList();
  }

  @override
  Future<List<String>> getDistinctArtistList() async {
    final db = await _db.database;
    final result = await db.query('albums', 
      distinct: true,
      columns: ['artist']
    );
    return result.map((m) => m['artist'] as String).toList();
  }

  @override
  Future<List<String>> getDistinctSortArtistList() async {
    final db = await _db.database;
    final result = await db.query('albums', 
      distinct: true,
      columns: ['sort_artist'],
      where: 'sort_artist IS NOT NULL'
    );
    return result.map((m) => m['sort_artist'] as String).toList();
  }


  @override
  Future<List<Album>> searchAlbums({
    List<String>? terms,
    List<String>? plusTerms,
    List<String>? minusTerms,
    bool caseInsensitive = true,
  }) async {
    final db = await _db.database;
    final List<String> whereClauses = [];
    final List<dynamic> args = [];

    if (terms != null && terms.isNotEmpty) {
      final clause = terms
          .map((t) => '(title LIKE ? OR artist LIKE ? OR sortArtist LIKE ?)')
          .join(' OR ');
      whereClauses.add('($clause)');
      for (var t in terms) {
        final term = caseInsensitive ? '%${t.toLowerCase()}%' : '%$t%';
        args.addAll([term, term, term]);
      }
    }

    if (plusTerms != null && plusTerms.isNotEmpty) {
      for (var t in plusTerms) {
        final term = caseInsensitive ? '%${t.toLowerCase()}%' : '%$t%';
        whereClauses.add(
            '(title LIKE ? OR artist LIKE ? OR sortArtist LIKE ?)');
        args.addAll([term, term, term]);
      }
    }

    if (minusTerms != null && minusTerms.isNotEmpty) {
      for (var t in minusTerms) {
        final term = caseInsensitive ? '%${t.toLowerCase()}%' : '%$t%';
        whereClauses.add(
            '(title NOT LIKE ? AND artist NOT LIKE ? AND sortArtist NOT LIKE ?)');
        args.addAll([term, term, term]);
      }
    }

    final maps = await db.query(
      'albums',
      where: whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null,
      whereArgs: args.isNotEmpty ? args : null,
    );

    return maps.map((m) => Album.fromMap(m)).toList();
  }

  @override
  Future<List<Album>> getAlbumsSorted({
    required String sortBy,
    bool ascending = true,
  }) async {
    String orderBy = '';
    switch (sortBy) {
      case 'title':
        orderBy = 'title COLLATE NOCASE ${ascending ? 'ASC' : 'DESC'}';
        break;
      case 'artist':
        orderBy = 'artist COLLATE NOCASE ${ascending ? 'ASC' : 'DESC'}';
        break;
      case 'sortArtist':
        orderBy =
            '(CASE WHEN sortArtist IS NOT NULL THEN sortArtist ELSE artist END) COLLATE NOCASE ${ascending ? 'ASC' : 'DESC'}';
        break;
      case 'releaseDate':
        orderBy =
            '(CASE WHEN releaseDate IS NOT NULL THEN releaseDate ELSE "" END) ${ascending ? 'ASC' : 'DESC'}';
        break;
      default:
        orderBy = 'title COLLATE NOCASE ASC';
    }

    final db = await _db.database;
    final maps = await db.query('albums', orderBy: orderBy);
    return maps.map((m) => Album.fromMap(m)).toList();
  }
}
