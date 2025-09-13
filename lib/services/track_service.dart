// lib/services/track_service.dart

import '../models/tag.dart';
import '../models/track.dart';
import '../models/album.dart';
import '../repositories/track_repository.dart';
import '../repositories/album_repository.dart';

class TrackService {
  final TrackRepository trackRepository;
  final AlbumRepository albumRepository;

  TrackService({
    required this.trackRepository,
    required this.albumRepository,
  });

  /// Add a new track and update its album’s track list.
  Future<void> addTrack(Track track) async {
    await trackRepository.insertTrack(track);

    final album = await albumRepository.getAlbumById(track.albumId);
    if (album != null) {
      final updatedTracks = [...album.tracks, track];
      final updatedAlbum = album.copyWith(tracks: updatedTracks);
      await albumRepository.updateAlbum(updatedAlbum);
    }
  }

  /// Update an existing track.
  Future<void> updateTrack(Track track) async {
    if (track.id == null) {
      throw ArgumentError('Track must have an ID to be updated');
    }
    await trackRepository.updateTrack(track);
  }

  /// Delete a track and update its album’s track list.
  Future<void> deleteTrack(Track track) async {
    if (track.id == null) return;

    await trackRepository.deleteTrack(track.id!);

    final album = await albumRepository.getAlbumById(track.albumId);
    if (album != null) {
      final updatedTracks =
          album.tracks.where((id) => id != track.id).toList();
      final updatedAlbum = album.copyWith(tracks: updatedTracks);
      await albumRepository.updateAlbum(updatedAlbum);
    }
  }
}

extension AlbumCopyWith on Album {
  Album copyWith({
    String? title,
    String? artist,
    String? sortArtist,
    int? releaseYear,
    int? releaseMonth,
    int? releaseDay,
    String? coverImagePath,
    String? coverThumbnailPath,
    String? tagSummary,
    List<Track>? tracks,
    List<Tag>? tags,
  }) {
    return Album(
      id: id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      sortArtist: sortArtist ?? this.sortArtist,
      releaseYear: releaseYear ?? this.releaseYear,
      releaseMonth: releaseMonth ?? this.releaseMonth,
      releaseDay: releaseDay ?? this.releaseDay,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      coverThumbnailPath: coverThumbnailPath ?? this.coverThumbnailPath,
      tagSummary: tagSummary ?? this.tagSummary,
      tracks: tracks ?? this.tracks,
      tags: tags ?? this.tags,
    );
  }
}
