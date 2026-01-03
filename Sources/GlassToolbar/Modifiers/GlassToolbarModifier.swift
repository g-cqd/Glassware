//
//  GlassToolbarModifier.swift
//  GlassToolbar
//
//  View modifier for applying glass toolbar to views.
//

import SwiftUI

// MARK: - Glass Toolbar Modifier

/// Modifier that applies glass toolbar to a view.
///
/// The toolbar is positioned at the specified edge using an overlay.
/// This approach is efficient because:
/// - Toolbar doesn't affect parent content's layout
/// - Overlay is not in scroll content (no cell recycling concerns)
/// - Single overlay per view hierarchy
///
/// The edge parameter determines:
/// - Overlay alignment (top, bottom, leading, trailing)
/// - Layout orientation (horizontal for top/bottom, vertical for leading/trailing)
/// - Safe area handling (appropriate insets for each edge)
struct GlassToolbarModifier: ViewModifier {
    let leadingItems: [AnyView]
    let trailingItems: [AnyView]
    let groups: [ToolbarGroup]
    let edge: ToolbarEdge
    let glass: Glass

    @Environment(\.toolbarDensity) private var density

    /// Namespace for glass effect grouping.
    @Namespace private var glassNamespace

    private var metrics: ToolbarMetrics {
        ToolbarMetrics(density: density)
    }

    init(
        edge: ToolbarEdge,
        glass: Glass,
        leadingItems: [ToolbarItem],
        trailingItems: [ToolbarItem],
        primaryItems: [ToolbarItem]
    ) {
        self.edge = edge
        self.glass = glass
        self.leadingItems = leadingItems.compactMap { item in
            if case .view(let view) = item { return view }
            return nil
        }
        self.trailingItems = trailingItems.compactMap { item in
            if case .view(let view) = item { return view }
            return nil
        }
        self.groups = parseItems(primaryItems)
    }

    func body(content: Content) -> some View {
        content
            .overlay(alignment: edge.overlayAlignment) {
                GlassEffectContainer(spacing: metrics.containerSpacing) {
                    ToolbarContainer(
                        leadingItems: leadingItems,
                        trailingItems: trailingItems,
                        groups: groups,
                        edge: edge,
                        glass: glass,
                        glassNamespace: glassNamespace
                    )
                }
                .environment(\.toolbarEdge, edge)
            }
    }
}
