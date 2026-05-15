//
//  SegmentedPickerSnapshotTests.swift
//  GlasswareSnapshotTests
//
//  Renders the SegmentedPicker across Dynamic Type sizes, styles, and color
//  schemes. The regression scenario this catches: when individual cells flip
//  from wider-than-tall to taller-than-wide at large Dynamic Type, the thumb
//  must continue to parallel the outer glass capsule's curve.
//

#if canImport(UIKit) && !targetEnvironment(macCatalyst)

import Glassware
import SnapshotTesting
import SwiftUI
import XCTest

private enum DemoTab: Int, CaseIterable, Hashable {
    case home, search, profile

    var title: String {
        switch self {
        case .home: "Home"
        case .search: "Search"
        case .profile: "Profile"
        }
    }

    var systemImage: String {
        switch self {
        case .home: "house"
        case .search: "magnifyingglass"
        case .profile: "person"
        }
    }
}

/// Wraps a SegmentedPicker so tests can mount it with a stable initial
/// selection without each test re-declaring the harness view.
private struct PickerHarness: View {
    @State var selected: DemoTab = .home
    let style: Glassware.SegmentedPickerStyle
    let nested: Bool

    var body: some View {
        Group {
            if nested {
                Color(white: 0.1)
                    .glassBar {
                        picker
                            .segmentedPickerStyle(sizing: .evenFill)
                    }
            } else {
                picker
                    .padding(3)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(white: 0.1))
            }
        }
        .frame(height: 220)
    }

    private var picker: some View {
        SegmentedPicker(selection: $selected, style: style) {
            ForEach(DemoTab.allCases, id: \.rawValue) { tab in
                SegmentedPickerItem(
                    tab,
                    systemImage: tab.systemImage,
                    style: style,
                    isSelected: selected == tab
                ) { Text(tab.title) }
            }
        }
    }
}

final class SegmentedPickerSnapshotTests: SnapshotTestCase {

    // MARK: - Edge-hug regression matrix
    //
    // Each combination of (style, Dynamic Type size, color scheme) renders the
    // picker inside a `.glassBar(...)`, which is the layout context in which
    // the thumb-edge bug originally manifested. The committed PNGs are the
    // visual contract: the thumb's corner radius must parallel the outer
    // glass capsule's edge across all rows.

    private let allStyles: [(Glassware.SegmentedPickerStyle, String)] = [
        (.iconOnly, "iconOnly"),
        (.titleOnly, "titleOnly"),
        (.titleAndIcon, "titleAndIcon")
    ]

    func testNestedInGlassBar_lightMode() {
        for (style, label) in allStyles {
            for size in [DynamicTypeSize.xSmall, .large, .accessibility1] {
                assertSnapshot(
                    of: PickerHarness(style: style, nested: true),
                    named: "\(label)-\(SnapshotMatrix.label(for: size))-light",
                    colorScheme: .light,
                    dynamicTypeSize: size
                )
            }
        }
    }

    func testNestedInGlassBar_darkMode() {
        for (style, label) in allStyles {
            for size in [DynamicTypeSize.xSmall, .large, .accessibility1] {
                assertSnapshot(
                    of: PickerHarness(style: style, nested: true),
                    named: "\(label)-\(SnapshotMatrix.label(for: size))-dark",
                    colorScheme: .dark,
                    dynamicTypeSize: size
                )
            }
        }
    }

    // MARK: - Standalone (no glass container) baseline
    //
    // Verifies the picker still renders cleanly when used outside a
    // `.glassBar(...)` wrapper, where `containerInset` is zero and the thumb
    // simply matches its cell.

    func testStandalone_largeType_lightAndDark() {
        for (style, label) in allStyles {
            assertSnapshot(
                of: PickerHarness(style: style, nested: false),
                named: "\(label)-L-light-standalone",
                colorScheme: .light,
                dynamicTypeSize: .large
            )
            assertSnapshot(
                of: PickerHarness(style: style, nested: false),
                named: "\(label)-L-dark-standalone",
                colorScheme: .dark,
                dynamicTypeSize: .large
            )
        }
    }

    // MARK: - Right-to-left spot check

    func testRTL_titleAndIcon_largeType() {
        let harness = PickerHarness(style: Glassware.SegmentedPickerStyle.titleAndIcon, nested: true)
        assertSnapshot(
            of: harness,
            named: "titleAndIcon-L-light-rtl",
            colorScheme: .light,
            dynamicTypeSize: .large,
            layoutDirection: .rightToLeft
        )
    }
}

#endif
