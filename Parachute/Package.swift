// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Parachute",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "Controllers",
            targets: ["Controllers"]
        ),
        .library(
            name: "Server",
            targets: ["Server"]
        ),
        .library(
            name: "DI",
            targets: ["DI"]
        ),
        .library(
            name: "Common",
            targets: ["Common"]
        ),
    ],
    dependencies: [
        .package(path: "../ProxyService"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "Server",
            dependencies: [
                "Common",
            ]
        ),
        .testTarget(
            name: "ServerTests",
            dependencies: [
                "Server",
            ]
        ),
        .target(
            name: "Controllers",
            dependencies: [
                "Common",
                "DI",
                .product(name: "ProxyService", package: "ProxyService"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
            ]
        ),
        .target(
            name: "Common",
            dependencies: [
                .product(name: "ProxyService", package: "ProxyService"),
            ]
        ),
        .target(name: "DI"),
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
    ]
)
