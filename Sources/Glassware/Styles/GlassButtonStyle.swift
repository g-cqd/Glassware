//
//  GlassButtonStyle.swift
//  Glassware
//
//  Unified button style for toolbar items.
//

import SwiftUI

// MARK: - Toolbar Item Button Style

/// Unified button style for all toolbar items with configurable intent and visual style.
///
/// This style consolidates tab and action button behaviors into a single configurable style:
/// - **Intent** determines behavior: `.tab` for navigation with selection, `.action` for discrete actions
/// - **Visual style** determines layout: `.titleAndIcon`, `.titleOnly`, or `.iconOnly`
/// - **Selection** only applies to `.tab` intent
///
/// ## Tab Intent Features
/// - Selection indicator with animated matchedGeometryEffect within container
/// - Smart text blending for contrast when selected
/// - Secondary color when unselected, primary when selected
///
/// ## Action Intent Features
/// - Scaling press feedback with background capsule
/// - Always appears prominent (primary color)
///
/// ## Accessibility
/// - Respects `accessibilityReduceMotion` for animations
/// - Adds `.isSelected` trait for tab items
/// - Includes sensory feedback on press
///
/// ## Usage Examples
/// ```swift
/// // Tab with icon and title (default)
/// Button("Home", systemImage: "house") { }
///     .buttonStyle(.glass(isSelected: selectedTab == 0))
///
/// // Tab with icon only
/// Button("Home", systemImage: "house") { }
///     .buttonStyle(.glass(style: .iconOnly(), isSelected: selectedTab == 0))
///
/// // Action button
/// Button("Share", systemImage: "square.and.arrow.up") { }
///     .buttonStyle(.glass(intent: .action))
///
/// // Action button icon only
/// Button("Add", systemImage: "plus") { }
///     .buttonStyle(.glass(intent: .action, style: .iconOnly()))
/// ```
public struct GlassButtonStyle: ButtonStyle {
    // MARK: - Configuration

    /// The semantic intent of the button (tab or action).
    public let intent: GlassIntent

    /// The visual layout style (titleAndIcon, titleOnly, iconOnly).
    public let visualStyle: GlassVisualStyle

    /// Whether the tab is selected (only applies to tab intent).
    public let isSelected: Bool

