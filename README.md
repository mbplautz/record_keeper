# Record Keeper — User Guide & Help

_(Markdown help file for the Record Keeper app — thorough, step-by-step)_

## Introduction

**Record Keeper** is a lightweight, no-nonsense vinyl record cataloging app.  
You can quickly add albums, attach cover photos, maintain track lists and tags, search and sort your collection in many flexible ways, export/import your collection, and save commonly used searches.

This guide explains the app UI, features, and how to use them on both mobile (iOS / Android) and desktop (macOS / Windows) builds. If you’re a developer or power user, the guide also contains troubleshooting tips and notes about permissions and platform differences.

## Table of Contents

1.  Main concepts
    
2.  Main Screen (Library)
    
    -   Title banner & header
        
    -   Search bar & search settings
        
    -   Sort settings
        
    -   Album list and album card
        
    -   Sticky headers
        
    -   Swipe actions (Slidable)
        
    -   Floating Add button
        
3.  Album Details view
    
    -   View vs Edit mode
        
    -   Fields and validation
        
    -   Cover image handling & crop
        
    -   Tracks: add, edit, reorder, delete
        
    -   Tags: add, remove
        
    -   Saving and canceling
        
4.  Saved Searches
    
    -   Save current search
        
    -   Load / Manage saved searches
        
    -   Default saved search
        
5.  Import / Export (Collection)
    
6.  Right-side Menu (slide-out)
    
7.  About & Welcome dialogs
    
8.  Showcase / Guided Tour
    
9.  Platform notes & permissions
    
10.  Troubleshooting and developer tips
    
11.  Appendix: quick keyboard & UI tips
    

## 1. Main concepts

-   **Album**: record entry with title, artist, optional `sortArtist`, optional release year/month/day (partial dates supported), optional wiki URL, optional cover image, tracks (ordered list), tags (free text labels).
    
-   **Tag**: small label attached to an album; used for quick filtering and as a visual cue.
    
-   **Track**: one string per track; stored/ordered per album.
    
-   **Saved search**: snapshot of a search query, which fields to search in, and the sort option.
    
-   **Tag summary**: (legacy) short text — in current app designs tagSummary was removed in favor of loading tags so they can be searched and rendered accurately.
    

All searches and sorts are **case-insensitive** unless otherwise noted.

## 2. Main Screen (Library)

### Title banner (top)

-   Always at the top. Displays app name **Record Keeper** centered horizontally and vertically.
    

### Search bar (below title banner)

-   Type any search query.
    
-   The search is parsed for:
    
    -   Quoted phrases `"like this"` — treated as a single term.
        
    -   `+term` — _must be present_ (AND).
        
    -   `-term` — _must NOT be present_ (NOT).
        
    -   Plain terms — treated as optional (OR across selected fields).
        
-   By default the search area (which fields are searched) is controlled by the **Search Settings** (see below). There must always be at least one active search field.
    

### Search Settings (button to right of search bar)

-   Opens a popup with checkboxes:
    
    -   Title, Artist, Sort Artist, Release Date, Tracks, Tags
        
-   At least one item must be checked (the UI prevents unchecking all).
    
-   When multiple boxes are checked a result matches if any checked field matches (terms are logically combined with the `+`/`-` semantics described above).
    
-   The Search Settings button sits to the right of the search bar, with the Sort Settings button next to it.
    

### Sort Settings (button)

-   Popup with radio options (only one may be active):
    
    1.  By artist, then release year (default on app open)
        
    2.  By artist, then alphabetically
        
    3.  By album alphabetically
        
    4.  By release date (constructed from year/month/day)
        
    5.  Randomly
        
-   Sorting uses logic in Section 3.2 of the spec (partial dates transform to full date for comparison: missing year → sentinel (9999-12-31), year-only → Jan 1, year+month → day 1).
    

### Album list and album card

-   Albums load first time from the local SQLite DB. After initial load, searching and sorting are done **in-memory** (fast for hundreds to low thousands of albums).
    
-   Each album card shows:
    
    -   Cover thumbnail (`coverThumbnailPath`) on the left
        
    -   Title, Artist, Year/Date, and rendered tags to the right
        
    -   Tags are rendered as rounded rectangles and truncated to a single line so only full tags that fit are shown (no half tags).
        
