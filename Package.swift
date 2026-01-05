// swift-tools-version: 6.2

import PackageDescription

let package = Package(
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
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "GlasswareTests",
            dependencies: ["Glassware"]
        )
    ]
)
