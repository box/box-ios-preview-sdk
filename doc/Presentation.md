Presentation
==============

The SDK can take care of presenting all previewable Box file types in a self-contained UIViewController.

Types of files supported:
- images
- PDFs
- audio/video files
- markdown/text/code files
- 3D mesh files
- Office documents

Currently not supported:
- Box Notes


Initializing View Controllers
---------------------

BOXFilePreviewController can be initialized for just one file:
```objectivec
BOXFile *file = ... // A BOXFile that you retrieved through the Content SDK or Browse SDK.
BOXFilePreviewController *filePreviewController = [[BOXFilePreviewController alloc] initWithPreviewClient:previewClient file:file];
[self presentViewController:filePreviewController animated:YES completion:nil];
```

Or as part an array of items (e.g. viewing a collection of photos):
```objectivec
BOXFilePreviewController *filePreviewController = [[BOXFilePreviewController alloc] initWithPreviewClient:previewClient file:file inItems:files];
[self presentViewController:filePreviewController animated:YES completion:nil];
```

BOXFilePreviewController can be initialized with just a BOXContentClient if no cache customizations are needed.
```objectivec
BOXFile *file = ... // A BOXFile that you retrieved through the Content SDK or Browse SDK.
BOXFilePreviewController *filePreviewController = [[BOXFilePreviewController alloc] initWithContentClient:contentClient file:file];
[self presentViewController:filePreviewController animated:YES completion:nil];
```

```objectivec
BOXFilePreviewController *filePreviewController = [[BOXFilePreviewController alloc] initWithContentClient:contentClient file:file inItems:files];
[self presentViewController:filePreviewController animated:YES completion:nil];
```

Customizing View Controllers
---------------------

The navigation bar button items can be customized by implementing the BOXFilePreviewControllerDelegate methods:
```objectivec
- (NSArray *)boxFilePreviewController:(BOXFilePreviewController *)controller
willChangeToLeftBarButtonItems:(NSArray *)items;

- (NSArray *)boxFilePreviewController:(BOXFilePreviewController *)controller
willChangeToRightBarButtonItems:(NSArray *)items;
```

The navigation bar, toolbar, and status bar can also be customized to never hide.
The default is for them to be hidden on interaction.

For preventing the navigation and toolbars from being hidden:
```objectivec
filePreviewController.shouldHideBars = NO;
```

For preventing the status bar from being hidden:
```objectivec
filePreviewController.shouldHideStatusBar = NO;
```
