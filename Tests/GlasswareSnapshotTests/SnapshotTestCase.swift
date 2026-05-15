//
//  SnapshotTestCase.swift
//  GlasswareSnapshotTests
//
//  Shared base for SwiftUI snapshot tests targeting the iOS Simulator.
//

#if canImport(UIKit) && !targetEnvironment(macCatalyst)

import SnapshotTesting
import SwiftUI
import UIKit
import XCTest

/// Base class for Glassware snapshot tests.
///
/// The package's tests build on macOS (`swift test`) and on iOS Simulator
/// (`xcodebuild test`). UI rendering only works in the iOS Simulator path —
/// glass effects, `UIHostingController`, and the `SnapshotTesting` rendering
/// strategies all require UIKit. Subclasses guard their test bodies with the
/// same `#if canImport(UIKit) && !targetEnvironment(macCatalyst)` clause so
/// they become inert on macOS host runs without breaking the build.
///
/// ## Precision policy
///
/// Glass material is Metal-backed and not byte-identical run-to-run. We use
/// `perceptualPrecision: 0.95` (Delta-E based comparison, ~5% perceptual
/// tolerance) and `precision: 0.99` (per-pixel tolerance) to absorb that
/// noise. Tighten these on individual tests if a particular component's
/// rendering is fully deterministic.
@MainActor
class SnapshotTestCase: XCTestCase {

    /// Set the env var `GLASSWARE_RECORD_SNAPSHOTS=1` to regenerate baselines.
    /// CI keeps it unset so tests assert against committed PNGs. Local devs
    /// can flip it for a single run via `GLASSWARE_RECORD_SNAPSHOTS=1 xcodebuild
    /// test ...` without editing source.
    ///
    /// `.missing` is preferred over `.all` so existing baselines aren't
    /// silently overwritten — only first-time tests record new files.
    static var recordMode: SnapshotTestingConfiguration.Record? {
        let flag = ProcessInfo.processInfo.environment["GLASSWARE_RECORD_SNAPSHOTS"]
        switch flag {
        case "1", "all": return .all
        case "missing": return .missing
        default: return nil
        }
    }

    // MARK: - Snapshot helpers

    /// Snapshot a SwiftUI view at a chosen device size, color scheme, and
    /// Dynamic Type setting. Wraps the view in `UIHostingController` (the
    /// standard SwiftUI -> UIView bridge that `SnapshotTesting` rendering
    /// strategies accept) and applies the trait environment.
    func assertSnapshot<V: View>(
        of view: V,
        named name: String? = nil,
        device: ViewImageConfig = .iPhone13Pro,
        colorScheme: ColorScheme = .light,
        dynamicTypeSize: DynamicTypeSize = .large,
        layoutDirection: LayoutDirection = .leftToRight,
        precision: Float = 0.99,
        perceptualPrecision: Float = 0.95,
        file: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line
    ) {
        let configured = view
            .environment(\.colorScheme, colorScheme)
            .environment(\.dynamicTypeSize, dynamicTypeSize)
            .environment(\.layoutDirection, layoutDirection)

        let host = UIHostingController(rootView: configured)
        host.overrideUserInterfaceStyle = (colorScheme == .dark) ? .dark : .light

        let traits = UITraitCollection { mutable in
            mutable.userInterfaceStyle = (colorScheme == .dark) ? .dark : .light
            mutable.layoutDirection = (layoutDirection == .rightToLeft) ? .rightToLeft : .leftToRight
        }

        withSnapshotTesting(record: Self.recordMode) {
            SnapshotTesting.assertSnapshot(
                of: host,
                as: .image(
                    on: device,
                    precision: precision,
                    perceptualPrecision: perceptualPrecision,
                    traits: traits
                ),
                named: name,
                file: file,
                testName: testName,
                line: line
            )
        }
    }
}

/// Naming helpers shared across the snapshot suites.
enum SnapshotMatrix {
    /// Compact label for a Dynamic Type size, used in committed PNG filenames
    /// so reviewers can tell at a glance which trait combination broke.
    static func label(for size: DynamicTypeSize) -> String {
        switch size {
        case .xSmall: "xS"
        case .small: "S"
        case .medium: "M"
        case .large: "L"
        case .xLarge: "XL"
        case .xxLarge: "XXL"
        case .xxxLarge: "XXXL"
        case .accessibility1: "A1"
        case .accessibility2: "A2"
        case .accessibility3: "A3"
        case .accessibility4: "A4"
        case .accessibility5: "A5"
        @unknown default: "?"
        }
    }
}

#endif
