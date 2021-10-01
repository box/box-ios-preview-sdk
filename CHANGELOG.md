Changelog
=========

## v3.3.0 [2021-10-01]

__Breaking Changes:__

__New Features and Enhancements:__

- Add the ability to have `mailto`, `tel`, etc. links open in the appropriate apps ([#93](https://github.com/box/box-ios-preview-sdk/pull/93))

__Bug Fixes:__

- Fix bug with Alerts and Share Sheets on the iPad ([#92](https://github.com/box/box-ios-preview-sdk/pull/92))
- Fix bug where invalid links in a PDF crash the app when clicked ([#93](https://github.com/box/box-ios-preview-sdk/pull/93))
- Upgrade dependencies ([#98](https://github.com/box/box-ios-preview-sdk/pull/98))
- Rename default branch from master to main ([#101](https://github.com/box/box-ios-preview-sdk/pull/101))


## v3.2.0 [2020-02-13]

__Breaking Changes:__

__New Features and Enhancements:__

- Add audio and video previewing

## v3.1.0 [2020-01-10]

__Breaking Changes:__

__New Features and Enhancements:__

- Show file download progress before a file previews
- Added log out button for OAuth2 sample app 

__Bug Fixes:__

- Back button for search results exits out of search view, allowing the user to view the file instead of exiting to the table view for the folder items
- Constant zoom level instead of a variable zoom level on PDFs when a user double taps
- Full screen mode now toggles on PDFs when a user single taps

## v3.0.0 [2019-11-18]

__Breaking Changes:__


__New Features and Enhancements:__

- Added file specific icons in the Sample Apps
- Now displays folders in the Sample Apps


## v3.0.0-rc.3 [2019-11-14]

__Breaking Changes:__


__New Features and Enhancements:__

- Update Sample Apps to use new PagingIterator responses 


## v3.0.0-rc.2 [2019-10-30]

__Breaking Changes:__

- Changed SDK errors from customValue enum cases to specific enum cases


__New Features and Enhancements:__

- Added Xcode 11 + iOS 13 support to Travis CI


## v3.0.0-rc.1 [2019-10-18]

__Breaking Changes:__

- Temporarily removed progress closure for uploads and downloads


__New Features and Enhancements:__

- Added Xcode 11 support (SDK builds still target iOS 11.0)
- Added new Error View for displaying errors
- Added ability to open multiple image files at once with navigation
- Added search for PDF files
- Added search results navigation
- Added search string history
- Added support of all iOS-supported image file extensions
- Improved structure and usability of Sample Apps


## v3.0.0-alpha.3 [2019-08-29]

__Breaking Changes:__


__New Features and Enhancements:__

- Added Print / Save / Share functionality for PDFs and images
- Added a JWT Sample Application
- Added search for PDFs
- Added search history for PDFs
- Added search results navigation for PDFs
- Added logout feature to OAuth2 Sample App
- Added support for custom Error Views


## v3.0.0-alpha.2 [2019-08-08]

__Breaking Changes:__


__New Features and Enhancements:__

- Fixed bug with double tap zoom
- Fixed bug with swipe left/right page navigation
- Fixed bug with Full Screen mode for images
- Disabled PDF Thumbnail Navigation for single-page PDF files


## v3.0.0-alpha.1 [2019-07-25]

Initial beta release :tada:
