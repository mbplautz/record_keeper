// lib/models/album.dart

import 'dart:convert';
import 'track.dart';
import 'tag.dart';

class Album {
  final String id;
  String title;
  String artist;
  String? sortArtist;
  int? releaseYear;
  int? releaseMonth;
  int? releaseDay;
  String? wikiUrl;
  String? coverImagePath;
  String? coverThumbnailPath;
  String? tagSummary;

  List<Track> tracks;
  List<Tag> tags;

  // Calculated field not persisted in the database
  String? headerKey;

  Album({
    required this.id,
    required this.title,
    required this.artist,
    this.sortArtist,
    this.releaseYear,
    this.releaseMonth,
    this.releaseDay,
    this.wikiUrl,
    this.coverImagePath,
    this.coverThumbnailPath,
    this.tagSummary,
    this.tracks = const [],
    this.tags = const [],
  });

  /// Convert Album to a map for SQLite insert/update
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'sort_artist': sortArtist,
      'release_year': releaseYear,
      'release_month': releaseMonth,
      'release_day': releaseDay,
      'wiki_url': wikiUrl,
      'cover_image_path': coverImagePath,
      'cover_thumbnail_path': coverThumbnailPath,
      'tag_summary': tagSummary
    };
  }

  /// Construct Album from SQLite row
  factory Album.fromMap(Map<String, dynamic> map,
      {List<Track> tracks = const [], List<Tag> tags = const []}) {
    return Album(
      id: map['id'] as String,
      title: map['title'] as String,
      artist: map['artist'] as String,
      sortArtist: map['sort_artist'] as String?,
      releaseYear: map['release_year'] as int?,
      releaseMonth: map['release_month'] as int?,
      releaseDay: map['release_day'] as int?,
      wikiUrl: map['wiki_url'] as String?,
      coverImagePath: map['cover_image_path'] as String?,
      coverThumbnailPath: map['cover_thumbnail_path'] as String?,
      tagSummary: map['tag_summary'] as String,
      tracks: tracks,
      tags: tags,
    );
  }

  /// Serialize Album (with tracks & tags) to JSON
  String toJson() => jsonEncode({
        'id': id,
        'title': title,
        'artist': artist,
        'sortArtist': sortArtist,
        'releaseYear': releaseYear,
        'releaseMonth': releaseMonth,
        'releaseDay': releaseDay,
        'wikiUrl': wikiUrl,
        'coverImagePath': coverImagePath,
        'coverThumbnailPath': coverThumbnailPath,
        'tagSummary': tagSummary,
        'tracks': tracks.map((t) => t.toMap()).toList(),
        'tags': tags.map((t) => t.toMap()).toList(),
      });

  /// Deserialize Album (with tracks & tags) from JSON
  factory Album.fromJson(String source) {
    final data = jsonDecode(source);
    return Album(
      id: data['id'],
      title: data['title'],
      artist: data['artist'],
      sortArtist: data['sortArtist'],
      releaseYear: data['releaseYear'],
      releaseMonth: data['releaseMonth'],
      releaseDay: data['releaseDay'],
      wikiUrl: data['wikiUrl'],
      coverImagePath: data['coverImagePath'],
      coverThumbnailPath: data['coverThumbnailPath'],
      tagSummary: data['tagSummary'],
      tracks: (data['tracks'] as List<dynamic>)
          .map((t) => Track.fromMap(Map<String, dynamic>.from(t)))
          .toList(),
      tags: (data['tags'] as List<dynamic>)
          .map((t) => Tag.fromMap(Map<String, dynamic>.from(t)))
          .toList(),
    );
  }

  /// Validation helpers
  void validate() {
    if (title.trim().isEmpty) {
      throw ArgumentError('Album title cannot be empty.');
    }
    if (artist.trim().isEmpty) {
      throw ArgumentError('Artist cannot be empty.');
    }
    if (releaseMonth != null && (releaseMonth! < 1 || releaseMonth! > 12)) {
      throw ArgumentError('Release month must be between 1 and 12.');
    }
    if (releaseDay != null && (releaseDay! < 1 || releaseDay! > 31)) {
      throw ArgumentError('Release day must be between 1 and 31.');
    }
    if (releaseDay != null && releaseMonth == null) {
      throw ArgumentError('Cannot specify release day without release month.');
    }
    if (releaseMonth != null && releaseYear == null) {
      throw ArgumentError('Cannot specify release month without release year.');
    }
  }
}
