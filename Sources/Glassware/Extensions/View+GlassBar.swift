//
//  View+GlassBar.swift
//  Glassware
//
//  View extension for adding glass bar.
//

import SwiftUI

// MARK: - View Extension

extension View {
    /// Adds a glass-effect bar with configurable edge, content, and layout.
    ///
    /// The bar can be positioned at any edge of the screen and automatically adapts:
    /// - **Top/Bottom edges**: Horizontal layout with items flowing left-to-right
    /// - **Leading/Trailing edges**: Vertical layout with items flowing top-to-bottom
    ///
    /// ## Edge Alignment
    /// ```swift
    /// // Bottom bar (default)
    /// .glassBar { ... }
    ///
    /// // Top bar
    /// .glassBar(edge: .top) { ... }
    ///
    /// // Side bar (vertical layout)
    /// .glassBar(edge: .leading) { ... }
    /// ```
    ///
    /// ## Density
    /// Control bar density via environment:
    /// ```swift
    /// .glassBar { ... }
    ///     .glassDensity(.dense)       // Dense layout
    ///     .glassDensity(.sparse)      // Spacious layout
    ///     .glassDensity(.extraDense)  // Ultra-compact
    /// ```
    ///
    /// ## Glass Effect
    /// Customize the glass material:
    /// ```swift
    /// .glassBar(effect: .thin) { ... }    // Thinner glass
    /// .glassBar(effect: .regular) { ... } // Default glass
    /// ```
    ///
    /// - Parameters:
    ///   - edge: The screen edge where the bar is positioned. Defaults to `.bottom`.
    ///   - effect: The glass effect material for bar containers. Defaults to `.regular`.
    ///   - leading: Optional leading items (top items for vertical layout).
    ///   - content: Primary bar content.
    ///   - trailing: Optional trailing items (bottom items for vertical layout).
    /// - Returns: A view with the glass bar overlay.
    public func glassBar(
        edge: GlassEdge = .bottom,
        effect: Glass = .regular,
        @GlassContentBuilder leading: () -> [GlassBarItem] = { [] },
        @GlassContentBuilder content: () -> [GlassBarItem],
        @GlassContentBuilder trailing: () -> [GlassBarItem] = { [] }
    ) -> some View {
        modifier(
            GlassBarModifier(
                edge: edge,
                glass: effect,
                leadingItems: leading(),
                trailingItems: trailing(),
                primaryItems: content()
            )
        )
    }
}
