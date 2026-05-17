//
//  GlassOverlayModifier.swift
//  Glassware
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
private struct GlassHeightPreferenceKey: PreferenceKey {
    static let defaultValue: GlassHeightReport = .empty

    static func reduce(value: inout GlassHeightReport, nextValue: () -> GlassHeightReport) {
        let next = nextValue()
        // Take the maximum per-edge across the view tree so nested glass containers
        // can never shrink an outer report. Absent values mean "no contribution".
        if let bottom = next.bottom { value.bottom = max(value.bottom ?? 0, bottom) }
        if let top = next.top { value.top = max(value.top ?? 0, top) }
        if let leading = next.leading { value.leading = max(value.leading ?? 0, leading) }
        if let trailing = next.trailing { value.trailing = max(value.trailing ?? 0, trailing) }
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
/// @Environment(\.glassHeights) private var toolbarHeights
/// content.safeAreaPadding(.bottom, toolbarHeights.bottom ?? 0)
/// ```
struct GlassOverlayModifier: ViewModifier {
    let items: [AnyGlassContent]
    let glass: Glass

    /// Configurations grouped by edge.
    ///
    /// Computed once in `init` so the four `.overlay` blocks below can each read
    /// the partitioned configuration without re-running the partition pass on
    /// every body evaluation. Previously this was a computed property — every
    /// `body` re-evaluation (one per scroll tick during a collapse animation)
    /// partitioned `items` four times.
    private let edgeConfigurations: [GlassEdge: EdgeToolbarConfiguration]

    /// Tracked heights for all toolbar edges.
    @State private var heights: GlassHeightReport = .empty

    init(items: [AnyGlassContent], glass: Glass) {
        self.items = items
        self.glass = glass
        self.edgeConfigurations = Self.partition(items: items)
    }

    private static func partition(items: [AnyGlassContent]) -> [GlassEdge: EdgeToolbarConfiguration] {
        var configs: [GlassEdge: EdgeToolbarConfiguration] = [:]

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
            .environment(\.glassHeights, heights)
            // Each edge gets its own overlay with proper alignment
            .overlay(alignment: .top) {
                if let config = edgeConfigurations[.top] {
                    EdgeGlassContainer(edge: .top, config: config, glass: glass)
                }
            }
            .overlay(alignment: .bottom) {
                if let config = edgeConfigurations[.bottom] {
                    EdgeGlassContainer(edge: .bottom, config: config, glass: glass)
                }
            }
            .overlay(alignment: .leading) {
                if let config = edgeConfigurations[.leading] {
                    EdgeGlassContainer(edge: .leading, config: config, glass: glass)
                }
            }
            .overlay(alignment: .trailing) {
                if let config = edgeConfigurations[.trailing] {
                    EdgeGlassContainer(edge: .trailing, config: config, glass: glass)
                }
            }
            // Collect heights from all edge containers
            .onPreferenceChange(GlassHeightPreferenceKey.self) { newHeights in
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
private struct EdgeGlassContainer: View {
    let edge: GlassEdge
    let config: EdgeToolbarConfiguration
    let glass: Glass

    @Environment(\.glassDensity) private var density
    @Environment(\.glassPaddingConfiguration) private var paddingConfig
    @Environment(\.glassCollapseConfiguration) private var collapseConfig
    @Environment(\.glassCollapseState) private var collapseState
    @Environment(\.glassCollapseToggle) private var collapseToggle
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Measured height/width of the primary toolbar content.
    @State private var toolbarSize: CGFloat = 0

    /// Shared namespace for glass effect grouping across toolbar and accessories.
    @Namespace private var glassNamespace

    /// Namespace for collapse merge animations.
    @Namespace private var collapseNamespace

    private var metrics: GlassMetrics {
        GlassMetrics(density: density, context: primarySizeContext)
    }

    // MARK: - Size Contexts

    /// Effective collapse state for sizing - always expanded if collapse isn't enabled.
    private var effectiveCollapseState: GlassCollapseState {
        isCollapseEnabled ? collapseState : .expanded
    }

    /// Size context for primary toolbar content.
    private var primarySizeContext: GlassEdgeContext {
        GlassEdgeContext(
            edge: edge,
            isAccessory: false,
            collapseState: effectiveCollapseState
        )
    }

    /// Size context for accessory content (constant sizing).
    private var accessorySizeContext: GlassEdgeContext {
        GlassEdgeContext(
            edge: edge,
            isAccessory: true,
            collapseState: effectiveCollapseState
        )
    }

    /// Stable identifier for container-to-merge morphing transitions.
    private var primaryContainerTransitionID: String {
        "toolbar-primary-container-\(edge.rawValue)"
    }

    /// Whether toolbar is currently collapsed.
    /// Collapse only applies to the bottom edge when there's at least one accessory.
    /// Without an accessory, collapse is disabled regardless of configuration.
    private var isCollapsed: Bool {
        edge == .bottom && collapseConfig != nil && !config.accessories.isEmpty && collapseState == .collapsed
    }

    /// Whether collapse behavior is enabled for this edge.
    /// Hard constraint: collapse requires a bottom accessory.
    private var isCollapseEnabled: Bool {
        edge == .bottom && collapseConfig != nil && !config.accessories.isEmpty
    }

    /// Calculates the maximum accessory extension (how far accessories extend beyond toolbar).
    ///
    /// Extension = accessoryHeight + userOffset (when positive)
    /// - accessoryHeight (48pt) = base extension
    /// - Positive userOffset adds to separation
    private var maxAccessoryExtension: CGFloat {
        guard !config.accessories.isEmpty else { return 0 }
        // Find the accessory with maximum separation (most positive offset)
        let maxUserOffset = config.accessories.map { $0.offset }.max() ?? 0
        // Total extension = accessory height + user offset (if positive) + container spacing
        return accessorySizeContext.containerHeight + max(0, maxUserOffset) + metrics.containerSpacing
    }

    /// Extra spacing added to bottom edge height for content padding.
    private static let bottomContentSpacing: CGFloat = 16

    /// Total height of this toolbar edge including accessories and padding.
    ///
    /// Height calculation varies based on state:
    /// - **Collapsed**: Accessory merges with toolbar, so just toolbar height + padding
    /// - **Expanded with accessories**: Primary toolbar + accessory extension + padding
    /// - **No accessories**: Just toolbar height + padding
    /// - **Bottom edge**: Adds 16pt content spacing for comfortable scroll padding
    private var totalHeight: CGFloat {
        guard toolbarSize > 0 else { return 0 }
        let additionalPadding = paddingConfig.resolvedAdditionalPadding(density: density)
        let contentSpacing = edge == .bottom ? Self.bottomContentSpacing : 0

        // When collapsed, accessory merges with toolbar (centered alignment)
        // so total height is just the toolbar height
        if isCollapsed {
            return toolbarSize + additionalPadding + contentSpacing
        }

        // When expanded with accessories, total = primary + accessory extension
        if !config.accessories.isEmpty {
            return toolbarSize + maxAccessoryExtension + additionalPadding + contentSpacing
        }

        // No accessories - just toolbar height
        return toolbarSize + additionalPadding + contentSpacing
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
        // Safe-area padding wraps the whole effect container so the inner
        // `primaryToolbar.size` measured above is the visible bar only — the
        // accessory's `.center` overlay then aligns with the leading/trailing
        // centers (otherwise `toolbarSize` would include the bottom
        // safe-area inset and shift the accessory down at large Dynamic
        // Type).
        .modifier(
            EdgeSafeAreaModifier(
                edge: edge,
                paddingConfig: paddingConfig,
                density: density
            )
        )
        .environment(\.glassEdge, edge)
        .preference(key: GlassHeightPreferenceKey.self, value: heightReport)
        .animation(edge == .bottom ? collapseAnimation : nil, value: isCollapsed)
    }

    /// Animation for collapse transitions, respecting reduced motion.
    /// Provides a minimal crossfade for reduced motion instead of nil to maintain visual continuity.
    private var collapseAnimation: Animation {
        if reduceMotion {
            return .linear(duration: GlassTokens.Animation.disabledTransitionDuration)
        }
        return collapseConfig?.animation ?? .spring(
            duration: GlassTokens.Animation.collapseSpringResponse,
            bounce: GlassTokens.Animation.collapseSpringBounce
        )
    }

    /// Creates a height report for just this edge.
    private var heightReport: GlassHeightReport {
        var report = GlassHeightReport()
        report[edge] = totalHeight
        return report
    }

    // MARK: - Primary Toolbar

    /// Collapse morph configuration for GlassContainer.
    /// Returns nil if collapse is not enabled (requires bottom edge with accessory).
    private var collapseMorphConfig: GlassContainer.CollapseMorphConfig? {
        guard let collapseConfig, isCollapseEnabled else { return nil }
        return GlassContainer.CollapseMorphConfig(
            namespace: collapseNamespace,
            transitionID: primaryContainerTransitionID,
            mergeSide: collapseConfig.mergeSide,
            isCollapsed: isCollapsed
        )
    }

    @ViewBuilder
    private var primaryToolbar: some View {
        if !config.isEmpty {
            GlassContainer(
                leadingItems: effectiveLeadingItems,
                trailingItems: effectiveTrailingItems,
                groups: effectivePrimaryGroups,
                edge: edge,
                glass: glass,
                glassNamespace: glassNamespace,
                collapseConfig: collapseMorphConfig
            )
            .environment(\.glassSizeContext, primarySizeContext)
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
    private var effectivePrimaryGroups: [GlassGroup] {
        guard !isCollapsed else { return [] }
        guard !config.primaryItems.isEmpty else { return [] }
        return [GlassGroup(id: 0, items: config.primaryItems, trailingSpacer: nil)]
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
        // Merge icon only appears when collapse is enabled (requires bottom accessory)
        if let collapseConfig, isCollapseEnabled {
            Button {
                collapseToggle?()
            } label: {
                Image(systemName: collapseConfig.mergeIcon)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.glass(style: .iconOnly()))
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
    /// When expanded, aligns to the same edge so offset calculation is straightforward.
    private var accessoryAlignment: Alignment {
        if isCollapsed && edge == .bottom {
            return .center
        }
        switch edge {
        case .bottom: return .bottom
        case .top: return .top
        case .leading: return .leading
        case .trailing: return .trailing
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
    private var accessoryMetrics: GlassMetrics {
        GlassMetrics(density: density, context: accessorySizeContext)
    }

    /// Positions accessory using offset from toolbar edge.
    /// - offset = 0: accessory bottom touches primary top (no gap)
    /// - offset > 0: gap between accessory and primary
    /// - offset < 0: accessory overlaps primary
    @ViewBuilder
    private func accessoryView(content: AnyView, offset: CGFloat, index: Int) -> some View {
        content
            .environment(\.glassSizeContext, accessorySizeContext)
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

    /// Calculates offset to position accessory relative to primary toolbar.
    /// When collapsed, accessory aligns with the merge icon.
    ///
    /// - Parameter userOffset: Gap between accessory and primary toolbar in points.
    ///   - Zero = accessory bottom touches primary top (no gap)
    ///   - Positive = gap between accessory and primary
    ///   - Negative = accessory overlaps primary ("melting" effect)
    private func accessoryOffset(_ userOffset: CGFloat) -> CGSize {
        // When collapsed, accessory aligns with the merge icon position
        if isCollapsed {
            return collapsedAccessoryOffset
        }

        // Accessory starts at same edge as primary (e.g., both at bottom)
        // Move by toolbar size to position accessory's near edge at primary's far edge,
        // then add user offset for gap/overlap
        switch edge {
        case .bottom:
            // Move up by toolbar height + user offset
            return CGSize(width: 0, height: -(effectiveToolbarSize + userOffset))

        case .top:
            // Move down by toolbar height + user offset
            return CGSize(width: 0, height: effectiveToolbarSize + userOffset)

        case .leading:
            // Move right by toolbar width + user offset
            return CGSize(width: effectiveToolbarSize + userOffset, height: 0)

        case .trailing:
            // Move left by toolbar width + user offset
            return CGSize(width: -(effectiveToolbarSize + userOffset), height: 0)
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
    /// Applies a multi-edge glass bar overlay using placement-based API.
    ///
    /// This API allows positioning glass bar items at any edge and supports
    /// accessory views with configurable spacing.
    ///
    /// ## Usage
    /// ```swift
    /// .glass {
    ///     GlassItem(placement: .bottomLeading) {
    ///         Button("Settings", systemImage: "gearshape") { }
    ///             .buttonStyle(.glass(style: .iconOnly()))
    ///     }
    ///
    ///     GlassItemGroup(placement: .bottomPrimary) {
    ///         ForEach(tabs) { tab in
    ///             Button(tab.title, systemImage: tab.icon) { selectedTab = tab }
    ///                 .buttonStyle(.glass(isSelected: selectedTab == tab))
    ///         }
    ///     }
    ///
    ///     GlassItem(placement: .bottomAccessory(offset: -8)) {
    ///         VehiclePicker(selection: $vehicle)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - effect: The glass effect style to apply.
    ///   - content: A builder closure providing glass bar items.
    /// - Returns: A view with the glass bar overlay applied.
    public func glass(
        _ effect: Glass = .regular,
        @GlassBuilder content: () -> [AnyGlassContent]
    ) -> some View {
        modifier(GlassOverlayModifier(items: content(), glass: effect))
    }
}
