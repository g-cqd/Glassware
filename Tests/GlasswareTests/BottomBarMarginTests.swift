//
//  BottomBarMarginTests.swift
//  GlasswareTests
//
//  Layout tests for the bottom bar's margins.
//
//  The suite hosts the bar in a `UIWindow` and measures the frame SwiftUI
//  actually produced, so it needs UIKit (iOS Simulator). On macOS it compiles
//  to nothing, like the snapshot target.
//
//  The rule under test mirrors the system floating tab bar: the gap between
//  the bar and the physical bottom edge equals the gap at its sides. The
//  home indicator is drawn inside that gap, so the container's bottom inset
//  is deliberately not added on top of it.
//

#if canImport(UIKit) && !targetEnvironment(macCatalyst)

import SwiftUI
import Testing
import UIKit

@testable import Glassware

@MainActor
@Suite("Bottom bar margins")
struct BottomBarMarginTests {
    private static let windowSize = CGSize(width: 390, height: 844)
    private static let homeIndicatorInset: CGFloat = 34

    /// The item's own offset from the bar edge differs per axis (container
    /// internals), so margins are measured against `edgeToEdge`, which has no
    /// bottom margin by definition: `margin = gap(preset) - gap(edgeToEdge)`.
    private func bottomMargin(
        of padding: GlassPaddingConfiguration, bottomInset: CGFloat = homeIndicatorInset
    ) async throws -> CGFloat {
        let preset = try await measuredLeadingItem(padding: padding, bottomInset: bottomInset)
        let reference = try await measuredLeadingItem(padding: .edgeToEdge, bottomInset: bottomInset)
        #expect(preset.height > 0 && reference.height > 0, "The bar item was never laid out")
        return preset.bottomGap - reference.bottomGap
    }

    @Test("The tight preset's bottom margin equals its side margin")
    func tightBottomMarginEqualsSideMargin() async throws {
        let margin = try await bottomMargin(of: .tight)
        #expect(
            abs(margin - GlassPaddingConfiguration.tight.externalPadding) < 0.5,
            "Bottom margin \(margin) differs from the side margin \(GlassPaddingConfiguration.tight.externalPadding)"
        )
    }

    @Test("The bottom margin does not depend on the container's bottom inset")
    func bottomMarginIgnoresContainerInset() async throws {
        let withIndicator = try await bottomMargin(of: .tight, bottomInset: Self.homeIndicatorInset)
        let withoutIndicator = try await bottomMargin(of: .tight, bottomInset: 0)
        #expect(abs(withIndicator - withoutIndicator) < 0.5)
    }

    @Test("The default preset adds its density padding below the side margin")
    func defaultAddsPadding() async throws {
        let margin = try await bottomMargin(of: .default)
        #expect(margin > GlassPaddingConfiguration.default.externalPadding + 0.5)
    }

    /// Control: `edgeToEdge` is the zero-margin reference, so a preset with a
    /// margin must sit strictly higher. If the measurement cannot tell them
    /// apart, every assertion above proves nothing.
    @Test("A preset with a margin sits higher than edge-to-edge")
    func marginedPresetSitsHigher() async throws {
        let margin = try await bottomMargin(of: .tight)
        #expect(margin > 1)
    }

    // MARK: Harness

    private struct Measurement {
        var frame: CGRect
        var windowHeight: CGFloat
        var sideGap: CGFloat { frame.minX }
        var bottomGap: CGFloat { windowHeight - frame.maxY }
        var height: CGFloat { frame.height }
    }

    @MainActor
    private final class FrameBox {
        var frame: CGRect = .zero
    }

    private func measuredLeadingItem(
        padding: GlassPaddingConfiguration,
        bottomInset: CGFloat = homeIndicatorInset
    ) async throws -> Measurement {
        let box = FrameBox()
        // `glassPadding` must wrap `.glass { }`: environment values flow from
        // the outside in, so applying it to the content would leave the bar on
        // the default padding no matter what is requested.
        let root = Color.clear
            .glass {
                GlassItem(placement: .bottomLeading) {
                    // Far above the container's minimum cross-axis size, so the
                    // circle around it is item plus symmetric padding and the
                    // item's offsets from the circle match on both axes.
                    Color.clear
                        .frame(width: 120, height: 120)
                        .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { box.frame = $0 }
                }
                GlassItem(placement: .bottomTrailing) {
                    Color.clear.frame(width: 44, height: 44)
                }
            }
            .glassLayout(.distributed)
            .glassPadding(padding)
        let host = UIHostingController(rootView: root)
        host.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        let window = UIWindow(frame: CGRect(origin: .zero, size: Self.windowSize))
        window.rootViewController = host
        window.makeKeyAndVisible()
        defer { window.isHidden = true }

        for _ in 0..<30 {
            try await Task.sleep(for: .milliseconds(50))
            host.view.layoutIfNeeded()
            if box.frame.height > 0 { break }
        }
        try await Task.sleep(for: .milliseconds(200))
        return Measurement(frame: box.frame, windowHeight: Self.windowSize.height)
    }
}

#endif
