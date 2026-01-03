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

// MARK: - Segmented Picker Axis

/// Layout axis for the segmented picker.
public enum SegmentedPickerAxis: Sendable, Equatable {
    /// Horizontal layout (default).
    case horizontal
    /// Vertical layout.
    case vertical
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
/// Automatically shows visual selection state when the drag thumb passes over it.
public struct SegmentedPickerItem<Value: Hashable, Label: View>: View {
    let value: Value
    let systemImage: String?
    let style: SegmentedPickerStyle
    let isSelected: Bool
    @ViewBuilder let label: () -> Label

    @Environment(\.toolbarDensity) private var density
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

    private var metrics: ToolbarMetrics {
        ToolbarMetrics(density: density)
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
            .frame(minWidth: style == .iconOnly ? metrics.minimumTapTarget : metrics.primaryButtonMinWidth)
            .frame(minHeight: metrics.minimumTapTarget)
            .padding(metrics.componentPadding)
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
            .animation(reduceMotion ? nil : .snappy(duration: ToolbarTokens.Animation.itemDuration), value: appearsSelected)
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
/// - Draggable capsule for gesture-based selection with spring animation
/// - Visual selection feedback during drag (items highlight as thumb passes over)
/// - Drag constrained to picker bounds
/// - Invisible hit areas below each item for tap selection
/// - Supports iconOnly, titleOnly, and titleAndIcon styles
/// - Supports horizontal and vertical orientation
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
    let axis: SegmentedPickerAxis
    @ViewBuilder let content: () -> Content

    @State private var itemFrames: [Value: CGRect] = [:]
    @State private var cachedSortedValues: [Value] = []
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false

    @Environment(\.toolbarDensity) private var density
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        selection: Binding<Value>,
        style: SegmentedPickerStyle,
        axis: SegmentedPickerAxis = .horizontal,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._selection = selection
        self.style = style
        self.axis = axis
        self.content = content
    }

    private var metrics: ToolbarMetrics {
        ToolbarMetrics(density: density)
    }

    /// The frame of the currently selected item.
    private var selectedFrame: CGRect? {
        itemFrames[selection]
    }

    /// Calculates bounds for drag offset based on item positions.
    private var dragBounds: ClosedRange<CGFloat> {
        guard let selectedFrame,
              let firstValue = cachedSortedValues.first,
              let lastValue = cachedSortedValues.last,
              let firstFrame = itemFrames[firstValue],
              let lastFrame = itemFrames[lastValue] else {
            return 0...0
        }

        if axis == .horizontal {
            let minOffset = firstFrame.minX - selectedFrame.minX
            let maxOffset = lastFrame.minX - selectedFrame.minX
            return minOffset...maxOffset
        } else {
            let minOffset = firstFrame.minY - selectedFrame.minY
            let maxOffset = lastFrame.minY - selectedFrame.minY
            return minOffset...maxOffset
        }
    }

    /// The value currently under the thumb during drag.
    private var visualSelection: Value? {
        guard isDragging, let selectedFrame else { return nil }

        let thumbPosition: CGFloat
        if axis == .horizontal {
            thumbPosition = selectedFrame.midX + dragOffset
        } else {
            thumbPosition = selectedFrame.midY + dragOffset
        }

        // Find item whose center is closest to thumb center
        var closestValue: Value?
        var closestDistance: CGFloat = .infinity

        for (value, frame) in itemFrames {
            let itemCenter = axis == .horizontal ? frame.midX : frame.midY
            let distance = abs(itemCenter - thumbPosition)
            if distance < closestDistance {
                closestDistance = distance
                closestValue = value
            }
        }

        return closestValue
    }

