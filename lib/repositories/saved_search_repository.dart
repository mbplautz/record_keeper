// lib/repositories/saved_search_repository.dart

import '../models/saved_search.dart';

abstract class SavedSearchRepository {
  /// Returns the saved search marked as default, or null if none.
  Future<SavedSearch?> getDefaultSearch();

  /// Marks exactly the given id as default (id must exist). Will clear the flag on other rows.
  Future<void> setDefaultSearch(int id);

  /// Returns all saved searches (ordered by name).
  Future<List<SavedSearch>> getSavedSearches();

  /// Save a search. If a SavedSearch with the same name exists, it will be overwritten (update).
  /// Returns the id of the inserted/updated row.
  Future<int> saveSearch(SavedSearch search);

  /// Delete by numeric id.
  Future<void> deleteSearch(int id);

  /// Find a saved search by exact name. Returns null if not found.
  Future<SavedSearch?> findByName(String name);
}
