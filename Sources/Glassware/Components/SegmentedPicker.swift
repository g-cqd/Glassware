//
//  SegmentedPicker.swift
//  Glassware
//
//  Custom segmented picker with draggable selection capsule.
//

import SwiftUI

// MARK: - Segmented Picker

/// A custom segmented picker with a draggable selection capsule.
///
/// Features:
/// - Sliding capsule indicator that animates between selections
/// - Draggable capsule for gesture-based selection with spring animation
/// - Two-layer visual design: secondary content below, primary content masked by thumb
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

    @State private var childSizes: [Int: CGSize] = [:]
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false

    @Environment(\.glassDensity) private var density
    @Environment(\.glassSizeContext) private var sizeContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.glassEdge) private var toolbarEdge
    @Environment(\.glassContainerContext) private var containerContext

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

    private var metrics: GlassMetrics {
        GlassMetrics(density: density, context: sizeContext)
    }

    /// Effective axis, accounting for vertical toolbar edge placement.
    private var effectiveAxis: SegmentedPickerAxis {
        toolbarEdge.isVertical ? .vertical : axis
    }

    /// Effective style, accounting for vertical toolbar edge placement.
    private var effectiveStyle: SegmentedPickerStyle {
        if toolbarEdge.isVertical {
            .iconOnly
        } else {
            style
        }
    }

    public var body: some View {
        _VariadicView.Tree(SegmentedPickerRoot(
            selection: $selection,
            style: effectiveStyle,
            axis: effectiveAxis,
            childSizes: $childSizes,
            dragOffset: $dragOffset,
            isDragging: $isDragging,
            reduceMotion: reduceMotion,
            metrics: metrics
        )) {
            content()
        }
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
    }
}

// MARK: - Variadic View Root

private struct SegmentedPickerRoot<Value: Hashable>: _VariadicView.UnaryViewRoot {
    @Binding var selection: Value
    let style: SegmentedPickerStyle
    let axis: SegmentedPickerAxis
    @Binding var childSizes: [Int: CGSize]
    @Binding var dragOffset: CGFloat
    @Binding var isDragging: Bool
    let reduceMotion: Bool
    let metrics: GlassMetrics

    @MainActor
    func body(children: _VariadicView.Children) -> some View {
        SegmentedPickerLayout(
            selection: $selection,
            style: style,
            axis: axis,
            childSizes: $childSizes,
            dragOffset: $dragOffset,
            isDragging: $isDragging,
            reduceMotion: reduceMotion,
            metrics: metrics,
            children: children
        )
    }
}

// MARK: - Layout View

private struct SegmentedPickerLayout<Value: Hashable>: View {
    @Binding var selection: Value
    let style: SegmentedPickerStyle
    let axis: SegmentedPickerAxis
    @Binding var childSizes: [Int: CGSize]
    @Binding var dragOffset: CGFloat
    @Binding var isDragging: Bool
    let reduceMotion: Bool
    let metrics: GlassMetrics
    let children: _VariadicView.Children

    private var layout: AnyLayout {
        switch axis {
        case .horizontal:
            AnyLayout(HStackLayout(spacing: 0))
        case .vertical:
            AnyLayout(VStackLayout(spacing: 0))
        }
    }

    /// Computes the frame for a child at the given index based on accumulated sizes.
    private func frameForChild(at index: Int) -> CGRect {
        var origin: CGFloat = 0
        for i in 0..<index {
            if let size = childSizes[i] {
                origin += axis == .horizontal ? size.width : size.height
            }
        }
        let size = childSizes[index] ?? .zero
        if axis == .horizontal {
            return CGRect(x: origin, y: 0, width: size.width, height: size.height)
        } else {
            return CGRect(x: 0, y: origin, width: size.width, height: size.height)
        }
    }

    /// Index of the selected child, derived from trait values.
    private var selectedIndex: Int? {
        for (index, child) in children.enumerated() {
            if let value = child[SegmentedPickerValueTrait<Value>.self], value == selection {
                return index
            }
        }
        return nil
    }

    /// Frame of the currently selected item.
    private var selectedFrame: CGRect? {
        guard let index = selectedIndex else { return nil }
        return frameForChild(at: index)
    }

