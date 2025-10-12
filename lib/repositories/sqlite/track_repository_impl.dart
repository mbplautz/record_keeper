// lib/repositories/track_repository_impl.dart

import 'package:sqflite/sqflite.dart';
import '../../db/app_database.dart';
import '../../models/track.dart';
import '../track_repository.dart';

class TrackRepositoryImpl implements TrackRepository {
  final AppDatabase _db;

  TrackRepositoryImpl(this._db);

  @override
  Future<void> insertTrack(Track track) async {
    try {
      final db = await _db.database;
      await db.insert(
        'tracks',
        track.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e) {
      throw Exception('Failed to insert track: $e');
    }
  }

  @override
  Future<void> updateTrack(Track track) async {
    try {
      final db = await _db.database;
      await db.update(
        'tracks',
        track.toMap(),
        where: 'id = ?',
        whereArgs: [track.id],
      );
    } catch (e) {
      throw Exception('Failed to update track: $e');
    }
  }

  @override
  Future<void> deleteTrack(int trackId) async {
    try {
      final db = await _db.database;
      await db.delete(
        'tracks',
        where: 'id = ?',
        whereArgs: [trackId],
      );
    } catch (e) {
      throw Exception('Failed to delete track: $e');
    }
  }

  @override
  Future<Track?> getTrackById(int trackId) async {
    final db = await _db.database;
    final maps = await db.query(
      'tracks',
      where: 'id = ?',
      whereArgs: [trackId],
    );
    if (maps.isNotEmpty) {
      return Track.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<List<Track>> getAllTracks() async {
    final db = await _db.database;
    final maps = await db.query(
      'tracks'
    );
    return maps.map((m) => Track.fromMap(m)).toList();
  }

  @override
  Future<List<Track>> getTracksByAlbumId(String albumId) async {
    final db = await _db.database;
    final maps = await db.query(
      'tracks',
      where: 'album_id = ?',
      whereArgs: [albumId],
    );
    return maps.map((m) => Track.fromMap(m)).toList();
  }

  @override
  Future<void> deleteTracksByAlbumId(String albumId) async {
    try {
      final db = await _db.database;
      await db.delete(
        'tracks',
        where: 'album_id = ?',
        whereArgs: [albumId],
      );
    } catch (e) {
      throw Exception('Failed to delete tracks by album id: $e'); 
    }
  }
}
