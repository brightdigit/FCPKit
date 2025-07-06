// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FCPKit",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "FCPKit",
            targets: ["FCPKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/CoreOffice/XMLCoder.git", from: "0.17.0")
    ],
    targets: [
        .target(
            name: "FCPKit",
            dependencies: ["XMLCoder"]
        ),
        .testTarget(
            name: "FCPKitTests",
            dependencies: ["FCPKit"],
            resources: [
                .copy("TestData")
            ]
        ),
    ]
)