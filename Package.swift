// swift-tools-version:5.0
//
//  BoxPreviewSDK.swift
//  BoxPreviewSDK
//
//  Created by Box Inc on 01/04/19.
//  Copyright © 2019 Box Inc. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "BoxPreviewSDK",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "BoxPreviewSDK",
            targets: ["BoxPreviewSDK"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/box/box-swift-sdk.git", .upToNextMajor(from: "3.0.0"))
    ],
    targets: [
        .target(
            name: "BoxPreviewSDK",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "BoxPreviewSDKTests",
            dependencies: ["BoxPreviewSDK"],
            path: "Tests"
        )
    ]
)
