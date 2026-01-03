//
//  ToolbarEdge.swift
//  GlassToolbar
//
//  Edge positioning for toolbar placement.
//

import SwiftUI

// MARK: - Toolbar Edge

/// Defines which edge of the screen the toolbar is attached to.
///
/// The edge affects both layout orientation and safe area handling:
/// - `.top`/`.bottom`: Horizontal layout (HStack)
/// - `.leading`/`.trailing`: Vertical layout (VStack)
///
/// Each edge automatically respects the appropriate safe areas
/// (notch, home indicator, rounded corners, sidebar).
public enum ToolbarEdge: Int, Sendable, Equatable {
    /// Toolbar at the top of the screen (horizontal layout).
    case top = 0

    /// Toolbar at the bottom of the screen (horizontal layout, default).
    case bottom = 1

    /// Toolbar at the leading edge of the screen (vertical layout).
    case leading = 2

    /// Toolbar at the trailing edge of the screen (vertical layout).
    case trailing = 3

    /// Whether this edge uses vertical layout (VStack).
    public var isVertical: Bool {
        self == .leading || self == .trailing
    }

    /// Whether this edge uses horizontal layout (HStack).
    public var isHorizontal: Bool {
        self == .top || self == .bottom
    }

    /// The alignment for overlay positioning.
    public var overlayAlignment: Alignment {
        switch self {
        case .top: .top
        case .bottom: .bottom
        case .leading: .leading
        case .trailing: .trailing
        }
    }
}
