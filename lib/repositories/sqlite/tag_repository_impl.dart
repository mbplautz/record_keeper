// lib/repositories/tag_repository_impl.dart

import 'package:sqflite/sqflite.dart';
import '../../db/app_database.dart';
import '../../models/tag.dart';
import '../tag_repository.dart';

class TagRepositoryImpl implements TagRepository {
  final AppDatabase _db;

  TagRepositoryImpl(this._db);

  @override
  Future<void> insertTag(Tag tag) async {
    try {
      final db = await _db.database;
      await db.insert(
        'tags',
        tag.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e) {
      throw Exception('Failed to insert tag: $e');
    }
  }

  @override
  Future<void> deleteTag(int tagId) async {
    try {
      final db = await _db.database;
      await db.delete(
        'tags',
        where: 'id = ?',
        whereArgs: [tagId],
      );
    } catch (e) {
      throw Exception('Failed to delete tag: $e');
    }
  }

  @override
  Future<List<String>> getDistinctTagList() async {
    final db = await _db.database;
    final result = await db.query('tags', 
      distinct: true,
      columns: ['tag']
    );
    return result.map((m) => m['tag'] as String).toList();
  }

  @override
  Future<Tag?> getTagById(int tagId) async {
    final db = await _db.database;
    final maps = await db.query(
      'tags',
      where: 'id = ?',
      whereArgs: [tagId],
    );
    if (maps.isNotEmpty) {
      return Tag.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<List<Tag>> getAllTags() async {
    final db = await _db.database;
    final maps = await db.query(
      'tags',
    );
    return maps.map((m) => Tag.fromMap(m)).toList();
  }

  @override
  Future<List<Tag>> getTagsByAlbumId(String albumId) async {
    final db = await _db.database;
    final maps = await db.query(
      'tags',
      where: 'album_id = ?',
      whereArgs: [albumId],
    );
    return maps.map((m) => Tag.fromMap(m)).toList();
  }

  @override
  Future<void> deleteTagsByAlbumId(String albumId) async {
    final db = await _db.database;
    await db.delete(
      'tags',
      where: 'album_id = ?',
      whereArgs: [albumId]
    );
  }
}
