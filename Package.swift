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
            name: "FCPKitScripting",
            targets: ["FCPKitScripting"]
        ),
        .library(
            name: "FCPXMLDiff",
            targets: ["FCPXMLDiff"]
        ),
        .library(
            name: "FCPKitDSL",
            targets: ["FCPKitDSL"]
        ),
        .executable(
            name: "fcpxml-generator",
            targets: ["fcpxml-generator"]
        ),
        .executable(
            name: "fcpxml-dsl",
            targets: ["fcpxml-dsl"]
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
            name: "FCPKitScripting",
            dependencies: ["FCPKit"]
        ),
        .target(
            name: "FCPXMLDiff",
            dependencies: ["FCPKit", "XMLCoder"]
        ),
        .target(
            name: "FCPKitDSL",
            dependencies: ["FCPKit"]
        ),
        .executableTarget(
            name: "fcpxml-generator",
            dependencies: ["FCPKitMediaTools"]
        ),
        .executableTarget(
            name: "fcpxml-dsl",
            dependencies: ["FCPKit", "FCPKitDSL", "FCPKitMediaTools"]
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
        .testTarget(
            name: "FCPKitScriptingTests",
            dependencies: ["FCPKitScripting", "FCPKit"]
        ),
        .testTarget(
            name: "FCPKitDSLTests",
            dependencies: ["FCPKitDSL", "FCPKit", "FCPXMLDiff"]
        ),
    ]
)
