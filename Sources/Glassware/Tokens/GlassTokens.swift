//
//  GlassTokens.swift
//  Glassware
//
//  Design tokens for the glass toolbar system.
//  Centralizes all magic numbers for consistency and easy theming.
//

import SwiftUI

/// Design tokens for the glass toolbar system.
///
/// This namespace centralizes all hardcoded values used throughout the toolbar,
/// making it easy to maintain consistency and adjust the visual design.
///
/// ## Usage
/// ```swift
/// Color.primary.inverted.opacity(GlassTokens.Opacity.backgroundFill)
/// ```
public enum GlassTokens: Sendable {

    // MARK: - Opacity Values

    /// Opacity tokens for various visual elements.
    public enum Opacity: Sendable {
        /// Background fill opacity for selection indicators and pressed states.
        public static let backgroundFill: Double = 0.3

        /// Border stroke opacity for glass container outlines.
        public static let borderStroke: Double = 0.5

        /// Disabled state opacity.
        public static let disabled: Double = 0.3

        /// Pressed tab state opacity.
        public static let pressedTab: Double = 0.9
    }

    // MARK: - Selection Thumb Values

    /// Design tokens for the selection thumb indicator.
    /// Uses a white-based approach that works universally on glass backgrounds.
    public enum SelectionThumb: Sendable {
        /// Fill opacity for the thumb background.
        /// White at this opacity creates a gentle presence without being harsh.
        public static let fillOpacity: Double = 0.1

        /// Stroke opacity for the subtle edge definition.
        /// "Slight" - visible but not heavy.
        public static let strokeOpacity: Double = 0.12

        /// Shadow opacity for the soft depth effect.
        /// "Very very soft" - barely perceptible lift.
        public static let shadowOpacity: Double = 0.06

        /// Shadow radius for the small, delicate shadow.
        /// "Small" - tight and subtle.
        public static let shadowRadius: CGFloat = 2
    }

    // MARK: - Shadow Values

    /// Shadow tokens for depth and elevation.
    public enum Shadow: Sendable {
        /// Shadow radius for selection indicators.
        public static let radius: CGFloat = 5

        /// Shadow opacity for selection indicators.
        public static let opacity: Double = 0.3

        /// Text shadow radius for selected labels (contrast enhancement).
        public static let textRadius: CGFloat = 1

        /// Text shadow opacity for selected labels.
        public static let textOpacity: Double = 0.15

        /// Text shadow Y offset.
        public static let textOffsetY: CGFloat = 0.5
    }

    // MARK: - Border Values

    /// Border tokens for strokes and outlines.
    public enum Border: Sendable {
        /// Line width for glass container borders.
        public static let lineWidth: CGFloat = 0.5
    }

    // MARK: - Animation Values

    /// Animation duration tokens.
    public enum Animation: Sendable {
        /// Duration for selection state changes.
        public static let selectionDuration: Double = 0.25

        /// Duration for item state changes.
        public static let itemDuration: Double = 0.2

        /// Duration for press feedback.
        public static let pressDuration: Double = 0.1

        /// Scale factor for action button press state.
        public static let pressedScale: CGFloat = 0.85
    }

    // MARK: - Typography Values

    /// Typography tokens for text scaling and sizing.
    public enum Typography: Sendable {
        /// Minimum scale factor for label text.
        public static let minimumScaleFactor: CGFloat = 0.8
    }

    // MARK: - Accessibility Values

    /// Accessibility-related tokens.
    public enum Accessibility: Sendable {
        /// Minimum tap target size per Apple HIG / WCAG guidelines.
        public static let minimumTapTarget: CGFloat = 44
    }
}
