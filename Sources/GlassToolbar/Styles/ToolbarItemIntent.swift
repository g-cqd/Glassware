//
//  ToolbarItemIntent.swift
//  GlassToolbar
//
//  Semantic intent for toolbar button behavior.
//

import SwiftUI

// MARK: - Toolbar Item Intent

/// Defines the semantic intent of a toolbar button, affecting its visual behavior.
///
/// Intent determines how the button responds to interaction:
/// - **Tab**: For navigation buttons that can be selected/unselected.
///   Shows selection indicator and supports matchedGeometryEffect animation.
/// - **Action**: For buttons that perform discrete actions (Share, Edit, Delete).
///   Shows press feedback with scaling background. Does not have selection state.
public enum ToolbarItemIntent: Int, Sendable, Equatable {
    /// Navigation button with selection state.
    /// Used for tabs like Home, Favorites, Profile.
    case tab = 0

    /// Action button without selection state.
    /// Used for actions like Share, Edit, Delete, Add.
    case action = 1
}