-   Tapping the album opens the **Album Details view** in view mode.
    
-   Add (+) FloatingActionButton opens Album Details in **edit mode** with all fields blank.
    

### Sticky headers

-   When sorting by artist/album/year: sticky letter(s) (or year for release date sort) appear as you scroll.
    
-   Each visible group shows one header at the top; the header updates as you scroll into a new group.
    

### Swipe actions (slidable)

-   Swipe an album card left to reveal actions:
    
    -   Default action (right-most) opens Album Details (same as tapping).
        
    -   Add Tag action opens Add Tag workflow.
        
    -   Delete prompts a confirmation dialog, then deletes the album if confirmed.
        
-   Full-swipe behavior is configurable; the last action can be treated as the “default” when swiped all the way, but implementation uses a non-destructive confirm for delete.
    

### Scrollbar

-   A native iOS-style scrollbar appears intermittently and is draggable. For grouped lists a ScrollController is attached so the scrollbar thumb is interactive.
    

## 3. Album Details view

Accessible by tapping an album (view mode) or pressing Add (edit mode, blank fields).

### View vs Edit mode

-   When opened from the main list, the view may be in **view mode** initially; pressing the right-side confirm button switches to **edit**.
    
-   When opened from the Add button, it starts **edit mode** with blank fields.
    
-   Confirm button behaves:
    
    -   In view mode: label "Edit", tapping switches to edit mode.
        
    -   In edit mode: "Save" or "Add" (for new albums) — saves data if form is valid.
        

### Required fields & validation

-   **Album name** and **Artist** are required.
    
-   Release date is validated: if month or day provided, year must be present. Day must be valid for the given month (basic validation; Feb leap year logic may be simplified).
    
-   Validation is live — as you edit these fields the Save/Add button enables/disables.
    

### Artist and Sort Artist autocomplete

-   Artist and Sort Artist fields use an Autocomplete that suggests distinct values from existing albums (case-insensitive substring matching). Suggestions are built from in-memory data for performance.
    

### Cover image handling

-   You may choose to pick from gallery or take a photo (mobile).
    
-   On mobile the image capture respects platform permissions (camera).
    
-   Image is saved to app documents/images folder; thumbnails are generated and saved.
    
-   On desktop, image cropping may be bypassed; cropping is enabled on mobile builds only.
    
-   In edit mode, if a cover is set, a small circular delete (X) is shown on the top-right corner of the cover — tap to remove the image.
    
-   A camera icon is shown (in center) to change the image.
    

### Tracks

-   Tracks are edited inline (local list until Save/Add).
    
-   Add new track via the bottom input field with a plus icon.
    
-   Edit a track: pressing Edit hides other edit/add controls until commit; editing uses a text field and check mark to commit.
    
-   You can reorder tracks up/down using arrows.
    
-   On Save the app persists tracks; on Cancel edits are discarded.
    

### Tags

-   Add Tag button shows centered dialog to add tags; tags are persisted immediately.
    
-   Tags are case-sensitive for duplicates (per spec).
    
-   Removing tags immediately deletes them from DB and re-computes any summary (if used).
    

### Save / Cancel

-   Save persists album row and associated tracks/tags and images.
    
-   On Save when editing an existing album, the UI reloads data to keep main list up to date.
    
-   Cancel reverts to previously persisted data (for editing existing album) or returns back for new album.
    

## 4. Saved Searches

Saved searches store:

-   `name` (text)
    
-   `is_default` (boolean)
    
-   `query` (text)
    
-   boolean flags for each search field (title, artist, sortArtist, releaseDate, tracks, tags)
    
-   `sort_option` (enum stored as integer)
    

### Use-cases

-   Save the current search criteria with a name, or overwrite an existing saved search.
    
-   Load saved search: opens dialog with list of saved searches, preview of the query, which fields are enabled, and sort mode.
    
-   Make a saved search default: the default search loads when the app starts (if configured).
    
-   When saving as a new search, the UI prevents duplicate names; when overwriting, the selected saved search is updated.
    

### UI dialogs

