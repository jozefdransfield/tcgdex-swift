// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TCGDex",
    platforms: [
            .macOS(.v12),
            .iOS(.v15),
            .watchOS(.v8),
            .tvOS(.v15)
        ],
    products: [
        .library(
            name: "TCGDex",
            targets: ["TCGDex"]
        ),
    ],
    targets: [
        .target(
            name: "TCGDex"
        ),
        .testTarget(
            name: "TCGDexTests",
            dependencies: ["TCGDex"]
        ),
    ]
)
