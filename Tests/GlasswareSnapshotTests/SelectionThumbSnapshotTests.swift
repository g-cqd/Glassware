//
//  SelectionThumbSnapshotTests.swift
//  GlasswareSnapshotTests
//

#if canImport(UIKit) && !targetEnvironment(macCatalyst)

import Glassware
import SnapshotTesting
import SwiftUI
import XCTest

private struct ThumbHarness<S: Shape>: View {
    let shape: S
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue.opacity(0.4), .purple.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            SelectionThumb(shape: shape)
                .frame(width: width, height: height)
        }
        .frame(width: 320, height: 200)
    }
}

final class SelectionThumbSnapshotTests: SnapshotTestCase {

    func testCapsule_wide_light() {
        assertSnapshot(
            of: ThumbHarness(shape: Capsule(), width: 200, height: 48),
            named: "capsule-wide-light",
            colorScheme: .light
        )
    }

    func testCapsule_wide_dark() {
        assertSnapshot(
            of: ThumbHarness(shape: Capsule(), width: 200, height: 48),
            named: "capsule-wide-dark",
            colorScheme: .dark
        )
    }

    func testCircle_light() {
        assertSnapshot(
            of: ThumbHarness(shape: Circle(), width: 56, height: 56),
            named: "circle-light",
            colorScheme: .light
        )
    }

    func testRoundedRect_tall_light() {
        assertSnapshot(
            of: ThumbHarness(
                shape: RoundedRectangle(cornerRadius: 24, style: .continuous),
                width: 60,
                height: 80
            ),
            named: "roundedRect-tall-light",
            colorScheme: .light
        )
    }
}

#endif
