[![Project Status](http://opensource.box.com/badges/active.svg)](http://opensource.box.com/badges)

Box iOS Preview SDK
===================

This SDK makes it easy to present Box files in your iOS application.

Developer Setup
---------------
* Ensure you have the latest version of [XCode](https://developer.apple.com/xcode/) installed.
* We encourage you to use [Carthage](https://github.com/Carthage/Carthage#installing-carthage) to manage dependencies. Minimal supported version for Carthage is 0.22.0.

Quickstart
----------
Step 1: Add to your Cartfile
```
# Box SDKs
git "git@github.com:box/box-ios-sdk.git" "master"

binary "https://github.com/box/box-ios-preview-sdk/releases/download/v1.1.2/previewSDK.json" ==  1.1.2

# 3rd Party SDKs
github "SnapKit/Masonry" ~> 1.0.1
github "jdg/MBProgressHUD" ~> 1.0.0
```
Step 2: Update dependencies
```
carthage update
```
Step 3: Drag the built framework from Carthage/Build/iOS into your project.
```
For more detailed instructions please see the official documentation for Carthage (https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos)
```
Step 4: Import
```objectivec
@import BoxPreviewSDK;
```
Step 5: Set the Box Client ID and Client Secret that you obtain from [creating your app](doc/Setup.md).
```objectivec
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  // The UIApplicationDelegate is a good place to do this.
  [BOXContentClient setClientID:@"your-client-id" clientSecret:@"your-client-secret"];
}
```
Step 5: Present a file
```objectivec
BOXFile *file = ... // A BOXFile that you retrieved through the Content SDK or Browse SDK. See the Sample Application for an example.
BOXFilePreviewController *filePreviewController = [[BOXFilePreviewController alloc] initWithContentClient:[BOXContentClient defaultClient] file:file];
[self.navigationController pushViewController:filePreviewController animated:YES completion:nil];
```
Using an existing Content Client to initialize a BOXFilePreviewController will create a Preview Client behind the scenes with the default caching policy.
To [customize caching settings](doc/PreviewCaching.md), you can explicitly create a Preview Client to pass in.

 
Sample App
----------
A sample app can be found in the [BoxPreviewSDKSampleApp](../../tree/master/BoxPreviewSDKSampleApp) folder. To execute the sample app:

Step 1: Run carthage
```
cd BoxPreviewSDKSampleApp
carthage update --platform iOS
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
 
Licensed under the Box Terms of Service; you may not use this file except in compliance with the [License](LICENSE.pdf).
