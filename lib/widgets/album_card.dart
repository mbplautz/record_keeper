// lib/widgets/album_card.dart

import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/material.dart';
import '../models/album.dart';
import '../providers/album_provider.dart';
import '../utils/image_utils.dart';
import '../views/album_details_view.dart';
import 'package:provider/provider.dart';

class AlbumCard extends StatelessWidget {
  final Album album;

  const AlbumCard({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
  return Slidable(
    key: ValueKey(album.id),

    // Defines the action pane when swiping left
    endActionPane: ActionPane(
      motion: const StretchMotion(),
      extentRatio: 0.5, // 50% of the item width (adjust as needed)
      children: [
        SlidableAction(
          onPressed: (_) {
            // Default option: open album details
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AlbumDetailsView(albumId: album.id),
              ),
            );
          },
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          icon: Icons.info,
          label: 'View',
        ),
        SlidableAction(
          onPressed: (ctx) async {
            final albumProv = ctx.read<AlbumProvider>();
            final confirm = await showDialog<bool>(
              context: ctx,
              builder: (context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        const Text(
                          'Confirm',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Body
                        const Text('Are you sure?'),
                        const SizedBox(height: 24),

                        // Buttons row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false); // Cancel
                              },
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true); // OK
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );

            if (confirm == true) {
              albumProv.deleteAlbum(album.id);
            }
          },
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          icon: Icons.delete,
          label: 'Delete',
        ),
      ],
    ),

    // The child is your existing album card layout
    child:     Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // Album thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(6.0),
              child: album.coverThumbnailPath != null
                  ? ImageUtils.loadImageWidget(
                      album.coverThumbnailPath!,
                      width: 64,
                      height: 64,
                    )
                  : Container(
                      width: 64,
                      height: 64,
                      color: Colors.grey[300],
                      child: const Icon(Icons.album, size: 32),
                    ),
            ),
            const SizedBox(width: 12),

            // Album details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    album.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Artist (fall back to unknown if missing)
                  Text(
                    album.artist,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (album.tags.isNotEmpty)
                  SizedBox(
                    height: 32, // height of one tag row
                    child: ClipRect(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final tag in album.tags)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(tag.tag, style: const TextStyle(color: Colors.white)),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
  );
  }
}
/*
I'll tell you about another change I made to the code. I noticed that the search feature was not actually searching any of the tracks or the tags, even when those were selected as search options. I realized that it was because in the call to `fetchAllAlbums`, it was only reading from the `albums` table and having empty lists for the tags and tracks fields. To fix it, I added loads to the `tags` and `tracks` tables, and populated the empty lists so that `fetchAllAlbums` now loaded all album data. */