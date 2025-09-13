// lib/providers/album_provider.dart

import 'package:flutter/foundation.dart';
import '../models/album.dart';
import '../repositories/album_repository.dart';

class AlbumProvider extends ChangeNotifier {
  final AlbumRepository _repo;
  List<Album> _albums = [];

  List<Album> get albums => _albums;

  AlbumProvider(this._repo);

  /// Load all albums (used by Main Screen)
  Future<void> loadAlbums() async {
    _albums = await _repo.getAllAlbums();
    notifyListeners();
  }

  /// Add a new album
  Future<void> addAlbum(Album album) async {
    await _repo.insertAlbum(album);
    await loadAlbums();
  }

  /// Update an existing album
  Future<void> updateAlbum(Album album) async {
    await _repo.updateAlbum(album);
    await loadAlbums();
  }

  /// Delete an album by its UUID string
  Future<void> deleteAlbum(String albumId) async {
    await _repo.deleteAlbum(albumId);
    await loadAlbums();
  }

  /// Get a single album (useful for Album Details screen to load the album and then tracks/tags)
  Future<Album?> getAlbumById(String albumId) async {
    return await _repo.getAlbumById(albumId);
  }

  // Get the entire list of albums
  Future<List<Album>> getAllAlbums() async {
    return await _repo.getAllAlbums();
  }
}
