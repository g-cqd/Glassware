//
//  View+GlassToolbar.swift
//  GlassToolbar
//
//  View extension for adding glass toolbar.
//

import SwiftUI

// MARK: - View Extension

extension View {
    /// Adds a glass-effect toolbar with configurable edge, content, and layout.
    ///
    /// The toolbar can be positioned at any edge of the screen and automatically adapts:
    /// - **Top/Bottom edges**: Horizontal layout with items flowing left-to-right
    /// - **Leading/Trailing edges**: Vertical layout with items flowing top-to-bottom
    ///
    /// ## Edge Alignment
    /// ```swift
    /// // Bottom toolbar (default)
    /// .glassToolbar { ... }
    ///
    /// // Top toolbar
    /// .glassToolbar(edge: .top) { ... }
    ///
    /// // Side toolbar (vertical layout)
    /// .glassToolbar(edge: .leading) { ... }
    /// ```
    ///
    /// ## Density
    /// Control toolbar density via environment:
    /// ```swift
    /// .glassToolbar { ... }
    ///     .toolbarDensity(.dense)       // Dense layout
    ///     .toolbarDensity(.sparse)      // Spacious layout
    ///     .toolbarDensity(.extraDense)  // Ultra-compact
    /// ```
    ///
    /// ## Glass Effect
    /// Customize the glass material:
    /// ```swift
    /// .glassToolbar(glass: .thin) { ... }    // Thinner glass
    /// .glassToolbar(glass: .regular) { ... } // Default glass
    /// ```
    ///
    /// - Parameters:
    ///   - edge: The screen edge where the toolbar is positioned. Defaults to `.bottom`.
    ///   - glass: The glass effect material for toolbar containers. Defaults to `.regular`.
    ///   - leading: Optional leading items (top items for vertical layout).
    ///   - content: Primary toolbar content.
    ///   - trailing: Optional trailing items (bottom items for vertical layout).
    /// - Returns: A view with the glass toolbar overlay.
    public func glassToolbar(
        edge: ToolbarEdge = .bottom,
        glass: Glass = .regular,
        @ToolbarContentBuilder leading: () -> [ToolbarItem] = { [] },
        @ToolbarContentBuilder content: () -> [ToolbarItem],
        @ToolbarContentBuilder trailing: () -> [ToolbarItem] = { [] }
    ) -> some View {
        modifier(
            GlassToolbarModifier(
                edge: edge,
                glass: glass,
                leadingItems: leading(),
                trailingItems: trailing(),
                primaryItems: content()
            )
        )
    }
}
