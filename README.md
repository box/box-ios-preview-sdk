[![Project Status](http://opensource.box.com/badges/active.svg)](http://opensource.box.com/badges)

Box iOS Preview SDK
===================

This SDK makes it easy to present Box files in your iOS application.

Developer Setup
---------------
* Ensure you have the latest version of [XCode](https://developer.apple.com/xcode/) installed.
* We encourage you to use [Cocoa Pods](http://cocoapods.org/) to import the SDK into your project. Cocoa Pods is a simple, but powerful dependency management tool. If you do not already use Cocoa Pods, it's very easy to [get started](http://guides.cocoapods.org/using/getting-started.html).

Quickstart
----------
Step 1: Add to your Podfile
```
pod 'box-ios-preview-sdk'
```
Step 2: Install
```
pod install
```
Step 3: Import
```objectivec
#import <BoxPreviewSDK/BoxPreviewSDK.h>
```
Step 4: Set the Box Client ID and Client Secret that you obtain from [creating a developer account](http://developers.box.com/)
```objectivec
[BOXContentClient setClientID:@"your-client-id" clientSecret:@"your-client-secret"];
```
Step 5: Present a file
```objectivec
BOXFile *file = ... // A BOXFile that you retrieved through the Content SDK or Browse SDK. See the Sample Application for an example.
BOXFilePreviewController *filePreviewController = [[BOXFilePreviewController alloc] initWithContentClient:[BOXContentClient defaultClient] item:file];
[self.navigationController pushViewController:filePreviewController animated:YES completion:nil];
```
Using an existing Content Client to initialize a BOXFilePreviewController will create a Preview Client behind the scenes with the default caching policy.
To [customize caching settings](doc/PreviewCaching.md), you can explicitly create a Preview Client to pass in.

 
Sample App
----------
A sample app can be found in the [BoxPreviewSDKSampleApp](../../tree/master/BoxPreviewSDKSampleApp) folder. To execute the sample app:

Step 0: (temporary, should not be necessary at public launch):
```
./build_framework.sh
```
Step 1: Install Pods
```
cd BoxPreviewSDKSampleApp
pod install
```
Step 2: Open Workspace
```
open BoxPreviewSDKSampleApp.xcworkspace
```

Documentation
-------------
You can find guides and tutorials in the `doc` directory.
 
* [Presentation](doc/Presentation.md)
* [Preview Caching](doc/PreviewCaching.md)
* [Additional Features](doc/AdditionalFeatures.md)
 
Contributing
------------
This SDK is currently not open source. Please submit issues in GitHub to report bugs and suggest improvements.


Copyright and License
---------------------
Copyright 2015 Box, Inc. All rights reserved.
 
Licensed under the Box Terms of Service; you may not use this file except in compliance with the License.
You may obtain a copy of the License at [https://www.box.com/legal/termsofservice/](https://www.box.com/legal/termsofservice/)
