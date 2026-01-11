//
//  GlasswareTests.swift
//  Glassware
//

import Testing
import SwiftUI
@testable import Glassware

@Suite("GlassMetrics Tests")
struct GlassMetricsTests {

    @Test("Minimum tap target respects accessibility guidelines at regular density")
    func minimumTapTargetAtRegular() {
        let metrics = GlassMetrics(density: .regular)
        #expect(metrics.minimumTapTarget >= 44)
    }

    @Test("Minimum tap target at extraDense is below guidelines")
    func minimumTapTargetAtExtraDense() {
        let metrics = GlassMetrics(density: .extraDense)
        #expect(metrics.minimumTapTarget < 44)
    }

    @Test("Edge padding decreases with density")
    func edgePaddingDecreases() {
        let sparse = GlassMetrics(density: .sparse)
        let regular = GlassMetrics(density: .regular)
        let dense = GlassMetrics(density: .dense)

        #expect(sparse.edgePadding > regular.edgePadding)
        #expect(regular.edgePadding > dense.edgePadding)
    }
}

@Suite("GlassDensity Tests")
struct GlassDensityTests {

    @Test("Accessibility safe upgrades dense densities")
    func accessibilitySafeUpgrades() {
        #expect(GlassDensity.dense.accessibilitySafe(isAccessibilityEnabled: true) == .compact)
        #expect(GlassDensity.extraDense.accessibilitySafe(isAccessibilityEnabled: true) == .compact)
    }

    @Test("Accessibility safe does not change safe densities")
    func accessibilitySafeNoChange() {
        #expect(GlassDensity.regular.accessibilitySafe(isAccessibilityEnabled: true) == .regular)
        #expect(GlassDensity.sparse.accessibilitySafe(isAccessibilityEnabled: true) == .sparse)
    }

    @Test("Accessibility safe is no-op when disabled")
    func accessibilitySafeDisabled() {
        #expect(GlassDensity.extraDense.accessibilitySafe(isAccessibilityEnabled: false) == .extraDense)
    }
}

@Suite("GlassEdge Tests")
struct GlassEdgeTests {

    @Test("Horizontal edges are top and bottom")
    func horizontalEdges() {
        #expect(GlassEdge.top.isHorizontal)
        #expect(GlassEdge.bottom.isHorizontal)
        #expect(!GlassEdge.leading.isHorizontal)
        #expect(!GlassEdge.trailing.isHorizontal)
    }

    @Test("Vertical edges are leading and trailing")
    func verticalEdges() {
        #expect(GlassEdge.leading.isVertical)
        #expect(GlassEdge.trailing.isVertical)
        #expect(!GlassEdge.top.isVertical)
        #expect(!GlassEdge.bottom.isVertical)
    }
}

@Suite("GlassVisualStyle Tests")
struct GlassVisualStyleTests {

    @Test("iconOnly detection")
    func iconOnlyDetection() {
        #expect(GlassVisualStyle.iconOnly.isIconOnly)
        #expect(!GlassVisualStyle.titleOnly.isIconOnly)
        #expect(!GlassVisualStyle.titleAndIcon.isIconOnly)
    }

    @Test("titleOnly detection")
    func titleOnlyDetection() {
        #expect(GlassVisualStyle.titleOnly.isTitleOnly)
        #expect(!GlassVisualStyle.iconOnly.isTitleOnly)
        #expect(!GlassVisualStyle.titleAndIcon.isTitleOnly)
    }

    @Test("Custom icon detection")
    func customIconDetection() {
        #expect(!GlassVisualStyle.iconOnly().hasCustomIcon)
        #expect(GlassVisualStyle.iconOnly(systemImage: "plus").hasCustomIcon)
        #expect(GlassVisualStyle.iconOnly(image: "custom").hasCustomIcon)
    }
}

@Suite("GlassTokens Tests")
struct GlassTokensTests {

    @Test("Opacity values are in valid range")
    func opacityValues() {
        #expect(GlassTokens.Opacity.backgroundFill >= 0 && GlassTokens.Opacity.backgroundFill <= 1)
        #expect(GlassTokens.Opacity.borderStroke >= 0 && GlassTokens.Opacity.borderStroke <= 1)
        #expect(GlassTokens.Opacity.disabled >= 0 && GlassTokens.Opacity.disabled <= 1)
    }

    @Test("Animation durations are positive")
    func animationDurations() {
        #expect(GlassTokens.Animation.selectionDuration > 0)
        #expect(GlassTokens.Animation.itemDuration > 0)
        #expect(GlassTokens.Animation.pressDuration > 0)
    }
}
