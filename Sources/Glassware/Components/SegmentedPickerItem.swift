//
//  SegmentedPickerItem.swift
//  Glassware
//
//  Individual item in a segmented picker.
//

import SwiftUI

// MARK: - Preference Key for Item Frames

/// Stores the frame of each picker item, keyed by its value.
struct SegmentedPickerItemFramePreference<Value: Hashable>: PreferenceKey {
    static var defaultValue: [Value: CGRect] { [:] }

    static func reduce(value: inout [Value: CGRect], nextValue: () -> [Value: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
}

// MARK: - Segmented Picker Item

/// A single item in the segmented picker.
///
/// Renders icon and/or title based on the style, reports its frame via preference key.
/// Automatically shows visual selection state when the drag thumb passes over it.
public struct SegmentedPickerItem<Value: Hashable, Label: View>: View {
    let value: Value
    let systemImage: String?
    let style: SegmentedPickerStyle
    let isSelected: Bool
    @ViewBuilder let label: () -> Label

    @Environment(\.glassDensity) private var density
    @Environment(\.glassSizeContext) private var sizeContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.pickerVisualSelection) private var visualSelection

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

    /// Whether this item is visually selected (thumb is over it during drag).
    private var isVisuallySelected: Bool {
        visualSelection?.matches(value) ?? false
    }

    /// Item appears selected if actually selected or visually selected during drag.
    private var appearsSelected: Bool {
        isSelected || isVisuallySelected
    }

    public var body: some View {
        itemContent
            .font(.body.weight(.medium))
            .fontDesign(.rounded)
            .foregroundStyle(appearsSelected ? .primary : .secondary)
            // Icon-only: fixed size for touch targets
            // Text items: flexible width allowing compression
            .frame(
                minWidth: style == .iconOnly ? metrics.minimumTapTarget : nil,
                idealWidth: style == .iconOnly ? nil : metrics.primaryButtonMinWidth,
                minHeight: metrics.minimumTapTarget
            )
            .padding(metrics.effectiveComponentPadding)
            // Report frame to parent via preference key
            .background {
                GeometryReader { geo in
                    Color.clear.preference(
                        key: SegmentedPickerItemFramePreference<Value>.self,
                        value: [value: geo.frame(in: .named("picker"))]
                    )
                }
            }
            // Items themselves are not tappable
            .allowsHitTesting(false)
            .animation(reduceMotion ? nil : .snappy(duration: GlassTokens.Animation.itemDuration), value: appearsSelected)
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
