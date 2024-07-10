// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "TEFeatureToggles",
    platforms: [
        .macOS(.v11), .iOS(.v13)
    ],
    products: [
        .library(
            name: "FeatureToggles",
            targets: ["FeatureToggles"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "FeatureToggles",
            dependencies: [],
            path: "FeatureToggles"),
    ]
)
