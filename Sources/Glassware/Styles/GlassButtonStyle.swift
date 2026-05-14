//
//  GlassButtonStyle.swift
//  Glassware
//
//  Button styles for glass toolbar items with native SwiftUI configuration support.
//

import SwiftUI

// MARK: - Glass Button Style

/// A button style for glass toolbar items.
///
/// This style provides elegant press feedback through coordinated effects:
/// - Foreground opacity change on press
/// - Haptic feedback
/// - Smooth symbol replacement transitions
///
/// It automatically responds to:
/// - **Pressed state**: Dims foreground opacity
/// - **Disabled state**: Smoothly fades to 30% opacity
/// - **Destructive role**: Tints foreground red
/// - **Cancel role**: Standard primary appearance
/// - **Symbol changes**: Smooth replace transition between SF Symbols
///
/// ## Usage
/// ```swift
/// Button("Share", systemImage: "square.and.arrow.up") { }
///     .buttonStyle(.glass)
///
/// Button("Delete", systemImage: "trash", role: .destructive) { }
///     .buttonStyle(.glass)
///
/// Button("Settings", systemImage: "gearshape") { }
///     .buttonStyle(.glass(style: .iconOnly()))
/// ```
public struct GlassButtonStyle: ButtonStyle {
    // MARK: - Configuration

    /// The visual layout style (titleAndIcon, titleOnly, iconOnly).
    public let visualStyle: GlassVisualStyle

    // MARK: - Environment

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.glassDensity) private var density
    @Environment(\.glassSizeContext) private var sizeContext
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

    /// Layout metrics computed from density and context.
    private var metrics: GlassMetrics {
        GlassMetrics(density: density, context: sizeContext)
    }

    /// Actual minimum width, accounting for density.
    private var scaledMinWidth: CGFloat {
        baseMinWidth * (metrics.primaryButtonMinWidth / 64.0)
    }

    /// Actual minimum height, accounting for density and context.
    private var scaledMinHeight: CGFloat {
        baseMinHeight * (metrics.effectiveButtonSize / 44.0)
    }

    /// Actual icon button size, accounting for density and context.
    private var scaledSize: CGFloat {
        baseSize * (metrics.effectiveButtonSize / 44.0)
    }

    /// Image scale based on density and visual style.
    private var imageScale: Image.Scale {
        if effectiveVisualStyle.isIconOnly {
            switch density {
            case .extraSparse, .sparse, .regular, .compact: .large
            case .dense, .extraDense: .medium
            }
        } else {
            metrics.imageScale
        }
    }

    // MARK: - Initializer

    public init(style: GlassVisualStyle = .titleAndIcon()) {
        self.visualStyle = style
    }

    // MARK: - Body

    public func makeBody(configuration: Configuration) -> some View {
        let role = configuration.role

        labelContent(configuration: configuration)
            .font(.body.weight(.medium))
            .fontDesign(.rounded)
            .imageScale(imageScale)
            .foregroundStyle(foregroundColor(role: role))
            .opacity(labelOpacity(isPressed: configuration.isPressed))
            .frame(
                minWidth: effectiveVisualStyle.isIconOnly ? scaledSize : nil,
                idealWidth: effectiveVisualStyle.isIconOnly ? nil : scaledMinWidth,
                minHeight: scaledMinHeight
            )
            .padding(.vertical, metrics.effectiveComponentPadding)
            .padding(.horizontal, effectiveHorizontalPadding)
            .contentShape(.rect)
            .sensoryFeedback(.selection, trigger: configuration.isPressed) { _, newValue in
                newValue
            }
            .animation(disabledAnimation, value: isEnabled)
    }

    // MARK: - Layout Helpers

    private var disabledAnimation: Animation? {
        reduceMotion ? nil : .easeInOut(duration: GlassTokens.Animation.disabledTransitionDuration)
    }

    private var effectiveHorizontalPadding: CGFloat {
        if effectiveVisualStyle.isIconOnly || containerContext.isVerticalEdge {
            metrics.effectiveComponentPadding
        } else {
            metrics.effectiveComponentPadding + 6
        }
    }

    // MARK: - Label Content

    @ViewBuilder
    private func labelContent(configuration: Configuration) -> some View {
        switch effectiveVisualStyle {
        case .titleAndIcon(let image, let systemImage):
            if let systemImage {
                GlassLabelStyle.IconLabel(
                    icon: Image(systemName: systemImage),
                    title: { configuration.label.labelStyle(.titleOnly) },
                    density: density
                )
            } else if let image {
                GlassLabelStyle.IconLabel(
                    icon: Image(image),
                    title: { configuration.label.labelStyle(.titleOnly) },
                    density: density
                )
            } else {
                configuration.label
                    .labelStyle(GlassLabelStyle())
            }

        case .titleOnly:
            configuration.label
                .labelStyle(.titleOnly)

        case .iconOnly(let image, let systemImage):
            Group {
                if let systemImage {
                    Image(systemName: systemImage)
                        .accessibilityHidden(true)
                        .accessibilityRepresentation { configuration.label }
                } else if let image {
                    Image(image)
                        .accessibilityHidden(true)
                        .accessibilityRepresentation { configuration.label }
                } else {
                    configuration.label
                        .labelStyle(.iconOnly)
                }
            }
            .contentTransition(.symbolEffect(.replace))
        }
    }

    // MARK: - Foreground Color & Opacity

    /// Foreground color based on role.
    private func foregroundColor(role: ButtonRole?) -> Color {
        role == .destructive ? .red : .primary
    }

    /// Label opacity based on pressed and enabled states.
    private func labelOpacity(isPressed: Bool) -> CGFloat {
        if !isEnabled { return GlassTokens.Opacity.disabled }
        return isPressed ? 0.6 : 1
    }
}

