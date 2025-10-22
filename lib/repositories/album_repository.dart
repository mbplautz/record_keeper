// lib/repositories/album_repository.dart

import '../models/album.dart';

abstract class AlbumRepository {
  /// CRUD Operations
  Future<void> insertAlbum(Album album);
  Future<void> updateAlbum(Album album);
  Future<void> deleteAlbum(String albumId);
  Future<void> deleteAllAlbums();
  Future<Album?> getAlbumById(String albumId);
  Future<List<Album>> getAllAlbums();
  Future<List<String>> getDistinctArtistList();
  Future<List<String>> getDistinctSortArtistList();
  Future<void> addTagToList(String tag, List<String> albumIdList);
  Future<void> deleteTagFromList(String tag, List<String> albumIdList);
  Future<void> deleteAlbumList(List<String> albumIdList);

  /// Filtering & Searching
  /// Returns albums that match any of the provided terms (OR logic),
  /// minusTerms are excluded, plusTerms are required.
  Future<List<Album>> searchAlbums({
    List<String>? terms,
    List<String>? plusTerms,
    List<String>? minusTerms,
    bool caseInsensitive = true,
  });

  /// Sorting
  /// Sorts by a single field at a time. Options: title, artist, sortArtist, releaseDate
  Future<List<Album>> getAlbumsSorted({
    required String sortBy,
    bool ascending = true,
  });
}
