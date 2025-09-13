# 1. Objective

## 1.1 App Purpose

This app will be used to store and maintain a list of vinyl records. Records will be able to be added and removed, edited, sorted, searched and tagged. The list of records in the app is designed to be filtered to make searching this list easy.

## 1.2 App Technologies

### 1.2.1 Platform

This app is designed to be run on multiple platforms, but its target is touchscreen and mobile devices. Therefore, it is also is intended to integrate with its device's camera and storage capabilities (in addition to its touch and display capabilities).

### 1.2.2 Framework

As the app is intended for multiple platforms, it will utilize a cross-platform mobile development framework. This app will utilize Flutter, and consequently be written in Dart.

# 2. User Interface

## 2.1 General Layout

### 2.1.1 Views

The app will have a total of 2 views. Upon initial entry of the app, the app will start on the main screen view. The other view will be album details view.

### 2.1.2 Main Screen View

This is the screen a user will interact with to:
1.	View the list of albums
2.	Add albums to the list
3.	Remove albums from the list
4.	Select an album to view its details
5.	Search/filter the list
6.	Adjust the filter criteria
7.	Adjust the sort criteria

This view is the view the app will initially load.

### 2.1.2 Album Details View

A user enters this screen for two reasons
1.	To add an album to the list
2.	To view or edit an album already on the list

This view contains an album's information. The information presented on this page about each album is:
1.	A photograph of the album
2.	The album title
3.	The album artist
4.	The sorting album artist
5.	The year (and optionally month and day) of release
6.	An optional link to the album's Wikipedia page
7.	A list of all of the tracks on the album
8.	A list of user generated tags

When entering this view to add an album, all of this information will be blank. When entering this view to view an album details, all of this information will be filled in with whatever information was entered upon the initial addition of this album, or what has most recently been updated.

This view will have two modes:
1.	View mode
2.	Edit mode

In view mode, all of the text-based information is simply visible as line of text each (with a header for each piece of information). In edit mode, each line of information becomes a editable text field input, with the same header as in view mode. The album cover picture can only be changed in edit mode. In both modes, tags can be added or removed. When adding a record, the album details view will always be in edit mode. When viewing record details, the album information view always starts in view mode, but can enter and exit edit mode if the user decides to edit an album's details.

## 2.2 View Layouts

### 2.2.1 Main Screen View Layout

#### 2.2.1.1 Title Banner

- A banner will appear across the top of the main screen view
- The banner will contain the name of the app. The name of the app is "Record Keeper." The name of the app will appear without quotes surrounding it.
- The width of the banner will be 100% of the width of the device's viewport
- The height of the banner will be the line height of "large" sized text, plus 10 pixels of padding on the top and bottom.
- The name of the app will be centered horizontally and vertically within the banner
- The font size of the app name will be "large" sized font
- The font color and banner background color will match the look and feel of the platform
- The background color of the banner must not be the same light gray as the background of the list, so it can be distinguished
- In the case that a default look and feel for the platform is not defined, the banner background will be HTML color code #4798F6 and the font color will be white

#### 2.2.1.2 Search Bar

- A panel devoted to the search bar will appear near the top of the main screen view immediately underneath and adjacent to the Title Banner
- The width of this panel will be 100% of the width of the device's viewport
- The height of this panel will 1.5 times the line height of the font used
- Within the search bar panel will be a search bar widget
- The search bar widget will have the placeholder text "Search" (not displayed in quotes) when no search criteria are entered
- The search bar widget will be left justified within the search panel
- To the right of the search bar will be two icon buttons:
  1.	The Search Settings Button
  2.	The Sort Settings Button
- The Search Settings Button will be displayed as an icon using the Filter symbol as an icon
- The Sort Settings Button will be displayed as an icon using the Sort symbol as an icon
- Tapping on the search settings button will reveal the search settings popup widget
- Tapping on the sort settings button will reveal the sort settings popup widget
- The search panel will have its widgets tightly packed, so the width of the search bar widget will be the full width of the panel minus the width of the search settings icon button and the sort settings icon button, also leaving room for standard look and feel padding between widgets

