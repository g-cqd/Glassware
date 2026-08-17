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
        .package(url: "https://github.com/Aemi-Studio/AemiSDR.git", revision: "8e7d2399489315a9fd9c9351485d69cf2d7ce7e0"),
        // Snapshot testing — pinned exact to keep snapshot baselines stable
        // across dependency-resolver runs. Bump deliberately when intentionally
        // regenerating snapshots.
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", exact: "1.19.2")
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
        ),
        // Snapshot tests are iOS-only at runtime (glass effects + UIHostingController
        // are UIKit-bound). The target compiles on macOS so `swift test` and
        // Xcode Indexing don't error, but the test bodies are wrapped in
        // `#if canImport(UIKit) && !targetEnvironment(macCatalyst)` so they
        // only execute when running on the iOS Simulator via `xcodebuild test`.
        .testTarget(
            name: "GlasswareSnapshotTests",
            dependencies: [
                "Glassware",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            exclude: ["__Snapshots__"],
            swiftSettings: snapshotTestSwiftSettings
        )
    ]
)

private let swiftSettings: [SwiftSetting] = [
    .strictMemorySafety(),
    .swiftLanguageMode(.version("6.2")),
    .enableUpcomingFeature("StrictConcurrency")
]

// Snapshot tests use XCTest (Swift Testing support in swift-snapshot-testing
// 1.19 is still beta, and mixing the two frameworks in a single target is
// unsupported), and pull in UIKit symbols when running on iOS — strict
// memory safety would otherwise reject `UIHostingController`'s ObjC bridge.
private let snapshotTestSwiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.version("6.2")),
    .enableUpcomingFeature("StrictConcurrency")
]