// MARK: - Glass Prominent Button Style

/// A prominent button style for primary actions in glass toolbars.
///
/// This style provides higher visual prominence than the standard glass style,
/// suitable for primary or call-to-action buttons. Features:
/// - Persistent selection thumb background
/// - Scale and opacity feedback on press
/// - Smooth symbol replacement transitions
///
/// It automatically responds to:
/// - **Pressed state**: Scales background, dims opacity
/// - **Disabled state**: Smoothly fades to 30% opacity
/// - **Destructive role**: Red-tinted background and white foreground
/// - **Cancel role**: Standard appearance
/// - **Symbol changes**: Smooth replace transition between SF Symbols
///
/// ## Usage
/// ```swift
/// Button("Add", systemImage: "plus") { }
///     .buttonStyle(.glassProminent)
///
/// Button("Save") { }
///     .buttonStyle(.glassProminent(style: .titleOnly))
/// ```
public struct GlassProminentButtonStyle: ButtonStyle {
    // MARK: - Configuration

    /// The visual layout style (titleAndIcon, titleOnly, iconOnly).
    public let visualStyle: GlassVisualStyle

    // MARK: - Environment

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.glassDensity) private var density
    @Environment(\.glassSizeContext) private var sizeContext
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

    /// Layout metrics computed from density and context.
    private var metrics: GlassMetrics {
        GlassMetrics(density: density, context: sizeContext)
    }

    /// Actual minimum width, accounting for density.
    private var scaledMinWidth: CGFloat {
        baseMinWidth * (metrics.primaryButtonMinWidth / 64.0)
    }

    /// Actual minimum height, accounting for density and context.
    private var scaledMinHeight: CGFloat {
        baseMinHeight * (metrics.effectiveButtonSize / 44.0)
    }

    /// Actual icon button size, accounting for density and context.
    private var scaledSize: CGFloat {
        baseSize * (metrics.effectiveButtonSize / 44.0)
    }

    /// Image scale based on density and visual style.
    private var imageScale: Image.Scale {
        if effectiveVisualStyle.isIconOnly {
            switch density {
            case .extraSparse, .sparse, .regular, .compact: .large
            case .dense, .extraDense: .medium
            }
        } else {
            metrics.imageScale
        }
    }

    // MARK: - Initializer

    public init(style: GlassVisualStyle = .titleAndIcon()) {
        self.visualStyle = style
    }

    // MARK: - Body

    public func makeBody(configuration: Configuration) -> some View {
        let role = configuration.role

        labelContent(configuration: configuration)
            .font(.body.weight(.medium))
            .fontDesign(.rounded)
            .imageScale(imageScale)
            .foregroundStyle(foregroundColor(role: role))
            .opacity(labelOpacity(isPressed: configuration.isPressed))
            .frame(
                minWidth: effectiveVisualStyle.isIconOnly ? scaledSize : nil,
                idealWidth: effectiveVisualStyle.isIconOnly ? nil : scaledMinWidth,
                minHeight: scaledMinHeight
            )
            .padding(.vertical, metrics.effectiveComponentPadding)
            .padding(.horizontal, effectiveHorizontalPadding)
            .background { backgroundView(role: role) }
            .contentShape(.rect)
            .sensoryFeedback(.selection, trigger: configuration.isPressed) { _, newValue in
                newValue
            }
            .animation(disabledAnimation, value: isEnabled)
    }

    // MARK: - Layout Helpers

    private var disabledAnimation: Animation? {
        reduceMotion ? nil : .easeInOut(duration: GlassTokens.Animation.disabledTransitionDuration)
    }

    private var effectiveHorizontalPadding: CGFloat {
        if effectiveVisualStyle.isIconOnly || containerContext.isVerticalEdge {
            metrics.effectiveComponentPadding
        } else {
            metrics.effectiveComponentPadding + 6
        }
    }

    // MARK: - Label Content

    @ViewBuilder
    private func labelContent(configuration: Configuration) -> some View {
        switch effectiveVisualStyle {
        case .titleAndIcon(let image, let systemImage):
            if let systemImage {
                GlassLabelStyle.IconLabel(
                    icon: Image(systemName: systemImage),
                    title: { configuration.label.labelStyle(.titleOnly) },
                    density: density
                )
            } else if let image {
                GlassLabelStyle.IconLabel(
                    icon: Image(image),
                    title: { configuration.label.labelStyle(.titleOnly) },
                    density: density
                )
            } else {
                configuration.label
                    .labelStyle(GlassLabelStyle())
            }

        case .titleOnly:
            configuration.label
                .labelStyle(.titleOnly)

        case .iconOnly(let image, let systemImage):
            Group {
                if let systemImage {
                    Image(systemName: systemImage)
                        .accessibilityHidden(true)
                        .accessibilityRepresentation { configuration.label }
                } else if let image {
                    Image(image)
                        .accessibilityHidden(true)
                        .accessibilityRepresentation { configuration.label }
                } else {
                    configuration.label
                        .labelStyle(.iconOnly)
                }
            }
            .contentTransition(.symbolEffect(.replace))
        }
    }

    // MARK: - Background View

    @ViewBuilder
    private func backgroundView(role: ButtonRole?) -> some View {
        if role == .destructive {
            let shape = effectiveVisualStyle.isIconOnly && containerContext.isSingleItem
                ? AnyShape(.circle)
                : AnyShape(.capsule)
            DestructiveThumb(shape: shape)
        }
    }

    // MARK: - Foreground Color & Opacity

    /// Foreground color based on role.
    private func foregroundColor(role: ButtonRole?) -> Color {
        role == .destructive ? .white : .primary
    }

    /// Label opacity reacts to both enabled and press state so the prominent
    /// style gets the same press feedback as the standard one (audit 1.8).
    private func labelOpacity(isPressed: Bool) -> CGFloat {
        if !isEnabled { return GlassTokens.Opacity.disabled }
        return isPressed ? 0.6 : 1
    }
}

