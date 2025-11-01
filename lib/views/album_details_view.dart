// lib/views/album_details_view.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/album.dart';
import '../models/track.dart';
import '../models/tag.dart';
import '../providers/album_provider.dart';
import '../providers/track_provider.dart';
import '../providers/tag_provider.dart';
import '../utils/image_utils.dart';

class AlbumDetailsView extends StatefulWidget {
  /// If albumId is null, this view is creating a new album (starts in edit mode).
  final String? albumId;
  final bool editMode;

  const AlbumDetailsView({super.key, this.albumId, this.editMode = false});

  @override
  State<AlbumDetailsView> createState() => _AlbumDetailsViewState();
}

class _AlbumDetailsViewState extends State<AlbumDetailsView> {
  // UI state
  late bool _isNew;
  bool _isEditMode = false;
  bool _startedInViewMode = false;
  bool _dirtyTags = false;

  // Album in-memory
  Album? _album;

  // Controllers for editable fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();
  final TextEditingController _sortArtistController = TextEditingController();
  final TextEditingController _wikiController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();

  // Month: 0 = blank, 1 = January ... 12 = December
  int _monthSelected = 0;

  // Tracks: local editable list of track names (persisted only on Save/Add)
  final TextEditingController _newTrackController = TextEditingController();
  final TextEditingController _editTrackController = TextEditingController();

  List<String> _localTracks = [];
  int? _editingTrackIndex; // which index is being edited inline (-1 none)

  // Temp picked image file (not yet saved to app storage).
  File? _pickedImageFile;
  bool _deletedImage = false;

  // Tag dialog controller
  final TextEditingController _tagController = TextEditingController();

  // Value Notifier for Form Validation
  late final ValueNotifier<bool> _isFormValidNotifier;

  List<String> _distinctArtists = [];
  List<String> _distinctSortArtists = [];
  List<String> _distinctTags = [];
  List<Tag> _newAlbumTags = [];

  // Helpers to access providers
  AlbumProvider get _albumProv => context.read<AlbumProvider>();
  TrackProvider get _trackProv => context.read<TrackProvider>();
  TagProvider get _tagProv => context.read<TagProvider>();