#### 2.2.1.3 Album List

- The list of albums will take up the remainder of the area of the device viewport
- The list will be full of list item elements, where each element represents one single album
- The list item elements will be sorted according to the currently selected sort settings
- The list item elements will show all albums in the list, unless the currently active filter limits them
- The background of this list will be a light gray as specified in the device's look and feel for default background
- In the case that a default look and feel is not defined, the background color will be HTML color code #eeeeee

#### 2.2.1.4 Album List Item

- Each list item will contain 4 elements:
  1.	The album cover thumbnail photo, which will always be a square aspect ratio
  2.	The album title
  3.	The album artist and year of release
  4.	A list of tags the user has entered for that album
- The height of each list item will be 3 times the line height of "normal" sized font
- For each list item, the album cover will be the leftmost element of the list item, and will always display as a square aspect ratio
- If no album cover is specified for that album, then the image displayed will be a square with a solid filled diagonal gradient going from medium gray (HTML color code #8e8e8e) to light gray (HTML color code #e0e0e0) from the bottom left corner to the top right corner.
- To the right of the album cover thumbnail image will be 3 lines of text, all left aligned (to the right side of the album thumbnail image, with default widget padding between)
- The first line of text contains the album's title, in black
- The second line of text contains the album's artist, and if a release year is specified, then it will be followed by a hyphen with spaces on either side, followed by the album's year of release
- The third line of text contains a list of tags as they have been entered by the user
- The tags will appear in the order in which they were entered
- Each individual tag will be surrounded by a rounded rectangle background enclosing the text of that tag
- The color of the tag background will be the same as the app banner background color
- The color of the tag text will be the same as the app banner text color
- If the combined rendered width of all the tags (with their backgrounds and appropriate margin between each) exceeds the remaining width of the list item (after the album image thumbnail photo), then only the first several tags that fully fit within that width are to be shown
- All tags will appear in a horizontal line, each subsequent tag to the right of the previous tag
- Tapping on a list item will navigate the user to the album details view for that album
- Since this list is scrollable, a scroll bar will be intermittently visible on against the right edge of this list view, as per the default widget behavior
- If sorting alphabetically by artist or album, the list will use sticky headers to indicate the beginning letter of the artist or album that is currently within the top of the list's visible viewport
- If sorting chronologically by year, the list will use sticky headers to indicate the year of the album that is currently within the top of the list's viewport
- The sticky headers will be the full width of the list, the line height of "normal" text, and will have black text display either the letter or year (per the requirements above) left justified within the header, with a left-margin 2 times the line height of "normal" sized text, with a medium-to-light gray background

#### 2.2.1.5 Add Album Button

- The add album button will be a floating action button in the bottom right corner of the app
- The add album button will be floating over any list element if one is present at the bottom
- It will be circular
- It will display a + (plus) icon symbol
- The background of the button will match the background of the app title banner
- The color of the plus icon will be the font color of the app title text within the app banner
- Tapping on the add album button will navigate the user to a blank version of the album details view, that is, the album details view with none of the information filled out yet, in edit mode

#### 2.2.1.6 Search Settings Popup Widget

- When the search settings popup widget is revealed, it will be displayed as a popup bubble with the bubble point pointing to and adjacent to the search settings button on the search panel
- The popup will encase a text header and list of items, with a checkbox widget to the left of each text
- The text header at the top of the popup widget will say "Search within:" (without the quotes)
- The list of items within this popup widget are:
  1.	Artist
  2.	Album Name
  3.	Album Release Date
  4.	Album Tracks
  5.	Sort Artist
  6.	Tags
- By default, the checkbox widgets next to each list item are checked
- Tapping on any part of the device viewport outside of the popup widget causes the popup widget to hide and lose focus
- If any selections on this widget have been modified, and after the popup widget hides, then the list of records must update immediately afterward, reflecting the new filter criteria

#### 2.2.1.7 Sort Settings Popup Widget

- When the sort settings popup widget is revealed, it will be displayed as a popup bubble with the bubble point pointing to and adjacent to the sort settings button on the search panel
- The popup will encase a text header and a list of items, with a checkbox widget to the left of each text
- The text header at the top of the popup widget will say "Sort by:" (without the quotes)
- The list of items within this popup widget are:
  1.	By artist, then release year (default)
  2.	By artist, then alphabetically
  3.	By album alphabetically
  4.	By release year
  5.	Randomly
- By default, only the checkbox widget for the first item is checked
- This list has radio button behavior, so only one item's checkbox widget can be checked at a time
- Tapping on any part of the device viewport outside of the popup widget causes the opus widget to hide and lose focus
- If a different item is selected upon hiding of the widget than upon revealing, then the list of records must update immediately afterward, reflecting the new sort criteria

### 2.2.2 Album Details View Layout

- The album details view will consist of the following sections:
  1.	Header
  2.	Album Image
  3.	Album Details
  4.	Track Listing
  5.	Tags
- The header will be stationary
- All other sections will together have the ability to scroll vertically if their height exceeds the remaining height of the device viewport after the header

#### 2.2.2.1 Header

- The visual details of the header, including placement, size, colors, and font, will be based on the Title Banner detailed in Section 2.2.1.1.
- Instead of the app name as the text, the text will state the following based on the application state:
  1.	If coming to the view from the Add Album button, the text will say "Add Album" (without the quotes)
  2.	If coming to the view from having tapped on a record in the list on the Main Screen View, the text will say "Album Details" (without the quotes)
  3.	If the view was in view mode and is now in edit mode, the text will say "Edit Album" (without the quotes)
- Floating on the left side of the header will be a button which will be identified as the cancelButton
- Depending on the application state, the cancelButton will be:
  1.	A left arrow if coming to the view from the Add Album button
  2.	A left arrow if coming to the view from having tapped on a record in the list on the Main Screen View, and it is in view mode
  3.	The word "Cancel" (without quotes) if the view was in view mode and is now in edit mode
- Floating on the right side of the header will be a button which will be identified as the confirmButton
- Depending on the application state, the confirmButton will say:
  1.	"Add" (without quotes) if coming to the view from the Add Album button
  2.	"Edit" (without quotes) if coming to the view from having tapped on a record in the list on the Main Screen View, and it is in view mode
  3.	"Save" (without quotes) if the view was in view mode and is now in edit mode
- In edit mode, the text color the confirmButton button will match the text color of the Header text if the button is enabled
- In edit mode, the text color of the confirmButton button will be medium gray if the button is disabled

#### 2.2.2.2 Album Image

- Immediately underneath and adjacent to the Header will be the Album Image section of the Album Details View
- The width of the Album Image section will be 100% of the width of the device viewport
- The height of the Album Image section will be the smaller of the following two:
  1.	400 pixels
  2.	One third of the height of the device viewport
- A square that contains the album image will be horizontally centered within the Album Image section
- Both the height and width of the album image square will be 100% of the height of the Album Image section
- The spaces on the left and right side of the Album Image section will be filled with a solid medium gray color
- If the currently selected album has an image, it will be displayed in the album image square, and will take up the entire area, stretching to fit the square
- If the currently selected album does not have an image, it will be a square with a solid filled diagonal gradient going from medium gray (HTML color code #8e8e8e) to light gray (HTML color code #e0e0e0) from the bottom left corner to the top right corner.
- If and only if the view is in edit mode, a photo button, identified as the photoButton, which will be a camera icon in all white with a gray shadow, surrounded by a circle, will appear in the very center of the album image square as a floating action button

#### 2.2.2.3 Album Details

- Following the album image section will be the album details section
- This section has the following album labelled text fields:
  1.	Album name
  2.	Artist
  3.	Release Date
  4.	Sort Artist
  5.	Album Wikipedia Page
- The Release Date will be separated into three fields, all adjacent and occupying the same line:
  1.	Year
  2.	Month
  3.	Day
- The release date label will also be in small text, but not attached to an individual field, rather, instead it will appear on the line above the labels for each of the release date component fields
- In view mode, all of these fields will appear as written text, with a label in smaller text above the field toward the left of the field
- In edit mode, each of the fields (except the month field) will appear as a text input field with their values either blank if not yet entered or filled in with the previously entered corresponding value, or whatever the user has modified the value to be
- In edit mode, the Year field of the Release Date will be a numeric text field that only accepts whole numbers (values 0 - 9)
- In edit mode, the Month field will be a dropdown select with the following options:
  1.	January
  2.	February
  3.	March
  4.	April
  5.	May
  6.	June
  7.	July
  8.	August
  9.	September
  10.	October
  11.	November
  12.	December
- In edit mode, the day field will be a numeric text field that only accepts whole numbers (values 0 - 9)
- In both view and edit mode, for all text fields (which include Album name, Artist, Sort Artist, and Album Wikipedia Page), all text beyond the width of each field will be word wrapped
- The width of each text field will be 100% of the device's viewport width, minus any padding built into the widget's default formatting
- When in this view in edit mode, the Album Name and Artist field will have an asterisk (*) following their labels

#### 2.2.2.4 Track Listing

- Immediately beneath the labelled text fields in the Album Details section will be a header with the text: Track Listing
- Beneath the Track Listing header will be a numbered list of all the album tracks
- If no tracks have been entered for the album, no tracks will be listed
- All text in this numbered list will word wrap if their text is longer than the device viewport width
- If and only if the view is in edit mode:
  - several icons will appear in a row justified, aligned to the right side of the device viewport, with standard icon padding:
    1. An up icon
    2. A down icon
    3. An edit icon
    4. A trash can icon
  - The appearence of the icons in edit mode will shrink the width available for track names to be displayed, in which case the track names rendered wider than this width will be word wrapped
  - Clicking the edit icon to the right of any track transforms that line from displayed text to an text input field, and also makes the icons momentarily disappear to instead be replaced by a single check icon, also right justified, which when pressed saves the edit, transforms the text input field back to displayed text, and has the original icons reappear right justified
  - An empty text field is always at the bottom, with a plus icon right justified and vertically aligned to the field
  - The width of the empty text field is the viewport's width, minus standard padding, also minus the width of the plus icon with its standard padding

#### 2.2.2.5 Tags

- The tag section vertically follows the Track Listing section underneath, and has no heading
- Each individual tag that has been entered for the album will be surrounded by a rounded rectangle background enclosing the text of that tag, and within that rounded rectangle background will be an x icon (the close icon) always to the left of the text
- The color of the tag background will be the same as the app banner background color
- The color of the tag text will be the same as the app banner text color
- If any tags have been entered, the first tag will appear left-justified immediately underneath the Track Listing section, and each subsequent tag will appear to the right of the previous tag, and will wrap back around to the next line as their placement exceeds the width of the device viewport
- After the very last tag (or in place of where the first tag would be if no tags have been entered yet) will be a button that will be formatted the exact same as the rest of the tags and will have the text "Add Tag" (without the quotes) and will have a plus (+) icon to the right of the text, within the rounded rectangle

#### 2.2.2.6 Add Tag Dialog

- The add tag dialog will be invisible by default, but will display upon clicking the Add Tag button
- When the dialog is visible, it will be displayed in the horizonal and vertical center of the viewport, laying over top of the Album Details View
- The add tag dialog will have the following elements:
  1.	Header: Add Tag
  2.	Text Field Input
  3.	OK button
  4.	Cancel button
- The OK button and Cancel button will be vertically aligned, underneath the Text Field Input

## 2.3 State Transitions

### 2.3.1 Splash Screen

- Upon initial app load, the splash screen is displayed
- From the splash screen, the only screen it can transition to is the Main Screen View
- From the Main Screen View the following transitions apply:
  1. When tapping the Add Album button, to the Album Details View in edit mode
  2. When tapping on an album, to the Album Details View in view mode
  3. When selecting Edit Album from a left swipe gesture on an album list item or by doing a full left swipe on an album list item, to the Album Details view in edit mode
- From the Album Details View, the following transitions apply:
  - When in view mode:
    1. When tapping the left arrow button in the header, to the Main Screen View
    2. When tapping the "Edit" button in the header, to the Album Details View in edit mode
  - When in edit mode:
    1. When tapping the Cancel button in the header, to the Album Details View in view mode
    2. When tapping the "Save" button in the header, to the Album Details View in view mode
    3. When tapping the "Add" button in the header, to the Main Screen View

## 2.4 Splash Screen

- Upon initial app load, a Splash Screen will be displayed
- The splash screen will be displayed for a minimum of 500 milliseconds
- The splash screen must stay displayed until all elements of the main screen have loaded
- The splash screen will display an image, identified by the identifier splashScreenImage that will be specified outside of this document

# 3. Functional and Logic Specifications

## 3.1 Loading the album data

- Upon initial app load, the list of albums and all of its data must be retrieved from device storage
- This load must occur while the splash screen is displayed, before the Main Screen View can render the album list

## 3.2 Main Screen View Sorting

- The Main Screen View has 5 different sort modes:
  1.	By artist, then release year (default)
  2.	By artist, then alphabetically
  3.	By album alphabetically
  4.	By release year
  5.  Randomly
- By default, option 1 (by artist, then release year) is selected
- This selection is changed through the Sort Settings Popup Widget
- Each time the selection is changed, the album list in Main Screen view updates to reflect the new order of list items, and the list is scrolled to the very top
- Each time the selection is changed, this change is persisted on device storage
- Each time the app loads from the start, the sort order must be loaded from device storage
- The sorting algorithms are detailed in the following sections
- Each reference to sorting alphabetically implies being sorted alphabetically, case insensitive, with numbers preceeding letters, according to each character's character code
- All sorting assumes ascending order

### 3.2.1 By artist, then release year (default)

- Each list item will be ordered by:
  1.	The Sort Artist, alphabetically
  2.	If there is no Sort Artist specified, then by the Artist alphabetically
  3.	Then by Release Date, chronologically
    - If no date is specified, assume the date is 31 December 9999
    - If only the Year is specified, assume the Month is January and the Day is 1
    - If the Year and Month are specified, assume the Day is 1
  4.	For all albums where the Sort Artist or Artist and Release Date are the same, then sort by Album title, alphabetically

### 3.2.2 By artist, then alphabetically

- Each list item will be ordered by
  1.	The Sort Artist, alphabetically
  2.	If there is no Sort Artist specified, then by the Artist alphabetically
  3.	Then by Album title, alphabetically

### 3.2.3 By album alphabetically

- Each list item will be ordered by
  1.	Album title, alphabetically
  2.	Then by Sort Artist, alphabetically, or Artist, alphabetically if no sort artist is specified
  3.	Then by Release Date, chronologically
    - If no date is specified, assume the date is 31 December 9999
    - If only the Year is specified, assume the Month is January and the Day is 1
    - If the Year and Month are specified, assume the Day is 1

### 3.2.4 By release year

- Each list item will be ordered by
  1.	Release Date, chronologically
    - If no date is specified, assume the date is 31 December 9999
    - If only the Year is specified, assume the Month is January and the Day is 1
    - If the Year and Month are specified, assume the Day is 1
  2.	Then by Sort Artist, alphabetically, or Artist, alphabetically if no sort artist is specified
  3.	Then by Album title, alphabetically

### 3.2.5 Randomly

- Each list item will be in a completely random order
- The randomness of the album list is generated when the sorting mode switches to randomly
- No sticky headers are present in this mode

## 3.3 Main Screen View Filtering

- As each character is entered in the Search Bar, the list of Albums in the Main Screen View will update to reflect the new filter criteria
- For the text entered in the Search Bar, it will be broken apart into separate search terms by spaces
- Any words enclosed by quotes will be treated as a single search term, removing the quotes in the search term
- A quote may be present in a search term if it is escaped with a backslash prior to the quote, for example \\"
- A backslash my be present in a search term if it escaped with a backslash prior to the backslash, for example \\\\
- The list of albums shown will only be albums that contain any of the search terms (except terms that have a minus (-) or a plus (+) as their first character) entered in the Search Bar in any of their:
  1.	Artist, if Artist selected in the Search Settings Popup Widget
  2.	Album Name, if Album Name is selected in the Search Settings Popup Widget
  3.	Album Release Date, if Album Release Date is selected in the Search Settings Popup Widget
  4.	Album Tracks, if Album Tracks is selected in the Search Settings Popup Widget
  5.	Sort Artist, if Sort Artist is selected in the Search Settings Popup Widget
  6.	Tags, if Tags is selected in the Search Settings Popup Widget
- Search terms that begin with a minus (-) are search terms where this text must not appear in the places to be searched as specified by the Search Settings Popup Widget, that is, this is a way to exclude results from the search
- Each search term that begins with a plus (+) must be present in the places to be searched as specified by the Search Settings Popup Widget

## 3.4 Search Settings Popup Widget

- Each time one of the checkboxes is checked or unchecked, the album list in the Main Screen View is updated based on the search terms entered in the Search Bar
- There must be at least one item checked
- Therefore if only one item is checked (and the rest are unchecked), and an attempt is made to uncheck the only checked item, that attempt will have no effect and the only checked item will remain checked

## 3.5 Sort Settings Popup Widget

- Each of the items in this widget behaves like a radio button, therefore exactly one item must be checked at a time

## 3.6 Album list

- The list may employ a lazy-loading scheme to prevent rendering of album information or images that are not displayed on-screen
- The list must have a scrollbar capability so the list can be scrolled to a specific scroll position if desired
- If the native behavior causes the scrollbar to disappear while the list's scroll position is constant, this is acceptable

## 3.7 Album list item gestures

- Swiping an album list item to the left will reveal options to the right side while moving the entire list item toward the left. In order from left to right, the options are:
  1.	Delete
  2.	Add Tag
  3.	Edit Album
- Because Edit Album is the last option in the list of options for a left swipe gesture, a full, continuous left swipe will automatically select the Edit Album gesture
- If the Delete option is selected, a confirmation dialog will appear in the horizontal and vertical center of the screen with the following details:
  1.	Header: Confirm
  2.	Text: Are you sure?
  3.	OK Button
  4.	Cancel Button
- On the delete confirmation dialog, selecting OK causes the dialog to disappear and also permanently removes the album from the album list
- On the delete confirmation dialog, selecting Cancel causes the dialog to disappear and the album list remains unchanged
- Selecting the Add Tag options causes the Add Tag dialog to appear in the Main Screen View, as detailed in Section 2.2.2.6
- On the Add tag dialog, selecting OK will attempt to add a tag to that album, based on the following:
  1.	If no text is entered in the text input field, then the dialog disappears with no effect
  2.	If text is entered, and a tag with that exact case sensitive text does not exist in that album's tag list, then a tag with that exact text is added to that album's list of tags
  3.	If text is entered, and a tag with that exact case sensitive text does exist in that album's tag list, then the dialog disappears with no effect
- On the Add tag dialog, selecting Cancel will make the dialog disappear
- Selecting the Edit Album option transitions the app to the album details page in edit mode for the specific album selected by the swipe gesture

## 3.8 Album image

- If the cameraButton is pressed, the system dialog appears to choose an existing photo or to take a new one
- Canceling from this system dialog leaves the Album Image unchanged
- Selecting an image from this system dialog updates the album image
- In the process of changing the album image, several things happen:
  1.	A 400x400 pixel version of the image created by scaling the image down so that the width of the image is 400 (if the height of the image is greater than the width) or the height of the image is 400 (if the height of the image is not greater than the width), and then the image is cropped so that only a square from the center the size 400x400 remains
  2.	A 100x100 thumbnail version of the image is created by scaling down the 400x400 version of the image
  3.	Both of these images are stored on device storage through the app, and if the "Save" or "Add" button in the header is pressed, paths to them are stored in the album's data

## 3.9 Album details input fields

- When on the Album Details View in edit mode, the fields that are required to have text entered are:
  1.	Album name
  2.	Artist
- For the fields that are required, they are only valid if the length of their trimmed text (that is, text with all leading and trailing space removed) is greater than 0
- In edit mode, the "Add" button in the header (if in the view from pressing the Add Album button from the Main Screen View) or "Save" button (if in the view from pressing the "Edit" button in the header) is only enabled if all fields pass validation, and disabled otherwise
- The Release Year field must only accept numeric input, and furthermore must be a whole, positive number, less than 10,000
- The Release Month field is a dropdown select, so it can only be one of 13 possible values, including blank which is an option
- The Release Day field must only accept numeric input, and is only valid if the combination of the Year, Month, and Day input field together produce a valid date
- The Month field is invalid if the Year field is blank and the Month field has a value other than blank
- The Day field is invalid if either the Year field or Month field is blank and the Day field is not blank
- The Album name, Artist, Sort Artist, Album Wikipedia Page, any Track Name under the Track Listing section, or any Tag field must not accept any more than 255 characters
- The Artist Name and Sort Artist name field will be autocomplete dropdown select fields, that is, as text is entered, a dropdown will appear underneath with a collective, case-insensitive, alphabetized list of all distinct Artists and Sort Artists from all albums that already exist in the list
- For the two autocomplete dropdown select fields, if an option is selected from the dropdown, that value becomes what is entered in that text field, and the dropdown select disappears
- Pressing Return/Enter on the keyboard causes any visible autocomplete dropdown to disappear
- Except for changes to tags, changes in the album data are only stored in the list and updated for that album if and only if the "Add" button in the header is pressed or "Save" button in the header is pressed
- Any changes in the album name, artist, release data, sort artist, album Wikipedia page, or Track Listing are disregarded if the left arrow button or Cancel button in the header is pressed
- For the track listing section in edit mode
  - Click the up icon aligned with a track moves advances it up to swap spaces with the previous track
  - Clicking the up icon on the very first track has no effect
  - Clicking the down icon aligned with a track moves it down to swap spaces with the following track
  - Clicking the down icon on the very last track has no effect
  - Clicking the edit icon puts that single track in edit mode, which causes all other icons on each track to disappear (including the selected track), replaces all icons with a single right justified check icon only on the selected track, causes the plus icon next to the empty text field at the bottom the track listing to disappear, and transforms the displayed text of that track to become a text input field filled with the contents of the track name
  - Clicking the check icon of a track in edit mode puts that track back to display mode, which causes the check icon of the selected track to disappear, causes all other icons on each track to reappear (including the selected track), causes the plus icon next to the empty text field at the bottom of the track listing to reappear, and transforms the entered text in the text input field back to displayed text, saving that text to the view's data model, but not necessarily persisting it on device storage
  - If and only if the text within the text input field at the bottom of the track listing is valid, then clicking the plus icon next to that text input field appends the entered text as a new track to the track listing, and clears the contents of the text field
  - The text within the text input field at the bottom of the track listing is valid if and only if the length of its trimmed text (that is, text with all leading and trailing spaces removed) is greater than zero and less than 256
- The numbering of the tracks in the track listing section is automatic, starting from one and counting up by one until the last track
- All changes to the tag list must immediately be persisted to device storage

# 4. Other Specification

## 4.1 Font

- The font will be the system default font

## 4.2 Software Engineering

- The source code for this file must be broken down into individual units for code maintenance and debug purposes
- At the minimum, there must be a separate code file for the Main Screen View and another one for the Album Details View

## 4.3 Image Storage

- Each time an album image is stored, both a "full size" and a "thumbnail size" version of the image must be stored, cropped to have a square aspect ratio.
- The "full size" image is scaled down from the original image to be 400 pixels by 400 pixels
- The "thumbnail size" image is scaled down from the original image to be 100 pixels by 100 pixels
- The "full size" image will always be what is displayed in the Album Details View
- The "thumbnail size" image will always be what is displayed in each list item for each album in the Main Screen View

## 4.4 Data Storage

- For all data that is persisted on device storage it must be stored in a format that allows records to be written, edited, deleted, recalled and queried
- There is not a hard constraint for the technology that must be employed to achieve this behavior, but examples would include a NoSQL document database or a SQLite database embedded within the program