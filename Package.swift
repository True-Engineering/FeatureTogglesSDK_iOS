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
    dependencies: [
        .package(url: "https://github.com/divar-ir/NetShears.git", from: "3.2.3"),
    ],
    targets: [
        .target(
            name: "FeatureToggles",
            dependencies: ["NetShears"],
            path: "FeatureToggles"),
    ]
)
