// lib/widgets/album_card.dart

import 'package:flutter/material.dart';
import '../models/album.dart';
import '../utils/image_utils.dart';

class AlbumCard extends StatelessWidget {
  final Album album;

  const AlbumCard({Key? key, required this.album}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
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
    );
  }
}
/*
I'll tell you about another change I made to the code. I noticed that the search feature was not actually searching any of the tracks or the tags, even when those were selected as search options. I realized that it was because in the call to `fetchAllAlbums`, it was only reading from the `albums` table and having empty lists for the tags and tracks fields. To fix it, I added loads to the `tags` and `tracks` tables, and populated the empty lists so that `fetchAllAlbums` now loaded all album data. */