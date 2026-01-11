//
//  SegmentedPicker.swift
//  Glassware
//
//  Custom segmented picker with draggable selection capsule.
//

import SwiftUI

// MARK: - Sizing

/// Combined sizing configuration for segmented picker items and container.
public enum SegmentedPickerSizing: Sendable, Equatable {
    /// Items are distributed evenly, container fits content.
    case evenFit
    /// Items are distributed evenly, container expands to fill available space.
    case evenFill
    /// Each item gets its ideal size, container fits content.
    case adaptiveFit
    /// Each item gets its ideal size, container expands to fill available space.
    case adaptiveFill
    /// All items use a fixed size.
    case fixed(CGFloat)

    /// Whether items are distributed evenly or use their ideal size.
    var isEven: Bool {
        switch self {
        case .evenFit, .evenFill: true
        case .adaptiveFit, .adaptiveFill, .fixed: false
        }
    }

    /// Whether items use their ideal (adaptive) size.
    var isAdaptive: Bool {
        switch self {
        case .adaptiveFit, .adaptiveFill: true
        case .evenFit, .evenFill, .fixed: false
        }
    }

    /// Whether the container expands to fill available space.
    var fills: Bool {
        switch self {
        case .evenFill, .adaptiveFill: true
        case .evenFit, .adaptiveFit, .fixed: false
        }
    }

    /// Fixed width if applicable.
    var fixedSize: CGFloat? {
        if case .fixed(let size) = self { size } else { nil }
    }
}

extension EnvironmentValues {
    /// Spacing between items in a segmented picker.
    @Entry var segmentedPickerSpacing: CGFloat = 0

    /// How the picker and its items are sized.
    @Entry var segmentedPickerSizing: SegmentedPickerSizing = .evenFit
}

// MARK: - View Modifier

