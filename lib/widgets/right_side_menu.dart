import 'package:flutter/material.dart';

class RightSideMenu extends StatefulWidget {
  final double width;
  final VoidCallback onExportCollection;
  final VoidCallback onImportCollection;
  final VoidCallback onDeleteCollection;
  final VoidCallback onSaveSearch;
  final VoidCallback onManageSavedSearches;
  final VoidCallback onAddTag;
  final VoidCallback onRemoveTag;
  final VoidCallback onRemoveAlbums;
  final int totalAlbums;
  final int listedAlbums;
  final VoidCallback onClose;

  const RightSideMenu({
    super.key,
    required this.width,
    required this.onExportCollection,
    required this.onImportCollection,
    required this.onDeleteCollection,
    required this.onSaveSearch,
    required this.onManageSavedSearches,
    required this.onAddTag,
    required this.onRemoveTag,
    required this.onRemoveAlbums,
    required this.totalAlbums,
    required this.listedAlbums,
    required this.onClose,
  });

  @override
  State<RightSideMenu> createState() => _RightSideMenuState();
}

class _RightSideMenuState extends State<RightSideMenu> {
  final Map<String, bool> _expandedSections = {
    'My collection': false,
    'Saved searches': false,
    'Special actions': false,
  };

  void _expandSection(String title, bool isExpanded) {
    for (var key in _expandedSections.keys) {
      _expandedSections[key] = false; // collapse all sections
    }
    _expandedSections[title] = !isExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Semi-transparent backdrop
        GestureDetector(
          onTap: widget.onClose,
          child: Container(
            color: Colors.black54,
          ),
        ),
        // Sliding panel
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: widget.width,
            height: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Menu',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: widget.onClose,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Accordion sections
                  _buildSection(
                    title: 'My collection',
                    items: [
                      _buildAction('Export collection', widget.onExportCollection),
                      _buildAction('Import collection', widget.onImportCollection),
                      _buildAction('Delete collection', widget.onDeleteCollection),
                      _buildInfo('${widget.totalAlbums} albums total'),
                      _buildInfo('${widget.listedAlbums} albums listed'),
                    ],
                  ),
                  _buildSection(
                    title: 'Saved searches',
                    items: [
                      _buildAction('Save current search', widget.onSaveSearch),
                      _buildAction('Manage saved searches', widget.onManageSavedSearches),
                    ],
                  ),
                  _buildSection(
                    title: 'Special actions',
                    items: [
                      _buildAction('Add tag to list', widget.onAddTag),
                      _buildAction('Remove tag from list', widget.onRemoveTag),
                      _buildAction('Remove albums in list', widget.onRemoveAlbums),
                    ],
                  ),
                  ListTile(
                    dense: true,
                    title: Text(
                      'About',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    onTap: () {
                      widget.onClose(); // hide menu before performing action
                      _onAboutPressed().call();
                    },
                  ),

                  /*// Non-expandable section
                  const Divider(height: 24),
                  const Text(
                    'About',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Record Keeper v1.0\nDeveloped with Flutter',
                    style: TextStyle(color: Colors.black54),
                  ),*/
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required List<Widget> items}) {
    final expanded = _expandedSections[title] ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          dense: true,
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          trailing: Icon(expanded ? Icons.expand_less : Icons.expand_more),
          onTap: () => setState(() => _expandSection(title, expanded)),
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(children: items),
          ),
        const Divider(),
      ],
    );
  }

  Widget _buildAction(String text, VoidCallback onPressed) {
    return ListTile(
      dense: true,
      title: Text(text),
      onTap: () {
        widget.onClose(); // hide menu before performing action
        onPressed();
      },
    );
  }

  Widget _buildInfo(String text) {
    return ListTile(
      dense: true,
      title: Text(
        text,
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }

  VoidCallback _onAboutPressed() {
    return () {
      print("About pressed"); // Replace with actual about dialog logic
    };
  }
}