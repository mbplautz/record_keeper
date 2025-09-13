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

                  // Tags summary
                  if (album.tagSummary != null &&
                      album.tagSummary!.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        album.tagSummary!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
