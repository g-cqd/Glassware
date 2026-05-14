//
//  GlassLabelStyle.swift
//  Glassware
//
//  Label style for vertical icon + text layout.
//

import SwiftUI

// MARK: - Glass Label Style

/// Custom label style for vertical icon + text layout.
///
/// Renders the icon above the title text, centered vertically.
/// Used by glass button styles for titleAndIcon visual layout.
public struct GlassLabelStyle: LabelStyle {
    @Environment(\.glassDensity) private var density

    public init() {}

    /// Spacing between icon and text, based on density.
    private var spacing: CGFloat {
        GlassMetrics(density: density).primaryButtonSpacing
    }

    public func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: spacing) {
            // Invisible circle provides consistent icon sizing
            Image(systemName: "circle")
                .foregroundStyle(.clear)
                .overlay {
                    configuration.icon
                }

            configuration.title
                .font(.caption2.weight(.medium))
                .minimumScaleFactor(GlassTokens.Typography.minimumScaleFactor)
                .lineLimit(1)
        }
        .contentShape(.rect)
    }

    // MARK: - Icon Label Helper

    /// Helper view for rendering a custom icon with a title from the button's label.
    ///
    /// Used when the visual style specifies a custom image that overrides the label's icon.
    public struct IconLabel<Title: View>: View {
        let icon: Image
        @ViewBuilder let title: () -> Title
        let density: GlassDensity

        public init(
            icon: Image,
            @ViewBuilder title: @escaping () -> Title,
            density: GlassDensity
        ) {
            self.icon = icon
            self.title = title
            self.density = density
        }

        private var spacing: CGFloat {
            GlassMetrics(density: density).primaryButtonSpacing
        }

        public var body: some View {
            VStack(spacing: spacing) {
                // Invisible circle provides consistent icon sizing
                Image(systemName: "circle")
                    .foregroundStyle(.clear)
                    .overlay {
                        icon
                    }

                title()
                    .font(.caption2.weight(.medium))
                    .minimumScaleFactor(GlassTokens.Typography.minimumScaleFactor)
                    .lineLimit(1)
            }
            .contentShape(.rect)
        }
    }
}
