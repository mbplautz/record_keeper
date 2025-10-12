// lib/providers/track_provider.dart

import 'package:flutter/foundation.dart';
import '../models/track.dart';
import '../repositories/track_repository.dart';

class TrackProvider extends ChangeNotifier {
  final TrackRepository _repo;
  List<Track> _tracks = [];
  String? _albumId; // which album we're currently holding tracks for

  List<Track> get tracks => _tracks;
  String? get albumId => _albumId;

  TrackProvider(this._repo);

  /// Load tracks for a specific album (Album Details view should call this)
  Future<void> loadTracksForAlbum(String albumId) async {
    _albumId = albumId;
    _tracks = await _repo.getTracksByAlbumId(albumId);
    notifyListeners();
  }

  /// Add track (Track.albumId must be set)
  Future<void> addTrack(Track track) async {
    await _repo.insertTrack(track);
    // reload the current album's tracks (use track.albumId to be safe)
    await loadTracksForAlbum(track.albumId);
  }

  /// Update track
  Future<void> updateTrack(Track track) async {
    await _repo.updateTrack(track);
    await loadTracksForAlbum(track.albumId);
  }

  /// Delete track by integer id (matches model/schema)
  Future<void> deleteTrack(int trackId) async {
    await _repo.deleteTrack(trackId);
    if (_albumId != null) {
      await loadTracksForAlbum(_albumId!);
    }
  }

  /// Delete all tracks for a given album
  Future<void> deleteTracksByAlbumId(String albumId) async {
    await _repo.deleteTracksByAlbumId(albumId);
    if (_albumId == albumId) {
      _tracks = [];
      notifyListeners();
    }
  }
}