-   **Save Search dialog**: choose "save as new" (enter name) or "overwrite existing" (pick existing). OK button only enabled when the chosen option is valid.
    
-   **Load Saved Search dialog**: shows list of saved searches (selectable), query preview, search fields grid, sort description, and action buttons (Make Default, Reset Default, Delete, Select). Delete is confirmed with another dialog.
    

## 5. Import / Export collection

### Export

-   Exports the SQLite database file and all image files (images directory) into a ZIP archive.
    
-   A version manifest file may be included.
    
-   Export presses show a modal spinner while processing; heavy work is run in a background isolate using `compute()` so the spinner actually animates and UI stays responsive.
    
-   Once the ZIP is ready, platform sharing is used:
    
    -   iOS / Android: share sheet (SharePlus) lets you save to Files, send via Messages, etc.
        
    -   macOS / Windows: show standard file chooser/save dialog to pick destination.
        

### Import

-   Use a file picker (platform file chooser) to select an exported ZIP.
    
-   Import merges data: IDs must be reassigned to avoid collisions (especially when album IDs are string UUIDs or microsecond timestamps). The import code re-maps IDs and also renames image files to match new ids.
    
-   Import skips `is_default` for saved searches — imported saved searches are inserted with `is_default=false` to prevent overriding local defaults.
    
-   Import warns about or resolves duplicate saved-search names by appending `(1)`, `(2)`, … like Chrome file duplicates.
    

## 6. Right-side Menu (slide-out)

-   A menu icon in the header opens a slide-out panel from the right covering half the screen (or a set max width).
    
-   Header says **Menu**, contents are an accordion with categories:
    
    -   **My collection**: Export collection, Import collection, Delete collection (with confirm + "I am sure" checkbox), and non-interactive info rows: `xxx albums total`, `xxx albums listed`.
        
    -   **Saved searches**: Save current search, Manage saved searches.
        
    -   **Special actions**: Add tag to list, Remove tag from list, Remove albums in list.
        
    -   **About**: navigates to About page (not expandable).
        
-   The menu is implemented as a widget that accepts callbacks for each actionable item so the `MainScreenView` can wire actual behaviors.
    

Animation note: the menu is an `AnimatedPositioned` panel; expand/collapse animations for submenus use `AnimatedSize` or `AnimatedCrossFade`. Some care is taken to avoid layout-time mutations causing AnimatedSize exceptions.

## 7. About & Welcome dialogs

### About page

-   Header: **About**
    
-   Square splash image from `assets/images/splash-screen.png`
    
-   Text lines:
    
    -   _Written by Michael Plautz_
        
    -   _Version 1.0.0_
        
    -   _Distributed by Bryan Ratledge_ (only on iOS/macOS)
        
    -   _Record Keeper is an Open Source app written using Dart and Flutter_ — with `Dart` and `Flutter` hyperlinked to their sites.
        
-   Below, 3 list items with icon + hyperlink texts (GitHub repo, Dart, Flutter).
    

### Welcome dialog

-   Shows once by default on first run (controlled by `SharedPreferences` boolean `showWelcome`, default `true`).
    
-   Header: **Welcome**
    
-   Body: friendly explanatory text and a checkbox `Show Welcome Dialog on Startup`.
    
-   Buttons: `Begin Tour` (triggers showcase/tour) and `Close`.
    
-   Dialog persists the checkbox value into `SharedPreferences` on close.
    

## 8. Showcase / Guided Tour

-   App uses the `showcaseview` package (current API uses `ShowcaseView.register()` and `ShowcaseView.get().startShowCase([...])`).
    
-   Wrapping top-level or root widgets with `ShowcaseView.register()` is recommended; it has minimal overhead when not in use.
    
-   Tour highlights elements (search bar, add button, menu icon, album card, etc.) with overlay and explanatory text.
    
-   The Welcome dialog “Begin Tour” calls `ShowcaseView.get().startShowCase([...])`.
    

## 9. Platform notes & permissions

### iOS

-   **Camera**: add `NSCameraUsageDescription` to `ios/Runner/Info.plist`. Without it, app will crash when attempting to access the camera.
    
