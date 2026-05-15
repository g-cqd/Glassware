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
                // Respect safe area: Content padded above home indicator
                // Use regular .padding for horizontal to avoid stacking with device safe area
                // in landscape mode. The glass containers extend into the safe area naturally.
                content
                    .padding(.horizontal, externalPadding)
                    .ignoresSafeArea(.container, edges: .horizontal)
                    .ignoresSafeArea(.all, edges: .bottom)
                    .safeAreaPadding(.bottom, additionalPadding)
            }

        case .top:
            // Top: Content below notch/Dynamic Island with padding
            // Use regular .padding for horizontal to avoid stacking with device safe area
            content
                .padding(.horizontal, externalPadding)
                .ignoresSafeArea(.container, edges: .horizontal)
                .safeAreaPadding(.top, additionalPadding)

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
