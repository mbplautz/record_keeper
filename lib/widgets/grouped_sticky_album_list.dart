import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import '../models/album.dart';

typedef ItemBuilderFn<T> = Widget Function(BuildContext context, T item);

class StickyGroupedAlbumList extends StatefulWidget {
  final List<Album> albums;
  final ItemBuilderFn<Album> itemBuilder;

  const StickyGroupedAlbumList({
    required this.albums,
    required this.itemBuilder,
    super.key,
  });

  @override
  State<StickyGroupedAlbumList> createState() => _StickyGroupedAlbumListState();
}

class _StickyGroupedAlbumListState extends State<StickyGroupedAlbumList> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Group albums
    final Map<String, List<Album>> groups = {};
    for (var album in widget.albums) {
      final key = album.headerKey!;
      groups.putIfAbsent(key, () => []).add(album);
    }
    final groupKeys = groups.keys.toList();

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,   // Always visible when scrolling
      interactive: true,       // Enable drag-to-scroll behavior
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          for (var g in groupKeys) ...[
            SliverStickyHeader(
              header: Container(
                height: 40,
                color: Colors.grey[300],
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  g,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, idx) {
                    final album = groups[g]![idx];
                    return widget.itemBuilder(context, album);
                  },
                  childCount: groups[g]!.length,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