-   **Files / Documents**: for macOS packaging, you may need entitlements for `com.apple.security.files.user-selected.read-write` to allow file pickers (in `DebugProfile.entitlements` and `Release.entitlements`).
    

### Android

-   Declare camera and storage permissions as needed in `AndroidManifest.xml`. Modern Android uses runtime permissions for camera.
    

### Desktop (macOS/Windows)

-   Image cropping plugin may not provide desktop implementations — cropping can be bypassed on desktop to avoid `MissingPluginException`.
    
-   For file pickers on macOS ensure entitlements & sandboxing are configured if the app is sandboxed.
    

### Files & persistence

-   Images saved under app documents directory (e.g. `documents/images/`); database saved via `sqflite` in the app directory.
    
-   When saving image file paths in DB, prefer **relative paths** (relative to the app documents dir) to avoid differences across sessions or when app root changes.
    

## 10. Troubleshooting & developer tips

-   **Spinner never shows?** If the UI blocks while zipping, ensure heavy work runs after giving Flutter a frame (`await Future.delayed(Duration.zero)`) or offload with `compute()`/isolates.
    
-   **MissingPluginException (cropImage)** on desktop: plugin not implemented for that platform — either guard calls by platform or skip cropping on desktop.
    
-   **Scrollbar says “no position attached”**: ensure the Scrollbar receives the same controller as the ScrollView. For grouped lists you may need a package-specific controller (e.g. `GroupedItemScrollController`), or wrap with a Scrollbar that takes the same controller.
    
-   **Showcase deprecated API**: use `ShowcaseView.register()` / `ShowcaseView.get().startShowCase()`.
    
-   **Dialog layout errors** like `RenderViewport does not support returning intrinsic dimensions` or `LayoutBuilder does not support returning intrinsic dimensions`:
    
    -   Avoid returning widgets that require intrinsic size measurement from inside LayoutBuilder.
        
    -   Use fixed or constrained heights for ListView/GridView inside dialogs; put scrollable content inside a `Flexible` or `Expanded` so the dialog can layout deterministically.
        
-   **SQLite ID types**: be consistent — if album IDs are TEXT (string UUIDs), keep them that way. If `db.insert()` returns `int` (rowid), that is only when you create INTEGER PRIMARY KEY that auto-increments. If using custom string IDs, insert them explicitly before inserting rows.
    
-   **Use relative image paths** when saving to DB to avoid stale absolute paths across device reboots or sandbox changes.
    
-   **Focus & keyboard behavior**: call `FocusScope.of(context).unfocus()` when opening dialogs or when taps outside text fields occur. For better behavior, also remove focus on dialog close via `await` and `if (mounted) FocusScope.of(context).unfocus();`.
    
-   **Autocomplete highlighting issue**: avoid resetting controller selection unnecessarily inside `fieldViewBuilder`. Use a controller for the Autocomplete that mirrors the backing controller only when needed and avoid calling `setState()` from text listeners during build (use microtask/debounce).
    

## 11. Appendix & Quick Tips

-   **Add new album**: press the floating Add (+) button → Album Details appears in edit mode with blank fields → fill `Title` & `Artist` (required) → optionally cover image, release date, tracks, tags → press **Add**.
    
-   **Edit existing album**: tap an album → press **Edit** (top-right) → make changes → press **Save**.
    
-   **Search examples**:
    
    -   `beatles` — finds records in any selected fields
        
    -   `+beatles -remastered "white album"` — results MUST include `beatles`, MUST NOT include `remastered`, and must contain phrase `white album`.
        
-   **Export**: Menu → My collection → Export collection. Select destination via share sheet (mobile) or save dialog (desktop). Long exports use background isolate, spinner shows while processing.
    
-   **Import**: Menu → My collection → Import collection → pick zip file. Conflicting IDs will be remapped; images renamed appropriately.
    
-   **Saved searches**:
    
    -   Save current search via the menu.
        
    -   Make a saved search default to apply at app start.
        
    -   Overwriting vs Save as new is supported.
        

## Closing notes

Thank you for using Record Keeper! The app was built to be simple and fast for personal cataloging. If you run into issues or want enhancements (batch editing, cloud sync, full text track search performance tuning, etc.), note them down — several extension points exist (repository interfaces, providers, services).