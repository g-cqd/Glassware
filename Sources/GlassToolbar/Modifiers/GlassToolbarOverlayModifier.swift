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

// MARK: - Toolbar Height Preference Key

/// Preference key for aggregating toolbar heights from all edges.
private struct ToolbarHeightPreferenceKey: PreferenceKey {
    static let defaultValue: ToolbarHeightReport = .empty

    static func reduce(value: inout ToolbarHeightReport, nextValue: () -> ToolbarHeightReport) {
        let next = nextValue()
        // Merge non-nil values from each edge
        if let bottom = next.bottom { value.bottom = bottom }
        if let top = next.top { value.top = top }
        if let leading = next.leading { value.leading = leading }
        if let trailing = next.trailing { value.trailing = trailing }
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
///
/// ## Height Notification
/// The modifier reports total toolbar heights via `toolbarHeights` environment.
/// Content views can use this to add padding that accounts for the floating toolbar:
/// ```swift
/// @Environment(\.toolbarHeights) private var toolbarHeights
/// content.safeAreaPadding(.bottom, toolbarHeights.bottom ?? 0)
/// ```
struct GlassToolbarOverlayModifier: ViewModifier {
    let items: [AnyGlassToolbarContent]
    let glass: Glass

    /// Tracked heights for all toolbar edges.
    @State private var heights: ToolbarHeightReport = .empty

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
        content
            // Inject heights into content's environment
            .environment(\.toolbarHeights, heights)
            // Each edge gets its own overlay with proper alignment
            .overlay(alignment: .top) {
                if let config = edgeConfigurations[.top] {
                    EdgeToolbarContainer(edge: .top, config: config, glass: glass)
                }
            }
            .overlay(alignment: .bottom) {
                if let config = edgeConfigurations[.bottom] {
                    EdgeToolbarContainer(edge: .bottom, config: config, glass: glass)
                }
            }
            .overlay(alignment: .leading) {
                if let config = edgeConfigurations[.leading] {
                    EdgeToolbarContainer(edge: .leading, config: config, glass: glass)
                }
            }
            .overlay(alignment: .trailing) {
                if let config = edgeConfigurations[.trailing] {
                    EdgeToolbarContainer(edge: .trailing, config: config, glass: glass)
                }
            }
            // Collect heights from all edge containers
            .onPreferenceChange(ToolbarHeightPreferenceKey.self) { newHeights in
                heights = newHeights
            }
    }
}

// MARK: - Edge Toolbar Container

/// Container for a single edge's toolbar content with accessory support.
///
/// Layout strategy:
/// - Primary toolbar renders at edge with glass containers
/// - Accessories are positioned using measured toolbar height + offset
/// - Negative offset = overlap, positive offset = separation
/// - All items share a glass effect namespace for unified glass interaction
private struct EdgeToolbarContainer: View {
    let edge: ToolbarEdge
    let config: EdgeToolbarConfiguration
    let glass: Glass

    @Environment(\.toolbarDensity) private var density
    @Environment(\.toolbarPaddingConfiguration) private var paddingConfig
    @Environment(\.toolbarCollapseConfiguration) private var collapseConfig
    @Environment(\.toolbarCollapseState) private var collapseState
    @Environment(\.toolbarCollapseToggle) private var collapseToggle
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Measured height/width of the primary toolbar content.
    @State private var toolbarSize: CGFloat = 0

    /// Shared namespace for glass effect grouping across toolbar and accessories.
    @Namespace private var glassNamespace

    /// Namespace for collapse merge animations.
    @Namespace private var collapseNamespace

    private var metrics: ToolbarMetrics {
        ToolbarMetrics(density: density, context: primarySizeContext)
    }

    // MARK: - Size Contexts

    /// Size context for primary toolbar content.
    private var primarySizeContext: EdgeSizeContext {
        EdgeSizeContext(
            edge: edge,
            isAccessory: false,
            collapseState: collapseState
        )
    }

    /// Size context for accessory content (constant sizing).
    private var accessorySizeContext: EdgeSizeContext {
        EdgeSizeContext(
            edge: edge,
            isAccessory: true,
            collapseState: collapseState
        )
    }

    /// Stable identifier for container-to-merge morphing transitions.
    private var primaryContainerTransitionID: String {
        "toolbar-primary-container-\(edge.rawValue)"
    }

    /// Whether toolbar is currently collapsed.
    /// Collapse only applies to the bottom edge; other edges remain unaffected.
    private var isCollapsed: Bool {
        edge == .bottom && collapseConfig != nil && collapseState == .collapsed
    }

