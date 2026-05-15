//
//  GlassMetricsContextTests.swift
//  GlasswareTests
//
//  Covers context-aware sizing — the path that picks different container
//  heights and padding adjustments based on edge / accessory / collapse
//  state. Without a context, metrics fall back to a density-only path; with
//  a context, the published container heights match Apple's native iOS
//  navigation/tab patterns (44pt top, 62pt bottom expanded, etc.).
//

import Testing
@testable import Glassware

@Suite("GlassMetrics context-aware sizing")
struct GlassMetricsContextTests {

    @Test("No-context init falls back to density-derived container height")
    func noContextFallback() {
        let metrics = GlassMetrics(density: .regular)
        // .regular density: minimumTapTarget = 44, containerPadding = 3 → 44 + 6 = 50
        #expect(metrics.minimumTapTarget == 44)
        #expect(metrics.containerPadding == 3)
        #expect(metrics.effectiveContainerHeight == 50)
    }

    @Test("Top edge context yields 44pt container height")
    func topEdgeHeight() {
        let context = GlassEdgeContext(edge: .top)
        let metrics = GlassMetrics(density: .regular, context: context)
        #expect(metrics.effectiveContainerHeight == 44)
    }

    @Test("Bottom edge expanded context yields 62pt container height")
    func bottomExpandedHeight() {
        let context = GlassEdgeContext(edge: .bottom, collapseState: .expanded)
        let metrics = GlassMetrics(density: .regular, context: context)
        #expect(metrics.effectiveContainerHeight == 62)
    }

    @Test("Bottom edge collapsed context yields 48pt container height")
    func bottomCollapsedHeight() {
        let context = GlassEdgeContext(edge: .bottom, collapseState: .collapsed)
        let metrics = GlassMetrics(density: .regular, context: context)
        #expect(metrics.effectiveContainerHeight == 48)
    }

    @Test("Accessory placement is always 48pt regardless of edge or collapse")
    func accessoryHeightIsConstant() {
        for edge in [GlassEdge.top, .bottom, .leading, .trailing] {
            for state in [GlassCollapseState.expanded, .collapsed] {
                let context = GlassEdgeContext(edge: edge, isAccessory: true, collapseState: state)
                let metrics = GlassMetrics(density: .regular, context: context)
                #expect(metrics.effectiveContainerHeight == 48)
            }
        }
    }

    @Test("Side edges are 48pt")
    func sideEdgeHeight() {
        for edge in [GlassEdge.leading, .trailing] {
            let context = GlassEdgeContext(edge: edge)
            let metrics = GlassMetrics(density: .regular, context: context)
            #expect(metrics.effectiveContainerHeight == 48)
        }
    }

    @Test("Effective padding never goes negative")
    func paddingNeverNegative() {
        // extraDense + a context with strong negative adjustment must clamp to 0
        // rather than wrap around. Otherwise a future tuning of the
        // GlassEdgeContext adjustment values could silently introduce
        // negative-padding bugs that only surface as overlapping content.
        let context = GlassEdgeContext(edge: .top)
        let metrics = GlassMetrics(density: .extraDense, context: context)
        #expect(metrics.effectiveComponentPadding >= 0)
        #expect(metrics.effectiveContainerPadding >= 0)
    }
}
