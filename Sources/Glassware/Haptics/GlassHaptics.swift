//
//  GlassHaptics.swift
//  Glassware
//
//  Haptic feedback vocabulary for Glassware components.
//

import SwiftUI

// MARK: - Semantic Events

/// Semantic events the library can emit through the Taptic Engine.
///
/// Glassware components emit events at meaningful interaction moments; the
/// active `GlasswareHapticsConfiguration` maps each event to a concrete
/// `SensoryFeedback`. Consumers override the mapping through the
/// `glasswareHaptics(_:)` environment modifier instead of touching components.
public enum GlassHapticEvent: Sendable, Equatable, CaseIterable {
    /// A discrete value moved to a new index — picker, stepper, segmented
    /// control. Apple's HIG canonical mapping is `.selection`.
    case selectionChange

    /// User pushed against a min/max — slider clamp, scroll rubber-band end,
    /// first/last cell of a segmented picker during a drag.
    case boundaryReached

    /// A two-state control flipped on.
    case toggleOn

    /// A two-state control flipped off.
    case toggleOff

    /// A value was committed — drag released onto a snap, slider lift-off.
    case commit

    /// Terminal warning (validation, almost-out-of-range).
    case warning

    /// Terminal error (rejected input, blocked action).
    case error

    /// Terminal success (apply, save, paid).
    case success
}

extension GlassHapticEvent {
    /// Outcome events still fire under Low Power Mode because they
    /// double as accessibility cues for blocked / completed actions.
    var isOutcome: Bool {
        switch self {
        case .warning, .error, .success: true
        case .selectionChange, .boundaryReached, .toggleOn, .toggleOff, .commit: false
        }
    }
}

// MARK: - Configuration

/// Mapping from `GlassHapticEvent` to `SensoryFeedback` plus a few system-level
/// gates. The default `.standard` follows Apple HIG: light selection clicks for
/// discrete movement, light/medium impacts for state changes and commits, and
/// the system semantic effects for warning / error / success.
public struct GlassHapticsConfiguration: Sendable, Equatable {
    /// Master enable. When false, components emit nothing.
    public var isEnabled: Bool

    /// When true (default), non-outcome events are suppressed while
    /// `ProcessInfo.processInfo.isLowPowerModeEnabled` is on. Outcome events
    /// (success / warning / error) still fire because they aid accessibility.
    public var suppressUnderLowPower: Bool

    public var selectionChange: SensoryFeedback?
    public var boundaryReached: SensoryFeedback?
    public var toggleOn: SensoryFeedback?
    public var toggleOff: SensoryFeedback?
    public var commit: SensoryFeedback?
    public var warning: SensoryFeedback?
    public var error: SensoryFeedback?
    public var success: SensoryFeedback?

    /// Creates a haptics configuration with optional per-event overrides.
    ///
    /// All parameters have HIG-aligned defaults — you typically only override
    /// the events whose feel you want to change. Pass `nil` for an event to
    /// silence it while leaving others active.
    ///
    /// - Parameters:
    ///   - isEnabled: Master switch. When false, every event resolves to nil.
    ///   - suppressUnderLowPower: Suppress non-outcome events while the
    ///     device is in Low Power Mode. Outcome events (success / warning /
    ///     error) keep firing because they double as accessibility cues for
    ///     completed or blocked actions.
    ///   - selectionChange: Discrete value moved — picker / segmented / stepper.
    ///   - boundaryReached: User pushed against min/max.
    ///   - toggleOn: Two-state control flipped on.
    ///   - toggleOff: Two-state control flipped off.
    ///   - commit: Value committed — drag released onto a snap.
    ///   - warning: Soft validation cue (close to limit, recoverable).
    ///   - error: Hard rejection (input blocked).
    ///   - success: Operation completed (apply, save, paid).
    public init(
        isEnabled: Bool = true,
        suppressUnderLowPower: Bool = true,
        selectionChange: SensoryFeedback? = .selection,
        boundaryReached: SensoryFeedback? = .impact(weight: .light, intensity: 0.6),
        toggleOn: SensoryFeedback? = .impact(weight: .light),
        toggleOff: SensoryFeedback? = .impact(weight: .light),
        commit: SensoryFeedback? = .impact(weight: .medium, intensity: 0.7),
        warning: SensoryFeedback? = .warning,
        error: SensoryFeedback? = .error,
        success: SensoryFeedback? = .success
    ) {
        self.isEnabled = isEnabled
        self.suppressUnderLowPower = suppressUnderLowPower
        self.selectionChange = selectionChange
        self.boundaryReached = boundaryReached
        self.toggleOn = toggleOn
        self.toggleOff = toggleOff
        self.commit = commit
        self.warning = warning
        self.error = error
        self.success = success
    }

    /// Default vocabulary recommended for Glassware components.
    public static let standard = GlassHapticsConfiguration()

    /// Fully silent.
    public static let disabled = GlassHapticsConfiguration(isEnabled: false)

    /// Resolves an event to the feedback that should actually be played, or
    /// `nil` if it should be skipped. Honors `isEnabled` and the Low Power
    /// Mode rule. The system Sounds & Haptics master switch is honored by
    /// `SensoryFeedback` itself, no extra gating needed here.
    func feedback(for event: GlassHapticEvent) -> SensoryFeedback? {
        guard isEnabled else { return nil }
        if suppressUnderLowPower,
           !event.isOutcome,
           ProcessInfo.processInfo.isLowPowerModeEnabled {
            return nil
        }
        return switch event {
        case .selectionChange: selectionChange
        case .boundaryReached: boundaryReached
        case .toggleOn: toggleOn
        case .toggleOff: toggleOff
        case .commit: commit
        case .warning: warning
        case .error: error
        case .success: success
        }
    }
}

// MARK: - Environment

extension EnvironmentValues {
    /// Active haptics configuration for Glassware components in this subtree.
    @Entry public var glasswareHaptics: GlassHapticsConfiguration = .standard
}

public extension View {
    /// Override the haptic vocabulary used by Glassware components in this
    /// subtree. Pass `.disabled` to silence haptics entirely.
    func glasswareHaptics(_ configuration: GlassHapticsConfiguration) -> some View {
        environment(\.glasswareHaptics, configuration)
    }

    /// Convenience: toggle haptics on or off without authoring a full
    /// configuration. Preserves any existing custom mapping when re-enabling.
    func glasswareHaptics(enabled: Bool) -> some View {
        transformEnvironment(\.glasswareHaptics) { config in
            config.isEnabled = enabled
        }
    }
}

// MARK: - Component-side Helper

extension View {
    /// Plays the configured `SensoryFeedback` for `event` each time `trigger`
    /// changes, honoring the active `GlasswareHapticsConfiguration`.
    func emitGlassHaptic<T: Equatable>(
        _ event: GlassHapticEvent,
        trigger: T
    ) -> some View {
        modifier(GlassHapticEmitter(event: event, trigger: trigger))
    }
}

private struct GlassHapticEmitter<T: Equatable>: ViewModifier {
    let event: GlassHapticEvent
    let trigger: T
    @Environment(\.glasswareHaptics) private var config

    func body(content: Content) -> some View {
        // The closure form of `.sensoryFeedback` runs on every trigger change
        // and returns the feedback to play (or nil to skip). That lets us
        // re-resolve the configuration each fire, so toggling Low Power Mode
        // or switching configurations mid-session takes effect immediately
        // without rebuilding the view tree.
        content.sensoryFeedback(trigger: trigger) { _, _ in
            config.feedback(for: event)
        }
    }
}
