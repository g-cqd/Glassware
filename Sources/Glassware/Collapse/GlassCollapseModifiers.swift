//
//  GlassCollapseModifiers.swift
//  Glassware
//
//  View modifiers for scroll-responsive glass bar collapse.
//

import SwiftUI

// MARK: - Scroll Offset Tracking Modifier

/// Modifier that tracks scroll content offset using onScrollGeometryChange.
///
/// The reported offset is quantised to integer points before being written back
/// to the binding. On ProMotion devices `onScrollGeometryChange` fires up to 120
/// times per second with sub-pixel deltas; without quantisation every tick
/// triggers downstream environment writes and re-evaluations of any view that
/// reads `glassScrollOffset` or derives state from the binding.
struct ScrollOffsetTrackingModifier: ViewModifier {
    @Binding var offset: CGFloat

    func body(content: Content) -> some View {
        content
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                // contentOffset.y is positive when scrolled down
                geometry.contentOffset.y
            } action: { _, newOffset in
                let quantised = newOffset.rounded()
                if offset != quantised {
                    offset = quantised
                }
            }
    }
}

// MARK: - Glass Collapse Modifier

/// Modifier that manages collapse state based on scroll offset.
///
/// This modifier:
/// 1. Tracks scroll offset changes
/// 2. Applies hysteresis thresholds to determine state
/// 3. Supports manual toggle override
/// 4. Propagates configuration and state via environment
struct GlassCollapseModifier: ViewModifier {
    let configuration: GlassCollapseConfiguration
    @Binding var scrollOffset: CGFloat

    @State private var collapseState: GlassCollapseState = .expanded
    @State private var isManualOverride: Bool = false

    func body(content: Content) -> some View {
        content
            .environment(\.glassCollapseConfiguration, configuration)
            .environment(\.glassCollapseState, collapseState)
            .environment(\.glassCollapseManualOverride, isManualOverride)
            .environment(\.glassScrollOffset, scrollOffset)
            .environment(\.glassCollapseToggle, toggle)
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

    /// Enables scroll-responsive glass bar collapse behavior.
    ///
    /// When configured, scrolling down causes primary content to merge
    /// into a specified side, while the accessory slides to the primary position.
    ///
    /// ## Usage
    /// ```swift
    /// .glass {
    ///     GlassItem(placement: .bottomLeading) { settingsButton }
    ///     GlassItemGroup(placement: .bottomPrimary) { tabs }
    ///     GlassItem(placement: .bottomAccessory(offset: -16)) { picker }
    /// }
    /// .glassCollapsible(
    ///     configuration: .init(mergeSide: .trailing, mergeIcon: "square.grid.2x2"),
    ///     scrollOffset: $scrollOffset
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - configuration: Configuration for collapse behavior.
    ///   - scrollOffset: Binding to the ScrollView's content offset.
    /// - Returns: A view with collapse-enabled glass bar.
    public func glassCollapsible(
        configuration: GlassCollapseConfiguration = .default,
        scrollOffset: Binding<CGFloat>
    ) -> some View {
        modifier(GlassCollapseModifier(
            configuration: configuration,
            scrollOffset: scrollOffset
        ))
    }

    /// Sets the glass bar collapse configuration without scroll binding.
    ///
    /// Use this when you want to control collapse state programmatically
    /// without scroll-based triggering.
    ///
    /// - Parameter configuration: Configuration for collapse behavior.
    /// - Returns: A view with the collapse configuration applied.
    public func glassCollapseConfiguration(
        _ configuration: GlassCollapseConfiguration?
    ) -> some View {
        environment(\.glassCollapseConfiguration, configuration)
    }
}
