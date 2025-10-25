// lib/repositories/saved_search_repository_impl.dart

import 'package:sqflite/sqflite.dart';
import '../../db/app_database.dart';
import '../../models/saved_search.dart';
import '../saved_search_repository.dart';

class SavedSearchRepositoryImpl implements SavedSearchRepository {
  final AppDatabase _db;

  static const String tableName = 'saved_searches';

  SavedSearchRepositoryImpl(this._db);

  Future<Database> get _database async => (await _db.database);

  @override
  Future<SavedSearch?> getDefaultSearch() async {
    final db = await _database;
    final maps = await db.query(
      tableName,
      where: 'is_default = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return SavedSearch.fromMap(maps.first);
  }

  @override
  Future<void> setDefaultSearch(int id) async {
    final db = await _database;
    await db.transaction((txn) async {
      await txn.update(tableName, {'is_default': 0});
      await txn.update(tableName, {'is_default': 1}, where: 'id = ?', whereArgs: [id]);
    });
  }

  @override
  Future<List<SavedSearch>> getSavedSearches() async {
    final db = await _database;
    final maps = await db.query(tableName, orderBy: 'name COLLATE NOCASE ASC');
    return maps.map((m) => SavedSearch.fromMap(m)).toList();
  }

  @override
  Future<int> saveSearch(SavedSearch search) async {
    final db = await _database;

    // If a saved search with the same name exists, update it.
    final existing = await db.query(tableName, where: 'name = ?', whereArgs: [search.name], limit: 1);
    if (existing.isNotEmpty) {
      final map = search.toMap();
      final id = existing.first['id'] as int;
      // ensure id is present for update
      map['id'] = id;
      await db.update(tableName, map, where: 'id = ?', whereArgs: [id]);

      // if marking default, ensure single default
      if (search.isDefault) {
        await setDefaultSearch(id);
      }
      return id;
    } else {
      // insert
      final map = search.toMap();
      // ensure we don't include id in insert (autoinc)
      map.remove('id');
      final newId = await db.insert(tableName, map);
      if (search.isDefault) {
        await setDefaultSearch(newId);
      }
      return newId;
    }
  }

  @override
  Future<void> deleteSearch(int id) async {
    final db = await _database;
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<SavedSearch?> findByName(String name) async {
    final db = await _database;
    final maps = await db.query(tableName, where: 'name = ?', whereArgs: [name], limit: 1);
    if (maps.isEmpty) return null;
    return SavedSearch.fromMap(maps.first);
  }
}
