//
//  GlassCollapseConfiguration.swift
//  Glassware
//
//  Configuration types for scroll-responsive toolbar collapse behavior.
//

import SwiftUI

// MARK: - Toolbar Merge Side

/// Specifies which side primary content merges into when collapsed.
public enum GlassMergeSide: Int, Sendable, Equatable {
    /// Primary content merges behind the leading container.
    case leading = 0

    /// Primary content merges behind the trailing container.
    case trailing = 1
}

// MARK: - Toolbar Collapse State

/// Represents the current collapse state of the toolbar.
public enum GlassCollapseState: Sendable, Equatable {
    /// Toolbar is fully expanded with primary content visible.
    case expanded

    /// Toolbar is collapsed with primary content merged into side container.
    case collapsed
}

// MARK: - Toolbar Collapse Configuration

/// Configuration for scroll-responsive toolbar collapse behavior.
///
/// When enabled, scrolling down causes primary toolbar content to merge
/// into a specified side container, while the accessory slides into
/// the primary position.
///
/// ## Usage
/// ```swift
/// .glass {
///     // Toolbar items...
/// }
/// .toolbarCollapseEnabled(
///     configuration: GlassCollapseConfiguration(
///         mergeSide: .trailing,
///         mergeIcon: "ellipsis.circle",
///         collapseThreshold: 80,
///         expandThreshold: 30
///     ),
///     scrollOffset: $scrollOffset
/// )
/// ```
///
/// ## Hysteresis
/// The separate collapse and expand thresholds create hysteresis,
/// preventing state flickering when scrolling near the boundary.
public struct GlassCollapseConfiguration: Sendable, Equatable {
    /// Which side to merge primary content into.
    public let mergeSide: GlassMergeSide

    /// SF Symbol name for the merge action icon.
    /// Tapping this icon toggles between collapsed/expanded states.
    public let mergeIcon: String

    /// Scroll offset threshold to trigger collapse (positive = scroll down).
    /// When content offset exceeds this value, toolbar collapses.
    public let collapseThreshold: CGFloat

    /// Scroll offset threshold to trigger expansion.
    /// When content offset drops below this value, toolbar expands.
    /// Hysteresis prevents flickering at the boundary.
    public let expandThreshold: CGFloat

    /// Animation timing for state transitions.
    public let animation: Animation

    /// Creates a collapse configuration.
    ///
    /// - Parameters:
    ///   - mergeSide: Side to merge primary content into. Defaults to `.trailing`.
    ///   - mergeIcon: SF Symbol for merge button. Defaults to `"ellipsis.circle"`.
    ///   - collapseThreshold: Offset to trigger collapse. Defaults to `80`.
    ///   - expandThreshold: Offset to trigger expansion. Defaults to `30`.
    ///   - animation: Transition animation. Defaults to spring.
    public init(
        mergeSide: GlassMergeSide = .trailing,
        mergeIcon: String = "ellipsis.circle",
        collapseThreshold: CGFloat = 80,
        expandThreshold: CGFloat = 30,
        animation: Animation = .spring(duration: 0.35, bounce: 0.2)
    ) {
        self.mergeSide = mergeSide
        self.mergeIcon = mergeIcon
        self.collapseThreshold = collapseThreshold
        self.expandThreshold = expandThreshold
        self.animation = animation
    }

    // MARK: - Presets

    /// Default configuration with trailing merge.
    public static let `default` = GlassCollapseConfiguration()

    /// Configuration merging to leading side.
    public static let leadingMerge = GlassCollapseConfiguration(mergeSide: .leading)

    /// Aggressive collapse with lower thresholds for quick response.
    public static let aggressive = GlassCollapseConfiguration(
        collapseThreshold: 40,
        expandThreshold: 15
    )

    /// Relaxed collapse with higher thresholds for less frequent transitions.
    public static let relaxed = GlassCollapseConfiguration(
        collapseThreshold: 120,
        expandThreshold: 50
    )
}
