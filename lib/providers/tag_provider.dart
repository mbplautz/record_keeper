// lib/providers/tag_provider.dart

import 'package:flutter/foundation.dart';
import '../models/tag.dart';
import '../repositories/tag_repository.dart';

class TagProvider extends ChangeNotifier {
  final TagRepository _repo;
  List<Tag> _tags = [];
  String? _albumId;

  List<Tag> get tags => _tags;
  String? get albumId => _albumId;

  TagProvider(this._repo);

  /// Load tags for a specific album (Album Details view should call this)
  Future<void> loadTagsForAlbum(String albumId) async {
    _albumId = albumId;
    _tags = await _repo.getTagsByAlbumId(albumId);
    notifyListeners();
  }

  /// Add a tag (Tag.albumId must be set)
  Future<void> addTag(Tag tag) async {
    await _repo.insertTag(tag);
    await loadTagsForAlbum(tag.albumId);
  }

  /// Delete a tag by its integer id
  Future<void> deleteTag(int tagId) async {
    await _repo.deleteTag(tagId);
    if (_albumId != null) {
      await loadTagsForAlbum(_albumId!);
    }
  }
}
