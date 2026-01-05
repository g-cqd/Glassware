//
//  GlassVisualStyle.swift
//  Glassware
//
//  Visual layout options for toolbar button content.
//

import SwiftUI

// MARK: - Toolbar Item Visual Style

/// Defines the visual layout of a toolbar button's content.
///
/// Style controls which elements are displayed and optionally overrides the icon:
/// - **titleOnly**: Shows only label text
/// - **titleAndIcon**: Shows both icon and label text (default). Optionally specify custom icon.
/// - **iconOnly**: Shows only icon. Optionally specify custom icon.
///
/// When no custom icon is provided, the button uses the icon from its Label.
/// When a custom icon is specified, it overrides the Label's icon.
///
/// ## Usage
/// ```swift
/// // Use label's built-in icon
/// Button("Home", systemImage: "house") {}
///     .buttonStyle(.glass(style: .iconOnly()))
///
/// // Override with custom system image
/// Button("Add") {}
///     .buttonStyle(.glass(style: .iconOnly(systemImage: "plus")))
///
/// // Override with asset image
/// Button("Profile") {}
///     .buttonStyle(.glass(style: .iconOnly(image: "custom-icon")))
/// ```
public enum GlassVisualStyle: Sendable, Equatable {
    /// Displays only the title label.
    case titleOnly

    /// Displays both icon and title label vertically stacked.
    /// - Parameters:
    ///   - image: Optional asset image name to override the label's icon.
    ///   - systemImage: Optional SF Symbol name to override the label's icon.
    case titleAndIcon(image: String? = nil, systemImage: String? = nil)

    /// Displays only the icon.
    /// - Parameters:
    ///   - image: Optional asset image name to override the label's icon.
    ///   - systemImage: Optional SF Symbol name to override the label's icon.
    case iconOnly(image: String? = nil, systemImage: String? = nil)

    /// Whether this style shows icon only (no title).
    public var isIconOnly: Bool {
        if case .iconOnly = self { return true }
        return false
    }

    /// Whether this style shows title only (no icon).
    public var isTitleOnly: Bool {
        if case .titleOnly = self { return true }
        return false
    }

    /// The custom image name if specified.
    public var customImage: String? {
        switch self {
        case .titleOnly: return nil
        case .titleAndIcon(let image, _): return image
        case .iconOnly(let image, _): return image
        }
    }

    /// The custom system image name if specified.
    public var customSystemImage: String? {
        switch self {
        case .titleOnly: return nil
        case .titleAndIcon(_, let systemImage): return systemImage
        case .iconOnly(_, let systemImage): return systemImage
        }
    }

    /// Whether a custom icon is specified.
    public var hasCustomIcon: Bool {
        customImage != nil || customSystemImage != nil
    }

    // MARK: - Convenience Static Properties

    /// Icon only with no custom icon (uses label's built-in icon).
    public static var iconOnly: Self { .iconOnly() }

    /// Title and icon with no custom icon (uses label's built-in icon).
    public static var titleAndIcon: Self { .titleAndIcon() }
}
