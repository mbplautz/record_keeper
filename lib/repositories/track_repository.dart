// lib/repositories/track_repository.dart

import '../models/track.dart';

abstract class TrackRepository {
  /// CRUD Operations
  Future<void> insertTrack(Track track);
  Future<void> updateTrack(Track track);
  Future<void> deleteTrack(int trackId);
  Future<Track?> getTrackById(int trackId);
  Future<List<Track>> getAllTracks();

  /// List tracks by album
  Future<List<Track>> getTracksByAlbumId(String albumId);
}
