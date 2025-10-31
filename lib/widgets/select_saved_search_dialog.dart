import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/saved_search_provider.dart';
import '../providers/album_provider.dart';

class SelectSavedSearchDialog extends StatefulWidget {
  const SelectSavedSearchDialog({super.key});

  @override
  State<SelectSavedSearchDialog> createState() => _SelectSavedSearchDialogState();
}

class _SelectSavedSearchDialogState extends State<SelectSavedSearchDialog> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final savedSearchProvider = Provider.of<SavedSearchProvider>(context);
    final albumProvider = Provider.of<AlbumProvider>(context, listen: false);

    final savedSearches = savedSearchProvider.savedSearches;
    final selectedSearch =
        _selectedIndex != null && _selectedIndex! < savedSearches.length
            ? savedSearches[_selectedIndex!]
            : null;

    void refresh() => setState(() {});

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 400;

                final buttonWidgets = [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: selectedSearch == null
                        ? null
                        : () async {
                            if (selectedSearch.isDefault == true) return;
                            await savedSearchProvider.setDefaultSearch(selectedSearch.id!);
                            refresh();
                          },
                    child: const Text('Make Default'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await savedSearchProvider.setDefaultSearch(-1);
                      refresh();
                    },
                    child: const Text('Reset Default'),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Edit',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.info_outline, color: Colors.blue.shade600, size: 18),
                    ],
                  ),
                  TextButton(
                    onPressed: selectedSearch == null
                        ? null
                        : () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Delete Saved Search'),
                                content: const Text(
                                    'Are you sure you want to delete this saved search?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await savedSearchProvider.deleteSearch(selectedSearch.id!);
                              setState(() => _selectedIndex = null);
                            }
                          },
                    child: const Text('Delete'),
                  ),
                  ElevatedButton(
                    onPressed: selectedSearch == null
                        ? null
                        : () {
                  albumProvider.applySavedSearch(selectedSearch);
                  Navigator.of(context).pop(selectedSearch);
                          },
                    child: const Text('Select'),
                  ),
                ];


        return AlertDialog(
          title: const Text('Saved Searches'),
          content: SizedBox(
            width: 500,
            child: LayoutBuilder(
              builder: (context, innerConstraints) {
                // Calculate available height dynamically for ListView
                final availableHeight = innerConstraints.maxHeight.isFinite
                    ? innerConstraints.maxHeight
                    : 400.0;
                final itemHeight = 40.0;
                final listHeight =
                    (availableHeight * 0.3).clamp(itemHeight * 2, itemHeight * 5);

                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ======== SAVED SEARCH LIST ========
                        Container(
                          height: listHeight,
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).dividerColor),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ListView.builder(
                            itemCount: savedSearches.length,
                            itemBuilder: (context, index) {
                              final search = savedSearches[index];
                              final bool isSelected = index == _selectedIndex;
                  final bool isDefault = search.isDefault;
                              return InkWell(
                                onTap: () => setState(() => _selectedIndex = index),
                                child: Container(
                                  color: isSelected
                        ? Theme.of(context).colorScheme.primary.withAlpha((0.1 * 255).round())
                                      : Colors.transparent,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 28,
                                        child: isDefault
                                            ? const Icon(Icons.star,
                                                color: Colors.amber, size: 20)
                                            : const SizedBox.shrink(),
                                      ),
                                      Expanded(
                            child: Text(
                              search.name,
                              style: TextStyle(
                                color: isSelected
                                    ? Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withAlpha((0.9 * 255).round())
                                    : null,
                              ),
                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ======== SEARCH QUERY ========
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Search Query:'),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: double.infinity,
                          child: TextField(
                            controller: TextEditingController(
                                text: selectedSearch?.query ?? ''),
                            enabled: false,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ======== SEARCH IN GRID ========
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Search In:'),
                        ),
                        const SizedBox(height: 4),
                        _buildSearchInGrid(selectedSearch),
                        const SizedBox(height: 12),

                        // ======== SORT OPTION ========
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              const Text('Sort: '),
                              Expanded(
                                child: Text(
                                  _sortDescription(selectedSearch?.sortOption),
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ======== ACTION BUTTONS ========
                        isNarrow ?
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: buttonWidgets
                                .map((b) => Padding(padding: const EdgeInsets.symmetric(vertical: 4.0), child: b))
                                .toList(),
                          )
                          : Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: buttonWidgets
                                  .map((b) => SizedBox(width: constraints.maxWidth / 3 - 12, child: b))
                                  .toList(),
                            )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

            );
      },
    );
  }

  Widget _buildSearchInGrid(savedSearch) {
    const searchFields = [
      'Title',
      'Artist',
      'Sort Artist',
      'Release Date',
      'Tracks',
      'Tags',
    ];
    final flags = {
      'Title': savedSearch?.searchTitle ?? false,
      'Artist': savedSearch?.searchArtist ?? false,
      'Sort Artist': savedSearch?.searchSortArtist ?? false,
      'Release Date': savedSearch?.searchReleaseDate ?? false,
      'Tracks': savedSearch?.searchTracks ?? false,
      'Tags': savedSearch?.searchTags ?? false
    };
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: searchFields.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 4,
        crossAxisSpacing: 8,
        childAspectRatio: 4,
      ),
      itemBuilder: (context, index) {
        final label = searchFields[index];
        final checked = flags[label] == true;
        return Row(
          children: [
            SizedBox(
              width: 24,
              child: checked
                  ? const Icon(Icons.check, size: 18)
                  : const SizedBox.shrink(),
            ),
            Flexible(child: Text(label)),
          ],
        );
      },
    );
  }

  String _sortDescription(dynamic sortOptionIndex) {
    if (sortOptionIndex == null) {
      return '';
    }
    final sortOption = SortOption.values[sortOptionIndex];
    switch (sortOption) {
      case SortOption.artistThenYear:
        return 'By artist, then release year';
      case SortOption.artistThenAlpha:
        return 'By artist, then alphabetically';
      case SortOption.albumAlpha:
        return 'By album alphabetically';
      case SortOption.releaseYear:
        return 'By release date';
      case SortOption.random:
        return 'Randomly';
      default:
        return '';
    }
  }
}
