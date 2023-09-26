// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Parachute",
    platforms: [.iOS("16.2")],
    products: [
        .library(
            name: "FilterCommon",
            targets: ["FilterCommon"]
        ),
        .library(
            name: "FilterData",
            targets: ["FilterData"]
        ),
        .library(
            name: "FilterControl",
            targets: ["FilterControl"]
        ),
        .library(
            name: "AppViews",
            targets: ["AppViews"]
        ),
        .library(
            name: "CommonViews",
            targets: ["CommonViews"]
        ),
        .library(
            name: "Controllers",
            targets: ["Controllers"]
        ),
        .library(
            name: "Activities",
            targets: ["Activities"]
        ),
        .library(
            name: "DI",
            targets: ["DI"]
        ),
        .library(
            name: "RangeMapping",
            targets: ["RangeMapping"]
        ),
        .library(
            name: "CommonLoaders",
            targets: ["CommonLoaders"]
        ),
        .library(
            name: "Models",
            targets: ["Models"]
        ),
        .library(
            name: "Common",
            targets: ["Common"]
        ),
    ],
    dependencies: [
        .package(path: "../ProxyService"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", branch: "master"),
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.0.0"),
        .package(url: "https://github.com/OneSignal/OneSignal-XCFramework.git", from: "5.0.1"),
    ],
    targets: [
        .target(
            name: "FilterCommon",
            dependencies: [
                .product(name: "ProxyService", package: "ProxyService"),
            ]
        ),
        .target(
            name: "FilterData",
            dependencies: [
                "Models",
                "Common",
                "FilterCommon",
                .product(name: "ProxyService", package: "ProxyService"),
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                // .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"), // FilterDataProvider may be too sandboxed to use this.
            ]
        ),
        .target(
            name: "FilterControl",
            dependencies: [
                "Common",
                "Models",
                "FilterCommon",
                .product(name: "ProxyService", package: "ProxyService"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
            ]
        ),
        .target(
            name: "Models",
            dependencies: [
                .product(name: "ProxyService", package: "ProxyService"),
            ]
        ),
        .testTarget(
            name: "ModelsTests",
            dependencies: [
                "Models",
            ]
        ),
        .target(
            name: "RangeMapping"
        ),
        .target(
            name: "Activities",
            dependencies: [
                "Models",
                .product(name: "ProxyService", package: "ProxyService"),
            ]
        ),
        .target(
            name: "AppViews",
            dependencies: [
                "Controllers",
                "CommonViews",
            ]
        ),
        .target(
            name: "CommonViews",
            dependencies: [
                "Controllers",
                "CommonLoaders",
                .product(name: "ProxyService", package: "ProxyService"),
            ],
            resources: [
                .copy("Resources/Assets.xcassets"),
                .process("Resources/Fonts"),
            ]
        ),
        .target(
            name: "CommonLoaders",
            dependencies: [
                "Controllers",
            ]
        ),
        .target(
            name: "Controllers",
            dependencies: [
                "RangeMapping",
                "Common",
                "DI",
                "Models",
                "Activities",
                .product(name: "ProxyService", package: "ProxyService"),
                .product(name: "OrderedCollections", package: "swift-collections"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "OneSignalFramework", package: "OneSignal-XCFramework"),
            ]
        ),
        .target(
            name: "Common",
            dependencies: [
                .product(name: "ProxyService", package: "ProxyService"),
            ]
        ),
        .target(name: "DI"),
    ]
)
