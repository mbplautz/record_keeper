// lib/providers/saved_search_provider.dart

import 'package:flutter/material.dart';
import '../models/saved_search.dart';
import '../repositories/saved_search_repository.dart';
import 'album_provider.dart';

class SavedSearchProvider extends ChangeNotifier {
  final SavedSearchRepository _repo;

  List<SavedSearch> _savedSearches = [];
  SavedSearch? _defaultSearch;

  bool _isLoading = false;

  SavedSearchProvider(this._repo);

  List<SavedSearch> get savedSearches => List.unmodifiable(_savedSearches);
  SavedSearch? get defaultSearch => _defaultSearch;
  bool get isLoading => _isLoading;

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    _savedSearches = await _repo.getSavedSearches();
    _defaultSearch = await _repo.getDefaultSearch();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async => loadAll();

  /// Save a search (inserts or updates by name). If search.isDefault==true, this becomes the default.
  Future<int> saveSearch(SavedSearch search) async {
    final id = await _repo.saveSearch(search);
    await loadAll();
    return id;
  }

  /// Helper: construct and save a SavedSearch from the current AlbumProvider state.
  /// This function reads the relevant bits from the AlbumProvider and stores them.
  Future<int> saveCurrentSearchFromAlbumProvider(AlbumProvider albumProvider, String name, {bool makeDefault = false}) async {
    final query = albumProvider.currentSearch;
    final fields = albumProvider.searchFields;

    final sortIndex = albumProvider.currentSort.index;

    final toSave = SavedSearch(
      id: null,
      isDefault: makeDefault,
      name: name,
      query: query,
      searchTitle: fields['title'] ?? true,
      searchArtist: fields['artist'] ?? true,
      searchSortArtist: fields['sortArtist'] ?? true,
      searchReleaseDate: fields['releaseDate'] ?? true,
      searchTracks: fields['tracks'] ?? true,
      searchTags: fields['tags'] ?? true,
      sortOption: sortIndex,
    );

    final id = await saveSearch(toSave);
    if (makeDefault) {
      await setDefaultSearch(id);
    }
    return id;
  }

  Future<void> deleteSearch(int id) async {
    await _repo.deleteSearch(id);
    await loadAll();
  }

  Future<void> setDefaultSearch(int id) async {
    await _repo.setDefaultSearch(id);
    await loadAll();
  }

  /// Convenience: get default search (fresh read)
  Future<SavedSearch?> getDefault() async {
    _defaultSearch = await _repo.getDefaultSearch();
    notifyListeners();
    return _defaultSearch;
  }

  /// Find by name
  Future<SavedSearch?> findByName(String name) => _repo.findByName(name);
}
