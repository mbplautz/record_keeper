// lib/models/tag.dart

class Tag {
  final int? id; // auto-incremented in DB
  final String albumId;
  String tag;

  Tag({
    this.id,
    required this.albumId,
    required this.tag,
  });

  /// Convert Tag to a map for SQLite insert/update
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'album_id': albumId,
      'tag': tag,
    };
  }

  /// Construct Tag from SQLite row
  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['id'] as int?,
      albumId: map['album_id'] as String,
      tag: map['tag'] as String,
    );
  }

  /// Validation helpers
  void validate() {
    if (tag.trim().isEmpty) {
      throw ArgumentError('Tag cannot be empty.');
    }
  }
}
