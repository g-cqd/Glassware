//
//  EdgeSafeAreaModifier.swift
//  Glassware
//
//  Safe area handling for toolbar edges.
//

import SwiftUI

// MARK: - Edge Safe Area Modifier

/// Applies appropriate safe area padding based on the toolbar edge and padding configuration.
///
/// This modifier handles the complexity of safe area management for each edge:
/// - **Top/Bottom**: Uses `safeAreaPadding` to respect notch/home indicator
/// - **Leading/Trailing**: Uses regular `padding` for consistent inset from screen edge
///
/// The difference is important because:
/// - Top has Dynamic Island/notch safe area inset
/// - Bottom has home indicator safe area inset
/// - Leading/Trailing typically have no safe area inset (except rounded corners)
///   so we use regular padding to ensure visible spacing from the edge
///
/// ## Padding Configuration
///
/// The `GlassPaddingConfiguration` controls:
/// - `externalPadding`: Always used for horizontal margins (default: 16)
/// - `additionalPadding`: Extra padding from safe area edge (`nil` uses density-based)
/// - `ignoresSafeArea`: When true, positions at screen edge ignoring safe area
struct EdgeSafeAreaModifier: ViewModifier {
    let edge: GlassEdge
    let paddingConfig: GlassPaddingConfiguration
    let density: GlassDensity

    /// External padding from screen edges (always uses config value).
    private var externalPadding: CGFloat {
        paddingConfig.externalPadding
    }

    /// Additional padding from safe area edge.
    private var additionalPadding: CGFloat {
        paddingConfig.resolvedAdditionalPadding(density: density)
    }

    /// Minimum inset required to clear the device rounded-corner curve on
    /// `.top` / `.bottom` edges. In landscape iPhone the system reports a
    /// top safe-area inset of 0pt, so `safeAreaPadding(.top, 0)` (the
    /// `.tight` configuration) lets the bar render under the corner
    /// radius. Apple's HIG corner-clearance recommendation is ~8pt; we
    /// enforce that as a floor independent of the user-declared
    /// additional padding.
    private static let cornerClearance: CGFloat = 8

    func body(content: Content) -> some View {
        switch edge {
        case .bottom:
            if paddingConfig.ignoresSafeArea {
                // Edge-to-edge: Position at screen bottom, ignore safe area
                content
                    .padding(.horizontal, externalPadding)
                    .padding(.bottom, additionalPadding)
                    .ignoresSafeArea(.all, edges: .bottom)
            } else {
                // Respect safe area: bar sits inside the home-indicator inset
                // AND inside the horizontal safe area. In landscape on devices
                // with Dynamic Island / rounded corners the horizontal inset
                // can exceed `externalPadding`; without honouring it the bar
                // items render under those system regions (reported
                // 2026-05-15, landscape capture, Glass top-trailing button
                // clipped under the corner radius). `safeAreaPadding` stacks
                // with the system inset rather than replacing it, so the
                // declared `externalPadding` is added on top of whatever the
                // device demands. `max(additionalPadding, cornerClearance)`
                // enforces a minimum ~8pt visual gap from the device's
                // rounded-corner curve even when the caller explicitly
                // asked for zero additional padding via `.tight`.
                content
                    .safeAreaPadding(.horizontal, externalPadding)
                    .ignoresSafeArea(.all, edges: .bottom)
                    .safeAreaPadding(.bottom, max(additionalPadding, Self.cornerClearance))
            }

        case .top:
            // Top: bar sits below the notch / Dynamic Island and inside the
            // horizontal safe area. Same rationale as `.bottom` above —
            // landscape capture showed Glass top-trailing buttons partially
            // clipped under the device corner radius when we ignored the
            // horizontal container inset and used a zero additional
            // padding. The `max(_, cornerClearance)` guarantees the bar
            // keeps ~8pt off the curve in landscape (where the system top
            // safe-area inset is 0).
            content
                .safeAreaPadding(.horizontal, externalPadding)
                .safeAreaPadding(.top, max(additionalPadding, Self.cornerClearance))

        case .leading:
            // Leading: Use regular padding for consistent spacing from edge
            content
                .safeAreaPadding(.vertical, externalPadding)
                .padding(.leading, additionalPadding)

        case .trailing:
            // Trailing: Use regular padding for consistent spacing from edge
            content
                .safeAreaPadding(.vertical, externalPadding)
                .padding(.trailing, additionalPadding)
        }
    }
}
