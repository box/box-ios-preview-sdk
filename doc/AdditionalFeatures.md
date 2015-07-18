Additional Features
==============

BOXPreviewClient also provides these additional methods:

```objectivec
/**
*  Downloads and caches a file's preview image. If the file is already cached, the content data will be immediately surfaced in the completion block.
*
*  @param fileID          The ID of the BOXFile
*  @param completionBlock The block to be executed either when finished downloading the file or successfully fetched from the cache.
*
*  @return A BOXRequest to download the BOXFile's preview image if it is not cached; otherwise, nil. Can be canceled.
*/
- (BOXRequest *)retrievePreviewImageForFile:(NSString *)fileID
completion:(BOXImageBlock)completionBlock;
```

```objectivec
/**
*  Retrieve underlying file's info for a shared link. If the shared link is not for a file, we return nil in completion.
*
*  @param sharedLink      The file's shared link.
*  @param completionBlock The block to be executed after file info is retrieved.
*
*  @return A BOXRequest to retrieve the file for a shared link. Can be canceled.
*/
- (BOXRequest *)retrieveFileForSharedLink:(NSURL *)sharedLink
completion:(BOXFileBlock)completionBlock;
```