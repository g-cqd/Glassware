//
//  GlassToolbarTests.swift
//  GlassToolbar
//

import Testing
@testable import GlassToolbar

@Suite("ToolbarMetrics Tests")
struct ToolbarMetricsTests {

    @Test("Minimum tap target respects accessibility guidelines at regular density")
    func minimumTapTargetAtRegular() {
        let metrics = ToolbarMetrics(density: .regular)
        #expect(metrics.minimumTapTarget >= 44)
    }

    @Test("Minimum tap target at extraDense is below guidelines")
    func minimumTapTargetAtExtraDense() {
        let metrics = ToolbarMetrics(density: .extraDense)
        #expect(metrics.minimumTapTarget < 44)
    }

    @Test("Edge padding decreases with density")
    func edgePaddingDecreases() {
        let sparse = ToolbarMetrics(density: .sparse)
        let regular = ToolbarMetrics(density: .regular)
        let dense = ToolbarMetrics(density: .dense)

        #expect(sparse.edgePadding > regular.edgePadding)
        #expect(regular.edgePadding > dense.edgePadding)
    }
}

@Suite("ToolbarDensity Tests")
struct ToolbarDensityTests {

    @Test("Accessibility safe upgrades dense densities")
    func accessibilitySafeUpgrades() {
        #expect(ToolbarDensity.dense.accessibilitySafe(isAccessibilityEnabled: true) == .compact)
        #expect(ToolbarDensity.extraDense.accessibilitySafe(isAccessibilityEnabled: true) == .compact)
    }

    @Test("Accessibility safe does not change safe densities")
    func accessibilitySafeNoChange() {
        #expect(ToolbarDensity.regular.accessibilitySafe(isAccessibilityEnabled: true) == .regular)
        #expect(ToolbarDensity.sparse.accessibilitySafe(isAccessibilityEnabled: true) == .sparse)
    }

    @Test("Accessibility safe is no-op when disabled")
    func accessibilitySafeDisabled() {
        #expect(ToolbarDensity.extraDense.accessibilitySafe(isAccessibilityEnabled: false) == .extraDense)
    }
}

@Suite("ToolbarEdge Tests")
struct ToolbarEdgeTests {

    @Test("Horizontal edges are top and bottom")
    func horizontalEdges() {
        #expect(ToolbarEdge.top.isHorizontal)
        #expect(ToolbarEdge.bottom.isHorizontal)
        #expect(!ToolbarEdge.leading.isHorizontal)
        #expect(!ToolbarEdge.trailing.isHorizontal)
    }

    @Test("Vertical edges are leading and trailing")
    func verticalEdges() {
        #expect(ToolbarEdge.leading.isVertical)
        #expect(ToolbarEdge.trailing.isVertical)
        #expect(!ToolbarEdge.top.isVertical)
        #expect(!ToolbarEdge.bottom.isVertical)
    }
}

@Suite("ToolbarItemVisualStyle Tests")
struct ToolbarItemVisualStyleTests {

    @Test("iconOnly detection")
    func iconOnlyDetection() {
        #expect(ToolbarItemVisualStyle.iconOnly.isIconOnly)
        #expect(!ToolbarItemVisualStyle.titleOnly.isIconOnly)
        #expect(!ToolbarItemVisualStyle.titleAndIcon.isIconOnly)
    }

    @Test("titleOnly detection")
    func titleOnlyDetection() {
        #expect(ToolbarItemVisualStyle.titleOnly.isTitleOnly)
        #expect(!ToolbarItemVisualStyle.iconOnly.isTitleOnly)
        #expect(!ToolbarItemVisualStyle.titleAndIcon.isTitleOnly)
    }

    @Test("Custom icon detection")
    func customIconDetection() {
        #expect(!ToolbarItemVisualStyle.iconOnly().hasCustomIcon)
        #expect(ToolbarItemVisualStyle.iconOnly(systemImage: "plus").hasCustomIcon)
        #expect(ToolbarItemVisualStyle.iconOnly(image: "custom").hasCustomIcon)
    }
}

@Suite("ToolbarTokens Tests")
struct ToolbarTokensTests {

    @Test("Opacity values are in valid range")
    func opacityValues() {
        #expect(ToolbarTokens.Opacity.backgroundFill >= 0 && ToolbarTokens.Opacity.backgroundFill <= 1)
        #expect(ToolbarTokens.Opacity.borderStroke >= 0 && ToolbarTokens.Opacity.borderStroke <= 1)
        #expect(ToolbarTokens.Opacity.disabled >= 0 && ToolbarTokens.Opacity.disabled <= 1)
    }

    @Test("Animation durations are positive")
    func animationDurations() {
        #expect(ToolbarTokens.Animation.selectionDuration > 0)
        #expect(ToolbarTokens.Animation.itemDuration > 0)
        #expect(ToolbarTokens.Animation.pressDuration > 0)
    }
}
