//
//  SegmentedPickerItem.swift
//  Glassware
//
//  Individual item in a segmented picker.
//

import SwiftUI

// MARK: - Segmented Picker Item

/// A single item in the segmented picker.
///
/// Renders icon and/or title based on the style.
/// Selection styling is handled by the parent picker via masking.
public struct SegmentedPickerItem<Value: Hashable, Label: View>: View {
    let value: Value
    let systemImage: String?
    let style: SegmentedPickerStyle
    let isSelected: Bool
    @ViewBuilder let label: () -> Label

    @Environment(\.glassDensity) private var density
    @Environment(\.glassSizeContext) private var sizeContext

    public init(
        _ value: Value,
        systemImage: String? = nil,
        style: SegmentedPickerStyle,
        isSelected: Bool,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.value = value
        self.systemImage = systemImage
        self.style = style
        self.isSelected = isSelected
        self.label = label
    }

    private var metrics: GlassMetrics {
        GlassMetrics(density: density, context: sizeContext)
    }

    public var body: some View {
        itemContent
            .font(.body.weight(.medium))
            .fontDesign(.rounded)
            // Icon-only: fixed size for touch targets
            // Text items: flexible width allowing compression
            .frame(
                minWidth: style == .iconOnly ? metrics.minimumTapTarget : nil,
                idealWidth: style == .iconOnly ? nil : metrics.primaryButtonMinWidth,
                minHeight: metrics.minimumTapTarget
            )
            .padding(metrics.effectiveComponentPadding)
            // Items themselves are not tappable
            .allowsHitTesting(false)
            // Pass value to parent via trait
            ._trait(SegmentedPickerValueTrait<Value>.self, value)
    }

    @ViewBuilder
    private var itemContent: some View {
        switch style {
        case .iconOnly:
            if let systemImage {
                Image(systemName: systemImage)
                    .imageScale(.large)
            }

        case .titleOnly:
            label()
                .font(.caption2.weight(.medium))
                .lineLimit(1)

        case .titleAndIcon:
            VStack(spacing: metrics.primaryButtonSpacing) {
                if let systemImage {
                    // Invisible circle for consistent sizing
                    Image(systemName: "circle")
                        .foregroundStyle(.clear)
                        .imageScale(.medium)
                        .overlay {
                            Image(systemName: systemImage)
                        }
                }
                label()
                    .font(.caption2.weight(.medium))
                    .minimumScaleFactor(GlassTokens.Typography.minimumScaleFactor)
                    .lineLimit(1)
            }
        }
    }
}
