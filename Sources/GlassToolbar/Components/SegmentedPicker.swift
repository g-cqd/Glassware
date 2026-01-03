//
//  SegmentedPicker.swift
//  GlassToolbar
//
//  Custom segmented picker with draggable selection capsule.
//

import SwiftUI

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
public struct SegmentedPickerItem<Value: Hashable, Label: View>: View {
    let value: Value
    let systemImage: String?
    let style: SegmentedPickerStyle
    let isSelected: Bool
    @ViewBuilder let label: () -> Label

    @Environment(\.toolbarDensity) private var density
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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

    private var metrics: ToolbarMetrics {
        ToolbarMetrics(density: density)
    }

    public var body: some View {
        itemContent
            .font(.body.weight(.medium))
            .fontDesign(.rounded)
            .foregroundStyle(isSelected ? .primary : .secondary)
            .frame(minWidth: style == .iconOnly ? metrics.minimumTapTarget : metrics.primaryButtonMinWidth)
            .frame(minHeight: metrics.minimumTapTarget)
            .padding(metrics.componentPadding)
            // Report frame to parent via preference key (using GeometryReader for stable frame tracking)
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
            .animation(reduceMotion ? nil : .snappy(duration: ToolbarTokens.Animation.itemDuration), value: isSelected)
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
                    .minimumScaleFactor(ToolbarTokens.Typography.minimumScaleFactor)
                    .lineLimit(1)
            }
        }
    }
}

// MARK: - Segmented Picker

/// A custom segmented picker with a draggable selection capsule.
///
/// Features:
/// - Sliding capsule indicator that animates between selections
/// - Draggable capsule for gesture-based selection
/// - Invisible hit areas below each item for tap selection
/// - Supports iconOnly, titleOnly, and titleAndIcon styles
/// - VoiceOver support with adjustable action
///
/// ## Usage
/// ```swift
/// @State private var selected: Tab = .home
///
/// SegmentedPicker(selection: $selected, style: .titleAndIcon) {
///     SegmentedPickerItem(.home, systemImage: "house", style: .titleAndIcon, isSelected: selected == .home) {
///         Text("Home")
///     }
///     SegmentedPickerItem(.search, systemImage: "magnifyingglass", style: .titleAndIcon, isSelected: selected == .search) {
///         Text("Search")
///     }
/// }
/// ```
public struct SegmentedPicker<Value: Hashable, Content: View>: View {
    @Binding var selection: Value
    let style: SegmentedPickerStyle
    @ViewBuilder let content: () -> Content

    @State private var itemFrames: [Value: CGRect] = [:]
    @State private var cachedSortedValues: [Value] = []
    @GestureState private var dragOffset: CGFloat = 0

    @Environment(\.toolbarDensity) private var density
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        selection: Binding<Value>,
        style: SegmentedPickerStyle,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._selection = selection
        self.style = style
        self.content = content
    }

    private var metrics: ToolbarMetrics {
        ToolbarMetrics(density: density)
    }

    /// The frame of the currently selected item.
    private var selectedFrame: CGRect? {
        itemFrames[selection]
    }

    public var body: some View {
        HStack(spacing: 0) {
            content()
        }
        .coordinateSpace(name: "picker")
        .onPreferenceChange(SegmentedPickerItemFramePreference<Value>.self) { frames in
            itemFrames = frames
            // Cache sorted values when frames change (performance improvement)
            cachedSortedValues = frames.sorted { $0.value.minX < $1.value.minX }.map(\.key)
        }
        .background(alignment: .topLeading) {
            // Selection capsule - positioned via offset
            if let frame = selectedFrame {
                selectionCapsule(for: frame)
            }
        }
        .background(alignment: .topLeading) {
            // Invisible hit areas for tap selection
            hitAreas
        }
        // VoiceOver: Allow swipe up/down to change selection
        .accessibilityElement(children: .combine)
        .accessibilityAdjustableAction { direction in
            adjustSelection(direction: direction)
        }
        .accessibilityValue(accessibilityValueText)
    }

    // MARK: - Accessibility

    private var accessibilityValueText: Text {
        if let index = cachedSortedValues.firstIndex(of: selection) {
            Text("\(index + 1) of \(cachedSortedValues.count)")
        } else {
            Text("")
        }
    }

    private func adjustSelection(direction: AccessibilityAdjustmentDirection) {
        guard let currentIndex = cachedSortedValues.firstIndex(of: selection) else { return }

        switch direction {
        case .increment:
            let nextIndex = currentIndex + 1
            if nextIndex < cachedSortedValues.count {
                selection = cachedSortedValues[nextIndex]
            }
        case .decrement:
            let prevIndex = currentIndex - 1
            if prevIndex >= 0 {
                selection = cachedSortedValues[prevIndex]
            }
        @unknown default:
            break
        }
    }

    // MARK: - Selection Capsule

    @ViewBuilder
    private func selectionCapsule(for frame: CGRect) -> some View {
        let shape: AnyShape = style == .iconOnly ? AnyShape(.circle) : AnyShape(.capsule)

        Color.primary.inverted.opacity(ToolbarTokens.Opacity.backgroundFill)
            .frame(width: frame.width, height: frame.height)
            .clipShape(shape)
            .overlay {
                shape
                    .fill(.clear)
                    .stroke(Color.primary.inverted.opacity(ToolbarTokens.Opacity.borderStroke), lineWidth: ToolbarTokens.Border.lineWidth)
            }
            .shadow(color: .black.opacity(ToolbarTokens.Shadow.opacity), radius: ToolbarTokens.Shadow.radius)
            .offset(x: frame.minX + dragOffset, y: frame.minY)
            .gesture(dragGesture)
            .animation(reduceMotion ? nil : .snappy(duration: ToolbarTokens.Animation.selectionDuration), value: selection)
    }

    // MARK: - Drag Gesture

    private var dragGesture: some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, _ in
                state = value.translation.width
            }
            .onEnded { value in
                guard let currentFrame = selectedFrame else { return }

                // Calculate where the capsule ended up
                let endX = currentFrame.midX + value.translation.width

                // Find the closest item by center position
                var closestValue: Value?
                var closestDistance: CGFloat = .infinity

                for (itemValue, itemFrame) in itemFrames {
                    let distance = abs(itemFrame.midX - endX)
                    if distance < closestDistance {
                        closestDistance = distance
                        closestValue = itemValue
                    }
                }

                if let newValue = closestValue {
                    selection = newValue
                }
            }
    }

    // MARK: - Invisible Hit Areas

    @ViewBuilder
    private var hitAreas: some View {
        // Use cachedSortedValues for stable iteration order (performance improvement)
        ForEach(cachedSortedValues, id: \.self) { value in
            if let frame = itemFrames[value] {
                Color.clear
                    .frame(width: frame.width, height: frame.height)
                    .contentShape(.rect)
                    .offset(x: frame.minX, y: frame.minY)
                    .onTapGesture {
                        selection = value
                    }
            }
        }
    }
}