// MARK: - Destructive Thumb

/// Selection indicator with a destructive (red) appearance.
private struct DestructiveThumb<S: Shape>: View {
    let shape: S

    var body: some View {
        shape
            .fill(Color.red.opacity(0.2))
            .overlay {
                shape.stroke(Color.red.opacity(0.4), lineWidth: GlassTokens.Border.lineWidth)
            }
    }
}

// MARK: - Convenience Extensions

extension ButtonStyle where Self == GlassButtonStyle {
    /// Glass button style for toolbar actions.
    ///
    /// A subtle style that shows press feedback on interaction.
    /// Automatically handles destructive and cancel roles.
    ///
    /// - Parameter style: The visual layout. Default: `.titleAndIcon()`
    public static func glass(style: GlassVisualStyle = .titleAndIcon()) -> GlassButtonStyle {
        GlassButtonStyle(style: style)
    }
}

extension ButtonStyle where Self == GlassProminentButtonStyle {
    /// Prominent glass button style for primary actions.
    ///
    /// A more visible style with persistent background, suitable for
    /// call-to-action or primary buttons.
    ///
    /// - Parameter style: The visual layout. Default: `.titleAndIcon()`
    public static func glassProminent(style: GlassVisualStyle = .titleAndIcon()) -> GlassProminentButtonStyle {
        GlassProminentButtonStyle(style: style)
    }
}
