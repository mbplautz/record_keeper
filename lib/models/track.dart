// lib/models/track.dart

class Track {
  final int? id; // auto-incremented in DB
  final String albumId;
  String title;

  Track({
    this.id,
    required this.albumId,
    required this.title,
  });

  /// Convert Track to a map for SQLite insert/update
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'album_id': albumId,
      'title': title,
    };
  }

  /// Construct Track from SQLite row
  factory Track.fromMap(Map<String, dynamic> map) {
    return Track(
      id: map['id'] as int?,
      albumId: map['album_id'] as String,
      title: map['title'] as String,
    );
  }

  /// Validation helpers
  void validate() {
    if (title.trim().isEmpty) {
      throw ArgumentError('Track title cannot be empty.');
    }
  }
}
