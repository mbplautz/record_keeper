import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/saved_search_provider.dart';
import '../providers/album_provider.dart';
import 'tooltip_icon.dart';

class SaveSearchDialog extends StatefulWidget {
  const SaveSearchDialog({super.key});

  @override
  State<SaveSearchDialog> createState() => _SaveSearchDialogState();
}

enum SaveMode { newSearch, overwrite }

class _SaveSearchDialogState extends State<SaveSearchDialog> {
  SaveMode _selectedMode = SaveMode.newSearch;
  final TextEditingController _nameController = TextEditingController();
  String? _selectedExisting;
  bool _isDuplicate = false;

  @override
  Widget build(BuildContext context) {
    final savedSearchProvider = Provider.of<SavedSearchProvider>(context, listen: false);
    final albumProvider = Provider.of<AlbumProvider>(context, listen: false);

    final existingSearches = savedSearchProvider.savedSearches.map((s) => s.name).toList();

    bool isNewSearch = _selectedMode == SaveMode.newSearch;
    bool nameBlank = _nameController.text.trim().isEmpty;
    bool existingNotSelected = _selectedExisting == null || _selectedExisting == 'Select existing search';

    // Determine duplicate state
    _isDuplicate = existingSearches.contains(_nameController.text.trim());

    bool isOkEnabled = false;
    if (isNewSearch && !nameBlank && !_isDuplicate) {
      isOkEnabled = true;
    } else if (!isNewSearch && !existingNotSelected) {
      isOkEnabled = true;
    }

    return AlertDialog(
      title: const Text('Save current search'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Save as new search
            InkWell(
              onTap: () => setState(() => _selectedMode = SaveMode.newSearch),
              child: Row(
                children: [
                  Icon(
                    _selectedMode == SaveMode.newSearch
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                  ),
                  const SizedBox(width: 8),
                  const Text('Save as new search'),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: SizedBox(
                width: 300,
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    TextField(
                      controller: _nameController,
                      enabled: isNewSearch,
                      decoration: const InputDecoration(
                        hintText: 'Enter name for saved search',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    if (_isDuplicate)
                      Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: 
                          TooltipIcon(
                            icon: Icon(Icons.warning_amber_rounded, color: Colors.red), 
                            tooltipMessage: 'A saved search with this name already exists. To overwrite it, select "Overwrite existing search".'
                          )
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Overwrite existing search
            InkWell(
              onTap: () => setState(() => _selectedMode = SaveMode.overwrite),
              child: Row(
                children: [
                  Icon(
                    _selectedMode == SaveMode.overwrite
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                  ),
                  const SizedBox(width: 8),
                  const Text('Overwrite existing search'),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: SizedBox(
                width: 300,
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedExisting ?? 'Select existing search',
                  decoration: const InputDecoration(),
                  items: [
                    const DropdownMenuItem(
                      value: 'Select existing search',
                      child: Text(
                        'Select existing search',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ...existingSearches.map((name) => DropdownMenuItem(
                          value: name,
                          child: Text(name),
                        )),
                  ],
                  onChanged: isNewSearch
                      ? null
                      : (value) {
                          setState(() => _selectedExisting = value);
                        },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isOkEnabled
              ? () async {
                  if (isNewSearch) {
                    await savedSearchProvider.saveCurrentSearchFromAlbumProvider(
                      albumProvider,
                      _nameController.text.trim(),
                    );
                  } else {
                    await savedSearchProvider.saveCurrentSearchFromAlbumProvider(
                      albumProvider,
                      _selectedExisting!,
                    );
                  }
                  if (mounted) Navigator.of(context).pop(true);
                }
              : null,
          child: const Text('OK'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
