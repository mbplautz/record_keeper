// lib/views/main_screen_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/album.dart';
import '../providers/album_provider.dart';
import '../widgets/album_card.dart';
import 'album_details_view.dart';

class MainScreenView extends StatefulWidget {
  const MainScreenView({Key? key}) : super(key: key);

  @override
  _MainScreenViewState createState() => _MainScreenViewState();
}

class _MainScreenViewState extends State<MainScreenView> {
  final TextEditingController _searchController = TextEditingController();

  void _onSearch(BuildContext context) {
    final terms = _searchController.text.trim().split(' ');
    //final sortOption = context.read<SortSettingsProvider>().currentSortOption;

    context.read<AlbumProvider>().searchAlbums(
          terms: terms,
          //sortOption: sortOption,
        );
  }

  @override
  Widget build(BuildContext context) {
    final albumProvider = Provider.of<AlbumProvider>(context);

    return Scaffold(
      // appBar: AppBar(
      //   title: const Center(child: Text('Record Keeper')),
      // ),
      appBar: AppBar(
        title: Row(
          children: [
            // Search Bar
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search albums...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                onSubmitted: (_) => _onSearch(context),
              ),
            ),
            const SizedBox(width: 8),
            // Sort Button inside same bar
            PopupMenuButton<String>(
              icon: const Icon(Icons.sort),
              initialValue: "titleAsc", //sortSettingsProvider.currentSortOption,
              onSelected: (sortOption) {
                //sortSettingsProvider.setSortOption(sortOption);
                _onSearch(context); // re-run search with new sort
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: "titleAsc", //SortOption.titleAsc,
                  child: Text('Title (A-Z)'),
                ),
                const PopupMenuItem(
                  value: "titleDesc", //SortOption.titleDesc,
                  child: Text('Title (Z-A)'),
                ),
                const PopupMenuItem(
                  value: "dateAsc", //SortOption.dateAsc,
                  child: Text('Date (Oldest)'),
                ),
                const PopupMenuItem(
                  value: "dateDesc", //SortOption.dateDesc,
                  child: Text('Date (Newest)'),
                ),
              ],
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Album>>(
        future: albumProvider.getAllAlbums(),
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

          return ListView.builder(
            itemCount: albums.length,
            itemBuilder: (context, index) {
              final album = albums[index];
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
          );
        },
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