    /// Calculates the maximum accessory extension (how far accessories extend beyond toolbar).
    ///
    /// With the default 12pt spacing, accessory extends:
    /// - accessoryHeight (48pt) + defaultSpacing (12pt) = 60pt above primary
    /// - Additional positive userOffset increases this, negative decreases it
    private var maxAccessoryExtension: CGFloat {
        guard !config.accessories.isEmpty else { return 0 }
        // Find the accessory with maximum separation (most positive offset)
        let maxUserOffset = config.accessories.map { $0.offset }.max() ?? 0
        // Total extension = accessory height + default spacing + user offset + container spacing
        // User offset adds to separation when positive
        return accessorySizeContext.containerHeight + defaultAccessorySpacing + max(0, maxUserOffset) + metrics.containerSpacing
    }

    /// Total height of this toolbar edge including accessories and padding.
    private var totalHeight: CGFloat {
        guard toolbarSize > 0 else { return 0 }
        let additionalPadding = paddingConfig.resolvedAdditionalPadding(density: density)
        if config.accessories.isEmpty {
            return toolbarSize + additionalPadding
        } else {
            return maxAccessoryExtension + additionalPadding
        }
    }

    var body: some View {
        GlassEffectContainer(spacing: metrics.containerSpacing) {
            primaryToolbar
                .onGeometryChange(for: CGFloat.self) { proxy in
                    edge.isHorizontal ? proxy.size.height : proxy.size.width
                } action: { size in
                    toolbarSize = size
                }
                .overlay(alignment: accessoryAlignment) {
                    accessoryStack
                }
        }
        .environment(\.toolbarEdge, edge)
        .preference(key: ToolbarHeightPreferenceKey.self, value: heightReport)
        .animation(edge == .bottom ? collapseAnimation : nil, value: isCollapsed)
    }

    /// Animation for collapse transitions, respecting reduced motion.
    /// Provides a minimal crossfade for reduced motion instead of nil to maintain visual continuity.
    private var collapseAnimation: Animation {
        if reduceMotion {
            return .linear(duration: 0.15)
        }
        return collapseConfig?.animation ?? .spring(duration: 0.35, bounce: 0.2)
    }

    /// Creates a height report for just this edge.
    private var heightReport: ToolbarHeightReport {
        var report = ToolbarHeightReport()
        report[edge] = totalHeight
        return report
    }

    // MARK: - Primary Toolbar

    /// Collapse morph configuration for ToolbarContainer.
    private var collapseMorphConfig: ToolbarContainer.CollapseMorphConfig? {
        guard let collapseConfig, edge == .bottom else { return nil }
        return ToolbarContainer.CollapseMorphConfig(
            namespace: collapseNamespace,
            transitionID: primaryContainerTransitionID,
            mergeSide: collapseConfig.mergeSide,
            isCollapsed: isCollapsed
        )
    }

    @ViewBuilder
    private var primaryToolbar: some View {
        if !config.isEmpty {
            ToolbarContainer(
                leadingItems: effectiveLeadingItems,
                trailingItems: effectiveTrailingItems,
                groups: effectivePrimaryGroups,
                edge: edge,
                glass: glass,
                glassNamespace: glassNamespace,
                collapseConfig: collapseMorphConfig
            )
            .environment(\.toolbarSizeContext, primarySizeContext)
        } else {
            // Empty placeholder when only accessories exist
            EmptyView()
        }
    }

    // MARK: - Collapse-Aware Items

    /// Leading items adjusted for collapse state.
    /// When collapsed to leading: shows merge icon only.
    /// When collapsed to trailing: preserves original leading items.
    private var effectiveLeadingItems: [AnyView] {
        guard let collapseConfig, isCollapsed else {
            return config.leadingItems
        }
        switch collapseConfig.mergeSide {
        case .leading:
            return [AnyView(mergeIconButton)]
        case .trailing:
            return config.leadingItems
        }
    }

    /// Trailing items adjusted for collapse state.
    /// When collapsed to trailing: shows merge icon only.
    /// When collapsed to leading: preserves original trailing items.
    private var effectiveTrailingItems: [AnyView] {
        guard let collapseConfig, isCollapsed else {
            return config.trailingItems
        }
        switch collapseConfig.mergeSide {
        case .trailing:
            return [AnyView(mergeIconButton)]
        case .leading:
            return config.trailingItems
        }
    }

    /// Primary groups hidden when collapsed.
    private var effectivePrimaryGroups: [ToolbarGroup] {
        guard !isCollapsed else { return [] }
        guard !config.primaryItems.isEmpty else { return [] }
        return [ToolbarGroup(id: 0, items: config.primaryItems, trailingSpacer: nil)]
    }

    /// Converts primary items into ToolbarGroup format.
    private var primaryGroups: [ToolbarGroup] {
        guard !config.primaryItems.isEmpty else { return [] }
        return [ToolbarGroup(id: 0, items: config.primaryItems, trailingSpacer: nil)]
    }

    // MARK: - Merge Icon Button

    /// Anchor point for merge icon scale animation.
    private var mergeAnchor: UnitPoint {
        guard let collapseConfig else { return .center }
        return collapseConfig.mergeSide == .leading ? .leading : .trailing
    }