    public var body: some View {
        Group {
            if axis == .horizontal {
                HStack(spacing: 0) {
                    content()
                }
            } else {
                VStack(spacing: 0) {
                    content()
                }
            }
        }
        // Pass visual selection to items via environment
        .environment(\.pickerVisualSelection, visualSelection.map { VisualSelectionState($0) })
        .coordinateSpace(name: "picker")
        .onPreferenceChange(SegmentedPickerItemFramePreference<Value>.self) { frames in
            itemFrames = frames
            // Cache sorted values based on axis
            if axis == .horizontal {
                cachedSortedValues = frames.sorted { $0.value.minX < $1.value.minX }.map(\.key)
            } else {
                cachedSortedValues = frames.sorted { $0.value.minY < $1.value.minY }.map(\.key)
            }
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
        let clampedOffset = dragOffset.clamped(to: dragBounds)

        Color.primary.inverted.opacity(ToolbarTokens.Opacity.backgroundFill)
            .frame(width: frame.width, height: frame.height)
            .clipShape(shape)
            .overlay {
                shape
                    .fill(.clear)
                    .stroke(Color.primary.inverted.opacity(ToolbarTokens.Opacity.borderStroke), lineWidth: ToolbarTokens.Border.lineWidth)
            }
            .shadow(color: .black.opacity(ToolbarTokens.Shadow.opacity), radius: ToolbarTokens.Shadow.radius)
            .offset(
                x: axis == .horizontal ? frame.minX + clampedOffset : frame.minX,
                y: axis == .vertical ? frame.minY + clampedOffset : frame.minY
            )
            .gesture(dragGesture)
            .animation(
                reduceMotion ? nil : (isDragging ? nil : .spring(response: 0.35, dampingFraction: 0.7)),
                value: selection
            )
            .animation(
                reduceMotion ? nil : (isDragging ? nil : .spring(response: 0.35, dampingFraction: 0.7)),
                value: dragOffset
            )
    }

    // MARK: - Drag Gesture

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                isDragging = true
                let translation = axis == .horizontal ? value.translation.width : value.translation.height
                dragOffset = translation.clamped(to: dragBounds)
            }
            .onEnded { value in
                guard let currentFrame = selectedFrame else {
                    isDragging = false
                    dragOffset = 0
                    return
                }

                // Calculate where the capsule ended up
                let translation = axis == .horizontal ? value.translation.width : value.translation.height
                let clampedTranslation = translation.clamped(to: dragBounds)
                let endPosition: CGFloat
                if axis == .horizontal {
                    endPosition = currentFrame.midX + clampedTranslation
                } else {
                    endPosition = currentFrame.midY + clampedTranslation
                }

                // Find the closest item by center position
                var closestValue: Value?
                var closestDistance: CGFloat = .infinity

                for (itemValue, itemFrame) in itemFrames {
                    let itemCenter = axis == .horizontal ? itemFrame.midX : itemFrame.midY
                    let distance = abs(itemCenter - endPosition)
                    if distance < closestDistance {
                        closestDistance = distance
                        closestValue = itemValue
                    }
                }

                // Reset drag state before updating selection
                // This allows the spring animation to trigger
                isDragging = false
                dragOffset = 0

                if let newValue = closestValue {
                    selection = newValue
                }
            }
    }

    // MARK: - Invisible Hit Areas

    @ViewBuilder
    private var hitAreas: some View {
        // Use cachedSortedValues for stable iteration order
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

// MARK: - Visual Selection Environment

/// Sendable wrapper for visual selection state.
struct VisualSelectionState: Sendable, Equatable {
    private let hashValue: Int

    init<Value: Hashable>(_ value: Value) {
        self.hashValue = value.hashValue
    }

    func matches<Value: Hashable>(_ value: Value) -> Bool {
        value.hashValue == hashValue
    }
}

/// Environment key for passing visual selection ID during drag.
struct VisualSelectionKey: EnvironmentKey {
    static let defaultValue: VisualSelectionState? = nil
}

extension EnvironmentValues {
    /// The value currently under the drag thumb (visual selection during drag).
    var pickerVisualSelection: VisualSelectionState? {
        get { self[VisualSelectionKey.self] }
        set { self[VisualSelectionKey.self] = newValue }
    }
}

// MARK: - Clamped Extension

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
