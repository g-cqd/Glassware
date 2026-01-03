//
//  ToolbarCollapseEnvironment.swift
//  GlassToolbar
//
//  Environment values for toolbar collapse behavior.
//

import SwiftUI

// MARK: - Environment Values

extension EnvironmentValues {
    /// Configuration for toolbar collapse behavior.
    /// When nil, collapse is disabled.
    @Entry public var toolbarCollapseConfiguration: ToolbarCollapseConfiguration? = nil

    /// Current collapse state (read-only, set by the collapse system).
    @Entry public var toolbarCollapseState: ToolbarCollapseState = .expanded

    /// Whether manual override is active (user tapped merge icon).
    /// When true, scroll-based collapse is temporarily disabled.
    @Entry var toolbarCollapseManualOverride: Bool = false

    /// Current scroll content offset for collapse calculations.
    @Entry var toolbarScrollOffset: CGFloat = 0
}

// MARK: - Collapse State Binding

/// Action closure for toggling collapse state manually.
public typealias ToolbarCollapseToggleAction = @MainActor @Sendable () -> Void

extension EnvironmentValues {
    /// Action to toggle collapse state from within toolbar buttons.
    @Entry var toolbarCollapseToggle: ToolbarCollapseToggleAction? = nil
}