    /// Transition for merge icon during collapse/expand.
    private var mergeIconTransition: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.6, anchor: mergeAnchor)
                .combined(with: .opacity),
            removal: .scale(scale: 1.2, anchor: mergeAnchor)
                .combined(with: .opacity)
        )
    }

    @ViewBuilder
    private var mergeIconButton: some View {
        if let collapseConfig {
            Button {
                collapseToggle?()
            } label: {
                Image(systemName: collapseConfig.mergeIcon)
            }
            .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly()))
            .matchedGeometryEffect(
                id: primaryContainerTransitionID,
                in: collapseNamespace,
                properties: .position,
                isSource: isCollapsed
            )
            .transition(mergeIconTransition)
            .accessibilityLabel(Text("Show tabs", comment: "Accessibility label for merge icon"))
            .accessibilityHint(Text("Expands toolbar to show all tabs", comment: "Merge icon hint"))
        }
    }

    // MARK: - Accessory Alignment

    /// The alignment edge for accessory overlay.
    /// When collapsed, uses center alignment to properly align with toolbar.
    private var accessoryAlignment: Alignment {
        if isCollapsed && edge == .bottom {
            return .center
        }
        switch edge {
        case .bottom: return .top
        case .top: return .bottom
        case .leading: return .trailing
        case .trailing: return .leading
        }
    }

    // MARK: - Accessories

    @ViewBuilder
    private var accessoryStack: some View {
        if config.accessories.isEmpty {
            EmptyView()
        } else {
            ForEach(Array(config.accessories.enumerated()), id: \.offset) { index, accessory in
                accessoryView(content: accessory.view, offset: accessory.offset, index: index)
            }
        }
    }

    /// Metrics for accessory content.
    private var accessoryMetrics: ToolbarMetrics {
        ToolbarMetrics(density: density, context: accessorySizeContext)
    }

    /// Positions accessory using offset from measured toolbar size.
    /// - offset < 0: overlap (accessory moves toward toolbar)
    /// - offset > 0: separation (accessory moves away from toolbar)
    @ViewBuilder
    private func accessoryView(content: AnyView, offset: CGFloat, index: Int) -> some View {
        content
            .environment(\.toolbarSizeContext, accessorySizeContext)
            .padding(accessoryMetrics.effectiveContainerPadding)
            .glassEffect(glass.interactive(), in: .capsule)
            .glassEffectID("accessory-\(index)", in: glassNamespace)
            .offset(accessoryOffset(offset))
    }

    /// The effective toolbar size for offset calculations.
    /// Uses measured size when expanded, but uses target height when collapsed
    /// to ensure smooth animation without jitter from size measurement lag.
    private var effectiveToolbarSize: CGFloat {
        if isCollapsed {
            // Use the known collapsed primary height (48pt) for consistent positioning
            return primarySizeContext.containerHeight
        }
        return toolbarSize
    }

    /// Default spacing between accessory and primary content (constant, density-independent).
    private let defaultAccessorySpacing: CGFloat = 12

    /// Calculates offset to position accessory outside toolbar bounds.
    /// When collapsed, accessory aligns with the merge icon.
    ///
    /// - Parameter userOffset: User-specified offset adjustment.
    ///   - Positive values add separation (accessory moves away from primary).
    ///   - Negative values reduce separation (accessory moves toward primary / overlaps).
    private func accessoryOffset(_ userOffset: CGFloat) -> CGSize {
        // When collapsed, accessory aligns with the merge icon position
        if isCollapsed {
            return collapsedAccessoryOffset
        }

        let accessoryHeight = accessorySizeContext.containerHeight

        // Base offset positions accessory with default 12pt spacing from primary.
        // The overlay places accessory at the primary's edge via alignment.
        // We move it out by (accessoryHeight + defaultSpacing) to achieve the gap.
        switch edge {
        case .bottom:
            // Move accessory up to create gap above primary
            // userOffset > 0: more separation (subtract to move further up)
            // userOffset < 0: less separation / overlap (subtract to move closer)
            let baseOffset = -(accessoryHeight + defaultAccessorySpacing)
            return CGSize(width: 0, height: baseOffset - userOffset)

        case .top:
            // Move accessory down to create gap below primary
            let baseOffset = accessoryHeight + defaultAccessorySpacing
            return CGSize(width: 0, height: baseOffset + userOffset)

        case .leading:
            // Move accessory right to create gap beside primary
            let baseOffset = accessoryHeight + defaultAccessorySpacing
            return CGSize(width: baseOffset + userOffset, height: 0)

        case .trailing:
            // Move accessory left to create gap beside primary
            let baseOffset = -(accessoryHeight + defaultAccessorySpacing)
            return CGSize(width: baseOffset - userOffset, height: 0)
        }
    }

    /// Offset for accessory when collapsed.
    /// Uses .zero since the overlay alignment switches to .center when collapsed,
    /// automatically centering the accessory both horizontally and vertically.
    private var collapsedAccessoryOffset: CGSize {
        .zero
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
