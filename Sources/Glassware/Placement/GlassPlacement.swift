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
/// // Accessory overlapping bottom toolbar by 8pt ("melting" effect)
/// GlassItem(placement: .bottomAccessory(offset: -8)) { picker }
///
/// // Accessory with 16pt gap from toolbar
/// GlassItem(placement: .bottomAccessory(offset: 16)) { banner }
/// ```
public struct GlassPlacement: Sendable, Hashable {
    /// The edge where the toolbar container is positioned.
    public let edge: GlassEdge

    /// The position within the edge (leading, primary, trailing).
    public let position: GlassButtonPlacement

    /// Offset for accessory items. Nil means this is not an accessory.
    /// - Zero = accessory's edge touches primary's edge (no gap)
    /// - Positive = gap between accessory and primary
    /// - Negative = accessory overlaps primary ("melting" effect)
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
    /// - Parameter offset: Distance between accessory bottom and toolbar top.
    ///   - `0` = touching (accessory bottom at toolbar top)
    ///   - Positive = gap (e.g., `8` = 8pt gap)
    ///   - Negative = overlap (e.g., `-8` = 8pt overlap, "melting" effect)
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
    /// Accessory overlapping the primary toolbar by 8pt.
    ///
    /// Creates a "melting" visual effect where the accessory appears to merge
    /// with the primary toolbar through glass effect overlap.
    public static func bottomAccessoryMelted() -> GlassPlacement {
        .bottomAccessory(offset: -8)
    }

    /// Accessory separated from primary content by a gap.
    ///
    /// - Parameter spacing: Gap between accessory and primary toolbar.
    ///   Default is 8pt.
    public static func bottomAccessorySeparated(spacing: CGFloat = 8) -> GlassPlacement {
        .bottomAccessory(offset: spacing)
    }
}
