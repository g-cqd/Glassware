//
//  GlassButtonSnapshotTests.swift
//  GlasswareSnapshotTests
//

#if canImport(UIKit) && !targetEnvironment(macCatalyst)

import Glassware
import SnapshotTesting
import SwiftUI
import XCTest

private struct ButtonHarness: View {
    let prominent: Bool
    let style: GlassVisualStyle

    var body: some View {
        VStack(spacing: 24) {
            Button("Plain") {}
                .buttonStyle(.glass(style: style))
            Button("Disabled") {}
                .buttonStyle(.glass(style: style))
                .disabled(true)
            if prominent {
                Button("Prominent") {}
                    .buttonStyle(.glassProminent(style: style))
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(white: 0.1))
        .frame(height: 320)
    }
}

final class GlassButtonSnapshotTests: SnapshotTestCase {

    func testStandardStyles_lightMode() {
        assertSnapshot(
            of: ButtonHarness(prominent: false, style: .titleAndIcon()),
            named: "standard-titleAndIcon-L-light",
            colorScheme: .light
        )
        assertSnapshot(
            of: ButtonHarness(prominent: false, style: .iconOnly()),
            named: "standard-iconOnly-L-light",
            colorScheme: .light
        )
    }

    func testProminent_largeType_lightAndDark() {
        assertSnapshot(
            of: ButtonHarness(prominent: true, style: .titleAndIcon()),
            named: "prominent-titleAndIcon-L-light",
            colorScheme: .light
        )
        assertSnapshot(
            of: ButtonHarness(prominent: true, style: .titleAndIcon()),
            named: "prominent-titleAndIcon-L-dark",
            colorScheme: .dark
        )
    }

    func testAccessibility1Scaling() {
        assertSnapshot(
            of: ButtonHarness(prominent: false, style: .titleAndIcon()),
            named: "standard-titleAndIcon-A1-light",
            colorScheme: .light,
            dynamicTypeSize: .accessibility1
        )
    }
}

#endif
