# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

### [3.3.1](https://github.com/box/box-ios-preview-sdk/compare/v3.3.0...v3.3.1) (2022-06-21)


## [3.3.0](https://github.com/box/box-ios-preview-sdk/compare/v3.2.0...v3.3.0) (2021-10-29)


### New Features and Enhancements

- Add the ability to have `mailto`, `tel`, etc. links open in the appropriate apps ([#93](https://github.com/box/box-ios-preview-sdk/pull/93))

### Bug Fixes

- Fix bug with Alerts and Share Sheets on the iPad ([#92](https://github.com/box/box-ios-preview-sdk/pull/92))
- Fix bug where invalid links in a PDF crash the app when clicked ([#93](https://github.com/box/box-ios-preview-sdk/pull/93))
- Upgrade dependencies ([#98](https://github.com/box/box-ios-preview-sdk/pull/98))
- Rename default branch from master to main ([#101](https://github.com/box/box-ios-preview-sdk/pull/101))

## [3.2.0](https://github.com/box/box-ios-preview-sdk/compare/v3.1.0...v3.2.0)  (2020-02-13)


### New Features and Enhancements

- Add audio and video previewing

## [3.1.0](https://github.com/box/box-ios-preview-sdk/compare/v3.0.0...v3.1.0)  (2020-01-10)


### New Features and Enhancements

- Show file download progress before a file previews
- Added log out button for OAuth2 sample app 

### Bug Fixes

- Back button for search results exits out of search view, allowing the user to view the file instead of exiting to the table view for the folder items
- Constant zoom level instead of a variable zoom level on PDFs when a user double taps
- Full screen mode now toggles on PDFs when a user single taps

## [3.0.0](https://github.com/box/box-ios-preview-sdk/compare/v3.0.0-rc.3...v3.0.0)  (2019-11-18)


### New Features and Enhancements

- Added file specific icons in the Sample Apps
- Now displays folders in the Sample Apps

## [3.0.0-rc.3](https://github.com/box/box-ios-preview-sdk/compare/v3.0.0-rc.2...v3.0.0-rc.3)  (2019-11-14)


### New Features and Enhancements

- Update Sample Apps to use new PagingIterator responses 

## [3.0.0-rc.2](https://github.com/box/box-ios-preview-sdk/compare/v3.0.0-rc.1...v3.0.0-rc.2)  (2019-10-30)


### ⚠ BREAKING CHANGES

- Changed SDK errors from customValue enum cases to specific enum cases

### New Features and Enhancements

- Added Xcode 11 + iOS 13 support to Travis CI

## [3.0.0-rc.1](https://github.com/box/box-ios-preview-sdk/compare/v3.0.0-alpha.3...v3.0.0-rc.1)  (2019-10-18)


### ⚠ BREAKING CHANGES

- Temporarily removed progress closure for uploads and downloads

### New Features and Enhancements

- Added Xcode 11 support (SDK builds still target iOS 11.0)
- Added new Error View for displaying errors
- Added ability to open multiple image files at once with navigation
- Added search for PDF files
- Added search results navigation
- Added search string history
- Added support of all iOS-supported image file extensions
- Improved structure and usability of Sample Apps

## [3.0.0-alpha.3](https://github.com/box/box-ios-preview-sdk/compare/v3.0.0-alpha.2...v3.0.0-alpha.3)  (2019-08-29)


### New Features and Enhancements

- Added Print / Save / Share functionality for PDFs and images
- Added a JWT Sample Application
- Added search for PDFs
- Added search history for PDFs
- Added search results navigation for PDFs
- Added logout feature to OAuth2 Sample App
- Added support for custom Error Views

## [3.0.0-alpha.2](https://github.com/box/box-ios-preview-sdk/compare/v3.0.0-alpha.1...v3.0.0-alpha.2)  (2019-08-08)


### New Features and Enhancements

- Fixed bug with double tap zoom
- Fixed bug with swipe left/right page navigation
- Fixed bug with Full Screen mode for images
- Disabled PDF Thumbnail Navigation for single-page PDF files

## [3.0.0-alpha.1] (2019-07-25)


Initial beta release :tada:
