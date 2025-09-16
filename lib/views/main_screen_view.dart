// lib/views/main_screen_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/album.dart';
import '../providers/album_provider.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      // Trigger the one-time fetch
      Provider.of<AlbumProvider>(context, listen: false).fetchAllAlbums();
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AlbumProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Section 2.2.1.1 - Title Banner
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
                    icon: const Icon(Icons.search),
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
                        child: Text(key),
                      );
                    }).toList(),
                  ),

                  const SizedBox(width: 8),

                  // Sort Settings Popup Menu
                  PopupMenuButton<SortOption>(
                    icon: const Icon(Icons.sort),
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
      child: /* FutureBuilder<List<Album>>(
        future: provider.getAllAlbums(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final albums = snapshot.data ?? [];

          if (albums.isEmpty) {
            return const Center(child: Text('No albums found.'));
          }

          return*/ ListView.builder(
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
                child: AlbumCard(album: album),
              );
            },
          )/*;
        },
      ),*/
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
    );
  }
}
