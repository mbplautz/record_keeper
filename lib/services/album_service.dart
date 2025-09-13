// lib/services/album_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';

import '../models/album.dart';
import '../models/tag.dart';
import '../models/track.dart';
import '../repositories/album_repository.dart';
import '../repositories/tag_repository.dart';
import '../utils/image_utils.dart';

class AlbumService {
  final AlbumRepository albumRepository;
  final TagRepository tagRepository;

  AlbumService({
    required this.albumRepository,
    required this.tagRepository,
  });

  /// Add a new album, handling cover image + thumbnail if provided.
  Future<void> addAlbum(Album album, {File? coverImage}) async {
    String? coverPath;
    String? thumbPath;

    if (coverImage != null) {
      // Save the full-size cover
      coverPath = await ImageUtils.saveImage(coverImage,
          filename: "${album.id}_cover.jpg");

      // Save the thumbnail
      thumbPath = await ImageUtils.generateThumbnail(
        coverImage,
        filename: "${album.id}_thumb.jpg",
      );
    }

    final updatedAlbum = Album(
      id: album.id,
      title: album.title,
      artist: album.artist,
      sortArtist: album.sortArtist,
      releaseYear: album.releaseYear,
      releaseMonth: album.releaseMonth,
      releaseDay: album.releaseDay,
      coverImagePath: coverPath,
      coverThumbnailPath: thumbPath,
      tagSummary: album.tagSummary,
      tracks: album.tracks,
      tags: album.tags,
    );

    await albumRepository.insertAlbum(updatedAlbum);
  }

  /// Update album, replacing cover image if provided.
  Future<void> updateAlbum(Album album, {File? newCoverImage}) async {
    String? coverPath = album.coverImagePath;
    String? thumbPath = album.coverThumbnailPath;

    if (newCoverImage != null) {
      // Delete old files
      if (coverPath != null) await ImageUtils.deleteImage(coverPath);
      if (thumbPath != null) await ImageUtils.deleteImage(thumbPath);

      // Save new ones
      coverPath = await ImageUtils.saveImage(newCoverImage,
          filename: "${album.id}_cover.jpg");
      thumbPath = await ImageUtils.generateThumbnail(
        newCoverImage,
        filename: "${album.id}_thumb.jpg",
      );
    }

    final updatedAlbum = album.copyWith(
      coverImagePath: coverPath,
      coverThumbnailPath: thumbPath,
    );

    await albumRepository.updateAlbum(updatedAlbum);
  }

  /// Delete album and all related files + tags
  Future<void> deleteAlbum(String albumId) async {
    final album = await albumRepository.getAlbumById(albumId);
    if (album != null) {
      if (album.coverImagePath != null) {
        await ImageUtils.deleteImage(album.coverImagePath!);
      }
      if (album.coverThumbnailPath != null) {
        await ImageUtils.deleteImage(album.coverThumbnailPath!);
      }
    }

    await tagRepository.deleteTagsByAlbumId(albumId);
    await albumRepository.deleteAlbum(albumId);
  }

  /// Add a tag to an album and update the tagSummary.
  Future<void> addTag(Tag tag) async {
    await tagRepository.insertTag(tag);

    final tags = await tagRepository.getTagsByAlbumId(tag.albumId);
    final summary = _generateTagSummary(tags);

    final album = await albumRepository.getAlbumById(tag.albumId);
    if (album != null) {
      final updated = album.copyWith(tagSummary: summary);
      await albumRepository.updateAlbum(updated);
    }
  }

  /// Remove a tag and update the tagSummary.
  Future<void> removeTag(Tag tag) async {
    if (tag.id != null) {
      await tagRepository.deleteTag(tag.id!);
    }

    final tags = await tagRepository.getTagsByAlbumId(tag.albumId);
    final summary = _generateTagSummary(tags);

    final album = await albumRepository.getAlbumById(tag.albumId);
    if (album != null) {
      final updated = album.copyWith(tagSummary: summary);
      await albumRepository.updateAlbum(updated);
    }
  }

  /// Private: build a semicolon-separated tag summary, max 255 chars.
  String _generateTagSummary(List<Tag> tags) {
    final joined = tags.map((t) => _escapeTag(t.tag)).join('; ');
    return joined.length > 255 ? joined.substring(0, 255) : joined;
  }

  /// Escape semicolons (so they don’t conflict with the separator).
  String _escapeTag(String tag) {
    return tag.replaceAll(';', r'\;');
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
