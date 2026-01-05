//
//  GlassContainer.swift
//  Glassware
//
//  Internal container view rendering the toolbar layout.
//

import SwiftUI

// MARK: - Toolbar Container

/// Internal container view rendering the toolbar layout.
///
/// The container adapts its layout based on the edge:
/// - **Top/Bottom edges**: Horizontal layout (HStack)
/// - **Leading/Trailing edges**: Vertical layout (VStack)
///
/// ## Performance Considerations
///
/// 1. **Environment injection point**: Placement environment is set at container level,
///    not individual button level. This reduces environment propagation overhead.
///
/// 2. **onGeometryChange**: More efficient than GeometryReader because:
///    - Only triggers callback on actual size changes
///    - Doesn't create additional coordinate space
///    - Doesn't block layout like GeometryReader can
///
/// 3. **Overlay vs ZStack**: Using overlay (in modifier) is appropriate here because
///    the toolbar doesn't need to participate in parent's layout calculation.
///
/// 4. **Metrics from Environment**: Density is read from environment
///    and used to compute all sizing and spacing values.
struct GlassContainer: View {
    // MARK: - Environment

    @Environment(\.glassDensity) private var density
    @Environment(\.glassSizeContext) private var sizeContext
    @Environment(\.glassPaddingConfiguration) private var paddingConfig
    @Environment(\.glassLayoutDistribution) private var distribution

    // MARK: - Properties

    let leadingItems: [AnyView]
    let trailingItems: [AnyView]
    let groups: [GlassGroup]
    let edge: GlassEdge
    let glass: Glass

    /// Namespace for glass effect grouping, shared with accessories.
    /// Passed from EdgeGlassContainer to ensure unified glass interaction.
    let glassNamespace: Namespace.ID

    /// Configuration for collapse morphing animation (optional, only bottom edge uses it).
    let collapseConfig: CollapseMorphConfig?

    /// Configuration for container-level collapse morphing.
    struct CollapseMorphConfig {
        let namespace: Namespace.ID
        let transitionID: String
        let mergeSide: GlassMergeSide
        let isCollapsed: Bool
    }

    /// Tracks the cross-axis size for consistent container sizing.
    /// For horizontal edges (top/bottom), this is height.
    /// For vertical edges (leading/trailing), this is width.
    @State private var crossAxisSize: CGFloat?

    // MARK: - Computed Properties

    /// Layout metrics computed from density and edge context.
    private var metrics: GlassMetrics {
        GlassMetrics(density: density, context: sizeContext)
    }

    // MARK: - Body

    var body: some View {
        content
            // Limit dynamic type to prevent toolbar from exceeding screen bounds.
            // Accessibility1 allows significant scaling while keeping layout manageable.
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            .onGeometryChange(
            for: CGFloat.self,
            of: { edge.isHorizontal ? $0.size.height : $0.size.width },
            action: { newSize in
                guard abs((crossAxisSize ?? 0) - newSize) > 1 else { return }
                crossAxisSize = newSize
            }
        )
        .modifier(
            EdgeSafeAreaModifier(
                edge: edge,
                paddingConfig: paddingConfig,
                density: density
            )
        )
    }

    private var layout: some Layout {
        if edge.isHorizontal {
            AnyLayout(HStackLayout(spacing: 0))
        } else {
            AnyLayout(VStackLayout(spacing: 0))
        }
    }

    @ViewBuilder
    private var content: some View {
        switch distribution {
        case .natural:
            naturalContent
        case .distributed:
            distributedContent
        case .centered:
            centeredContent
        }
    }

    /// Natural layout: content flows without extra spacers.
    @ViewBuilder
    private var naturalContent: some View {
        layout {
            // Leading items
            if !leadingItems.isEmpty {
                leadingContainer
            }

            // Spacer between leading and primary
            if !leadingItems.isEmpty, !groups.isEmpty {
                adaptiveSpacer(minLength: metrics.interGroupSpacing)
            }

            // Primary content groups
            primaryContainers

            // Spacer between primary and trailing
            if !trailingItems.isEmpty, !groups.isEmpty, groups.last?.trailingSpacer == nil {
                adaptiveSpacer(minLength: metrics.interGroupSpacing)
            }

            // Trailing items
            if !trailingItems.isEmpty {
                trailingContainer
            }
        }
    }

    /// Distributed layout: spacers fill empty compartments to maintain positions.
    @ViewBuilder
    private var distributedContent: some View {
        layout {
            // Leading items or spacer placeholder
            if !leadingItems.isEmpty {
                leadingContainer
            }

            // Spacer after leading (or at start if leading empty)
            Spacer(minLength: metrics.interGroupSpacing)

            // Primary content groups
            primaryContainers

            // Spacer before trailing (or at end if trailing empty)
            Spacer(minLength: metrics.interGroupSpacing)

            // Trailing items
            if !trailingItems.isEmpty {
                trailingContainer
            }
        }
    }

    /// Centered layout: all content groups together in center.
    @ViewBuilder
    private var centeredContent: some View {
        layout {
            Spacer(minLength: 0)

            // Leading items
            if !leadingItems.isEmpty {
                leadingContainer
            }

            // Primary content groups
            if !leadingItems.isEmpty, !groups.isEmpty {
                Spacer(minLength: metrics.interGroupSpacing).fixedSize()
            }

            primaryContainers

            // Trailing items
            if !trailingItems.isEmpty, !groups.isEmpty {
                Spacer(minLength: metrics.interGroupSpacing).fixedSize()
            }

            if !trailingItems.isEmpty {
                trailingContainer
            }

            Spacer(minLength: 0)
        }
    }