    /// Drag bounds based on item positions.
    private var dragBounds: ClosedRange<CGFloat> {
        guard let selectedFrame, !children.isEmpty else { return 0...0 }
        let firstFrame = frameForChild(at: 0)
        let lastFrame = frameForChild(at: children.count - 1)

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

    /// Whether the style uses a circle shape.
    private var usesCircleShape: Bool {
        style == .iconOnly
    }

    /// Offset for the thumb position.
    private var thumbOffset: CGSize {
        guard let frame = selectedFrame else { return .zero }
        let clampedOffset = dragOffset.clamped(to: dragBounds)
        if axis == .horizontal {
            return CGSize(width: frame.minX + clampedOffset, height: frame.minY)
        } else {
            return CGSize(width: frame.minX, height: frame.minY + clampedOffset)
        }
    }

    /// Size of the thumb.
    private var thumbSize: CGSize {
        selectedFrame?.size ?? .zero
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Layer 1: Secondary styled content (always visible)
            layout {
                ForEach(Array(children.enumerated()), id: \.element.id) { index, child in
                    child
                        .foregroundStyle(.secondary)
                        .background {
                            GeometryReader { geo in
                                Color.clear
                                    .onAppear { childSizes[index] = geo.size }
                                    .onChange(of: geo.size) { _, newSize in childSizes[index] = newSize }
                            }
                        }
                }
            }
            .allowsHitTesting(false)

            // Layer 2: Thumb
            if usesCircleShape {
                SelectionThumb(shape: Circle())
                    .frame(width: thumbSize.width, height: thumbSize.height)
                    .offset(thumbOffset)
            } else {
                SelectionThumb(shape: Capsule())
                    .frame(width: thumbSize.width, height: thumbSize.height)
                    .offset(thumbOffset)
            }

            // Layer 3: Primary styled content, masked by thumb shape
            layout {
                ForEach(Array(children.enumerated()), id: \.element.id) { _, child in
                    child
                        .foregroundStyle(.primary)
                }
            }
            .allowsHitTesting(false)
            .mask(alignment: .topLeading) {
                Group {
                    if usesCircleShape {
                        Circle()
                    } else {
                        Capsule()
                    }
                }
                .frame(width: thumbSize.width, height: thumbSize.height)
                .offset(thumbOffset)
            }

            // Layer 4: Invisible hit areas for tap selection
            hitAreas

            // Layer 5: Invisible drag handle on top
            Color.clear
                .frame(width: thumbSize.width, height: thumbSize.height)
                .contentShape(.rect)
                .offset(thumbOffset)
                .gesture(dragGesture)
        }
        .animation(
            reduceMotion ? nil : (isDragging ? nil : .spring(response: 0.35, dampingFraction: 0.7)),
            value: selectedIndex
        )
        .animation(
            reduceMotion ? nil : (isDragging ? nil : .spring(response: 0.35, dampingFraction: 0.7)),
            value: dragOffset
        )
        .accessibilityElement(children: .combine)
        .accessibilityAdjustableAction { direction in
            adjustSelection(direction: direction)
        }
        .accessibilityValue(accessibilityValueText)
    }

    // MARK: - Accessibility

    private var accessibilityValueText: Text {
        if let index = selectedIndex {
            Text("\(index + 1) of \(children.count)")
        } else {
            Text("")
        }
    }

    private func adjustSelection(direction: AccessibilityAdjustmentDirection) {
        guard let currentIndex = selectedIndex else { return }

        switch direction {
        case .increment:
            let nextIndex = currentIndex + 1
            if nextIndex < children.count {
                if let value = children[nextIndex][SegmentedPickerValueTrait<Value>.self] {
                    selection = value
                }
            }
        case .decrement:
            let prevIndex = currentIndex - 1
            if prevIndex >= 0 {
                if let value = children[prevIndex][SegmentedPickerValueTrait<Value>.self] {
                    selection = value
                }
            }
        @unknown default:
            break
        }
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

                let translation = axis == .horizontal ? value.translation.width : value.translation.height
                let clampedTranslation = translation.clamped(to: dragBounds)
                let endPosition: CGFloat
                if axis == .horizontal {
                    endPosition = currentFrame.midX + clampedTranslation
                } else {
                    endPosition = currentFrame.midY + clampedTranslation
                }

                // Find the closest item by center position
                var closestIndex: Int?
                var closestDistance: CGFloat = .infinity

                for i in 0..<children.count {
                    let frame = frameForChild(at: i)
                    let itemCenter = axis == .horizontal ? frame.midX : frame.midY
                    let distance = abs(itemCenter - endPosition)
                    if distance < closestDistance {
                        closestDistance = distance
                        closestIndex = i
                    }
                }

                isDragging = false
                dragOffset = 0

                if let index = closestIndex,
                   let value = children[index][SegmentedPickerValueTrait<Value>.self] {
                    selection = value
                }
            }
    }

    // MARK: - Hit Areas

    @ViewBuilder
    private var hitAreas: some View {
        ForEach(0..<children.count, id: \.self) { index in
            let frame = frameForChild(at: index)
            Color.clear
                .frame(width: frame.width, height: frame.height)
                .contentShape(.rect)
                .offset(x: frame.minX, y: frame.minY)
                .onTapGesture {
                    if let value = children[index][SegmentedPickerValueTrait<Value>.self] {
                        selection = value
                    }
                }
        }
    }
}

// MARK: - View Trait for Value

struct SegmentedPickerValueTrait<Value: Hashable>: _ViewTraitKey {
    static var defaultValue: Value? { nil }
}
