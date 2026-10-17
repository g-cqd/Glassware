//
//  BottomBarSafeAreaTests.swift
//  GlasswareTests
//
//  Layout tests for the bottom bar against a real container safe-area inset.
//
//  The suite hosts the bar in a `UIWindow` and measures the frame SwiftUI
//  actually produced, so it needs UIKit (iOS Simulator). On macOS it compiles
//  to nothing, like the snapshot target.
//

#if canImport(UIKit) && !targetEnvironment(macCatalyst)

import SwiftUI
import Testing
import UIKit

@testable import Glassware

@MainActor
@Suite("Bottom bar safe area")
struct BottomBarSafeAreaTests {
    private static let windowSize = CGSize(width: 390, height: 844)
    /// Height of the home-indicator region the container reports.
    private static let homeIndicatorInset: CGFloat = 34
    private static var safeBottom: CGFloat { windowSize.height - homeIndicatorInset }

    @Test(
        "Bar items stay above the home indicator",
        arguments: [GlassPaddingConfiguration.default, .tight]
    )
    func respectsHomeIndicator(padding: GlassPaddingConfiguration) async throws {
        let frame = try await measuredBarItemFrame(padding: padding)
        #expect(frame.height > 0, "The bar item was never laid out")
        #expect(
            frame.maxY <= Self.safeBottom,
            "Bar item bottom \(frame.maxY) is inside the home-indicator zone (safe bottom \(Self.safeBottom))"
        )
        // Sanity: it is a bottom bar, not collapsed somewhere else.
        #expect(frame.maxY > Self.windowSize.height * 0.8)
    }

    /// Control: `edgeToEdge` explicitly opts out of the safe area, so it must
    /// reach into the home-indicator zone. If this fails, the measurement
    /// cannot tell the two behaviours apart and the test above proves nothing.
    @Test("Edge-to-edge padding reaches the screen bottom")
    func edgeToEdgeIgnoresHomeIndicator() async throws {
        let frame = try await measuredBarItemFrame(padding: .edgeToEdge)
        #expect(frame.maxY > Self.safeBottom)
    }

    // MARK: Harness

    @MainActor
    private final class FrameBox {
        var frame: CGRect = .zero
    }

    private func measuredBarItemFrame(padding: GlassPaddingConfiguration) async throws -> CGRect {
        let box = FrameBox()
        // `glassPadding` must wrap `.glass { }`: environment values flow from
        // the outside in, so applying it to the content would leave the bar on
        // the default padding no matter what is requested.
        let root = Color.clear
            .glass {
                GlassItem(placement: .bottomPrimary) {
                    Color.clear
                        .frame(width: 120, height: 44)
                        .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { box.frame = $0 }
                }
            }
            .glassPadding(padding)
        let host = UIHostingController(rootView: root)
        host.additionalSafeAreaInsets = UIEdgeInsets(
            top: 0, left: 0, bottom: Self.homeIndicatorInset, right: 0)
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
        return box.frame
    }
}

#endif
