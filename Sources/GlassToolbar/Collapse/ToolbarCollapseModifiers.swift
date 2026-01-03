//
//  ToolbarCollapseModifiers.swift
//  GlassToolbar
//
//  View modifiers for scroll-responsive toolbar collapse.
//

import SwiftUI

// MARK: - Scroll Offset Tracking Modifier

/// Modifier that tracks scroll content offset using onScrollGeometryChange.
struct ScrollOffsetTrackingModifier: ViewModifier {
    @Binding var offset: CGFloat

    func body(content: Content) -> some View {
        content
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                // contentOffset.y is positive when scrolled down
                geometry.contentOffset.y
            } action: { _, newOffset in
                offset = newOffset
            }
    }
}

// MARK: - Toolbar Collapse Modifier

/// Modifier that manages collapse state based on scroll offset.
///
/// This modifier:
/// 1. Tracks scroll offset changes
/// 2. Applies hysteresis thresholds to determine state
/// 3. Supports manual toggle override
/// 4. Propagates configuration and state via environment
struct ToolbarCollapseModifier: ViewModifier {
    let configuration: ToolbarCollapseConfiguration
    @Binding var scrollOffset: CGFloat

    @State private var collapseState: ToolbarCollapseState = .expanded
    @State private var isManualOverride: Bool = false

    func body(content: Content) -> some View {
        content
            .environment(\.toolbarCollapseConfiguration, configuration)
            .environment(\.toolbarCollapseState, collapseState)
            .environment(\.toolbarCollapseManualOverride, isManualOverride)
            .environment(\.toolbarScrollOffset, scrollOffset)
            .environment(\.toolbarCollapseToggle, toggle)
            .onChange(of: scrollOffset) { _, newOffset in
                updateCollapseState(for: newOffset)
            }
    }

    /// Updates collapse state based on scroll offset with hysteresis.
    private func updateCollapseState(for offset: CGFloat) {
        let atRestPosition = offset < configuration.expandThreshold

        // Clear manual override when scroll returns to rest position
        if isManualOverride && atRestPosition {
            isManualOverride = false
        }

        // Skip scroll-based changes while manually overridden
        guard !isManualOverride else { return }

        let shouldCollapse = offset > configuration.collapseThreshold
        let shouldExpand = atRestPosition

        switch collapseState {
        case .expanded where shouldCollapse:
            collapseState = .collapsed

        case .collapsed where shouldExpand:
            collapseState = .expanded

        default:
            break
        }
    }

    /// Toggles collapse state manually from merge icon tap.
    private func toggle() {
        if collapseState == .collapsed {
            collapseState = .expanded
        } else {
            collapseState = .collapsed
        }
        isManualOverride = true
    }
}

// MARK: - View Extensions

extension View {
    /// Tracks scroll offset for use with collapsible toolbar.
    ///
    /// Apply this modifier to a `ScrollView` to enable scroll-responsive
    /// toolbar collapse behavior.
    ///
    /// ## Usage
    /// ```swift
    /// ScrollView {
    ///     content
    /// }
    /// .trackScrollOffset($scrollOffset)
    /// ```
    ///
    /// - Parameter offset: Binding to store the current scroll offset.
    /// - Returns: A view that tracks scroll offset.
    public func trackScrollOffset(_ offset: Binding<CGFloat>) -> some View {
        modifier(ScrollOffsetTrackingModifier(offset: offset))
    }

    /// Enables scroll-responsive toolbar collapse behavior.
    ///
    /// When configured, scrolling down causes primary toolbar content to merge
    /// into a specified side, while the accessory slides to the primary position.
    ///
    /// ## Usage
    /// ```swift
    /// .glassToolbarOverlay {
    ///     GlassToolbarItem(placement: .bottomLeading) { settingsButton }
    ///     GlassToolbarItemGroup(placement: .bottomPrimary) { tabs }
    ///     GlassToolbarItem(placement: .bottomAccessory(offset: -16)) { picker }
    /// }
    /// .toolbarCollapseEnabled(
    ///     configuration: .init(mergeSide: .trailing, mergeIcon: "square.grid.2x2"),
    ///     scrollOffset: $scrollOffset
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - configuration: Configuration for collapse behavior.
    ///   - scrollOffset: Binding to the ScrollView's content offset.
    /// - Returns: A view with collapse-enabled toolbar.
    public func toolbarCollapseEnabled(
        configuration: ToolbarCollapseConfiguration = .default,
        scrollOffset: Binding<CGFloat>
    ) -> some View {
        modifier(ToolbarCollapseModifier(
            configuration: configuration,
            scrollOffset: scrollOffset
        ))
    }

    /// Sets the toolbar collapse configuration without scroll binding.
    ///
    /// Use this when you want to control collapse state programmatically
    /// without scroll-based triggering.
    ///
    /// - Parameter configuration: Configuration for collapse behavior.
    /// - Returns: A view with the collapse configuration applied.
    public func toolbarCollapseConfiguration(
        _ configuration: ToolbarCollapseConfiguration?
    ) -> some View {
        environment(\.toolbarCollapseConfiguration, configuration)
    }
}
