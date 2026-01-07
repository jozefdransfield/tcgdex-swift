// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "tcgdex",
    platforms: [
            .macOS(.v12),    // This fixes your session.data error
            .iOS(.v15),      // Keeps it consistent with modern Swift Concurrency
            .watchOS(.v8),
            .tvOS(.v15)
        ],
    products: [
        .library(
            name: "tcgdex",
            targets: ["tcgdex"]
        ),
    ],
    targets: [
        .target(
            name: "tcgdex"
        ),
        .testTarget(
            name: "tcgdexTests",
            dependencies: ["tcgdex"]
        ),
    ]
)
