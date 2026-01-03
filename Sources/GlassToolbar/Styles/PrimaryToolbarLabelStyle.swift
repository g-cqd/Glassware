//
//  PrimaryToolbarLabelStyle.swift
//  GlassToolbar
//
//  Label style for vertical icon + text layout.
//

import SwiftUI

// MARK: - Primary Toolbar Label Style

/// Custom label style for vertical icon + text layout with selection-aware text rendering.
///
/// Renders the icon above the title text, centered vertically.
/// When selected, applies subtle contrast enhancement for readability.
public struct PrimaryToolbarLabelStyle: LabelStyle {
    @Environment(\.toolbarDensity) private var density
    let isSelected: Bool

    public init(isSelected: Bool = false) {
        self.isSelected = isSelected
    }

    /// Spacing between icon and text, based on density.
    private var spacing: CGFloat {
        ToolbarMetrics(density: density).primaryButtonSpacing
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
                .minimumScaleFactor(ToolbarTokens.Typography.minimumScaleFactor)
                .lineLimit(1)
                // Smart blending: when selected, add subtle shadow for contrast
                .shadow(
                    color: isSelected ? .black.opacity(ToolbarTokens.Shadow.textOpacity) : .clear,
                    radius: isSelected ? ToolbarTokens.Shadow.textRadius : 0,
                    y: isSelected ? ToolbarTokens.Shadow.textOffsetY : 0
                )
        }
        .contentShape(.rect)
    }

    // MARK: - Icon Label Helper

    /// Helper view for rendering a custom icon with a title from the button's label.
    ///
    /// Used when the visual style specifies a custom image that overrides the label's icon.
    /// This is a consolidated implementation that replaces the previous CustomIconLabel.
    public struct IconLabel<Title: View>: View {
        let icon: Image
        @ViewBuilder let title: () -> Title
        let isSelected: Bool
        let density: ToolbarDensity

        public init(
            icon: Image,
            @ViewBuilder title: @escaping () -> Title,
            isSelected: Bool,
            density: ToolbarDensity
        ) {
            self.icon = icon
            self.title = title
            self.isSelected = isSelected
            self.density = density
        }

        private var spacing: CGFloat {
            ToolbarMetrics(density: density).primaryButtonSpacing
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
                    .minimumScaleFactor(ToolbarTokens.Typography.minimumScaleFactor)
                    .lineLimit(1)
                    // Smart blending: when selected, add subtle shadow for contrast
                    .shadow(
                        color: isSelected ? .black.opacity(ToolbarTokens.Shadow.textOpacity) : .clear,
                        radius: isSelected ? ToolbarTokens.Shadow.textRadius : 0,
                        y: isSelected ? ToolbarTokens.Shadow.textOffsetY : 0
                    )
            }
            .contentShape(.rect)
        }
    }
}
