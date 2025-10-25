// lib/views/main_screen_view.dart

import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record_keeper/models/saved_search.dart';

import '../db/app_database.dart';
import '../models/album.dart';
import '../models/tag.dart';
import '../providers/album_provider.dart';
import '../providers/saved_search_provider.dart';
import '../providers/tag_provider.dart';
import '../services/export_service.dart';
import '../services/import_service.dart';
import '../utils/file_utils.dart';
import '../utils/image_utils.dart';
import '../widgets/album_card.dart';
import '../widgets/grouped_sticky_album_list.dart';
import '../widgets/right_side_menu.dart';
import '../widgets/saved_search_dialog.dart';
import 'album_details_view.dart';

typedef VoidCallbackFunction = Future<void> Function();

class MainScreenView extends StatefulWidget {
  const MainScreenView({super.key});

  @override
  State<MainScreenView> createState() => _MainScreenViewState();
}

class _MainScreenViewState extends State<MainScreenView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;
  bool _menuVisible = false;

  // Tag dialog controller
  final TextEditingController _tagController = TextEditingController();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    if (!_isInitialized) {
      // Trigger the one-time fetch
      final albumProvider = Provider.of<AlbumProvider>(context, listen: false);
      final savedSearchProvider = Provider.of<SavedSearchProvider>(context, listen: false);
      
      await albumProvider.fetchAllAlbums();
      await savedSearchProvider.loadAll();
      
      final defaultSearch = savedSearchProvider.defaultSearch;
      if (defaultSearch != null) {
        _searchController.text = defaultSearch.query;
        await albumProvider.applySavedSearch(defaultSearch);
      }

      ImageUtils.applicationDocumentsDirectory = (await getApplicationDocumentsDirectory()).path;
      _isInitialized = true;
    }
  }

  String _sortOptionLabel(SortOption option) {
    switch (option) {
      case SortOption.artistThenYear: //SortOption.byArtistReleaseYear:
        return 'By artist, then release year';
      case SortOption.artistThenAlpha: //SortOption.byArtistAlphabetically:
        return 'By artist, then alphabetically';
      case SortOption.albumAlpha: //SortOption.byAlbumAlphabetically:
        return 'By album alphabetically';
      case SortOption.releaseYear: //SortOption.byReleaseDate:
        return 'By release date';
      case SortOption.random: //SortOption.randomly:
        return 'Randomly';
    }
  }

  final Map<String, String> _searchOptionsLabels = {
    'title': 'Title',
    'artist': 'Artist',
    'sortArtist': 'Sort Artist',
    'releaseDate': 'Release Date',
    'tracks': 'Tracks',
    'tags': 'Tags',
  };

  void _toggleMenu() => setState(() => _menuVisible = !_menuVisible);

  Widget _buildTagAutocomplete(List<String> distinctTags) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue val) {
        if (val.text.isEmpty) return const Iterable.empty();
        final lower = val.text.toLowerCase();
        return distinctTags
            .where((a) => a.toLowerCase().contains(lower))
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      },
      onSelected: (selection) => _tagController.text = selection,
      fieldViewBuilder: (ctx, ctrl, focus, onSubmit) {
        ctrl.text = _tagController.text;
        ctrl.selection = _tagController.selection;
        ctrl.addListener(() {
          _tagController.text = ctrl.text;
          _tagController.selection = ctrl.selection;
        });
        return TextField(
          controller: ctrl,
          focusNode: focus,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          maxLength: 255,
        );
      },
    );
  }
  
  // Display Add Tag dialog per spec (centered). On OK: persist tag immediately.
  Future<void> _showAddTagDialog(String albumId, AlbumProvider albumProv, 
    { String? alternativeTitle, VoidCallbackFunction? alternativeCallback}) async {
    final tagProv = Provider.of<TagProvider>(context, listen: false);
    tagProv.loadTagsForAlbum(albumId);
    final List<String> distinctTags = await tagProv.getDistinctTagList();

    _tagController.clear();
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 600
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(alternativeTitle ?? 'Add Tag', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildTagAutocomplete(distinctTags),
                  const SizedBox(height: 12),
                  Row(
                    //crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: alternativeCallback ?? () async {
                            final text = _tagController.text;
                            if (text.trim().isEmpty) {
                              Navigator.of(ctx).pop();
                              return;
                            }

                            // Per spec: case-sensitive duplicate check
                            final existing = tagProv.tags;
                            final alreadyExists = existing.any((t) => t.tag == text);
                            if (!alreadyExists) {
                              final tag = Tag(id: null, albumId: albumId, tag: text);
                              await tagProv.addTag(tag); // persists immediately
                              albumProv.fetchAllAlbums();
                            }
                            Navigator.of(ctx).pop();
                            if (mounted) setState(() {});
                          },
                          child: const Text('OK'),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        );
      },
    );
  }

  Widget _buildStickyList(List<Album> albums, AlbumProvider provider) {
    if (albums.isEmpty) {
      return const Center(child: Text('No albums found'));
    }

    return StickyGroupedAlbumList(
      albums: provider.albums,
      itemBuilder: (ctx, album) => SizedBox(
        height: 96.0,
        child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AlbumDetailsView(albumId: album.id),
                    ),
                  );
                },
                child: AlbumCard(album: album, onAddTagPressed: () => {
                  _showAddTagDialog(album.id, provider)
                }),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AlbumProvider>(context);

    final needsSticky = provider.currentSort == SortOption.artistThenYear 
      || provider.currentSort == SortOption.artistThenAlpha
      || provider.currentSort == SortOption.albumAlpha
      || provider.currentSort == SortOption.releaseYear;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: /*
    return */Scaffold(
            // Section 2.2.1.1 - Title Banner
      appBar: AppBar(
        title: const Text("Record Keeper"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: _toggleMenu,
          ),
        ],
      ),
      body: Stack(
        children: [SafeArea(
        child: Column(
          children: [
/*            // Section 2.2.1.1 - Title Banner
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Record Keeper',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
*/
            // Section 2.2.1.2 - Search Bar + Buttons Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  // Search bar
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search albums...',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            provider.clearSearch();
                          },
                        ),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onChanged: (value) {
                        provider.setSearchQuery(value);
                      },
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Search Settings Popup Menu
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.filter_alt),
                    onSelected: (key) {
                      final updated = Map<String, bool>.from(provider.searchFields);
                      final checkedItems = updated.values.where((v) => v).length;

                      if (updated[key]! && checkedItems == 1) {
                        // Prevent unchecking the last checked item
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('At least one search setting must remain selected.'),
                          ),
                        );
                        return;
                      }

                      updated[key] = !updated[key]!;
                      provider.setSearchFields(updated);
                    },
                    itemBuilder: (context) => provider.searchFields.keys.map((key) {
                      return CheckedPopupMenuItem<String>(
                        value: key,
                        checked: provider.searchFields[key]!,
                        child: Text(_searchOptionsLabels[key]!),
                      );
                    }).toList(),
                  ),

                  const SizedBox(width: 8),

                  // Sort Settings Popup Menu
                  PopupMenuButton<SortOption>(
                    icon: Transform.rotate(
                      angle: 1.570796,
                      child: Icon(Icons.sync_alt),
                    ),
                    onSelected: (option) {
                      provider.setSortOption(option);
                    },
                    itemBuilder: (context) => SortOption.values.map((option) {
                      return CheckedPopupMenuItem<SortOption>(
                        value: option,
                        checked: provider.currentSort == option,
                        child: Text(_sortOptionLabel(option)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Albums list
            
            Expanded(
          child: needsSticky ? _buildStickyList(provider.albums, provider) : Scrollbar(thumbVisibility: false, interactive: true, controller: _scrollController, child: ListView.builder(
            controller: _scrollController,
            itemCount: provider.albums.length, //albums.length,
            itemBuilder: (context, index) {
              final album = provider.albums[index]; //albums[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AlbumDetailsView(albumId: album.id),
                    ),
                  );
                },
                child: AlbumCard(album: album, onAddTagPressed: () => {
                  _showAddTagDialog(album.id, provider)
                }),
              );
            },
          )
          )),
          ],
        )
      ),
          // Slide-in menu overlay
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              right: _menuVisible ? 0 : -min(MediaQuery.of(context).size.width, max(MediaQuery.of(context).size.width * 0.5, 300)).toDouble(),
              top: 0,
              bottom: 0,
              child: RightSideMenu(
                width: min(MediaQuery.of(context).size.width, max(MediaQuery.of(context).size.width * 0.5, 300)),
                onExportCollection: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  try {
                    final dbPath = await getDatabasePath();
                    final imageDirPath = await getImagesDirectoryPath();
                    final thumbnailDirPath = await getThumbnailsDirectoryPath();

                    await ExportService.exportCollection(
                      databasePath: dbPath,
                      imagesDirectoryPath: imageDirPath,
                      thumbnailsDirectoryPath: thumbnailDirPath,
                      context: context,
                    );

                    if (context.mounted) {
                      Navigator.of(context).pop(); // remove spinner
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.of(context).pop(); // remove spinner
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Export failed: $e')),
                      );
                    }
                  }
                },
                onImportCollection: () async {
                  final appDatabase = context.read<AppDatabase>();
                  final database = await appDatabase.database;
                  
                  // Show native file picker
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['zip'],
                  );

                  if (result != null && result.files.single.path != null) {
                    String filePath = result.files.single.path!;
                    File zipFile = File(filePath);

                    try {
                      // Call import service
                      await ImportService.importCollection(zipFile, database);
                      provider.fetchAllAlbums();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Import failed: $e')),
                        );
                      }
                    }
                  }
                },
                onDeleteCollection: () async {
                  final confirm = await showConfirmDeleteDialog(context);
                  if (confirm) {
                    await provider.deleteAllAlbums();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All albums deleted')),
                    );
                  }
                },
                onSaveSearch: () async {
                  await showDialog<bool>(
                    context: context,
                    builder: (context) => const SaveSearchDialog(),
                  );
                },
                onManageSavedSearches: () => print('Manage searches'),
                onImportSavedSearches: () async {
                  final appDatabase = context.read<AppDatabase>();
                  final database = await appDatabase.database;
                  try {
                    await database.execute('''
CREATE TABLE saved_searches (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  is_default INTEGER NOT NULL DEFAULT 0,
  name TEXT NOT NULL,
  query TEXT NOT NULL,
  search_title INTEGER NOT NULL DEFAULT 1,
  search_artist INTEGER NOT NULL DEFAULT 1,
  search_sort_artist INTEGER NOT NULL DEFAULT 1,
  search_release_date INTEGER NOT NULL DEFAULT 1,
  search_tracks INTEGER NOT NULL DEFAULT 1,
  search_tags INTEGER NOT NULL DEFAULT 1,
  sort_option INTEGER NOT NULL DEFAULT 0
);''');
                    await database.execute('''
CREATE UNIQUE INDEX IF NOT EXISTS idx_saved_searches_name ON saved_searches(name);
'''); 
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Saved searches imported successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Import saved searches failed: $e')),
                    );
                  }
                },
                onAddTag: () async {
                  await _showAddTagDialog("", provider, 
                    alternativeTitle: 'Add Tag to List',
                    alternativeCallback: () async {
                      final text = _tagController.text;
                      if (text.trim().isEmpty) {
                        Navigator.of(context).pop();
                        return;
                      }

                      await provider.addTagToList(text);
                      Navigator.of(context).pop();
                      if (mounted) setState(() {});
                    }
                  );
                },
                onRemoveTag: () async {
                  await _showAddTagDialog("", provider, 
                    alternativeTitle: 'Remove Tag from List',
                    alternativeCallback: () async {
                      final text = _tagController.text;
                      if (text.trim().isEmpty) {
                        Navigator.of(context).pop();
                        return;
                      }

                      await provider.deleteTagFromList(text);
                      Navigator.of(context).pop();
                      if (mounted) setState(() {});
                    }
                  );
                },
                onRemoveAlbums: () async {
                  final listCount = provider.albums.length;
                  if (listCount == 0) return;
                  final adjective = listCount > 1 ? 'these' : 'this';
                  final plural = listCount > 1 ? 's' : '';
                  final confirm = await showConfirmDeleteDialog(
                    context,
                    title: 'Delete List',
                    text: 'Are you sure you want to delete $adjective $listCount album$plural? This action cannot be undone.'
                  );
                  if (confirm) {
                    await provider.deleteAlbumList();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$listCount album$plural deleted')),
                    );
                  }
                },
                totalAlbums: provider.allAlbums.length,
                listedAlbums: provider.albums.length,
                onClose: _toggleMenu,
              ),
            ),
      ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
         // Per requirement 2.2.1.5: navigate to the existing AlbumDetailsView,
          // with a "blank" album (albumId = null) so it opens in edit mode.
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AlbumDetailsView(albumId: null),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    )
    );
  }

  Future<bool> showConfirmDeleteDialog(BuildContext context,
   { String title = 'Delete Collection', 
     String text = 'Are you sure? This action cannot be undone.'
   }) async {
    bool isChecked = false;

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false, // prevent closing without choosing
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(text),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: isChecked,
                        onChanged: (value) {
                          setState(() => isChecked = value ?? false);
                        },
                      ),
                      const Expanded(
                        child: Text('I am sure'),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: isChecked
                      ? () => Navigator.of(context).pop(true)
                      : null, // disabled when unchecked
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    ) ??
        false; // if dismissed, treat as false
  }
}
