// swift-tools-version: 6.2

import PackageDescription

private let package = Package(
    name: "Glassware",
    platforms: [
        .iOS(.v26),
        .macOS(.v26)
    ],
    products: [
        .library(
            name: "Glassware",
            targets: ["Glassware"]
        )
    ],
    targets: [
        .target(
            name: "Glassware",
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "GlasswareTests",
            dependencies: ["Glassware"],
            swiftSettings: swiftSettings
        )
    ]
)

private let swiftSettings: [SwiftSetting] = [
    .strictMemorySafety(),
    .swiftLanguageMode(.version("6.2")),
    .enableUpcomingFeature("StrictConcurrency")
]
