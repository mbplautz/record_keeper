// lib/providers/album_provider.dart

import 'package:flutter/foundation.dart';
import 'package:record_keeper/models/tag.dart';
import 'package:record_keeper/models/track.dart';
import 'package:record_keeper/repositories/tag_repository.dart';
import 'package:record_keeper/repositories/track_repository.dart';
import '../models/album.dart';
import '../repositories/album_repository.dart';

enum SortOption {
  artistThenYear,
  artistThenAlpha,
  albumAlpha,
  releaseYear,
  random,
}

class AlbumProvider extends ChangeNotifier {
  final AlbumRepository _repo;
  final TrackRepository _trackRepo;
  final TagRepository _tagRepo;
  List<Album> _allAlbums = [];
  List<Album> _filteredAlbums = [];
  SortOption _currentSort = SortOption.artistThenYear;
  String _currentSearch = '';
  Map<String, bool> _searchFields = {
    'title': true,
    'artist': true,
    'sortArtist': true,
    'releaseDate': true,
    'tracks': true,
    'tags': true,
  };

  AlbumProvider(this._repo, this._trackRepo, this._tagRepo);

  List<Album> get albums => _filteredAlbums;
  List<Album> get allAlbums => _allAlbums;
  SortOption get currentSort => _currentSort;
  String get currentSearch => _currentSearch;

  /// Load all albums (used by Main Screen)
  /// @Deprecated - use fetchAllAlbums
  Future<void> loadAlbums() async {
    _allAlbums = await _repo.getAllAlbums();
    notifyListeners();
  }

  /// Add a new album
  Future<void> addAlbum(Album album) async {
    await _repo.insertAlbum(album);
    await fetchAllAlbums();
  }

  /// Update an existing album
  Future<void> updateAlbum(Album album) async {
    await _repo.updateAlbum(album);
    await fetchAllAlbums();
  }

  /// Delete an album by its UUID string
  Future<void> deleteAlbum(String albumId) async {
    await _repo.deleteAlbum(albumId);
    await fetchAllAlbums();
  }

  /// Delete all albums (used for "Clear Collection" action)
  Future<void> deleteAllAlbums() async {
    await _repo.deleteAllAlbums();
    await fetchAllAlbums();
  }

  /// Get a single album (useful for Album Details screen to load the album and then tracks/tags)
  Future<Album?> getAlbumById(String albumId) async {
    return await _repo.getAlbumById(albumId);
  }

  // Get the entire list of albums
  Future<List<Album>> getAllAlbums() async {
    return await _repo.getAllAlbums();
  }

  Future<List<String>> getDistinctArtistList() async {
    return await _repo.getDistinctArtistList();
  }

  Future<List<String>> getDistinctSortArtistList() async {
    return await _repo.getDistinctSortArtistList();
  }

  Future<void> addTagToList(String tag) async {
    await _repo.addTagToList(tag, _filteredAlbums.map((a) => a.id).toList());
    await fetchAllAlbums();
  } 

  Future<void> deleteTagFromList(String tag) async {
    await _repo.deleteTagFromList(tag, _filteredAlbums.map((a) => a.id).toList());
    await fetchAllAlbums();
  }

  Future<void> deleteAlbumList() async {
    await _repo.deleteAlbumList(_filteredAlbums.map((a) => a.id).toList());
    await fetchAllAlbums();
  }

  Future<List<Album>> searchAlbums({
    List<String>? terms,
    List<String>? plusTerms,
    List<String>? minusTerms,
    bool caseInsensitive = true,
  }) async {
    return await _repo.searchAlbums(terms: terms, plusTerms: plusTerms, minusTerms: minusTerms, caseInsensitive: caseInsensitive);
  }

  Map<String, bool> get searchFields => _searchFields;
  SortOption get sortOption => _currentSort;

  Future<void> fetchAllAlbums() async {
    _allAlbums = await _repo.getAllAlbums();
    // Populate all of the tags and tracks in each album
    List<Track> tracks = await _trackRepo.getAllTracks();
    List<Tag> tags = await _tagRepo.getAllTags();
    Map<String, Album> albumMap = {};
    for (var a in _allAlbums) {
      albumMap[a.id] = a;
    }
    for (var t in tracks) {
      albumMap[t.albumId]?.tracks.add(t);
    }
    for (var t in tags) {
      albumMap[t.albumId]?.tags.add(t);
    }
    _applyFilters();
  }

  void setSearchFields(Map<String, bool> fields) {
    _searchFields = fields;
    _applyFilters();
  }

  void setSearchQuery(String query) {
    _currentSearch = query;
    _applyFilters();
  }

  /// Clear current search filter and restore all albums
  void clearSearch() {
    final filtered = List<Album>.from(_allAlbums);
    _currentSearch = '';
    _filteredAlbums = _sortAlbums(filtered, _currentSort);
    notifyListeners();
  }

  void setSortOption(SortOption option) {
    _currentSort = option;
    _applyFilters();
  }

  /// Recalculate filtered + sorted albums
  void _applyFilters() {
    final parsed = _parseSearchQuery(_currentSearch);
    final filtered = _filterAlbums(
      _allAlbums,
      parsed['terms']!,
      parsed['plusTerms']!,
      parsed['minusTerms']!,
    );

    _filteredAlbums = _sortAlbums(filtered, _currentSort);
    notifyListeners();
  }

