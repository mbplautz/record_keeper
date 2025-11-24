import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../views/about_view.dart';

class RightSideMenu extends StatefulWidget {
  final double width;
  final VoidCallback onExportCollection;
  final VoidCallback onImportCollection;
  final VoidCallback onDeleteCollection;
  final VoidCallback onSaveSearch;
  final VoidCallback onManageSavedSearches;
  final VoidCallback onImportSavedSearches;
  final VoidCallback onAddTag;
  final VoidCallback onRemoveTag;
  final VoidCallback onRemoveAlbums;
  final int totalAlbums;
  final int listedAlbums;
  final bool visible;
  final VoidCallback onShowWelcomeDialog;
  final VoidCallback onClose;

  const RightSideMenu({
    super.key,
    required this.width,
    required this.onExportCollection,
    required this.onImportCollection,
    required this.onDeleteCollection,
    required this.onSaveSearch,
    required this.onManageSavedSearches,
    required this.onImportSavedSearches,
    required this.onAddTag,
    required this.onRemoveTag,
    required this.onRemoveAlbums,
    required this.totalAlbums,
    required this.listedAlbums,
    required this.visible,
    required this.onShowWelcomeDialog,
    required this.onClose,
  });

  @override
  State<RightSideMenu> createState() => RightSideMenuState();
}

class RightSideMenuState extends State<RightSideMenu>
    with TickerProviderStateMixin {
  String? _expandedSection;

  void _toggleSection(String section) {
    setState(() {
      _expandedSection = _expandedSection == section ? null : section;
    });
  }

  void collapseAllSections() {
    setState(() {
      _expandedSection = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 8,
      child: SizedBox(
        width: widget.width, 
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
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
                        onPressed: widget.onClose
                      ),
                    ],
                  ),

              ),
              const Divider(),

              // My Collection
              _buildAccordionSection(
                title: 'My Collection',
                sectionKey: 'collection',
                children: [
                  _buildAction('Export collection', widget.onExportCollection),
                  _buildAction('Import collection', widget.onImportCollection),
                  _buildAction('Delete collection', widget.onDeleteCollection),
                  _buildInfo('${widget.totalAlbums} albums total'),
                  _buildInfo('${widget.listedAlbums} albums listed'),
                ],
              ),

              // Saved Searches
              _buildAccordionSection(
                title: 'Saved Searches',
                sectionKey: 'saved_searches',
                children: [
                  _buildAction('Save current search', widget.onSaveSearch),
                  _buildAction('Load saved search', widget.onManageSavedSearches),
                  _buildAction('Import saved searches', widget.onImportSavedSearches),
                ],
              ),

              // Special Actions
              _buildAccordionSection(
                title: 'Special Actions',
                sectionKey: 'special_actions',
                children: [
                  _buildAction('Add tag to list', widget.onAddTag),
                  _buildAction('Remove tag from list', widget.onRemoveTag),
                  _buildAction('Delete albums in list', widget.onRemoveAlbums),
                ],
              ),

              ListTile(
                dense: true,
                title: Text(
                  'About',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ),
                onTap: () {
                  setState(() {
                    _expandedSection = null; // collapse section
                  });
                  widget.onClose(); // hide menu before performing action
                  _onAboutPressed().call();
                },
              ),
              const Divider(),
              ListTile(
                dense: true,
                title: Text(
                  'Help',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ),
                onTap: () async {
                  setState(() {
                    _expandedSection = null; // collapse section
                  });
                  widget.onClose(); // hide menu before performing action
                  final url = 'https://github.com/mbplautz/record_keeper?tab=readme-ov-file#Record%20Keeper';
                  final uri = Uri.parse(url);
                  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                    throw Exception('Could not launch $url');
                  }
                },
              ),
            ],
          ),
        )
      ),
    );
  }

  Widget _buildAccordionSection({
    required String title,
    required String sectionKey,
    required List<Widget> children,
  }) {
    final isExpanded = _expandedSection == sectionKey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          trailing: AnimatedRotation(
            turns: isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: const Icon(Icons.expand_more),
          ),
          onTap: () => _toggleSection(sectionKey),
        ),

        // Animated expand/collapse
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: isExpanded
                ? const BoxConstraints()
                : const BoxConstraints(maxHeight: 0),
            child: Column(children: children),
          ),
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
        setState(() {
          _expandedSection = null; // collapse section
        });
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
//      print("About pressed"); // Replace with actual about dialog logic
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AboutView(
          onShowWelcomeDialog: widget.onShowWelcomeDialog,
        )),
      );
    };
  }
}