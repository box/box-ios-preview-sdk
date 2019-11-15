//
//  AppDelegate.swift
//  SwiftTestApp
//
//  Created by Abel Osorio on 5/9/19.
//  Copyright © 2019 Box. All rights reserved.
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
