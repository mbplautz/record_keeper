// lib/models/saved_search.dart

class SavedSearch {
  final int? id; // DB primary key (autoincrement). Nullable for new objects.
  final bool isDefault;
  final String name;
  final String query; // raw search string
  final bool searchTitle;
  final bool searchArtist;
  final bool searchSortArtist;
  final bool searchReleaseDate;
  final bool searchTracks;
  final bool searchTags;
  final int sortOption; // enum index

  const SavedSearch({
    this.id,
    required this.isDefault,
    required this.name,
    required this.query,
    required this.searchTitle,
    required this.searchArtist,
    required this.searchSortArtist,
    required this.searchReleaseDate,
    required this.searchTracks,
    required this.searchTags,
    required this.sortOption,
  });

  SavedSearch copyWith({
    int? id,
    bool? isDefault,
    String? name,
    String? query,
    bool? searchTitle,
    bool? searchArtist,
    bool? searchSortArtist,
    bool? searchReleaseDate,
    bool? searchTracks,
    bool? searchTags,
    int? sortOption,
  }) {
    return SavedSearch(
      id: id ?? this.id,
      isDefault: isDefault ?? this.isDefault,
      name: name ?? this.name,
      query: query ?? this.query,
      searchTitle: searchTitle ?? this.searchTitle,
      searchArtist: searchArtist ?? this.searchArtist,
      searchSortArtist: searchSortArtist ?? this.searchSortArtist,
      searchReleaseDate: searchReleaseDate ?? this.searchReleaseDate,
      searchTracks: searchTracks ?? this.searchTracks,
      searchTags: searchTags ?? this.searchTags,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  factory SavedSearch.fromMap(Map<String, dynamic> m) {
    return SavedSearch(
      id: m['id'] as int?,
      isDefault: (m['is_default'] as int) == 1,
      name: m['name'] as String,
      query: m['query'] as String,
      searchTitle: (m['search_title'] as int) == 1,
      searchArtist: (m['search_artist'] as int) == 1,
      searchSortArtist: (m['search_sort_artist'] as int) == 1,
      searchReleaseDate: (m['search_release_date'] as int) == 1,
      searchTracks: (m['search_tracks'] as int) == 1,
      searchTags: (m['search_tags'] as int) == 1,
      sortOption: m['sort_option'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'is_default': isDefault ? 1 : 0,
      'name': name,
      'query': query,
      'search_title': searchTitle ? 1 : 0,
      'search_artist': searchArtist ? 1 : 0,
      'search_sort_artist': searchSortArtist ? 1 : 0,
      'search_release_date': searchReleaseDate ? 1 : 0,
      'search_tracks': searchTracks ? 1 : 0,
      'search_tags': searchTags ? 1 : 0,
      'sort_option': sortOption,
    };
  }
}
