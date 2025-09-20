// lib/repositories/tag_repository.dart

import '../models/tag.dart';

abstract class TagRepository {
  /// CRUD Operations
  Future<void> insertTag(Tag tag);
  Future<void> deleteTag(int tagId);
  Future<Tag?> getTagById(int tagId);
  Future<List<String>> getDistinctTagList();
  Future<List<Tag>> getAllTags();

  /// List tags by album
  Future<List<Tag>> getTagsByAlbumId(String albumId);

  /// Delete all tags by album
  Future<void> deleteTagsByAlbumId(String albumId);
}
