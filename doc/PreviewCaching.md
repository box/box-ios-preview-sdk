Preview Caching
==============

We are caching the following types of items in the local file system:
- file content
- file previews
- thumbnails

By default, the Preview SDK supplies the following caching behavior:
* Max cache size - 1 GB
* Max cache age - 90 days (based on last time file was viewed)
* Cache directory location - NSLibraryDirectory

When the user logs out, all cached files will also be removed.

Creating a Preview Client
---------------------
Use an existing Content Client to create a Preview Client.
```objectivec
BOXPreviewClient *previewClient = [[BOXPreviewClient alloc] initWithContentClient:[BOXContentClient defaultClient]];
```

You can also pass in a directory for the location of the cache. A directory will be created within this specified directory to hold the cache contents.
```objectivec
BOXPreviewClient *previewClient = [[BOXPreviewClient alloc] initWithContentClient:[BOXContentClient defaultClient] cacheDirectory:[NSURL URLWithString:@"/Desired/Cache/Location"]];
```

Custom Caching Policy
---------------------

To customize the behavior of the cache, use these methods in the BOXPreviewClient:

```objectivec
BOXPreviewClient *previewClient = [[BOXPreviewClient alloc] initWithContentClient:[BOXContentClient defaultClient]];

[previewClient setMaxCacheSize:BOXPreviewClientCacheSize256MB];
[previewClient setMaxCacheAge:BOXPreviewClientCacheAge30Days];

// Cache directory can also be specified in the initializer.
// A directory will be created within this specified directory to hold the cache contents.
[previewClient setCacheDirectory:[NSURL URLWithString:@"/Desired/Cache/Location"]];
```

We provide some preset constants for convenience.

```objectivec
typedef NS_ENUM(NSUInteger, BOXPreviewClientCacheSize) {
BOXPreviewClientCacheSize256MB = 256 * 1024 * 1024,
BOXPreviewClientCacheSize512MB = 512 * 1024 * 1024,
BOXPreviewClientCacheSize1GB = 1024 * 1024 * 1024,
BOXPreviewClientCacheSizeDefault = BOXPreviewClientCacheSize1GB
};

typedef NS_ENUM(NSUInteger, BOXPreviewClientCacheAge) {
BOXPreviewClientCacheAge7Days = 7 * 24 * 60 * 60,
BOXPreviewClientCacheAge30Days = 30 * 24 * 60 * 60,
BOXPreviewClientCacheAge90Days = 90 * 24 * 60 * 60,
BOXPreviewClientCacheAgeDefault = BOXPreviewClientCacheAge90Days
};
```

Manual Cache Control
--------------

To manually add files to the cache:
```objectivec
[previewClient cacheFileWithID:fileID progress:nil completion:^(BOXFile *file, NSError *error) {
    if (error == nil) {
        // Do something with the file.
    }
}];
```

To manually remove files from the cache:
```objectivec
// This will remove all representations (e.g. preview and thumbnail) for the specified file.
[previewClient removeCacheForFileWithID:fileID];
```

To check if a file is in the cache:
```objectivec
BOOL isFileCached = [previewClient isFileWithIDCached:fileID];
```

To trigger a manual purge of the cache (i.e. remove files until below the max size):
```objectivec
[previewClient purgeCache];
```

To completely clear and reset the cache:
```objectivec
[previewClient resetCache];
```

To enforce persistence of specific files, implement the optional BOXPrereviewClientDelegate method:
```objectivec
- (BOOL)shouldPreviewClient:(BOXPreviewClient *)previewClient deleteCacheForFileWithID:(NSString *)fileID
{
    if ([fileID isEqualToString:@"123456"]) {
        return NO;
    }

    return YES;
}
```


Notifications
--------------

The BOXPreviewClient will broadcast NSNotifications when clearing the cache.

1. **BOXPreviewCacheDidExceedMaxSizeNotification** - when the cache exceeds the maxmium size and a purge is triggered.

2. **BOXPreviewCacheDidRemoveFilesNotification** - when files are removed from the cache. The userInfo is a dictionary with the key BOXPreviewCacheRemovedFileIDs corresponding to an array of file IDs that were removed.


