// lib/views/main_screen_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:path_provider/path_provider.dart';

import '../models/album.dart';
import '../models/tag.dart';
import '../providers/album_provider.dart';
import '../providers/tag_provider.dart';
import '../utils/image_utils.dart';
import '../widgets/album_card.dart';
import 'album_details_view.dart';

class MainScreenView extends StatefulWidget {
  const MainScreenView({super.key});

  @override
  State<MainScreenView> createState() => _MainScreenViewState();
}

class _MainScreenViewState extends State<MainScreenView> {
  final TextEditingController _searchController = TextEditingController();
  bool _isInitialized = false;

  // Tag dialog controller
  final TextEditingController _tagController = TextEditingController();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    if (!_isInitialized) {
      // Trigger the one-time fetch
      Provider.of<AlbumProvider>(context, listen: false).fetchAllAlbums();
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
  Future<void> _showAddTagDialog(String albumId, AlbumProvider albumProv) async {
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
                  const Text('Add Tag', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                          onPressed: () async {
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

    return StickyGroupedListView<Album, String>(
      key: ValueKey(provider.currentSearch),
      elements: albums,
      groupBy: (album) => album.headerKey ?? '',
      groupSeparatorBuilder: (Album album) {
        final header = album.headerKey ?? '';
        return Container(
          width: double.infinity,
          color: Colors.grey[200],
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
          child: Text(
            header,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        );
      },
      itemBuilder: (context, Album album) {
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
      // Since sorting is already done in provider:
      itemComparator: (a, b) => 0,
      groupComparator: (a, b) => a.compareTo(b),
      order: StickyGroupedListOrder.ASC,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AlbumProvider>(context);

    final needsSticky = provider.sortOption == SortOption.artistThenYear 
      || provider.sortOption == SortOption.artistThenAlpha
      || provider.sortOption == SortOption.albumAlpha
      || provider.sortOption == SortOption.releaseYear;

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
      ),
      body: SafeArea(
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
                        checked: provider.sortOption == option,
                        child: Text(_sortOptionLabel(option)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Albums list
            Expanded(
      child: needsSticky ? _buildStickyList(provider.albums, provider) : ListView.builder(
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
          ),
          ],
        )
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
}
