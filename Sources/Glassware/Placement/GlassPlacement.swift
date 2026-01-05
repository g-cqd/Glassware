//
//  GlassPlacement.swift
//  Glassware
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
/// GlassItem(placement: .bottomLeading) { settingsButton }
/// GlassItem(placement: .bottomPrimary) { tabs }
/// GlassItem(placement: .topTrailing) { filterButton }
/// ```
///
/// ## Accessory Placements
/// ```swift
/// // Accessory above bottom toolbar with 8pt overlap ("melting" effect)
/// GlassItem(placement: .bottomAccessory(offset: -8)) { picker }
///
/// // Accessory separated by 16pt
/// GlassItem(placement: .bottomAccessory(offset: 16)) { banner }
/// ```
public struct GlassPlacement: Sendable, Hashable {
    /// The edge where the toolbar container is positioned.
    public let edge: GlassEdge

    /// The position within the edge (leading, primary, trailing).
    public let position: GlassButtonPlacement

    /// Offset for accessory items. Nil means this is not an accessory.
    /// Negative values overlap with primary content ("melting" effect).
    /// Positive values add spacing between accessory and primary.
    public let accessoryOffset: CGFloat?

    /// Creates a placement with specified edge, position, and optional accessory offset.
    public init(
        edge: GlassEdge,
        position: GlassButtonPlacement,
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

extension GlassPlacement {
    /// Leading position on the bottom edge.
    public static let bottomLeading = GlassPlacement(
        edge: .bottom,
        position: .leading
    )

    /// Primary (center) position on the bottom edge.
    public static let bottomPrimary = GlassPlacement(
        edge: .bottom,
        position: .primary
    )

    /// Trailing position on the bottom edge.
    public static let bottomTrailing = GlassPlacement(
        edge: .bottom,
        position: .trailing
    )

    /// Accessory view above the bottom toolbar.
    ///
    /// Default spacing is 12pt above primary content (constant, density-independent).
    ///
    /// - Parameter offset: Adjustment to the default 12pt spacing.
    ///   - Positive values add more separation (accessory moves further from primary).
    ///   - Negative values reduce separation (accessory moves toward primary / overlaps).
    ///   - Example: `offset: -8` gives 4pt spacing (12 - 8 = 4pt).
    public static func bottomAccessory(offset: CGFloat = 0) -> GlassPlacement {
        GlassPlacement(edge: .bottom, position: .primary, accessoryOffset: offset)
    }
}

// MARK: - Top Edge Placements

extension GlassPlacement {
    /// Leading position on the top edge.
    public static let topLeading = GlassPlacement(
        edge: .top,
        position: .leading
    )

    /// Primary (center) position on the top edge.
    public static let topPrimary = GlassPlacement(
        edge: .top,
        position: .primary
    )

    /// Trailing position on the top edge.
    public static let topTrailing = GlassPlacement(
        edge: .top,
        position: .trailing
    )

    /// Accessory view below the top toolbar.
    public static func topAccessory(offset: CGFloat = 0) -> GlassPlacement {
        GlassPlacement(edge: .top, position: .primary, accessoryOffset: offset)
    }
}

// MARK: - Leading Edge Placements

extension GlassPlacement {
    /// Top position on the leading edge.
    public static let leadingTop = GlassPlacement(
        edge: .leading,
        position: .leading
    )

    /// Primary (center) position on the leading edge.
    public static let leadingPrimary = GlassPlacement(
        edge: .leading,
        position: .primary
    )

    /// Bottom position on the leading edge.
    public static let leadingBottom = GlassPlacement(
        edge: .leading,
        position: .trailing
    )

    /// Accessory view beside the leading toolbar.
    public static func leadingAccessory(offset: CGFloat = 0) -> GlassPlacement {
        GlassPlacement(edge: .leading, position: .primary, accessoryOffset: offset)
    }
}

// MARK: - Trailing Edge Placements

extension GlassPlacement {
    /// Top position on the trailing edge.
    public static let trailingTop = GlassPlacement(
        edge: .trailing,
        position: .leading
    )

    /// Primary (center) position on the trailing edge.
    public static let trailingPrimary = GlassPlacement(
        edge: .trailing,
        position: .primary
    )

    /// Bottom position on the trailing edge.
    public static let trailingBottom = GlassPlacement(
        edge: .trailing,
        position: .trailing
    )

    /// Accessory view beside the trailing toolbar.
    public static func trailingAccessory(offset: CGFloat = 0) -> GlassPlacement {
        GlassPlacement(edge: .trailing, position: .primary, accessoryOffset: offset)
    }
}

// MARK: - Semantic Accessory Helpers

extension GlassPlacement {
    /// Accessory positioned close to primary content (4pt gap instead of default 12pt).
    ///
    /// Creates a "melting" visual effect where the accessory appears to merge
    /// with the primary toolbar through glass effect overlap.
    public static func bottomAccessoryMelted() -> GlassPlacement {
        .bottomAccessory(offset: -8)
    }

    /// Accessory with additional separation from primary content.
    ///
    /// - Parameter spacing: Extra spacing to add beyond the default 12pt.
    ///   Example: `spacing: 8` gives 20pt total gap (12 + 8 = 20pt).
    public static func bottomAccessorySeparated(spacing: CGFloat = 8) -> GlassPlacement {
        .bottomAccessory(offset: spacing)
    }
}