    // MARK: - Environment

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.glassDensity) private var density
    @Environment(\.glassSizeContext) private var sizeContext
    @Environment(\.glassContainerNamespace) private var namespace
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.glassForcedVisualStyle) private var forcedVisualStyle
    @Environment(\.glassContainerContext) private var containerContext

    /// The effective visual style, accounting for any forced override.
    private var effectiveVisualStyle: GlassVisualStyle {
        forcedVisualStyle ?? visualStyle
    }

    /// Base sizes that scale with Dynamic Type.
    @ScaledMetric(relativeTo: .body) private var baseMinWidth: CGFloat = 64
    @ScaledMetric(relativeTo: .body) private var baseMinHeight: CGFloat = 44
    @ScaledMetric(relativeTo: .body) private var baseSize: CGFloat = 44

    // MARK: - Computed Properties

    /// Layout metrics computed from density and edge context.
    private var metrics: GlassMetrics {
        GlassMetrics(density: density, context: sizeContext)
    }

    /// Actual minimum width, accounting for density.
    private var scaledMinWidth: CGFloat {
        baseMinWidth * (metrics.primaryButtonMinWidth / 64.0)
    }

    /// Actual minimum height, accounting for density and edge context.
    /// Uses effectiveButtonSize for context-aware sizing.
    private var scaledMinHeight: CGFloat {
        baseMinHeight * (metrics.effectiveButtonSize / 44.0)
    }

    /// Actual icon button size, accounting for density and edge context.
    /// Uses effectiveButtonSize for context-aware sizing.
    private var scaledSize: CGFloat {
        baseSize * (metrics.effectiveButtonSize / 44.0)
    }

    /// Image scale based on density and visual style.
    private var imageScale: Image.Scale {
        if effectiveVisualStyle.isIconOnly {
            // Icon-only gets larger icons since there's no label text
            switch density {
            case .extraSparse, .sparse, .regular, .compact: .large
            case .dense, .extraDense: .medium
            }
        } else {
            metrics.imageScale
        }
    }

    /// Animation to use, respecting reduced motion preference.
    private var selectionAnimation: Animation? {
        reduceMotion ? nil : .snappy(duration: GlassTokens.Animation.selectionDuration)
    }

    // MARK: - Initializer

    public init(
        intent: GlassIntent = .tab,
        style: GlassVisualStyle = .titleAndIcon(),
        isSelected: Bool = false
    ) {
        self.intent = intent
        self.visualStyle = style
        self.isSelected = isSelected
    }

    // MARK: - Body

    public func makeBody(configuration: Configuration) -> some View {
        labelContent(configuration: configuration)
            .font(.body.weight(.medium))
            .fontDesign(.rounded)
            .imageScale(imageScale)
            .foregroundStyle(foregroundColor(isPressed: configuration.isPressed))
            // Icon-only: fixed size for consistent touch targets
            // Text buttons: flexible width, fixed height for touch targets
            .frame(
                minWidth: effectiveVisualStyle.isIconOnly ? scaledSize : nil,
                idealWidth: effectiveVisualStyle.isIconOnly ? nil : scaledMinWidth,
                minHeight: scaledMinHeight
            )
            .padding(.vertical, metrics.effectiveComponentPadding)
            .padding(.horizontal, effectiveHorizontalPadding)
            .background {
                backgroundView(isPressed: configuration.isPressed)
            }
            .contentShape(.rect)
            .accessibilityAddTraits(isSelected && intent == .tab ? .isSelected : [])
            .accessibilityHint(accessibilityHint)
            .sensoryFeedback(.selection, trigger: configuration.isPressed) { _, newValue in
                newValue
            }
            .animation(selectionAnimation, value: isSelected)
            .animation(
                reduceMotion ? nil : .easeOut(duration: GlassTokens.Animation.pressDuration),
                value: configuration.isPressed
            )
    }

    /// Horizontal padding, slightly larger for text-containing styles on horizontal edges.
    private var effectiveHorizontalPadding: CGFloat {
        if effectiveVisualStyle.isIconOnly || containerContext.isVerticalEdge {
            return metrics.effectiveComponentPadding
        } else {
            // Increase horizontal padding for titleOnly and titleAndIcon styles
            return metrics.effectiveComponentPadding + 6
        }
    }

    // MARK: - Accessibility Hint

    private var accessibilityHint: Text {
        switch intent {
        case .tab:
            if isSelected {
                Text("Currently selected")
            } else {
                Text("Double tap to switch")
            }
        case .action:
            Text("Double tap to activate")
        }
    }

    // MARK: - Label Content

    @ViewBuilder
    private func labelContent(configuration: Configuration) -> some View {
        switch effectiveVisualStyle {
        case .titleAndIcon(let image, let systemImage):
            if let systemImage {
                // Custom system image with label's title
                GlassLabelStyle.IconLabel(
                    icon: Image(systemName: systemImage),
                    title: { configuration.label.labelStyle(.titleOnly) },
                    isSelected: isSelected && intent == .tab,
                    density: density
                )
            } else if let image {
                // Custom asset image with label's title
                GlassLabelStyle.IconLabel(
                    icon: Image(image),
                    title: { configuration.label.labelStyle(.titleOnly) },
                    isSelected: isSelected && intent == .tab,
                    density: density
                )
            } else {
                // Use label's built-in icon
                configuration.label
                    .labelStyle(GlassLabelStyle(isSelected: isSelected && intent == .tab))
            }

        case .titleOnly:
            configuration.label
                .labelStyle(.titleOnly)

        case .iconOnly(let image, let systemImage):
            if let systemImage {
                // Custom system image, label provides accessibility
                Image(systemName: systemImage)
                    .accessibilityHidden(true)
                    .accessibilityRepresentation { configuration.label }
            } else if let image {
                // Custom asset image, label provides accessibility
                Image(image)
                    .accessibilityHidden(true)
                    .accessibilityRepresentation { configuration.label }
            } else {
                // Use label's built-in icon
                configuration.label
                    .labelStyle(.iconOnly)
            }
        }
    }

    // MARK: - Background View

    @ViewBuilder
    private func backgroundView(isPressed: Bool) -> some View {
        switch intent {
        case .tab:
            // Tab: show selection indicator with matchedGeometryEffect
            if isSelected, let namespace {
                selectionThumb
                    .matchedGeometryEffect(id: "tabSelection", in: namespace)
            }

        case .action:
            selectionThumb
                .opacity(isPressed ? 1 : 0)
                .scaleEffect(isPressed ? 1.0 : GlassTokens.Animation.pressedScale)
                .animation(
                    reduceMotion ? nil : .interactiveSpring(duration: GlassTokens.Animation.pressDuration),
                    value: isPressed
                )
        }
    }

    /// Creates the appropriate selection thumb shape based on visual style and container context.
    @ViewBuilder
    private var selectionThumb: some View {
        if effectiveVisualStyle.isIconOnly && containerContext.isSingleItem {
            SelectionThumb(shape: Circle())
        } else {
            SelectionThumb(shape: Capsule())
        }
    }

    // MARK: - Foreground Color

    /// Computes foreground color based on intent, selection, and enabled state.
    ///
    /// Visual hierarchy:
    /// - **Action (enabled)**: Primary - always prominent
    /// - **Tab selected**: Uses blended color for contrast against selection background
    /// - **Tab unselected**: Secondary - clearly tappable but not active
    /// - **Disabled**: Primary at 30% opacity - clearly unavailable
    private func foregroundColor(isPressed: Bool) -> Color {
        guard isEnabled else {
            return .primary.opacity(GlassTokens.Opacity.disabled)
        }

        switch intent {
        case .action:
            return .primary

        case .tab:
            if isSelected {
                // Smart blending: slightly lighter to contrast with selection background
                return .primary
            } else {
                return isPressed ? .primary.opacity(GlassTokens.Opacity.pressedTab) : .secondary
            }
        }
    }
}

// MARK: - Convenience Button Style Extension

extension ButtonStyle where Self == GlassButtonStyle {
    /// Glass bar button style with configurable intent and visual style.
    ///
    /// - Parameters:
    ///   - intent: The semantic intent (`.tab` for navigation, `.action` for actions). Default: `.tab`
    ///   - style: The visual layout. Default: `.titleAndIcon()`
    ///     - `.titleOnly`: Title text only
    ///     - `.titleAndIcon(image:systemImage:)`: Icon + title (optional custom icon)
    ///     - `.iconOnly(image:systemImage:)`: Icon only (optional custom icon)
    ///   - isSelected: Whether the tab is selected (only for `.tab` intent). Default: `false`
    public static func glass(
        intent: GlassIntent = .tab,
        style: GlassVisualStyle = .titleAndIcon(),
        isSelected: Bool = false
    ) -> GlassButtonStyle {
        GlassButtonStyle(intent: intent, style: style, isSelected: isSelected)
    }
}
