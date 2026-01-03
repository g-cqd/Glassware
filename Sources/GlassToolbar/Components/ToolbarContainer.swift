//
//  ToolbarContainer.swift
//  GlassToolbar
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
struct ToolbarContainer: View {
    // MARK: - Environment

    @Environment(\.toolbarDensity) private var density
    @Environment(\.toolbarPaddingConfiguration) private var paddingConfig
    @Environment(\.toolbarLayoutDistribution) private var distribution

    // MARK: - Properties

    let leadingItems: [AnyView]
    let trailingItems: [AnyView]
    let groups: [ToolbarGroup]
    let edge: ToolbarEdge
    let glass: Glass

    /// Namespace for glass effect grouping (separate from per-container selection namespace).
    @Namespace private var glassNamespace

    /// Tracks the cross-axis size for consistent container sizing.
    /// For horizontal edges (top/bottom), this is height.
    /// For vertical edges (leading/trailing), this is width.
    @State private var crossAxisSize: CGFloat?

    // MARK: - Computed Properties

    /// Layout metrics computed from density environment value.
    private var metrics: ToolbarMetrics {
        ToolbarMetrics(density: density)
    }

    // MARK: - Body

    var body: some View {
        GlassEffectContainer(spacing: metrics.containerSpacing) {
            content
        }
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
        .glassEffectID(ToolbarButtonPlacement.leading, in: glassNamespace)
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
        .glassEffectID(ToolbarButtonPlacement.trailing, in: glassNamespace)
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
            .glassEffectID(ToolbarButtonPlacement.primary, in: glassNamespace)

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
    /// - Uses circular shape for single-item leading/trailing
    /// - Uses capsule shape for multi-item or primary containers
    /// - Applies consistent cross-axis sizing for visual alignment
    /// - Leading/trailing containers are constrained to icon-only width and clipped
    /// - Wraps content in NamespacedContainer for per-container matchedGeometryEffect
    @ViewBuilder
    private func container<Content: View>(
        placement: ToolbarButtonPlacement,
        itemCount: Int,
        @ViewBuilder _ content: () -> Content
    ) -> some View {
        let isSingleItem = itemCount == 1 && (placement == .leading || placement == .trailing)
        let isAccessoryPlacement = placement == .leading || placement == .trailing
        let builtContent = content()

        // Leading/trailing containers constrained to icon-only size
        // This ensures consistent sizing regardless of button style used
        let iconOnlySize = metrics.iconButtonSize + metrics.containerPadding * 2

        if isSingleItem {
            NamespacedContainer(placement: placement) { builtContent }
                // Constrain content to icon size before padding
                .frame(
                    width: isAccessoryPlacement ? metrics.iconButtonSize : nil,
                    height: isAccessoryPlacement ? metrics.iconButtonSize : nil
                )
                .clipped()
                .padding(metrics.containerPadding)
                .frame(
                    minWidth: edge.isVertical ? crossAxisSize : nil,
                    minHeight: edge.isHorizontal ? crossAxisSize : nil
                )
                .glassEffect(glass.interactive(), in: .circle)
        } else {
            NamespacedContainer(placement: placement) { builtContent }
                .padding(metrics.containerPadding)
                .frame(
                    maxWidth: isAccessoryPlacement && edge.isHorizontal ? iconOnlySize : nil,
                    maxHeight: isAccessoryPlacement && edge.isVertical ? iconOnlySize : nil
                )
                .clipped()
                .frame(
                    minWidth: edge.isVertical ? crossAxisSize : nil,
                    minHeight: edge.isHorizontal ? crossAxisSize : nil
                )
                .glassEffect(glass.interactive(), in: .capsule)
        }
    }
}

// MARK: - Namespaced Container

/// A wrapper view that provides its own namespace for matchedGeometryEffect.
///
/// Each container gets its own namespace, ensuring that tab selection animations
/// only occur between items within the same container, not across containers.
private struct NamespacedContainer<Content: View>: View {
    @Namespace private var containerNamespace
    let placement: ToolbarButtonPlacement
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .environment(\.toolbarButtonPlacement, placement)
            .environment(\.toolbarContainerNamespace, containerNamespace)
    }
}

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
/// The `ToolbarPaddingConfiguration` controls:
/// - `externalPadding`: Always used for horizontal margins (default: 16)
/// - `additionalPadding`: Extra padding from safe area edge (-1 uses density-based)
/// - `ignoresSafeArea`: When true, positions at screen edge ignoring safe area
struct EdgeSafeAreaModifier: ViewModifier {
    let edge: ToolbarEdge
    let paddingConfig: ToolbarPaddingConfiguration
    let density: ToolbarDensity

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

// MARK: - Safe Collection Access

extension RandomAccessCollection {
    subscript(safe index: Index?) -> Element? {
        if let index, index >= startIndex, index < endIndex {
            self[index]
        } else {
            nil
        }
    }
}
