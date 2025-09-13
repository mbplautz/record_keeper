// lib/services/tag_service.dart

import '../models/tag.dart';
import '../models/album.dart';
import '../models/track.dart';
import '../repositories/tag_repository.dart';
import '../repositories/album_repository.dart';

class TagService {
  final TagRepository tagRepository;
  final AlbumRepository albumRepository;

  TagService({
    required this.tagRepository,
    required this.albumRepository,
  });

  /// Add a new tag and update the album’s tags + tagSummary.
  Future<void> addTag(Tag tag) async {
    await tagRepository.insertTag(tag);

    final album = await albumRepository.getAlbumById(tag.albumId);
    if (album != null) {
      final updatedTags = [...album.tags, tag];
      final updatedAlbum = album.copyWith(
        tags: updatedTags,
        // tagSummary should be updated by higher-level controller/service
      );
      await albumRepository.updateAlbum(updatedAlbum);
    }
  }

  /// Delete a tag and update the album’s tags + tagSummary.
  Future<void> deleteTag(Tag tag) async {
    if (tag.id == null) return;

    await tagRepository.deleteTag(tag.id!);

    final album = await albumRepository.getAlbumById(tag.albumId);
    if (album != null) {
      final updatedTags = album.tags.where((id) => id != tag.id).toList();
      final updatedAlbum = album.copyWith(
        tags: updatedTags,
        // tagSummary should be updated by higher-level controller/service
      );
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
