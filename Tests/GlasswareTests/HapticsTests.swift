//
//  HapticsTests.swift
//  GlasswareTests
//
//  Covers GlassHapticsConfiguration resolution logic. Cannot test the actual
//  Taptic Engine firing — that needs hardware — but the gating policy
//  (enabled flag, low-power suppression, event mapping) is pure data.
//

import Testing
import SwiftUI
@testable import Glassware

@Suite("GlassHapticsConfiguration Tests")
struct GlassHapticsConfigurationTests {

    @Test("Disabled config returns nil for every event")
    func disabledNoOps() {
        let config = GlassHapticsConfiguration.disabled
        for event in GlassHapticEvent.allCases {
            #expect(config.feedback(for: event) == nil)
        }
    }

    @Test("Standard config returns non-nil feedback for every event")
    func standardCovers() {
        let config = GlassHapticsConfiguration.standard
        for event in GlassHapticEvent.allCases {
            #expect(config.feedback(for: event) != nil)
        }
    }

    @Test("Standard maps selectionChange to .selection")
    func selectionMapping() {
        let config = GlassHapticsConfiguration.standard
        #expect(config.feedback(for: .selectionChange) == .selection)
    }

    @Test("Standard maps outcome events to their semantic feedbacks")
    func outcomeMappings() {
        let config = GlassHapticsConfiguration.standard
        #expect(config.feedback(for: .success) == .success)
        #expect(config.feedback(for: .warning) == .warning)
        #expect(config.feedback(for: .error) == .error)
    }

    @Test("Custom mapping is honored")
    func customMapping() {
        let config = GlassHapticsConfiguration(
            selectionChange: .impact(weight: .heavy),
            boundaryReached: nil
        )
        #expect(config.feedback(for: .selectionChange) == .impact(weight: .heavy))
        #expect(config.feedback(for: .boundaryReached) == nil)
        // Unspecified events fall back to the init's defaults.
        #expect(config.feedback(for: .success) == .success)
    }

    @Test("isEnabled = false overrides every mapping including outcomes")
    func disabledOverridesOutcomes() {
        var config = GlassHapticsConfiguration.standard
        config.isEnabled = false
        for event in GlassHapticEvent.allCases {
            #expect(config.feedback(for: event) == nil)
        }
    }
}

@Suite("GlassHapticEvent Tests")
struct GlassHapticEventTests {

    @Test("Outcome events are exactly success/warning/error")
    func outcomeClassification() {
        #expect(GlassHapticEvent.success.isOutcome)
        #expect(GlassHapticEvent.warning.isOutcome)
        #expect(GlassHapticEvent.error.isOutcome)
    }

    @Test("Non-outcome events are correctly classified")
    func nonOutcomeClassification() {
        #expect(!GlassHapticEvent.selectionChange.isOutcome)
        #expect(!GlassHapticEvent.boundaryReached.isOutcome)
        #expect(!GlassHapticEvent.toggleOn.isOutcome)
        #expect(!GlassHapticEvent.toggleOff.isOutcome)
        #expect(!GlassHapticEvent.commit.isOutcome)
    }

    @Test("CaseIterable covers all eight semantic events")
    func caseCount() {
        #expect(GlassHapticEvent.allCases.count == 8)
    }
}
