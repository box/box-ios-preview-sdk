//
//  AppDelegate.swift
//  CCGSampleApp
//
//  Created by Artur Jankowski on 05/04/2022.
//  Copyright © 2022 Box. All rights reserved.
//

import BoxPreviewSDK
import BoxSDK
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var contentSDK: BoxSDK!
    var client: BoxClient!
    var previewSDK: BoxPreviewSDK?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
}
