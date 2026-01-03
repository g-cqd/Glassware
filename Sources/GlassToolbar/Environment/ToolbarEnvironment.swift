//
//  ToolbarEnvironment.swift
//  GlassToolbar
//
//  Environment keys for toolbar configuration.
//

import SwiftUI

// MARK: - Toolbar Button Placement

/// Defines the placement context for toolbar buttons.
///
/// Performance note: Using enum with raw Int enables O(1) switch dispatch
/// via jump table. Sendable conformance allows safe cross-actor usage.
public enum ToolbarButtonPlacement: Int, Sendable, Equatable {
    case leading = 0
    case primary = 1
    case trailing = 2
}

// MARK: - Environment Keys

extension EnvironmentValues {
    /// The placement context for toolbar buttons.
    /// Set automatically by GlassToolbar based on container position.
    @Entry public var toolbarButtonPlacement: ToolbarButtonPlacement = .primary

    /// The density level for the toolbar.
    /// Affects both item sizing and spacing between items.
    @Entry public var toolbarDensity: ToolbarDensity = .regular

    /// The namespace for toolbar selection animation within a container.
    /// Each container creates its own namespace to ensure matchedGeometryEffect
    /// only animates between items in the same container.
    @Entry public var toolbarContainerNamespace: Namespace.ID? = nil

    /// Padding configuration for the glass toolbar.
    /// Controls safe area handling and external margins.
    @Entry public var toolbarPaddingConfiguration: ToolbarPaddingConfiguration = .default

    /// Layout distribution for the glass toolbar.
    /// Controls how containers distribute space when compartments are empty.
    @Entry public var toolbarLayoutDistribution: ToolbarLayoutDistribution = .natural

    /// Forced visual style override for toolbar items.
    /// When set, toolbar buttons use this style instead of their configured style.
    /// Used by AdaptiveLabelContainer for ViewThatFits progressive degradation.
    @Entry var toolbarForcedVisualStyle: ToolbarItemVisualStyle? = nil

    /// The edge of the screen where the toolbar is positioned.
    /// Set by the toolbar container for child components to adapt their layout.
    @Entry public var toolbarEdge: ToolbarEdge = .bottom

    /// Container context for toolbar items.
    /// Provides information about siblings within the same container.
    @Entry var toolbarContainerContext: ToolbarContainerContext = .default
}

// MARK: - Toolbar Container Context

/// Context information passed from container to child items.
///
/// This enables buttons to know their sibling count and adjust their shape accordingly:
/// - Single icon-only button in a container uses circle shape
/// - Multiple icon-only buttons in a container use capsule shape
public struct ToolbarContainerContext: Sendable, Equatable {
    /// Number of items in the container.
    public let itemCount: Int

    /// Whether this container is on a vertical edge (leading/trailing).
    public let isVerticalEdge: Bool

    /// Default context for standalone usage.
    public static let `default` = ToolbarContainerContext(itemCount: 1, isVerticalEdge: false)

    public init(itemCount: Int, isVerticalEdge: Bool) {
        self.itemCount = itemCount
        self.isVerticalEdge = isVerticalEdge
    }

    /// Whether the container has a single item.
    public var isSingleItem: Bool {
        itemCount == 1
    }
}

// MARK: - Toolbar Height Report

/// Reports the total rendered height for each toolbar edge.
///
/// Content views can read this to add appropriate padding or safe area insets
/// to prevent overlap with floating toolbar overlays.
///
/// ## Usage
/// ```swift
/// @Environment(\.toolbarHeights) private var toolbarHeights
///
/// ScrollView {
///     content
/// }
/// .safeAreaPadding(.bottom, toolbarHeights.bottom ?? 0)
/// ```
public struct ToolbarHeightReport: Sendable, Equatable {
    /// Total height of the bottom toolbar (primary + accessory + spacing).
    public var bottom: CGFloat?

    /// Total height of the top toolbar.
    public var top: CGFloat?

    /// Total width of the leading toolbar.
    public var leading: CGFloat?

    /// Total width of the trailing toolbar.
    public var trailing: CGFloat?

    /// Default empty report.
    public static let empty = ToolbarHeightReport()

    public init(
        bottom: CGFloat? = nil,
        top: CGFloat? = nil,
        leading: CGFloat? = nil,
        trailing: CGFloat? = nil
    ) {
        self.bottom = bottom
        self.top = top
        self.leading = leading
        self.trailing = trailing
    }

    /// Returns height/width for a specific edge.
    public subscript(edge: ToolbarEdge) -> CGFloat? {
        get {
            switch edge {
            case .bottom: bottom
            case .top: top
            case .leading: leading
            case .trailing: trailing
            }
        }
        set {
            switch edge {
            case .bottom: bottom = newValue
            case .top: top = newValue
            case .leading: leading = newValue
            case .trailing: trailing = newValue
            }
        }
    }
}

// MARK: - Height Report Environment

extension EnvironmentValues {
    /// Reported heights for all toolbar edges.
    /// Content can use this to add padding that accounts for floating toolbars.
    @Entry public var toolbarHeights: ToolbarHeightReport = .empty
}

// MARK: - View Extension for Density

extension View {
    /// Sets the toolbar density for this view and its descendants.
    ///
    /// - Parameter density: The density level to apply.
    /// - Returns: A view with the modified toolbar density.
    public func toolbarDensity(_ density: ToolbarDensity) -> some View {
        environment(\.toolbarDensity, density)
    }

    /// Sets the toolbar padding configuration for this view and its descendants.
    ///
    /// - Parameter configuration: The padding configuration to apply.
    /// - Returns: A view with the modified toolbar padding.
    public func toolbarPadding(_ configuration: ToolbarPaddingConfiguration) -> some View {
        environment(\.toolbarPaddingConfiguration, configuration)
    }

    /// Sets the toolbar layout distribution for this view and its descendants.
    ///
    /// - Parameter distribution: The layout distribution to apply.
    /// - Returns: A view with the modified toolbar layout.
    public func toolbarDistribution(_ distribution: ToolbarLayoutDistribution) -> some View {
        environment(\.toolbarLayoutDistribution, distribution)
    }
}

// MARK: - Toolbar Content Padding Modifier

/// Modifier that reads toolbar heights and applies appropriate safe area padding.
private struct ToolbarContentPaddingModifier: ViewModifier {
    @Environment(\.toolbarHeights) private var heights

    func body(content: Content) -> some View {
        content
            .safeAreaPadding(.bottom, heights.bottom ?? 0)
            .safeAreaPadding(.top, heights.top ?? 0)
            .safeAreaPadding(.leading, heights.leading ?? 0)
            .safeAreaPadding(.trailing, heights.trailing ?? 0)
    }
}

extension View {
    /// Applies safe area padding to avoid overlap with glass toolbar overlays.
    ///
    /// This modifier reads the `toolbarHeights` environment and applies
    /// appropriate padding for each edge where a toolbar exists.
    ///
    /// ## Usage
    /// ```swift
    /// ScrollView {
    ///     content
    /// }
    /// .glassToolbarContentPadding()
    /// .glassToolbarOverlay {
    ///     GlassToolbarItem(placement: .bottomPrimary) { ... }
    /// }
    /// ```
    ///
    /// - Returns: A view with safe area padding applied for all toolbar edges.
    public func glassToolbarContentPadding() -> some View {
        modifier(ToolbarContentPaddingModifier())
    }
}