  /// Parse search string into terms, plusTerms, minusTerms
  Map<String, List<String>> _parseSearchQuery(String query) {
    final terms = <String>[];
    final plusTerms = <String>[];
    final minusTerms = <String>[];

    final regex = RegExp(r'([+-]?"(?:\\.|[^"])*"|[^\s]+)');
    for (final match in regex.allMatches(query)) {
      var token = match.group(0)!;

      bool isPlus = token.startsWith('+');
      bool isMinus = token.startsWith('-');

      if (isPlus || isMinus) {
        token = token.substring(1);
      }

      // Handle quoted terms
      if (token.length > 1 && token.startsWith('"') && token.endsWith('"')) {
        token = token.substring(1, token.length - 1);
        token = token.replaceAll(r'\"', '"'); // unescape quotes
        token = token.replaceAll(r'\\', r'\'); // unescape backslashes
      }

      token = token.toLowerCase();

      if (isPlus) {
        plusTerms.add(token);
      } else if (isMinus) {
        minusTerms.add(token);
      } else {
        terms.add(token);
      }
    }

    return {
      'terms': terms,
      'plusTerms': plusTerms,
      'minusTerms': minusTerms,
    };
  }

  /// Filter albums by search terms
  List<Album> _filterAlbums(
    List<Album> albums,
    List<String> terms,
    List<String> plusTerms,
    List<String> minusTerms,
  ) {
    return albums.where((album) {
      final searchableText = _buildSearchableText(album).toLowerCase();

      // Required terms (+)
      if (plusTerms.any((t) => !searchableText.contains(t))) {
        return false;
      }

      // Excluded terms (-)
      if (minusTerms.any((t) => searchableText.contains(t))) {
        return false;
      }

      // Regular terms
      if (terms.isNotEmpty &&
          !terms.any((t) => searchableText.contains(t))) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Build a concatenated searchable string for an album
  String _buildSearchableText(Album album) {
    final buffer = StringBuffer();

    if (_searchFields['title'] == true) {
      buffer.write('${album.title} ');
    }
    if (_searchFields['artist'] == true) {
      buffer.write('${album.artist} ');
    }
    if (_searchFields['sortArtist'] == true && album.sortArtist != null) {
      buffer.write('${album.sortArtist} ');
    }
    if (_searchFields['releaseDate'] == true && album.releaseYear != null) {
      buffer.write('${_formatDateVariants(_constructReleaseDate(album))} ');
    }
    if (_searchFields['tracks'] == true && album.tracks.isNotEmpty) {
      for (var track in album.tracks) {
        buffer.write('${track.title} ');
      }
    }
    if (_searchFields['tags'] == true && album.tags.isNotEmpty) {
      for (var tag in album.tags) {
        buffer.write('${tag.tag} ');
      }
    }

    return buffer.toString();
  }

  /// Sort albums according to spec Section 3.2
  List<Album> _sortAlbums(List<Album> albums, SortOption option) {
    final sorted = [...albums];

    int ciCompare(String a, String b) =>
        a.toLowerCase().compareTo(b.toLowerCase());

    switch (option) {
      case SortOption.artistThenYear:
        sorted.sort((a, b) {
          final artistComp = ciCompare(a.sortArtist ?? a.artist, b.sortArtist ?? b.artist);
          if (artistComp != 0) return artistComp;
          return (_constructReleaseDate(a)).compareTo(_constructReleaseDate(b));
        });
        for (var album in sorted) {
          album.headerKey = (album.sortArtist ?? album.artist)[0].toUpperCase();
        }
        break;
      case SortOption.artistThenAlpha:
        sorted.sort((a, b) {
          final artistComp = ciCompare(a.sortArtist ?? a.artist, b.sortArtist ?? b.artist);
          if (artistComp != 0) return artistComp;
          return ciCompare(a.title, b.title);
        });
        for (var album in sorted) {
          album.headerKey = (album.sortArtist ?? album.artist)[0].toUpperCase();
        }
        break;
      case SortOption.albumAlpha:
        sorted.sort((a, b) => ciCompare(a.title, b.title));
        for (var album in sorted) {
          album.headerKey = album.title[0].toUpperCase();
        }
        break;
      case SortOption.releaseYear:
        sorted.sort((a, b) => (_constructReleaseDate(a)).compareTo(_constructReleaseDate(b)));
        for (var album in sorted) {
          album.headerKey = _constructReleaseDate(album).year.toString();
        }
        break;
      case SortOption.random:
        sorted.shuffle();
        break;
    }

    return sorted;
  }
  /// Construct a DateTime from album fields based on spec rules
  DateTime _constructReleaseDate(Album album) {
    final year = album.releaseYear;
    final month = album.releaseMonth;
    final day = album.releaseDay;

    if (year == null) {
      // No date -> 31 Dec 9999
      return DateTime(9999, 12, 31);
    } else if (month == null) {
      // Year only -> Jan 1
      return DateTime(year, 1, 1);
    } else if (day == null) {
      // Year + Month only -> Day 1
      return DateTime(year, month, 1);
    } else {
      // Full date
      return DateTime(year, month, day);
    }
  }

  /// Format a DateTime into four styles and join them into one string
  String _formatDateVariants(DateTime date) {
    // Year MonthName Day
    final yearMonthDay =
        '${date.year} ${_monthName(date.month)} ${date.day}';

    // ISO yyyy-mm-dd
    final iso = '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    // US mm/dd/yyyy
    final us = '${date.month.toString().padLeft(2, '0')}/'
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.year.toString().padLeft(4, '0')}';

    // English dd/mm/yyyy
    final uk = '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year.toString().padLeft(4, '0')}';

    return '$yearMonthDay $iso $us $uk';
  }

  /// Helper for month names
  String _monthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return names[month - 1];
  }
}