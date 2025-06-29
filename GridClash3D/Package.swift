// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "GridClash3D",
    platforms: [
        .iOS("26.0"),
        .macOS("26.0"),
        .tvOS("26.0"),
        .visionOS("26.0"),
    ],
    products: [
        .library(
            name: "GridClash3D",
            targets: ["GridClash3D"]
        ),
    ],
    targets: [
        .target(
            name: "GridClash3D",
            dependencies: []
        ),
    ]
)
