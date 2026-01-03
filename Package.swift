// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "GlassToolbar",
    platforms: [
        .iOS(.v26),
        .macOS(.v26)
    ],
    products: [
        .library(
            name: "GlassToolbar",
            targets: ["GlassToolbar"]
        )
    ],
    targets: [
        .target(
            name: "GlassToolbar",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "GlassToolbarTests",
            dependencies: ["GlassToolbar"]
        )
    ]
)
