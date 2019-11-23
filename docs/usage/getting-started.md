# BoxPreviewSDK

[![Platforms](https://img.shields.io/cocoapods/p/BoxPreviewSDK.svg)](https://cocoapods.org/pods/BoxPreviewSDK)
[![License](https://img.shields.io/cocoapods/l/BoxPreviewSDK.svg)](https://raw.githubusercontent.com/box/BoxPreviewSDK/master/LICENSE)

[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods compatible](https://img.shields.io/cocoapods/v/BoxPreviewSDK.svg)](https://cocoapods.org/pods/BoxPreviewSDK)

[![Build Status](https://travis-ci.com/box/box-swift-preview-sdk.svg?token=4tREKKzQDqwgYX8vMDUk&branch=master)](https://travis-ci.com/box/box-swift-preview-sdk)

This SDK makes it easy to present Box files in your iOS application.

- [Requirements](#requirements)
- [Installing the SDK](#installing-the-sdk)
  - [Carthage](#carthage)
  - [CocoaPods](#cocoapods)
  - [Swift Package Manager](#swift-package-manager)
- [Getting Started](#getting-started)
- [Sample App Config](#sample-app-config)
- [Using the Sample App](#using-the-sample-app)
- [Open a PDF File](#open-a-pdf-file)
- [Open an Image File](#open-an-image-file)
- [Future Enhancements](#future-enhancements)
- [Release Definitions](#release-definitions)
- [Copyright and License](#copyright-and-license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

Requirements
------------------

- iOS 11.0+
- Xcode 10.0+

Installing the SDK
------------------

### Carthage

__Step 1__: Add to your `Cartfile`

```ogdl
git "https://github.com/box/box-ios-sdk.git" ~> 3.0
git "https://github.com/box/box-ios-preview-sdk.git" ~> 3.0
```

__Step 2__: Update dependencies

```shell
$ carthage update --platform iOS
```

__Step 3__: The framework in the Carthage/Build/iOS folder is already referenced in the BoxPreviewSDKSampleApp Xcode project.

For more detailed instructions, please see the [official documentation for Carthage](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos).

### CocoaPods

__Step 1__: Add to your `Podfile`

```
pod 'BoxPreviewSDK', '~> 3.0'
```

__Step 2__: Install pod by running the following command in the directory with the `Podfile`

```
$ pod install
```

For more detailed instructions, please see the [official document for Cocoapods](https://guides.cocoapods.org/using/using-cocoapods.html).

### Swift Package Manager

#### Importing BoxPreviewSDK into Project

__Step 1__: Click on Xcode project file

__Step 2__: Click on Swift Packages and click on the plus to add a package

__Step 3__: Enter the following repository url `https://github.com/box/box-ios-preview-sdk.git` and click next

__Step 4__: Leave the default settings to get the most recent release and click next to finish importing

The process should look like below:

![Import Package](import-sdk-spm.gif)



#### Adding BoxPreviewSDK as a Dependency

For detailed instructions, please see the [official document for SPM](https://swift.org/package-manager/). 

Getting Started
---------------

To get started with the SDK, you'll need the Client ID and Client Secret of your app in the [Box Developer Console][dev-console].
If you're familar with [Getting Started with the OAuth2 Sample App in the Box Content SDK](https://github.com/box/box-ios-sdk/docs/usage/getting-started.md#oauth2-sample-app)
you'll find the process very similar.

[dev-console]: https://app.box.com/developers/console

Sample App Config
-----------------

A sample app using OAuth2 Authentication can be found in the repository [here][oauth2-sample-app].  This app demonstrates how to use the
Box Preview SDK to make calls with OAuth2 Authentication, and can be run directly by entering your own credentials to
log in.

[oauth2-sample-app]: https://github.com/box/box-ios-preview-sdk/tree/limited-beta-release/SampleApps/OAuth2SampleApp

To execute the sample app:

__Step 1__: Run carthage

```shell
$ cd BoxPreviewSDKSampleApp
$ carthage update --platform iOS
```

__Step 2__: Open Xcode Project File

```shell
$ open OAuth2SampleApp.xcodeproj
```

__Step 3__: Insert your client ID and client secret

First, find your OAuth2 app's client ID and secret from the [Box Developer Console][dev-console].  Then, add these
values to the sample app in `Constants.swift` file:

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

Open the `Info.plist` file in the sample app and find the key here:
URL Types --> Item 0 --> URL Schemes --> Item 0
Using the same client ID from the previous step, set the value for Item 0 to
`boxsdk-<<YOUR CLIENT ID>>`, where `<<YOUR CLIENT ID>>` is replaced with your client ID.  For example, if your client
ID were `vvxff7v61xi7gqveejo8jh9d2z9xhox5` the redirect URL should be
`boxsdk-vvxff7v61xi7gqveejo8jh9d2z9xhox5`

![Info.plist setting](redirect-url-scheme.png)

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
PDF and all iOS-supported image files are currently supported in the app.


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

The Preview SDK supports opening multiple images at once, but this is currently not exposed in the sample app.  Feel free to play around with this functionality on your own, by calling `BoxPreviewSDK.openImageFiles(fileIds:selectedId:delegate:allowedAction:displayThumbnails)`

  - Loads all images in thumbnail navigation bar at the bottom of the screen
  - Supports left and right swiping gestures to navigate from one image to the next
  - Gallery view


Future Enhancements
-------------------

You can expect to see the following enhancements in future updates of the Box Preview SDK:

- Support for more file types
- Local file caching
- Start app on last-viewed file
- And more!


## Release Definitions

Starting Oct 19th, 2019 the Box Swift SDK for iOS will be available for general use. This implies all Box developers will be able to use the SDK to build native iOS applications on Box. Between now and the next couple of months, we will be making frequent updates to the SDK based on feedback from our customers, and this document aims to set expectations with respect to:

1. the various release types you will see over the next few months, what they mean and how to identify them
1. support policy for each of the release types

Between now and the next couple of months, the Box Swift SDK for iOS releases will be one of the following types:

- [Release Candidate (RC)](#release-candidate-rc)
- [Current Release](#current-release)
- [Long Term Support](#long-term-support)

### Release Candidate (RC)

The initial releases of the SDK starting Oct 19th will be Release Candidate (RC). This means (1) the core functionality is present and tested, (2) additional functionality from this point on will be considered improvements or enhancements based on customer feedback. RC releases are usually more frequent (every few weeks), followed shortly by a current release. If you plan to use an RC release, we recommend:

- that you don't use it for production workloads (If that is unavoidable, we recommend upgrading to the Current Release version once it's ready.)
- that you create a plan to keep your application on the latest RC release version at all times (since older RC releases are considered "out of support" as soon as a new RC release is released)

Also, RC releases may carry breaking changes from the previous release and we advise developers to test their application adequately with the new RC release before adopting it.

The idea behind releasing RC releases is to rapidly iterate on the SDK (bug fixes, feature tweaks, etc.) to get it to a production-ready state, and typically we don't expect to have the SDK in the RC phase for more than a month.

> #### Support for RC releases
>
> A RC release
>
> - is Considered [Active](#active) when released
> - transitions to [End-of-life](#end-of-life) when the next release becomes Active


### Current Release

A Current Release is considered more stable that a Release Candidate Release and for that reason we expect less frequent releases of a Current Release. We typically expect to refresh Current Releases approximately every 3 months (could be shorter or longer depending on the criticality of the contents of the release).

A new Current Release will usually carry new functionality, bug fixes and may contain breaking changes. We will call out all breaking changes (if any) in the Release Notes section of every Current Release, and we advise developers to test their application adequately before adopting in for production use. 

A Current release is on the leading edge of our SDK development, and is intended for customers who are in active development and want the latest and greatest features.  Current releases are not intended for long-term use, and will only receive enough support after the next release becomes available to allow for a smooth transition to the new version. 


> #### Support for Current Release
>
> A Current Release
>
> - is Considered [Active](#active) when released
> - transitions to [Maintenance](#maintenance) 3 months after it becomes Active, or when the next release becomes Active, whichever is later
> - reaches [End-of-life](#end-of-life) 6 months after it becomes Active, or 3 months after the next release becomes Active, whichever is later


### Long Term Support

A Long-Term Support (LTS) release is one which we plan to guarantee compatibility with for an extended period of time.  The public interfaces of the SDK should not be changed in ways that would break customers’ application, and the release should continue to receive at least bug fixes for its entire lifecycle. We expect to refresh Long Term Release version every 18 - 24 months.

For the above reasons, we recommend all developers who do not intend to make frequent updates (~every 6 - 12 months) to their application, only use a Long Term Release version of the SDK. 

> #### Support for Long Term Release
>
> A Long Term Release
>
> - is considered [Active](#active) when released
> - transitions to [Maintenance](#maintenance) 1 year after it becomes Active, or when the next release becomes Active, whichever is later
> - reaches [End-of-life](#end-of-life) 2 years after it becomes Active, or 1 year after the next LTS release becomes Active, whichever is later


### Support Phases

#### Active

Once a release is considered ready for release, a new version is cut and the release enters the Active phase.  However, new features may be added to the SDK, including support for new API endpoints. 



#### Maintenance

After a time, the release is no longer under active development, but customers may still be depending on it.  At this time, we consider the release to be in Maintenance phase; generally, only bug fixes will be considered for inclusion in new versions.  We may of course opt to include new functionality based on customer demand, but in general customers should expect that the SDK feature set will be mostly frozen for the remainder of its lifecycle.

#### End-of-life

After a release is no longer being supported by Box, it enters End-of-life (EOL) and no further changes should be expected by customers.  Customers must upgrade to a newer release if they want to receive support.

Copyright and License
-------

Copyright 2019 Box, Inc. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.