//
//  GlassToolbarPlacement.swift
//  GlassToolbar
//
//  Defines placement positions for toolbar items in the multi-edge overlay API.
//

import SwiftUI

// MARK: - Glass Toolbar Placement

/// Defines where a toolbar item should be placed in the glass toolbar overlay.
///
/// Placements combine an edge (top, bottom, leading, trailing) with a position
/// within that edge (leading, primary, trailing). Accessories can be positioned
/// relative to the primary content with configurable offset.
///
/// ## Basic Placements
/// ```swift
/// GlassToolbarItem(placement: .bottomLeading) { settingsButton }
/// GlassToolbarItem(placement: .bottomPrimary) { tabs }
/// GlassToolbarItem(placement: .topTrailing) { filterButton }
/// ```
///
/// ## Accessory Placements
/// ```swift
/// // Accessory above bottom toolbar with 8pt overlap ("melting" effect)
/// GlassToolbarItem(placement: .bottomAccessory(offset: -8)) { picker }
///
/// // Accessory separated by 16pt
/// GlassToolbarItem(placement: .bottomAccessory(offset: 16)) { banner }
/// ```
public struct GlassToolbarPlacement: Sendable, Hashable {
    /// The edge where the toolbar container is positioned.
    public let edge: ToolbarEdge

    /// The position within the edge (leading, primary, trailing).
    public let position: ToolbarButtonPlacement

    /// Offset for accessory items. Nil means this is not an accessory.
    /// Negative values overlap with primary content ("melting" effect).
    /// Positive values add spacing between accessory and primary.
    public let accessoryOffset: CGFloat?

    /// Creates a placement with specified edge, position, and optional accessory offset.
    public init(
        edge: ToolbarEdge,
        position: ToolbarButtonPlacement,
        accessoryOffset: CGFloat? = nil
    ) {
        self.edge = edge
        self.position = position
        self.accessoryOffset = accessoryOffset
    }

    /// Whether this placement is for an accessory view.
    public var isAccessory: Bool {
        accessoryOffset != nil
    }
}

// MARK: - Bottom Edge Placements

extension GlassToolbarPlacement {
    /// Leading position on the bottom edge.
    public static let bottomLeading = GlassToolbarPlacement(
        edge: .bottom,
        position: .leading
    )

    /// Primary (center) position on the bottom edge.
    public static let bottomPrimary = GlassToolbarPlacement(
        edge: .bottom,
        position: .primary
    )

    /// Trailing position on the bottom edge.
    public static let bottomTrailing = GlassToolbarPlacement(
        edge: .bottom,
        position: .trailing
    )

    /// Accessory view above the bottom toolbar.
    ///
    /// - Parameter offset: Distance from accessory to primary content.
    ///   Negative values overlap ("melt" into primary), positive values add spacing.
    public static func bottomAccessory(offset: CGFloat = 0) -> GlassToolbarPlacement {
        GlassToolbarPlacement(edge: .bottom, position: .primary, accessoryOffset: offset)
    }
}

// MARK: - Top Edge Placements

extension GlassToolbarPlacement {
    /// Leading position on the top edge.
    public static let topLeading = GlassToolbarPlacement(
        edge: .top,
        position: .leading
    )

    /// Primary (center) position on the top edge.
    public static let topPrimary = GlassToolbarPlacement(
        edge: .top,
        position: .primary
    )

    /// Trailing position on the top edge.
    public static let topTrailing = GlassToolbarPlacement(
        edge: .top,
        position: .trailing
    )

    /// Accessory view below the top toolbar.
    public static func topAccessory(offset: CGFloat = 0) -> GlassToolbarPlacement {
        GlassToolbarPlacement(edge: .top, position: .primary, accessoryOffset: offset)
    }
}

// MARK: - Leading Edge Placements

extension GlassToolbarPlacement {
    /// Top position on the leading edge.
    public static let leadingTop = GlassToolbarPlacement(
        edge: .leading,
        position: .leading
    )

    /// Primary (center) position on the leading edge.
    public static let leadingPrimary = GlassToolbarPlacement(
        edge: .leading,
        position: .primary
    )

    /// Bottom position on the leading edge.
    public static let leadingBottom = GlassToolbarPlacement(
        edge: .leading,
        position: .trailing
    )

    /// Accessory view beside the leading toolbar.
    public static func leadingAccessory(offset: CGFloat = 0) -> GlassToolbarPlacement {
        GlassToolbarPlacement(edge: .leading, position: .primary, accessoryOffset: offset)
    }
}

// MARK: - Trailing Edge Placements

extension GlassToolbarPlacement {
    /// Top position on the trailing edge.
    public static let trailingTop = GlassToolbarPlacement(
        edge: .trailing,
        position: .leading
    )

    /// Primary (center) position on the trailing edge.
    public static let trailingPrimary = GlassToolbarPlacement(
        edge: .trailing,
        position: .primary
    )

    /// Bottom position on the trailing edge.
    public static let trailingBottom = GlassToolbarPlacement(
        edge: .trailing,
        position: .trailing
    )

    /// Accessory view beside the trailing toolbar.
    public static func trailingAccessory(offset: CGFloat = 0) -> GlassToolbarPlacement {
        GlassToolbarPlacement(edge: .trailing, position: .primary, accessoryOffset: offset)
    }
}

// MARK: - Semantic Accessory Helpers

extension GlassToolbarPlacement {
    /// Accessory that overlaps with primary content by 8pt ("melting" effect).
    public static func bottomAccessoryMelted() -> GlassToolbarPlacement {
        .bottomAccessory(offset: -8)
    }

    /// Accessory separated from primary content by default spacing.
    public static func bottomAccessorySeparated(spacing: CGFloat = 16) -> GlassToolbarPlacement {
        .bottomAccessory(offset: spacing)
    }
}
