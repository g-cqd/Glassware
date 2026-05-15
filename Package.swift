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
    dependencies: [
        .package(url: "https://github.com/Aemi-Studio/AemiSDR.git", revision: "b904bd38e52ee8cb4e1c4c50dfa2e56ed0fc9c8e")
    ],
    targets: [
        .target(
            name: "Glassware",
            dependencies: ["AemiSDR"],
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
