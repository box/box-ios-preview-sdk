Getting Started
===============

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Installing the SDK](#installing-the-sdk)
- [Getting Started](#getting-started)
- [Sample App Config](#sample-app-config)
- [Using the Sample App](#using-the-sample-app)
- [Open a PDF File](#open-a-pdf-file)
- [Open an Image File](#open-an-image-file)
- [Future Enhancements](#future-enhancements)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

Installing the SDK
------------------

__Step 1__: Add to your `Cartfile`
```ogdl
binary "https://github.com/box/box-ios-preview-sdk/releases/download/v3.0.0-alpha.1/boxPreviewSDK.json"
```

__Step 2__: Update dependencies
```shell
$ carthage update --platform iOS
```

__Step 3__: Drag the built framework from Carthage/Build/iOS into your project.

For more detailed instructions, please see the [official documentation for Carthage](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos).

Getting Started
---------------

To get started with the SDK, you'll need the Client ID and Client Secret of your app in the [Box Developer Console][dev-console].
If you're familar with [Getting Started with the OAuth2 Sample App in the Box Content SDK](https://github.com/box/box-ios-sdk/docs/usage/getting-started.md#oauth2-sample-app)
you'll find the process very similar. 

[dev-console]: https://app.box.com/developers/console

Sample App Config
-----------------

The Box Preview SDK Sample App can be found in the
[BoxPreviewSDKSampleApp](../../tree/limited-beta-release/BoxPreviewSDKSampleApp) folder.  This app demonstrates how to use the
Box Preview SDK to make calls with OAuth2 Authentication, and can be run directly by entering your own credentials to log in.

To execute the sample app:
__Step 1__: Run carthage
```shell
$ cd BoxPreviewSDKSampleApp
$ carthage update --platform iOS
```

__Step 2__: Open Workspace
```shell
$ open BoxPreviewSDKSampleApp.xcworkspace
```

__Step 3__: Insert your client ID and client secret

First, find your OAuth2 app's client ID and secret from the [Box Developer Console][dev-console].  Then, add these
values to the sample app in [Constants.swift](../../tree/limited-beta-release/BoxPreviewSDKSampleApp/Constants.swift):
```swift
static let clientId = "YOUR CLIENT ID GOES HERE"
static let clientSecret = "YOUR CLIENT SECRET GOES HERE"
```

__Step 4__: Set redirect URL

Using the same client ID from the previous step, set the redirect URL for your application in the [Box Developer Console][dev-console] to
`boxsdk-<<YOUR CLIENT ID>>://boxsdkoauth2redirect`, where `<<YOUR CLIENT ID>>` is replaced with your client ID.  For example, if your client
ID were `vvxff7v61xi7gqveejo8jh9d2z9xhox5` the redirect URL should be
`boxsdk-vvxff7v61xi7gqveejo8jh9d2z9xhox5://boxsdkoauth2redirect`

__Step 5__: Insert your client ID to receive the redirect in the app

Open the [Info.plist](../../tree/limited-beta-release/BoxPreviewSDKSampleApp/Resources/Info.plist) file and find the key here:
URL Types --> Item 0 --> URL Schemes --> Item 0
Using the same client ID from the previous step, set the value for Item 0 to
`boxsdk-<<YOUR CLIENT ID>>`, where `<<YOUR CLIENT ID>>` is replaced with your client ID.  For example, if your client
ID were `vvxff7v61xi7gqveejo8jh9d2z9xhox5` the redirect URL should be
`boxsdk-vvxff7v61xi7gqveejo8jh9d2z9xhox5`

![Info.plist setting](https://raw.githubusercontent.com/box/box-ios-preview-sdk/limited-beta-release/URL%20Schemes%20in%20Info.plist.png)

__Step 6__: Run the sample app

Using the Sample App
--------------------
The app opens with a prompt to begin OAuth2.0 Authentication.  Tap "OAuth2.0 Authentication" to proceed.

On the next screen, tap "Login".

An iOS System Dialog pops up asking if you agree to open a URL to authenticate.  Tap "Continue" to proceed.

A Box login page loads.  Enter your credentials and tap "Authorize" to proceed.

A confirmation screen displays the name of your application, as defined in the [Box Developer Console][dev-console], along with the scopes it is configured with.  
Tap "Grant access to Box" to grant your application access to the Box account.

The next screen displays all the files in the root folder for the account.  If you don't see any files on the screen, check that you have files saved in the root folder of the Box account.
Note that for simplicity, folders are not displayed in this sample app.
From this screen you can tap the back arrow to log out, or tap a file name in the list to download it and display it.  
PDF, JPG, JPEG, PNG files are currently supported.


Open a PDF File
---------------

Tap a PDF file in the file list.  A progress bar indicates the download progress as the file is retrieved from Box.  When the progress reaches 100%, the document is displayed.

The toolbar at the top contains an arrow to go back to the file list, the file name, the current page number, an outline view button (if the document contains an outline) and a gallery view button.  The toolbar can be toggled by tapping the document.

The outline view allows you to view the hierarchical structure of the document and offers quick navigation to a particular page.

The gallery view shows large thumbnails of each page and offers quick navigation to a particular page.

The document supports left and right swiping gestures to navigate one page at a time, pinch-to-zoom gestures and panning.

For PDF files containing multiple pages, the thumbnail navigation bar at the bottom of the screen allows for quick navigation through the entire document.


Open an Image File
------------------
Tap an image file (JPG, JPEG, PNG files are currently supported) in the file list.  A progress bar indicates the download progress as the file is retrieved from Box.  When the progress reaches 100%, the image is displayed.

The toolbar at the top contains an arrow to go back to the file list and the file name.  The toolbar can be toggled by tapping the image.

The image supports pinch-to-zoom gestures and panning.


Future Enhancements
-------------------

You can expect to see the following enhancements in future updates of the Box Preview SDK Sample App:
- Support for more file types
- Search
  - Search Results navigator
  - Search Results highlighting in document
  - Search history
- Local file caching
- Open multiple images at once
  - Load all images in thumbnail navigation bar at the bottom of the screen
  - Support for left and right swiping gestures to navigate from one image to the next
- Start app on last-viewed file
- And more!
