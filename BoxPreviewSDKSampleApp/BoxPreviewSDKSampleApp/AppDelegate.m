//
//  AppDelegate.m
//
//  Copyright (c) 2015 Box. All rights reserved.
//

#import "AppDelegate.h"
#import <BoxPreviewSDK/BoxPreviewSDK.h>
#import <BoxBrowseSDK/BoxBrowseSDK.h>

@interface AppDelegate () <BOXFolderViewControllerDelegate, BOXFilePreviewControllerDelegate>
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
#warning Set the client ID and client secret that can be retrieved by creating an application at http://developers.box.com
    [BOXContentClient setClientID:@"your_client_id" clientSecret:@"your_client_secret"];
    [self setupControllers];
    [self.window makeKeyAndVisible];
    
    return YES;    
}

- (void)itemsViewController:(BOXItemsViewController *)itemsViewController
                 didTapFile:(BOXFile *)file
                    inItems:(NSArray *)items
{

    BOXPreviewClient *previewClient = [[BOXPreviewClient alloc] initWithContentClient:[BOXContentClient defaultClient]];
    BOXFilePreviewController *filePreviewController = [[BOXFilePreviewController alloc] initWithPreviewClient:previewClient
                                                                                                   item:file
                                                                                                inItems:items];
    filePreviewController.delegate = self;

    [((UINavigationController *) self.window.rootViewController) pushViewController:filePreviewController animated:YES];
}

- (BOOL)itemsViewControllerShouldShowCloseButton:(BOXItemsViewController *)itemsViewController
{
    return NO;
}

- (void)logOutUser
{
    [[BOXContentClient defaultClient] logOut];
    [self setupControllers];
}

- (void)setupControllers
{
    BOXFolderViewController *folderViewController = [[BOXFolderViewController alloc] initWithContentClient:[BOXContentClient defaultClient]];
    folderViewController.delegate = self;
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:folderViewController];
    folderViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Log out"
                                                                                              style:UIBarButtonItemStylePlain
                                                                                             target:self
                                                                                             action:@selector(logOutUser)];
}

#pragma mark BOXFilePreviewControllerDelegate

- (NSArray *)boxFilePreviewController:(BOXFilePreviewController *)controller willChangeToRightBarButtonItems:(NSArray *)items
{
    // Modify the items array to customize the navigation bar buttons displayed in the File Previewer
    return items;
}

@end
