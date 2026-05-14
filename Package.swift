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
        .package(url: "https://github.com/Aemi-Studio/AemiSDR.git", revision: "0fa9c72f95e0be3859bc6ff8129f0f58ccc6dfda")
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
