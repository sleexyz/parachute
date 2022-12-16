// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ProxyService",
    products: [
        .library(
            name: "ProxyService",
            targets: ["ProxyService"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.20.3"),
    ],
    targets: [
        .target(
            name: "ProxyService",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
            ]),
    ]
)
