// swift-tools-version: 6.4
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
        .library(
            name: "FCPKitMediaTools",
            targets: ["FCPKitMediaTools"]
        ),
        .library(
            name: "FCPXMLDiff",
            targets: ["FCPXMLDiff"]
        ),
        .executable(
            name: "fcpxml-generator",
            targets: ["fcpxml-generator"]
        ),
        .executable(
            name: "fcpxml-diff",
            targets: ["FCPXMLDiffCLI"]
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
        .target(
            name: "FCPKitMediaTools",
            dependencies: ["FCPKit"]
        ),
        .target(
            name: "FCPXMLDiff",
            dependencies: ["FCPKit", "XMLCoder"]
        ),
        .executableTarget(
            name: "fcpxml-generator",
            dependencies: ["FCPKitMediaTools"]
        ),
        .executableTarget(
            name: "FCPXMLDiffCLI",
            dependencies: ["FCPXMLDiff"]
        ),
        .testTarget(
            name: "FCPKitTests",
            dependencies: ["FCPKit", "FCPKitMediaTools", "FCPXMLDiff", "XMLCoder"],
            exclude: [
                "FeaturePairs",
            ],
            resources: [
                .copy("TestData")
            ]
        ),
    ]
)
