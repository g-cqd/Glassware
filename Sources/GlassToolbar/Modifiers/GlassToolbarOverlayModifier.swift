//
//  GlassToolbarOverlayModifier.swift
//  GlassToolbar
//
//  Multi-edge toolbar overlay modifier using placement-based API.
//

import SwiftUI

// MARK: - Edge Configuration

/// Configuration for a single edge's toolbar content.
struct EdgeToolbarConfiguration {
    var leadingItems: [AnyView] = []
    var primaryItems: [AnyView] = []
    var trailingItems: [AnyView] = []
    var accessories: [(view: AnyView, offset: CGFloat)] = []

    var isEmpty: Bool {
        leadingItems.isEmpty && primaryItems.isEmpty && trailingItems.isEmpty
    }
}

// MARK: - Glass Toolbar Overlay Modifier

/// Modifier that applies multi-edge glass toolbar overlay.
///
/// This modifier positions toolbar items at any combination of edges,
/// supporting accessories with configurable offsets.
///
/// ## Performance
/// - Single overlay with ZStack for all edges
/// - Lazy rendering: Only non-empty edges create containers
/// - Per-edge namespace isolation for animations
struct GlassToolbarOverlayModifier: ViewModifier {
    let items: [AnyGlassToolbarContent]
    let glass: Glass

    init(items: [AnyGlassToolbarContent], glass: Glass) {
        self.items = items
        self.glass = glass
    }

    /// Configurations grouped by edge.
    private var edgeConfigurations: [ToolbarEdge: EdgeToolbarConfiguration] {
        var configs: [ToolbarEdge: EdgeToolbarConfiguration] = [:]

        for item in items {
            let edge = item.placement.edge

            if configs[edge] == nil {
                configs[edge] = EdgeToolbarConfiguration()
            }

            if item.placement.isAccessory {
                let offset = item.placement.accessoryOffset ?? 0
                configs[edge]?.accessories.append((AnyView(item), offset))
            } else {
                switch item.placement.position {
                case .leading:
                    configs[edge]?.leadingItems.append(AnyView(item))
                case .primary:
                    configs[edge]?.primaryItems.append(AnyView(item))
                case .trailing:
                    configs[edge]?.trailingItems.append(AnyView(item))
                }
            }
        }

        return configs
    }

    func body(content: Content) -> some View {
        content.overlay {
            ZStack {
                ForEach(Array(edgeConfigurations.keys.sorted(by: { $0.rawValue < $1.rawValue })), id: \.rawValue) { edge in
                    if let config = edgeConfigurations[edge] {
                        EdgeToolbarContainer(
                            edge: edge,
                            config: config,
                            glass: glass
                        )
                        .frame(
                            maxWidth: edge.isHorizontal ? .infinity : nil,
                            maxHeight: edge.isVertical ? .infinity : nil,
                            alignment: edge.overlayAlignment
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Edge Toolbar Container

/// Container for a single edge's toolbar content with accessory support.
private struct EdgeToolbarContainer: View {
    let edge: ToolbarEdge
    let config: EdgeToolbarConfiguration
    let glass: Glass

    @Environment(\.toolbarDensity) private var density

    private var metrics: ToolbarMetrics {
        ToolbarMetrics(density: density)
    }

    var body: some View {
        // Stack primary content with accessories
        let accessoryLayout = edge.isHorizontal
            ? AnyLayout(VStackLayout(spacing: 0))
            : AnyLayout(HStackLayout(spacing: 0))

        accessoryLayout {
            // Accessories before primary (for top/leading edges)
            if edge == .top || edge == .leading {
                accessoryViews(beforePrimary: true)
            }

            // Primary toolbar container
            if !config.isEmpty {
                ToolbarContainer(
                    leadingItems: config.leadingItems,
                    trailingItems: config.trailingItems,
                    groups: primaryGroups,
                    edge: edge,
                    glass: glass
                )
            }

            // Accessories after primary (for bottom/trailing edges)
            if edge == .bottom || edge == .trailing {
                accessoryViews(beforePrimary: false)
            }
        }
    }

    /// Converts primary items into ToolbarGroup format.
    private var primaryGroups: [ToolbarGroup] {
        guard !config.primaryItems.isEmpty else { return [] }
        return [ToolbarGroup(id: 0, items: config.primaryItems, trailingSpacer: nil)]
    }

    /// Renders accessory views with appropriate offsets.
    @ViewBuilder
    private func accessoryViews(beforePrimary: Bool) -> some View {
        let relevantAccessories = config.accessories

        ForEach(Array(relevantAccessories.enumerated()), id: \.offset) { _, accessory in
            accessory.view
                .padding(accessoryPadding(offset: accessory.offset, beforePrimary: beforePrimary))
        }
    }

    /// Calculates padding for accessory based on offset.
    private func accessoryPadding(offset: CGFloat, beforePrimary: Bool) -> EdgeInsets {
        // Negative offset = overlap (move toward primary)
        // Positive offset = separation (move away from primary)
        let adjustedOffset = beforePrimary ? offset : offset

        switch edge {
        case .top:
            return EdgeInsets(top: 0, leading: 0, bottom: adjustedOffset, trailing: 0)
        case .bottom:
            return EdgeInsets(top: adjustedOffset, leading: 0, bottom: 0, trailing: 0)
        case .leading:
            return EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: adjustedOffset)
        case .trailing:
            return EdgeInsets(top: 0, leading: adjustedOffset, bottom: 0, trailing: 0)
        }
    }
}

// MARK: - View Extension

extension View {
    /// Applies a multi-edge glass toolbar overlay using placement-based API.
    ///
    /// This API allows positioning toolbar items at any edge and supports
    /// accessory views with configurable spacing.
    ///
    /// ## Usage
    /// ```swift
    /// .glassToolbarOverlay {
    ///     GlassToolbarItem(placement: .bottomLeading) {
    ///         Button("Settings", systemImage: "gearshape") { }
    ///             .buttonStyle(.toolbarItem(style: .iconOnly()))
    ///     }
    ///
    ///     GlassToolbarItemGroup(placement: .bottomPrimary) {
    ///         ForEach(tabs) { tab in
    ///             Button(tab.title, systemImage: tab.icon) { selectedTab = tab }
    ///                 .buttonStyle(.toolbarItem(isSelected: selectedTab == tab))
    ///         }
    ///     }
    ///
    ///     GlassToolbarItem(placement: .bottomAccessory(offset: -8)) {
    ///         VehiclePicker(selection: $vehicle)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - glass: The glass effect style to apply.
    ///   - content: A builder closure providing toolbar items.
    /// - Returns: A view with the glass toolbar overlay applied.
    public func glassToolbarOverlay(
        glass: Glass = .regular,
        @GlassToolbarBuilder content: () -> [AnyGlassToolbarContent]
    ) -> some View {
        modifier(GlassToolbarOverlayModifier(items: content(), glass: glass))
    }
}
