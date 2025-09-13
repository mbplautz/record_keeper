// lib/views/main_screen_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/album.dart';
import '../providers/album_provider.dart';
import '../widgets/album_card.dart';
import 'album_details_view.dart';

class MainScreenView extends StatelessWidget {
  const MainScreenView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final albumProvider = Provider.of<AlbumProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Record Keeper')),
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
