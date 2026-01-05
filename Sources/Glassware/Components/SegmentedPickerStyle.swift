//
//  SegmentedPickerStyle.swift
//  Glassware
//
//  Visual style configuration for segmented picker items.
//

import Foundation

// MARK: - Segmented Picker Style

/// Visual style for segmented picker items.
public enum SegmentedPickerStyle: Sendable, Equatable {
    /// Shows only the icon.
    case iconOnly
    /// Shows only the title text.
    case titleOnly
    /// Shows icon above title (vertical stack).
    case titleAndIcon
}
