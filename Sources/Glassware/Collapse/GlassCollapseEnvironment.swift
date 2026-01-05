//
//  GlassCollapseEnvironment.swift
//  Glassware
//
//  Environment values for glass bar collapse behavior.
//

import SwiftUI

// MARK: - Environment Values

extension EnvironmentValues {
    /// Configuration for glass bar collapse behavior.
    /// When nil, collapse is disabled.
    @Entry public var glassCollapseConfiguration: GlassCollapseConfiguration? = nil

    /// Current collapse state (read-only, set by the collapse system).
    @Entry public var glassCollapseState: GlassCollapseState = .expanded

    /// Whether manual override is active (user tapped merge icon).
    /// When true, scroll-based collapse is temporarily disabled.
    @Entry var glassCollapseManualOverride: Bool = false

    /// Current scroll content offset for collapse calculations.
    @Entry var glassScrollOffset: CGFloat = 0
}

// MARK: - Collapse State Binding

/// Action closure for toggling collapse state manually.
public typealias GlassCollapseToggleAction = @MainActor @Sendable () -> Void

extension EnvironmentValues {
    /// Action to toggle collapse state from within glass bar buttons.
    @Entry var glassCollapseToggle: GlassCollapseToggleAction? = nil
}