public extension View {
    /// Configures the layout style for a segmented picker.
    ///
    /// - Parameters:
    ///   - spacing: Spacing between items. Default is 0.
    ///   - sizing: How items and container are sized. Default is `.evenFit`.
    func segmentedPickerStyle(
        spacing: CGFloat? = nil,
        sizing: SegmentedPickerSizing? = nil
    ) -> some View {
        self
            .transformEnvironment(\.segmentedPickerSpacing) { value in
                if let spacing { value = spacing }
            }
            .transformEnvironment(\.segmentedPickerSizing) { value in
                if let sizing { value = sizing }
            }
    }
}

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
    let axis: Axis
    @ViewBuilder let content: () -> Content

    @State private var cellFrames: [Int: CGRect] = [:]
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false

    @Environment(\.glassDensity) private var density
    @Environment(\.glassSizeContext) private var sizeContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.glassEdge) private var toolbarEdge
    @Environment(\.glassContainerContext) private var containerContext
    @Environment(\.segmentedPickerSpacing) private var spacing
    @Environment(\.segmentedPickerSizing) private var sizing

    public init(
        selection: Binding<Value>,
        style: SegmentedPickerStyle,
        axis: Axis = .horizontal,
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
    private var effectiveAxis: Axis {
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
            cellFrames: $cellFrames,
            dragOffset: $dragOffset,
            isDragging: $isDragging,
            reduceMotion: reduceMotion,
            metrics: metrics,
            spacing: spacing,
            sizing: sizing
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
    let axis: Axis
    @Binding var cellFrames: [Int: CGRect]
    @Binding var dragOffset: CGFloat
    @Binding var isDragging: Bool
    let reduceMotion: Bool
    let metrics: GlassMetrics
    let spacing: CGFloat
    let sizing: SegmentedPickerSizing

    @MainActor
    func body(children: _VariadicView.Children) -> some View {
        SegmentedPickerContent(
            selection: $selection,
            style: style,
            axis: axis,
            cellFrames: $cellFrames,
            dragOffset: $dragOffset,
            isDragging: $isDragging,
            reduceMotion: reduceMotion,
            metrics: metrics,
            spacing: spacing,
            sizing: sizing,
            children: children
        )
    }
}

// MARK: - Custom Layout

/// Layout that distributes children along an axis with configurable item sizing.
private struct SegmentedPickerAxisLayout: Layout {
    let axis: Axis
    let sizing: SegmentedPickerSizing
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard !subviews.isEmpty else { return .zero }

        let idealSizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let totalSpacing = spacing * CGFloat(max(0, subviews.count - 1))

        if axis == .horizontal {
            let maxHeight = idealSizes.map(\.height).max() ?? 0
            let idealTotalWidth = idealSizes.map(\.width).reduce(0, +) + totalSpacing

            switch sizing {
            case .adaptiveFit:
                // Hug content - use sum of ideal sizes
                return CGSize(width: idealTotalWidth, height: maxHeight)
            case .adaptiveFill:
                // Fill available space, fall back to ideal if no proposal
                let width = proposal.width ?? idealTotalWidth
                return CGSize(width: width, height: maxHeight)
            case .evenFit, .evenFill:
                let proposedWidth = proposal.width ?? idealTotalWidth
                return CGSize(width: proposedWidth, height: maxHeight)
            case .fixed(let fixedWidth):
                let totalWidth = fixedWidth * CGFloat(subviews.count) + totalSpacing
                return CGSize(width: totalWidth, height: maxHeight)
            }
        } else {
            let maxWidth = idealSizes.map(\.width).max() ?? 0
            let idealTotalHeight = idealSizes.map(\.height).reduce(0, +) + totalSpacing

            switch sizing {
            case .adaptiveFit:
                // Hug content - use sum of ideal sizes
                return CGSize(width: maxWidth, height: idealTotalHeight)
            case .adaptiveFill:
                // Fill available space, fall back to ideal if no proposal
                let height = proposal.height ?? idealTotalHeight
                return CGSize(width: maxWidth, height: height)
            case .evenFit, .evenFill:
                let proposedHeight = proposal.height ?? idealTotalHeight
                return CGSize(width: maxWidth, height: proposedHeight)
            case .fixed(let fixedHeight):
                let totalHeight = fixedHeight * CGFloat(subviews.count) + totalSpacing
                return CGSize(width: maxWidth, height: totalHeight)
            }
        }
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard !subviews.isEmpty else { return }

        let count = subviews.count
        let idealSizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let totalSpacing = spacing * CGFloat(max(0, count - 1))

        if axis == .horizontal {
            switch sizing {
            case .adaptiveFit:
                // Items at their ideal sizes, hugging content
                var x = bounds.minX
                for (index, subview) in subviews.enumerated() {
                    let width = idealSizes[index].width
                    subview.place(
                        at: CGPoint(x: x + width / 2, y: bounds.midY),
                        anchor: .center,
                        proposal: ProposedViewSize(width: width, height: bounds.height)
                    )
                    x += width + spacing
                }

            case .adaptiveFill:
                // Items expand proportionally to fill available space
                let idealTotalWidth = idealSizes.map(\.width).reduce(0, +)
                let availableWidth = bounds.width - totalSpacing
                let scale = idealTotalWidth > 0 ? availableWidth / idealTotalWidth : 1

                var x = bounds.minX
                for (index, subview) in subviews.enumerated() {
                    let width = idealSizes[index].width * scale
                    subview.place(
                        at: CGPoint(x: x + width / 2, y: bounds.midY),
                        anchor: .center,
                        proposal: ProposedViewSize(width: width, height: bounds.height)
                    )
                    x += width + spacing
                }

            case .evenFit, .evenFill:
                // All items get equal width
                let cellWidth = (bounds.width - totalSpacing) / CGFloat(count)
                for (index, subview) in subviews.enumerated() {
                    let x = bounds.minX + CGFloat(index) * (cellWidth + spacing)
                    subview.place(
                        at: CGPoint(x: x + cellWidth / 2, y: bounds.midY),
                        anchor: .center,
                        proposal: ProposedViewSize(width: cellWidth, height: bounds.height)
                    )
                }

            case .fixed(let fixedWidth):
                for (index, subview) in subviews.enumerated() {
                    let x = bounds.minX + CGFloat(index) * (fixedWidth + spacing)
                    subview.place(
                        at: CGPoint(x: x + fixedWidth / 2, y: bounds.midY),
                        anchor: .center,
                        proposal: ProposedViewSize(width: fixedWidth, height: bounds.height)
                    )
                }
            }
        } else {
            switch sizing {
            case .adaptiveFit:
                // Items at their ideal sizes, hugging content
                var y = bounds.minY
                for (index, subview) in subviews.enumerated() {
                    let height = idealSizes[index].height
                    subview.place(
                        at: CGPoint(x: bounds.midX, y: y + height / 2),
                        anchor: .center,
                        proposal: ProposedViewSize(width: bounds.width, height: height)
                    )
                    y += height + spacing
                }

            case .adaptiveFill:
                // Items expand proportionally to fill available space
                let idealTotalHeight = idealSizes.map(\.height).reduce(0, +)
                let availableHeight = bounds.height - totalSpacing
                let scale = idealTotalHeight > 0 ? availableHeight / idealTotalHeight : 1

                var y = bounds.minY
                for (index, subview) in subviews.enumerated() {
                    let height = idealSizes[index].height * scale
                    subview.place(
                        at: CGPoint(x: bounds.midX, y: y + height / 2),
                        anchor: .center,
                        proposal: ProposedViewSize(width: bounds.width, height: height)
                    )
                    y += height + spacing
                }

            case .evenFit, .evenFill:
                // All items get equal height
                let cellHeight = (bounds.height - totalSpacing) / CGFloat(count)
                for (index, subview) in subviews.enumerated() {
                    let y = bounds.minY + CGFloat(index) * (cellHeight + spacing)
                    subview.place(
                        at: CGPoint(x: bounds.midX, y: y + cellHeight / 2),
                        anchor: .center,
                        proposal: ProposedViewSize(width: bounds.width, height: cellHeight)
                    )
                }

            case .fixed(let fixedHeight):
                for (index, subview) in subviews.enumerated() {
                    let y = bounds.minY + CGFloat(index) * (fixedHeight + spacing)
                    subview.place(
                        at: CGPoint(x: bounds.midX, y: y + fixedHeight / 2),
                        anchor: .center,
                        proposal: ProposedViewSize(width: bounds.width, height: fixedHeight)
                    )
                }
            }
        }
    }
}

