//
//  GlassCollapseTests.swift
//  GlasswareTests
//

import Testing
@testable import Glassware

@Suite("GlassCollapseConfiguration Tests")
struct GlassCollapseConfigurationTests {

    @Test("Default config has trailing merge and reasonable thresholds")
    func defaults() {
        let config = GlassCollapseConfiguration.default
        #expect(config.mergeSide == .trailing)
        #expect(config.collapseThreshold == 80)
        #expect(config.expandThreshold == 30)
        #expect(config.expandThreshold < config.collapseThreshold)
    }

    @Test("All presets satisfy the hysteresis invariant")
    func presetsHonorInvariant() {
        for preset in [
            GlassCollapseConfiguration.default,
            .leadingMerge,
            .aggressive,
            .relaxed
        ] {
            #expect(
                preset.expandThreshold < preset.collapseThreshold,
                "Preset \(preset) violates hysteresis invariant"
            )
        }
    }

    @Test("Leading merge preset has leading mergeSide")
    func leadingMergePreset() {
        #expect(GlassCollapseConfiguration.leadingMerge.mergeSide == .leading)
    }

    @Test("Aggressive preset has lower thresholds than default")
    func aggressiveIsLower() {
        let aggressive = GlassCollapseConfiguration.aggressive
        let standard = GlassCollapseConfiguration.default
        #expect(aggressive.collapseThreshold < standard.collapseThreshold)
        #expect(aggressive.expandThreshold < standard.expandThreshold)
    }

    @Test("Relaxed preset has higher thresholds than default")
    func relaxedIsHigher() {
        let relaxed = GlassCollapseConfiguration.relaxed
        let standard = GlassCollapseConfiguration.default
        #expect(relaxed.collapseThreshold > standard.collapseThreshold)
        #expect(relaxed.expandThreshold > standard.expandThreshold)
    }

    @Test("Equatable considers all stored properties")
    func equatable() {
        let a = GlassCollapseConfiguration(mergeSide: .leading, collapseThreshold: 50, expandThreshold: 20)
        let b = GlassCollapseConfiguration(mergeSide: .leading, collapseThreshold: 50, expandThreshold: 20)
        let c = GlassCollapseConfiguration(mergeSide: .trailing, collapseThreshold: 50, expandThreshold: 20)
        #expect(a == b)
        #expect(a != c)
    }
}

@Suite("GlassCollapseState Tests")
struct GlassCollapseStateTests {

    @Test("Collapse states are not equal to each other")
    func statesDistinct() {
        #expect(GlassCollapseState.expanded != GlassCollapseState.collapsed)
    }
}