  @override
  void initState() {
    super.initState();
    _isNew = widget.albumId == null;
    _isEditMode = _isNew || widget.editMode;
    _startedInViewMode = !_isNew && !widget.editMode;

    // Form validation: watch text controllers
    _isFormValidNotifier = ValueNotifier<bool>(_isFormValid());

    for (final c in [
      _titleController,
      _artistController,
      _yearController,
      _dayController
    ]) {
      c.addListener(() {
        Future.microtask(() {
          if (mounted) {
            _isFormValidNotifier.value = _isFormValid();
          }
        });
      });
    }

    if (_isNew) {
      // Prepare an empty album placeholder (id created now)
      final newId = DateTime.now().microsecondsSinceEpoch.toString();
      _album = Album(
        id: newId,
        title: '',
        artist: '',
        sortArtist: null,
        releaseYear: null,
        releaseMonth: null,
        releaseDay: null,
        wikiUrl: null,
        coverImagePath: null,
        coverThumbnailPath: null,
        tracks: [],
        tags: [],
      );
      // Clear tags when adding new
      _tagProv.clearTags();
      _populateControllersFromAlbum();
    } else {
      _loadAlbumAndRelations();
    }

    // 🔹 Preload distinct artist/sort lists
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _distinctArtists = await _albumProv.getDistinctArtistList();
      _distinctSortArtists = await _albumProv.getDistinctSortArtistList();
      _distinctTags = await _tagProv.getDistinctTagList();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _sortArtistController.dispose();
    _wikiController.dispose();
    _yearController.dispose();
    _dayController.dispose();
    _newTrackController.dispose();
    _editTrackController.dispose();
    _tagController.dispose();
    _isFormValidNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadAlbumAndRelations() async {
    final id = widget.albumId!;
    final album = await _albumProv.getAlbumById(id);
    if (album == null) {
      // If album missing, pop back
      if (mounted) Navigator.of(context).pop();
      return;
    }
    _album = album;
    // Load tags and tracks via providers (tags must be loaded for immediate edits)
    await _tagProv.loadTagsForAlbum(id);
    await _trackProv.loadTracksForAlbum(id);

    // Populate local track list from provider (these will be persisted only when Save is pressed)
    final providerTracks = context.read<TrackProvider>().tracks;
    _localTracks = providerTracks.map((t) => t.title).toList();

    _populateControllersFromAlbum();
    if (mounted) setState(() {});
  }

  void _populateControllersFromAlbum() {
    if (_album == null) return;
    _titleController.text = _album!.title;
    _artistController.text = _album!.artist;
    _sortArtistController.text = _album!.sortArtist ?? '';
    _wikiController.text = _album!.wikiUrl ?? '';
    if (_album!.releaseYear != null) {
      _yearController.text = _album!.releaseYear.toString();
    } else {
      _yearController.text = '';
    }
    _monthSelected = _album!.releaseMonth ?? 0;
    if (_album!.releaseDay != null) {
      _dayController.text = _album!.releaseDay.toString();
    } else {
      _dayController.text = '';
    }
  }

  // Header text per requirement
  String get _headerText {
    if (_isNew) return 'Add Album';
    if (!_isEditMode) return 'Album Details';
    return 'Edit Album';
  }

  // Confirm button label per requirement
  String get _confirmButtonLabel {
    if (_isNew && _isEditMode) return 'Add';
    if (!_isEditMode) return 'Edit';
    return 'Save';
  }

  // Left cancel button widget per requirement
  Widget _buildLeadingButton() {
    if (_isEditMode) {
      if (_isNew) {
        // left arrow (navigate back)
        return IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        );
      } else {
        // view was in view mode and is now in edit mode -> show "Cancel" text button
        return TextButton(
          style: TextButton.styleFrom(
            minimumSize: const Size(100, 40),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),          
          onPressed: _onCancelEdit,
          child: const Text('Cancel'),
        );
      }
    } else {
      // view mode -> left arrow to navigate back
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () async {
          if (_dirtyTags) await _albumProv.fetchAllAlbums(); // Reload album model (with tags) if tags changed
          if (mounted) Navigator.of(context).pop();
        }
      );
    }
  }

  // Confirm button widget
  Widget _buildConfirmButton() {

    /*
    return TextButton(
      onPressed: enabled ? _onConfirmPressed : null,
      style: style,
      child: Text(_confirmButtonLabel),
    );*/

    return ValueListenableBuilder<bool>(
      valueListenable: _isFormValidNotifier, 
      builder: (context, isValid, child) {
        final enabled = !_isEditMode || _isFormValid(); //isValid; //_isFormValid();
/*        final style = TextButton.styleFrom(
          foregroundColor: enabled ? Theme.of(context).appBarTheme.titleTextStyle?.color : Colors.grey,
        );*/
        return TextButton(
          onPressed: enabled /*!_isEditMode || isValid */? _onConfirmPressed : null,
          //style: style,
          child: Text(_confirmButtonLabel),
        );
      }
    );
  }

  // Form validation per specification (title & artist required; year numeric <10000; day valid wrt month/year rules)
  bool _isFormValid() {
    final titleOk = _titleController.text.trim().isNotEmpty;
    final artistOk = _artistController.text.trim().isNotEmpty;

    // Year validation
    if (_yearController.text.trim().isEmpty) {
      // If month selected or day present but year empty -> invalid
      if (_monthSelected != 0) return false;
      if (_dayController.text.trim().isNotEmpty) return false;
    } else {
      final year = int.tryParse(_yearController.text.trim());
      if (year == null || year < 0 || year >= 10000) return false;
      // If month present but invalid? month value already constrained
      if (_dayController.text.trim().isNotEmpty) {
        final day = int.tryParse(_dayController.text.trim());
        if (day == null || day < 1 || day > 31) return false;
        // Validate day for selected month/year basic check (not perfect for Feb leap years)
        if (_monthSelected == 0) {
          return false;
        } else {
          final monthDays = <int>[
            0,
            31, // Jan
            28, // Feb (not checking leap to keep logic simple)
            31,
            30,
            31,
            30,
            31,
            31,
            30,
            31,
            30,
            31
          ];
          if (day > monthDays[_monthSelected]) return false;
        }
      }
    }

    // Title & artist must be present
    return titleOk && artistOk;
  }

  void _onCancelEdit() {
    if (_isNew) {
      Navigator.of(context).pop();
      return;
    }
    // Revert edits (reload original album data)
    _isEditMode = false;
    _pickedImageFile = null;
    _editingTrackIndex = null;
    _loadAlbumAndRelations();
  }

  Future<void> _onConfirmPressed() async {
    if (!_isEditMode) {
      // Switch into edit mode
      setState(() {
        _isEditMode = true;
        _editingTrackIndex = null;
      });
      return;
    }

    // Save / Add flow
    final isAdding = _isNew;
    await _saveAlbum(); // persist album metadata, images, and tracks

    if (isAdding) {
      // after adding, return to main screen
      if (mounted) Navigator.of(context).pop();
    } else {
      // return to view mode
      setState(() {
        _isEditMode = false;
        _pickedImageFile = null;
      });
      // reload album & providers
      if (_album != null) {
        await _albumProv.fetchAllAlbums(); // refresh main list
        await _tagProv.loadTagsForAlbum(_album!.id);
        await _trackProv.loadTracksForAlbum(_album!.id);
        final reloaded = await _albumProv.getAlbumById(_album!.id);
        _album = reloaded;
      }
      if (mounted) setState(() {});
    }
  }

  // Display Add Tag dialog per spec (centered). On OK: persist tag immediately.
  Future<void> _showAddTagDialog() async {
    _tagController.clear();
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 600
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Add Tag', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildTagAutocomplete(),
                  const SizedBox(height: 12),
                  Row(
                    //crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final text = _tagController.text;
                            if (text.trim().isEmpty) {
                              Navigator.of(ctx).pop();
                              return;
                            }

                            // Per spec: case-sensitive duplicate check
                            final existing = _isNew ? _newAlbumTags : _tagProv.tags;
                            final alreadyExists = existing.any((t) => t.tag == text);
                            if (!alreadyExists) {
                              if (_isNew) {
                                final tag = Tag(id: null, albumId: _album!.id, tag: text);
                                _newAlbumTags.add(tag); // persist later on Save/Add
                              } else {
                                final tag = Tag(id: null, albumId: _album!.id, tag: text);
                                await _tagProv.addTag(tag); // persists immediately
                                _dirtyTags = true;
                              }
                            }
                            Navigator.of(ctx).pop();
                            if (mounted) setState(() {});
                          },
                          child: const Text('OK'),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        );
      },
    );
  }

  // Remove a tag immediately (persisted)
  Future<void> _removeTag(Tag tag) async {
    if (tag.id == null) return;
    await _tagProv.deleteTag(tag.id!);
    _dirtyTags = true;
    if (mounted) setState(() {});
  }

  // Pick image (camera/gallery) and cache as _pickedImageFile (not persisted until Save)
  Future<void> _onPickImage({bool fromCamera = false}) async {
    final file = await ImageUtils.pickImage(fromCamera: fromCamera);
    if (file == null) return; // canceled
    setState(() {
      _pickedImageFile = file;
    });
  }

  Future<void> _onDeleteImage() async {
    if (_pickedImageFile != null) {
      setState(() {
        _pickedImageFile = null;
      });
    }
    else if (_album != null && _album!.coverImagePath != null) {
      if (mounted) {
        setState(() {
          _deletedImage = true;
        });
      }
    }
  }

  // Save album metadata + images + tracks
  Future<void> _saveAlbum() async {
    if (_album == null) return;
    // Build updated album object from inputs
    final newTitle = _titleController.text.trim();
    final newArtist = _artistController.text.trim();
    final newSortArtist = _sortArtistController.text.trim().isEmpty ? null : _sortArtistController.text.trim();
    final newWiki = _wikiController.text.trim().isEmpty ? null : _wikiController.text.trim();
    final newYear = _yearController.text.trim().isEmpty ? null : int.tryParse(_yearController.text.trim());
    final newMonth = _monthSelected == 0 ? null : _monthSelected;
    final newDay = _dayController.text.trim().isEmpty ? null : int.tryParse(_dayController.text.trim());

    String? coverPath = _album!.coverImagePath;
    String? thumbPath = _album!.coverThumbnailPath;

    // If user picked a new image, persist it now (delete previous if present)
    if (_pickedImageFile != null) {
      // delete old files if exist
      if (coverPath != null) await ImageUtils.deleteImage(coverPath);
      if (thumbPath != null) await ImageUtils.deleteImage(thumbPath);

      coverPath = await ImageUtils.saveImage(_pickedImageFile!, filename: '${_album!.id}_cover.jpg');
      thumbPath = await ImageUtils.generateThumbnail(_pickedImageFile!, filename: '${_album!.id}_thumb.jpg');
    }
    else if (_pickedImageFile == null && _deletedImage) {
      // User deleted existing image
      if (coverPath != null) await ImageUtils.deleteImage(coverPath);
      if (thumbPath != null) await ImageUtils.deleteImage(thumbPath);

      coverPath = null;
      thumbPath = null;
    }

    // Build album object to persist
    final updatedAlbum = Album(
      id: _album!.id,
      title: newTitle,
      artist: newArtist,
      sortArtist: newSortArtist,
      releaseYear: newYear,
      releaseMonth: newMonth,
      releaseDay: newDay,
      wikiUrl: newWiki,
      coverImagePath: coverPath,
      coverThumbnailPath: thumbPath,
      tracks: _localTracks.map((t) => Track(id: null, albumId: _album!.id, title: t)).toList(),
      tags: _tagProv.tags,
    );

    if (_isNew) {
      // Now add tags - do this and tracks before adding album so that they are present when album is loaded
      for (final tag in _newAlbumTags) {
        await _tagProv.addTag(tag);
      }

      // Add current local tracks
      for (final tTitle in _localTracks) {
        final newTrack = Track(id: null, albumId: _album!.id, title: tTitle);
        await _trackProv.addTrack(newTrack);
      }

      // Add new album
      await _albumProv.addAlbum(updatedAlbum);
    } else {
      // Persist album row
      await _albumProv.updateAlbum(updatedAlbum);

      // Persist tracks: delete previous tracks then insert current local tracks
      // First, load existing tracks (they have IDs)
      await _trackProv.loadTracksForAlbum(_album!.id);
      final existing = List<Track>.from(_trackProv.tracks);
      for (final t in existing) {
        if (t.id != null) {
          await _trackProv.deleteTrack(t.id!);
        }
      }
      // Insert current local tracks
      for (final tTitle in _localTracks) {
        final newTrack = Track(id: null, albumId: _album!.id, title: tTitle);
        await _trackProv.addTrack(newTrack);
      }
    }

    // Reset local state
    _pickedImageFile = null;
    _deletedImage = false;
    if (mounted) setState(() {});
  }

  // Track list helpers (local only until Save)
  void _onAddTrack() {
    final text = _newTrackController.text.trim();
    if (text.isEmpty) return;
    if (text.length > 255) return; // per spec
    setState(() {
      _localTracks.add(text);
      _newTrackController.clear();
    });
  }

  void _onEditTrackStart(int index) {
    setState(() {
      _editingTrackIndex = index;
      _editTrackController.text = _localTracks[index];
    });
  }

  void _onCommitTrackEdit() {
    if (_editingTrackIndex == null) return;
    final text = _editTrackController.text.trim();
    if (text.isEmpty || text.length > 255) return;
    setState(() {
      _localTracks[_editingTrackIndex!] = text;
      _editingTrackIndex = null;
      _editTrackController.clear();
    });
  }

  void _onMoveTrackUp(int index) {
    if (index <= 0) return;
    setState(() {
      final tmp = _localTracks[index - 1];
      _localTracks[index - 1] = _localTracks[index];
      _localTracks[index] = tmp;
    });
  }

  void _onMoveTrackDown(int index) {
    if (index >= _localTracks.length - 1) return;
    setState(() {
      final tmp = _localTracks[index + 1];
      _localTracks[index + 1] = _localTracks[index];
      _localTracks[index] = tmp;
    });
  }

  void _onDeleteTrack(int index) {
    setState(() {
      _localTracks.removeAt(index);
    });
  }

  Widget _buildAlbumImageSection(BuildContext context) {
    final media = MediaQuery.of(context);
    final sectionHeight = (media.size.height / 3).clamp(0, 400).toDouble();
    final squareSize = sectionHeight;

    final imageWidget = _pickedImageFile != null
        ? Image.file(File(_pickedImageFile!.path), fit: BoxFit.cover, width: squareSize, height: squareSize)
        : (_album?.coverImagePath != null && !_deletedImage
            ? ImageUtils.loadImageWidget(_album!.coverImagePath, width: squareSize, height: squareSize)
            : Container(
                width: squareSize,
                height: squareSize,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [Color(0xFF8e8e8e), Color(0xFFe0e0e0)],
                  ),
                ),
              ));

    return Container(
      width: double.infinity,
      height: sectionHeight,
      color: Colors.grey[350],
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(width: squareSize, height: squareSize, child: imageWidget),
            if (_isEditMode)
              Positioned(
                child: FloatingActionButton(
                  heroTag: 'photoButton',
                  backgroundColor: Colors.white,
                  mini: true,
                  onPressed: () async {
                    // choose camera or gallery — show simple bottom sheet
                    final choice = await showModalBottomSheet<String>(
                      context: context,
                      builder: (ctx) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('Choose from gallery'),
                              onTap: () => Navigator.of(ctx).pop('gallery'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text('Take photo'),
                              onTap: () => Navigator.of(ctx).pop('camera'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.close),
                              title: const Text('Cancel'),
                              onTap: () => Navigator.of(ctx).pop(null),
                            ),
                          ],
                        ),
                      ),
                    );

                    if (choice == 'gallery') {
                      await _onPickImage(fromCamera: false);
                    } else if (choice == 'camera') {
                      await _onPickImage(fromCamera: true);
                    }
                  },
                  child: const Icon(Icons.camera_alt, color: Colors.grey),
                ),
              ),
            if (_isEditMode && (_pickedImageFile != null || (_album != null && _album!.coverImagePath != null)))
              // Top-right delete button
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.close, color: Colors.white, size: 18),
                    onPressed: _onDeleteImage,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailField(String label, Widget child, {EdgeInsetsGeometry? padding}) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

    Widget _buildArtistAutocomplete() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue val) {
        if (val.text.isEmpty) return const Iterable.empty();
        final lower = val.text.toLowerCase();
        return _distinctArtists
            .where((a) => a.toLowerCase().contains(lower))
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      },
      onSelected: (selection) => _artistController.text = selection,
      fieldViewBuilder: (ctx, ctrl, focus, onSubmit) {
        ctrl.text = _artistController.text;
        ctrl.selection = _artistController.selection;
        ctrl.addListener(() {
          _artistController.text = ctrl.text;
          _artistController.selection = ctrl.selection;
        });
        return TextField(
          controller: ctrl,
          focusNode: focus,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          textCapitalization: TextCapitalization.words,
          maxLength: 255,
        );
      },
    );
  }
  Widget _buildSortArtistAutocomplete() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue val) {
        if (val.text.isEmpty) return const Iterable.empty();
        final lower = val.text.toLowerCase();
        return _distinctSortArtists
            .where((a) => a.toLowerCase().contains(lower))
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      },
      onSelected: (selection) => _sortArtistController.text = selection,
      fieldViewBuilder: (ctx, ctrl, focus, onSubmit) {
        ctrl.text = _sortArtistController.text;
        ctrl.selection = _sortArtistController.selection;
        ctrl.addListener(() {
          _sortArtistController.text = ctrl.text;
          _sortArtistController.selection = ctrl.selection;
        });
        return TextField(
          controller: ctrl,
          focusNode: focus,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          textCapitalization: TextCapitalization.words,
          maxLength: 255,
        );
      },
    );
  }
  Widget _buildTagAutocomplete() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue val) {
        if (val.text.isEmpty) return const Iterable.empty();
        final lower = val.text.toLowerCase();
        return _distinctTags
            .where((a) => a.toLowerCase().contains(lower))
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      },
      onSelected: (selection) => _tagController.text = selection,
      fieldViewBuilder: (ctx, ctrl, focus, onSubmit) {
        ctrl.text = _tagController.text;
        ctrl.selection = _tagController.selection;
        ctrl.addListener(() {
          _tagController.text = ctrl.text;
          _tagController.selection = ctrl.selection;
        });
        return TextField(
          controller: ctrl,
          focusNode: focus,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          maxLength: 255,
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final tags = _isNew ? _newAlbumTags : context.watch<TagProvider>().tags;

    return Scaffold(
      appBar: AppBar(
        title: Text(_headerText),
        centerTitle: true,
        leadingWidth: !_isNew && _isEditMode ? 100 : 50,
        leading: _buildLeadingButton(),
        actions: [
          _buildConfirmButton(),
        ],
      ),
      body: _album == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Album image section
                _buildAlbumImageSection(context),

                // Rest scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Album details: Album name, Artist, Release Date, Sort Artist, Wikipedia Page
                        _buildDetailField(
                          'Album name *',
                          _isEditMode
                              ? TextField(controller: _titleController, textCapitalization: TextCapitalization.words, maxLength: 255)
                              : Text(_album!.title.isNotEmpty ? _album!.title : '-', style: Theme.of(context).textTheme.bodyLarge),
                        ),
                        _buildDetailField(
                          'Artist *',
                          _isEditMode
                              ?  _buildArtistAutocomplete() //TextField(controller: _artistController, maxLength: 255)
                              : Text(_album!.artist.isNotEmpty ? _album!.artist : '-', style: Theme.of(context).textTheme.bodyLarge),
                        ),
                        _buildDetailField(
                          'Release Date',
                          _isEditMode ? _buildReleaseDateInputs() : Text(_formatReleaseDate(), style: Theme.of(context).textTheme.bodyLarge),
                        ),
                        _buildDetailField(
                          'Sort Artist',
                          _isEditMode
                              ? _buildSortArtistAutocomplete() //TextField(controller: _sortArtistController, maxLength: 255)
                              : Text(_album!.sortArtist ?? '-', style: Theme.of(context).textTheme.bodyLarge),
                        ),
                        _buildDetailField(
                          'Album Wikipedia Page',
                          _isEditMode
                              ? TextField(controller: _wikiController, maxLength: 255)
                              : //Text(_album!.wikiUrl ?? '-', style: Theme.of(context).textTheme.bodyLarge),
                              (_album!.wikiUrl != null && (_album!.wikiUrl?.indexOf('http://') == 0 || _album!.wikiUrl?.indexOf('https://') == 0)) ?
                                InkWell(
                                  onTap: () async {
                                    final uri = Uri.parse(_album!.wikiUrl ?? '-');
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                                    }
                                  },
                                  child: Text(
                                    _album!.wikiUrl ?? '-',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                )
                              :
                                (_album!.wikiUrl != null && _album!.wikiUrl!.isNotEmpty) ? Text (
                                    _album!.wikiUrl ?? '-',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      decoration: TextDecoration.underline,
                                    ),
                                ) : Text('-'),
                        ),

                        // Track Listing
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Track Listing', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              ListView.builder(
                                itemCount: _localTracks.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, i) {
                                  final trackName = _localTracks[i];
                                  final numbering = '${i + 1}. ';
                                  if (_isEditMode && _editingTrackIndex == i) {
                                    // editing single track shows text field and a check icon
                                    return Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _editTrackController,
                                            decoration: const InputDecoration(hintText: 'Edit track'),
                                            textCapitalization: TextCapitalization.words,
                                            maxLength: 255,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.check),
                                          onPressed: _onCommitTrackEdit,
                                        )
                                      ],
                                    );
                                  }

                                  return Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                                          child: Text('$numbering$trackName', style: Theme.of(context).textTheme.bodyLarge),
                                        ),
                                      ),
                                      if (_isEditMode && _editingTrackIndex == null) ...[
                                        IconButton(
                                          icon: const Icon(Icons.arrow_upward),
                                          onPressed: i == 0 ? null : () => _onMoveTrackUp(i),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.arrow_downward),
                                          onPressed: i == _localTracks.length - 1 ? null : () => _onMoveTrackDown(i),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => _onEditTrackStart(i),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () => _onDeleteTrack(i),
                                        ),
                                      ],
                                    ],
                                  );
                                },
                              ),

                              // Empty text field at bottom with plus icon
                              if (_isEditMode)
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _newTrackController,
                                        decoration: const InputDecoration(hintText: 'Add new track'),
                                        textCapitalization: TextCapitalization.words,
                                        maxLength: 255,
                                        onSubmitted: (_) => _onAddTrack(),
                                        enabled: _editingTrackIndex == null
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: _editingTrackIndex == null ?_onAddTrack : null,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),

                        // Tags (no heading)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              // existing tags
                              for (final tag in tags)
                                GestureDetector(
                                  onTap: () {
                                    // maybe open context menu in the future
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(tag.tag, style: const TextStyle(color: Colors.white)),
                                        const SizedBox(width: 6),
                                        GestureDetector(
                                          onTap: () async {
                                            // remove tag immediately
                                            if (_isNew) {
                                              _newAlbumTags.remove(tag);
                                              if (mounted) setState(() {});
                                            } else {
                                              await _removeTag(tag);
                                            }
                                          },
                                          child: const Icon(Icons.close, size: 16, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              // Add Tag button
                              GestureDetector(
                                onTap: _showAddTagDialog,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text('Add Tag', style: TextStyle(color: Colors.white)),
                                      SizedBox(width: 6),
                                      Icon(Icons.add, size: 16, color: Colors.white),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildReleaseDateInputs() {
    return Row(
      children: [
        // Year numeric
        Expanded(
          flex: 3,
          child: TextField(
            controller: _yearController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Year'),
            maxLength: 4,
          ),
        ),
        const SizedBox(width: 8),
        // Month dropdown
        Expanded(
          flex: 4,
          child: DropdownButtonFormField<int>(
            initialValue: _monthSelected,
            items: [
              const DropdownMenuItem(value: 0, child: Text('')),
              const DropdownMenuItem(value: 1, child: Text('January')),
              const DropdownMenuItem(value: 2, child: Text('February')),
              const DropdownMenuItem(value: 3, child: Text('March')),
              const DropdownMenuItem(value: 4, child: Text('April')),
              const DropdownMenuItem(value: 5, child: Text('May')),
              const DropdownMenuItem(value: 6, child: Text('June')),
              const DropdownMenuItem(value: 7, child: Text('July')),
              const DropdownMenuItem(value: 8, child: Text('August')),
              const DropdownMenuItem(value: 9, child: Text('September')),
              const DropdownMenuItem(value: 10, child: Text('October')),
              const DropdownMenuItem(value: 11, child: Text('November')),
              const DropdownMenuItem(value: 12, child: Text('December')),
            ],
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                _monthSelected = v;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        // Day numeric
        Expanded(
          flex: 2,
          child: TextField(
            controller: _dayController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Day'),
            maxLength: 2,
          ),
        ),
      ],
    );
  }

  String _formatReleaseDate() {
    if (_album == null) return '';
    final y = _album!.releaseYear;
    final m = _album!.releaseMonth;
    final d = _album!.releaseDay;

    if (y == null) return '-';
    if (m == null) return '$y';
    if (d == null) return '$y-${_monthName(m)}';
    return '$y-${_monthName(m)}-$d';
  }

  String _monthName(int m) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    if (m < 1 || m > 12) return '';
    return months[m];
  }
}