// MARK: - Content View

private struct SegmentedPickerContent<Value: Hashable>: View {
    @Binding var selection: Value
    let style: SegmentedPickerStyle
    let axis: Axis
    @Binding var cellFrames: [Int: CGRect]
    @Binding var dragOffset: CGFloat
    @Binding var isDragging: Bool
    let reduceMotion: Bool
    let metrics: GlassMetrics
    let spacing: CGFloat
    let sizing: SegmentedPickerSizing
    let children: _VariadicView.Children

    private var layout: SegmentedPickerAxisLayout {
        SegmentedPickerAxisLayout(axis: axis, sizing: sizing, spacing: spacing)
    }

    /// Index of the selected child, derived from tag values via reflection.
    private var selectedIndex: Int? {
        for (index, child) in children.enumerated() {
            if let value: Value = try? child.getTag(), value == selection {
                return index
            }
        }
        return nil
    }

    /// Frame of the currently selected item.
    private var selectedFrame: CGRect? {
        guard let index = selectedIndex else { return nil }
        return cellFrames[index]
    }

    /// Drag bounds based on item positions.
    private var dragBounds: ClosedRange<CGFloat> {
        guard let selectedFrame, !children.isEmpty,
              let firstFrame = cellFrames[0],
              let lastFrame = cellFrames[children.count - 1] else {
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

    /// Whether the thumb uses a circle shape.
    /// Circle for iconOnly with fit sizing, capsule for all other cases.
    private var usesCircleShape: Bool {
        style == .iconOnly && !sizing.fills
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

    /// Size of the thumb (from selected cell frame).
    private var thumbSize: CGSize {
        selectedFrame?.size ?? .zero
    }

    var body: some View {
        // Base layer: Secondary styled content (always visible)
        baseLayer
            .frame(
                maxWidth: sizing.fills && axis == .horizontal ? .infinity : nil,
                maxHeight: sizing.fills && axis == .vertical ? .infinity : nil
            )
            .fixedSize(
                horizontal: !sizing.fills && axis == .horizontal,
                vertical: !sizing.fills && axis == .vertical
            )
            .coordinateSpace(name: "picker")
            .overlay(alignment: .topLeading) { thumbLayer }
            .overlay { maskedLayer }
            .overlay { hittableLayer }
            .overlay(alignment: .topLeading) { invisibleDraggableRegion }
            .animation(selectionAnimation, value: selectedIndex)
            .animation(selectionAnimation, value: dragOffset)
            .accessibilityElement(children: .combine)
            .accessibilityAdjustableAction { direction in
                adjustSelection(direction: direction)
            }
            .accessibilityValue(accessibilityValueText)
    }

    /// Spring animation for selection changes, disabled during drag or when reduce motion is enabled.
    private var selectionAnimation: Animation? {
        guard !reduceMotion, !isDragging else { return nil }
        return .spring(
            response: GlassTokens.Animation.selectionSpringResponse,
            dampingFraction: GlassTokens.Animation.selectionSpringDamping
        )
    }

    /// Applies consistent sizing modifiers to a child view.
    /// This ensures all layers (base, masked, hittable) have identical layout behavior.
    @ViewBuilder
    private func sizedChild<V: View>(_ content: V) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .fixedSize(
                horizontal: sizing.isAdaptive && axis == .horizontal,
                vertical: sizing.isAdaptive && axis == .vertical
            )
    }

    @ViewBuilder
    private var baseLayer: some View {
        layout {
            ForEach(Array(children.enumerated()), id: \.element.id) { index, child in
                sizedChild(child.foregroundStyle(Color.primary.tertiary))
                    .onGeometryChange(for: CGRect.self) { proxy in
                        proxy.frame(in: .named("picker"))
                    } action: { frame in
                        if cellFrames[index] != frame {
                            cellFrames[index] = frame
                        }
                    }
            }
        }
    }
    
    @ViewBuilder
    private var thumbLayer: some View {
        if usesCircleShape {
            SelectionThumb(shape: .circle)
                .frame(width: thumbSize.width, height: thumbSize.height)
                .offset(thumbOffset)
        } else {
            SelectionThumb(shape: .capsule)
                .frame(width: thumbSize.width, height: thumbSize.height)
                .offset(thumbOffset)
        }
    }
    
    private var maskedLayer: some View {
        // Primary styled content, masked by thumb shape
        layout {
            ForEach(Array(children.enumerated()), id: \.element.id) { _, child in
                sizedChild(child.foregroundStyle(.primary))
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
    }
    
    private var hittableLayer: some View {
        layout {
            ForEach(Array(children.enumerated()), id: \.element.id) { index, child in
                // Use invisible child to maintain consistent sizing with other layers
                sizedChild(child.hidden())
                    .contentShape(.rect)
                    .onTapGesture {
                        if let value: Value = try? child.getTag() {
                            selection = value
                        }
                    }
            }
        }
    }
    
    private var invisibleDraggableRegion: some View {
        Color.clear
            .frame(width: thumbSize.width, height: thumbSize.height)
            .contentShape(.rect)
            .offset(thumbOffset)
            .gesture(dragGesture)
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
                if let value: Value = try? children[nextIndex].getTag() {
                    selection = value
                }
            }
        case .decrement:
            let prevIndex = currentIndex - 1
            if prevIndex >= 0 {
                if let value: Value = try? children[prevIndex].getTag() {
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
                    guard let frame = cellFrames[i] else { continue }
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
                   let value: Value = try? children[index].getTag() {
                    selection = value
                }
            }
    }
}

// MARK: - Tag Extraction

extension View {
    /// Extracts the tag value from a variadic view child using reflection.
    /// Path: traits → storage → (array) → value → tagged
    func getTag<TagType: Hashable>() throws -> TagType {
        let mirror = Mirror(reflecting: self)

        // Get traits.storage array
        guard let storage = mirror.descendant("traits", "storage") else {
            throw TagExtractionError.traitsNotFound
        }

        // Iterate through the storage array to find tag trait
        let storageMirror = Mirror(reflecting: storage)
        for child in storageMirror.children {
            // Look for value.tagged path in each trait
            let traitMirror = Mirror(reflecting: child.value)
            if let tagValue = traitMirror.descendant("value", "tagged") {
                // Try to cast to our expected type
                if let tag = tagValue as? TagType {
                    return tag
                }
            }
        }

        throw TagExtractionError.tagNotFound
    }
}

enum TagExtractionError: Error {
    case traitsNotFound
    case tagNotFound
}
