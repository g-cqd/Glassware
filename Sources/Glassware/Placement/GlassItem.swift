//
//  GlassItem.swift
//  Glassware
//
//  Item wrapper for placement-based toolbar API with optional local density override.
//

import SwiftUI

// MARK: - Glass Toolbar Item

/// A single item positioned at a specific placement in the glass toolbar overlay.
///
/// `GlassItem` wraps content and associates it with a `GlassPlacement`.
/// Items can optionally override the inherited toolbar density.
///
/// ## Basic Usage
/// ```swift
/// GlassItem(placement: .bottomLeading) {
///     Button("Settings", systemImage: "gearshape") { }
///         .buttonStyle(.glass(style: .iconOnly()))
/// }
/// ```
///
/// ## With Local Density Override
/// ```swift
/// GlassItem(placement: .topTrailing) {
///     Button("Filter", systemImage: "line.3.horizontal.decrease") { }
/// }
/// .glassDensity(.compact)
/// ```
public struct GlassItem<Content: View>: View, GlassContent {
    // MARK: - Properties

    public let placement: GlassPlacement
    private var localDensity: GlassDensity?
    private let content: Content

    // MARK: - Initializers

    /// Creates a toolbar item at the specified placement.
    ///
    /// - Parameters:
    ///   - placement: Where to position this item in the toolbar overlay.
    ///   - content: The view content for this item.
    public init(
        placement: GlassPlacement,
        @ViewBuilder content: () -> Content
    ) {
        self.placement = placement
        self.localDensity = nil
        self.content = content()
    }

    // MARK: - Modifiers

    /// Sets a local density override for this toolbar item.
    ///
    /// When set, this density applies to the item's content instead of
    /// the inherited toolbar density.
    ///
    /// - Parameter density: The density to use for this item.
    /// - Returns: A modified toolbar item with local density.
    public func glassDensity(_ density: GlassDensity) -> GlassItem {
        var copy = self
        copy.localDensity = density
        return copy
    }

    // MARK: - Body

    public var body: some View {
        if let localDensity {
            content.environment(\.glassDensity, localDensity)
        } else {
            content
        }
    }
}

// MARK: - Glass Toolbar Item Group

/// A group of items positioned at a specific placement in the glass toolbar overlay.
///
/// Use `GlassItemGroup` when multiple items should share the same placement
/// and be rendered together in a single glass container.
///
/// ## Usage
/// ```swift
/// GlassItemGroup(placement: .bottomPrimary) {
///     ForEach(tabs) { tab in
///         Button(tab.title, systemImage: tab.icon) { selectedTab = tab }
///             .buttonStyle(.glass(isSelected: selectedTab == tab))
///     }
/// }
/// ```
public struct GlassItemGroup<Content: View>: View, GlassContent {
    // MARK: - Properties

    public let placement: GlassPlacement
    private var localDensity: GlassDensity?
    private let content: Content

    // MARK: - Initializers

    /// Creates a toolbar item group at the specified placement.
    ///
    /// - Parameters:
    ///   - placement: Where to position this group in the toolbar overlay.
    ///   - content: The view content for this group.
    public init(
        placement: GlassPlacement,
        @ViewBuilder content: () -> Content
    ) {
        self.placement = placement
        self.localDensity = nil
        self.content = content()
    }

    // MARK: - Modifiers

    /// Sets a local density override for this toolbar item group.
    ///
    /// - Parameter density: The density to use for this group.
    /// - Returns: A modified toolbar item group with local density.
    public func glassDensity(_ density: GlassDensity) -> GlassItemGroup {
        var copy = self
        copy.localDensity = density
        return copy
    }

    // MARK: - Body

    public var body: some View {
        if let localDensity {
            content.environment(\.glassDensity, localDensity)
        } else {
            content
        }
    }
}
