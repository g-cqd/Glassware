//
//  GlassBarModifier.swift
//  Glassware
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
struct GlassBarModifier: ViewModifier {
    let leadingItems: [AnyView]
    let trailingItems: [AnyView]
    let groups: [GlassGroup]
    let edge: GlassEdge
    let glass: Glass

    @Environment(\.glassDensity) private var density

    /// Namespace for glass effect grouping.
    @Namespace private var glassNamespace

    private var metrics: GlassMetrics {
        GlassMetrics(density: density)
    }

    init(
        edge: GlassEdge,
        glass: Glass,
        leadingItems: [GlassBarItem],
        trailingItems: [GlassBarItem],
        primaryItems: [GlassBarItem]
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
                    GlassContainer(
                        leadingItems: leadingItems,
                        trailingItems: trailingItems,
                        groups: groups,
                        edge: edge,
                        glass: glass,
                        glassNamespace: glassNamespace,
                        collapseConfig: nil
                    )
                }
                .environment(\.glassEdge, edge)
            }
    }
}
