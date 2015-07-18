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
BOXFilePreviewController *filePreviewController = [[BOXFilePreviewController alloc] initWithPreviewClient:previewClient item:file];
[self presentViewController:filePreviewController animated:YES completion:nil];
```

Or as part an array of items (e.g. viewing a collection of photos):
```objectivec
BOXFilePreviewController *filePreviewController = [[BOXFilePreviewController alloc] initWithPreviewClient:previewClient item:file inItems:files];
[self presentViewController:filePreviewController animated:YES completion:nil];
```

BOXFilePreviewController can just be initialized with just a BOXContentClient if no cache customizations are needed.
```objectivec
BOXFile *file = ... // A BOXFile that you retrieved through the Content SDK or Browse SDK.
BOXFilePreviewController *filePreviewController = [[BOXFilePreviewController alloc] initWithContentClient:contentClient item:file];
[self presentViewController:filePreviewController animated:YES completion:nil];
```

```objectivec
BOXFilePreviewController *filePreviewController = [[BOXFilePreviewController alloc] initWithContentClient:contentClient item:file inItems:files];
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


Views
------------------------
We also provide standalone UI View for previewing a file without a UIViewController. This can be embedded in a UITableViewCell, UICollectionViewCell, or another UIView.

Using PreviewView with a file:
```objectivec
BOXFile *file = ... // A BOXFile that you retrieved through the Content SDK or Browse SDK.
BOXPreviewView *previewView = [[BOXPreviewView alloc] initWithPreviewClient:previewClient];

previewView.file = file;
```

Using PreviewView with a shared link:
```objectivec
NSURL *sharedLinkURL = [NSURL URLWithString:@"https://box.com/yoursharedlink"];
BOXPreviewView *previewView = [[BOXPreviewView alloc] initWithPreviewClient:previewClient];

previewView.sharedLink = sharedLinkURL;
```