    // MARK: - Content Containers

    @ViewBuilder
    private var leadingContainer: some View {
        container(
            placement: .leading,
            itemCount: leadingItems.count
        ) {
            layout {
                ForEach(leadingItems.indices, id: \.self) { index in
                    leadingItems[safe: index]
                }
            }
        }
        .glassEffectID(GlassButtonPlacement.leading, in: glassNamespace)
    }

    @ViewBuilder
    private var trailingContainer: some View {
        container(
            placement: .trailing,
            itemCount: trailingItems.count
        ) {
            layout {
                ForEach(trailingItems.indices, id: \.self) { index in
                    trailingItems[safe: index]
                }
            }
        }
        .glassEffectID(GlassButtonPlacement.trailing, in: glassNamespace)
    }

    /// Anchor point for collapse scale animation based on merge side.
    private var collapseAnchor: UnitPoint {
        guard let config = collapseConfig else { return .center }
        return config.mergeSide == .leading ? .leading : .trailing
    }

    /// Transition for primary container during collapse/expand.
    private var primaryContainerTransition: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.85, anchor: collapseAnchor)
                .combined(with: .opacity),
            removal: .scale(scale: 0.7, anchor: collapseAnchor)
                .combined(with: .opacity)
        )
    }

    @ViewBuilder
    private var primaryContainers: some View {
        ForEach(groups.indices, id: \.self) { index in
            let group = groups[index]
            container(
                placement: .primary,
                itemCount: group.items.count
            ) {
                layout {
                    ForEach(group.items.indices, id: \.self) { itemIndex in
                        group.items[safe: itemIndex]
                    }
                }
            }
            .glassEffectID(GlassButtonPlacement.primary, in: glassNamespace)
            // Lower priority allows primary container to compress when space is constrained
            .layoutPriority(-1)
            .ifLet(collapseConfig) { view, config in
                view
                    .matchedGeometryEffect(
                        id: config.transitionID,
                        in: config.namespace,
                        properties: .position,
                        isSource: !config.isCollapsed
                    )
                    .transition(primaryContainerTransition)
            }

            if let spacer = group.trailingSpacer {
                adaptiveSpacer(minLength: spacer)
            }
        }
    }

    // MARK: - Helper Views

    /// Spacer with minimum length that compresses gracefully when needed.
    /// Note: Spacer already handles compression - ViewThatFits adds unnecessary layout passes.
    private func adaptiveSpacer(minLength: CGFloat) -> some View {
        Spacer(minLength: minLength)
    }

    /// Creates glass container with placement environment and per-container namespace.
    ///
    /// Shape selection rules:
    /// - Single-item leading/trailing on horizontal edges: circle
    /// - Single-item on vertical edges: circle (when icon-only fits)
    /// - Multi-item containers: capsule
    /// - Vertical edges use adaptive label style (tries user style, falls back to iconOnly)
    /// - Wraps content in NamespacedContainer for per-container matchedGeometryEffect
    @ViewBuilder
    private func container<Content: View>(
        placement: GlassButtonPlacement,
        itemCount: Int,
        @ViewBuilder _ content: () -> Content
    ) -> some View {
        let isSingleItem = itemCount == 1 && (placement == .leading || placement == .trailing)
        let context = GlassContainerContext(itemCount: itemCount, isVerticalEdge: edge.isVertical)
        let builtContent = content()

        if isSingleItem && edge.isHorizontal {
            // Circular container for single items on horizontal edges
            NamespacedContainer(placement: placement, context: context) { builtContent }
                .padding(metrics.effectiveContainerPadding)
                .frame(
                    minWidth: edge.isVertical ? crossAxisSize : nil,
                    minHeight: edge.isHorizontal ? crossAxisSize : nil
                )
                .glassEffect(glass.interactive(), in: .circle)
        } else if edge.isVertical {
            // Vertical edge: all items constrained to icon size for consistency
            let shape: AnyShape = isSingleItem ? AnyShape(.circle) : AnyShape(.capsule)
            NamespacedContainer(placement: placement, context: context) {
                builtContent
                    .environment(\.glassForcedVisualStyle, .iconOnly())
            }
            .padding(metrics.effectiveContainerPadding)
            .glassEffect(glass.interactive(), in: shape)
        } else {
            // Horizontal edge with multiple items or primary placement
            NamespacedContainer(placement: placement, context: context) { builtContent }
                .padding(metrics.effectiveContainerPadding)
                .frame(minHeight: crossAxisSize)
                .glassEffect(glass.interactive(), in: .capsule)
        }
    }
}

// MARK: - Namespaced Container

/// A wrapper view that provides its own namespace for matchedGeometryEffect.
///
/// Each container gets its own namespace, ensuring that tab selection animations
/// only occur between items within the same container, not across containers.
/// Also passes container context (item count, edge info) for shape selection.
private struct NamespacedContainer<Content: View>: View {
    @Namespace private var containerNamespace
    let placement: GlassButtonPlacement
    let context: GlassContainerContext
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .environment(\.glassButtonPlacement, placement)
            .environment(\.glassContainerNamespace, containerNamespace)
            .environment(\.glassContainerContext, context)
    }
}

