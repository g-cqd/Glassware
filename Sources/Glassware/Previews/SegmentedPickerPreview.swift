//
//  SegmentedPickerPreview.swift
//  Glassware
//
//  Previews demonstrating the SegmentedPicker component.
//

import SwiftUI

// MARK: - Picker Tab Enum

private enum PickerTab: Int, CaseIterable, Hashable {
    case home = 0
    case search = 1
    case profile = 2
    case settings = 3

    var title: String {
        switch self {
        case .home: "Home"
        case .search: "Search"
        case .profile: "Profile"
        case .settings: "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .home: "house"
        case .search: "magnifyingglass"
        case .profile: "person"
        case .settings: "gearshape"
        }
    }
}

// MARK: - Interactive Picker Preview

/// Interactive segmented picker with all styles.
private struct InteractivePickerPreview: View {
    @State private var selectedTab: PickerTab = .home
    let style: SegmentedPickerStyle

    var body: some View {
        VStack(spacing: 16) {
            Text("Selected: \(selectedTab.title)")
                .font(.headline)

            SegmentedPicker(selection: $selectedTab, style: style) {
                ForEach(PickerTab.allCases, id: \.rawValue) { tab in
                    SegmentedPickerItem(
                        tab,
                        systemImage: tab.systemImage,
                        style: style,
                        isSelected: selectedTab == tab
                    ) {
                        Text(tab.title)
                    }
                }
            }
            .segmentedPickerStyle(spacing: 0, sizing: .evenFit)
            .padding(3)


            Text("Tap or drag to select")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .center)
        .background(.gray.gradient)
    }
}

// MARK: - Picker Style Comparison

/// Shows all picker styles side by side.
private struct PickerStyleComparisonView: View {
    @State private var selection1: PickerTab = .home
    @State private var selection2: PickerTab = .search
    @State private var selection3: PickerTab = .profile

    var body: some View {
        VStack(spacing: 32) {
            // Icon Only
            PreviewSection(title: "Icon Only") {
                SegmentedPicker(selection: $selection1, style: .iconOnly) {
                    ForEach(PickerTab.allCases, id: \.rawValue) { tab in
                        SegmentedPickerItem(
                            tab,
                            systemImage: tab.systemImage,
                            style: .iconOnly,
                            isSelected: selection1 == tab
                        ) {
                            Text(tab.title)
                        }
                    }
                }
                .padding(3)

            }

            // Title Only
            PreviewSection(title: "Title Only") {
                SegmentedPicker(selection: $selection2, style: .titleOnly) {
                    ForEach(PickerTab.allCases, id: \.rawValue) { tab in
                        SegmentedPickerItem(
                            tab,
                            systemImage: tab.systemImage,
                            style: .titleOnly,
                            isSelected: selection2 == tab
                        ) {
                            Text(tab.title)
                        }
                    }
                }
                .padding(3)

            }

            // Title and Icon
            PreviewSection(title: "Title and Icon") {
                SegmentedPicker(selection: $selection3, style: .titleAndIcon) {
                    ForEach(PickerTab.allCases, id: \.rawValue) { tab in
                        SegmentedPickerItem(
                            tab,
                            systemImage: tab.systemImage,
                            style: .titleAndIcon,
                            isSelected: selection3 == tab
                        ) {
                            Text(tab.title)
                        }
                    }
                }
                .padding(3)

            }
        }
        .padding()
    }
}

// MARK: - Picker in Toolbar

/// Shows segmented picker integrated into a glass toolbar.
private struct PickerInToolbarPreview: View {
    @State private var selectedTab: PickerTab = .home
    let style: SegmentedPickerStyle

    var body: some View {
        SampleContentView("Picker in Toolbar", color: .cyan.opacity(0.05))
            .glassBar(
                leading: {
                    Button {} label: {
                        Label("Menu", systemImage: "line.3.horizontal")
                    }
                    .buttonStyle(.glass(style: .iconOnly()))
                },
                content: {
                    // SegmentedPicker can be used directly as toolbar content
                    SegmentedPicker(selection: $selectedTab, style: style) {
                        ForEach(PickerTab.allCases.prefix(3), id: \.rawValue) { tab in
                            SegmentedPickerItem(
                                tab,
                                systemImage: tab.systemImage,
                                style: style,
                                isSelected: selectedTab == tab
                            ) {
                                Text(tab.title)
                            }
                        }
                    }
                    .segmentedPickerStyle(sizing: .evenFill)
                },
                trailing: {
                    Button {} label: {
                        Label("More", systemImage: "ellipsis")
                    }
                    .buttonStyle(.glass(style: .iconOnly()))
                }
            )
    }
}

// MARK: - Picker with Different Densities

/// Shows picker at different density levels.
private struct PickerDensityPreview: View {
    @State private var selection: PickerTab = .home

    var body: some View {
        VStack(spacing: 24) {
            ForEach([GlassDensity.sparse, .regular, .compact, .dense], id: \.rawValue) { density in
                VStack(alignment: .leading, spacing: 8) {
                    Text(densityName(density))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    SegmentedPicker(selection: $selection, style: .titleAndIcon) {
                        ForEach(PickerTab.allCases, id: \.rawValue) { tab in
                            SegmentedPickerItem(
                                tab,
                                systemImage: tab.systemImage,
                                style: .titleAndIcon,
                                isSelected: selection == tab
                            ) {
                                Text(tab.title)
                            }
                        }
                    }
                    .padding(3)

                    .glassDensity(density)
                }
            }
        }
        .padding()
    }

    private func densityName(_ density: GlassDensity) -> String {
        switch density {
        case .extraSparse: "Extra Sparse"
        case .sparse: "Sparse"
        case .regular: "Regular"
        case .compact: "Compact"
        case .dense: "Dense"
        case .extraDense: "Extra Dense"
        }
    }
}

// MARK: - Previews

#Preview("Picker - Icon Only") {
    InteractivePickerPreview(style: .iconOnly)
}

#Preview("Picker - Title Only") {
    InteractivePickerPreview(style: .titleOnly)
}

#Preview("Picker - Title and Icon") {
    InteractivePickerPreview(style: .titleAndIcon)
}

#Preview("Picker Style Comparison") {
    ScrollView {
        PickerStyleComparisonView()
    }
}

#Preview("Picker in Toolbar - Icon Only") {
    PickerInToolbarPreview(style: .iconOnly)
}

#Preview("Picker in Toolbar - Title and Icon") {
    PickerInToolbarPreview(style: .titleAndIcon)
}

#Preview("Picker Density Comparison") {
    ScrollView {
        PickerDensityPreview()
    }
}

#Preview("Drag Gesture Demo") {
    VStack(spacing: 24) {
        Text("Drag the selection capsule")
            .font(.headline)

        InteractivePickerPreview(style: .iconOnly)

        Text("The capsule snaps to the nearest item")
            .font(.caption)
            .foregroundStyle(.tertiary)
    }
}

// MARK: - Vertical Axis Previews

/// Interactive vertical segmented picker.
private struct VerticalPickerPreview: View {
    @State private var selectedTab: PickerTab = .home
    let style: SegmentedPickerStyle

    var body: some View {
        HStack(spacing: 24) {
            SegmentedPicker(selection: $selectedTab, style: style, axis: .vertical) {
                ForEach(PickerTab.allCases, id: \.rawValue) { tab in
                    SegmentedPickerItem(
                        tab,
                        systemImage: tab.systemImage,
                        style: style,
                        isSelected: selectedTab == tab
                    ) {
                        Text(tab.title)
                    }
                }
            }
            .padding(3)


            VStack(alignment: .leading, spacing: 8) {
                Text("Vertical Picker")
                    .font(.headline)
                Text("Selected: \(selectedTab.title)")
                    .font(.subheadline)
                Text("Drag vertically or tap to select")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
    }
}

/// Compares horizontal and vertical axis layouts.
private struct AxisComparisonView: View {
    @State private var horizontalSelection: PickerTab = .home
    @State private var verticalSelection: PickerTab = .home

    var body: some View {
        VStack(spacing: 32) {
            PreviewSection(title: "Horizontal Axis (Default)") {
                SegmentedPicker(selection: $horizontalSelection, style: .iconOnly, axis: .horizontal) {
                    ForEach(PickerTab.allCases, id: \.rawValue) { tab in
                        SegmentedPickerItem(
                            tab,
                            systemImage: tab.systemImage,
                            style: .iconOnly,
                            isSelected: horizontalSelection == tab
                        ) {
                            Text(tab.title)
                        }
                    }
                }
                .padding(3)

            }

            PreviewSection(title: "Vertical Axis") {
                HStack {
                    SegmentedPicker(selection: $verticalSelection, style: .iconOnly, axis: .vertical) {
                        ForEach(PickerTab.allCases, id: \.rawValue) { tab in
                            SegmentedPickerItem(
                                tab,
                                systemImage: tab.systemImage,
                                style: .iconOnly,
                                isSelected: verticalSelection == tab
                            ) {
                                Text(tab.title)
                            }
                        }
                    }
                    .padding(3)


                    Spacer()
                }
            }
        }
        .padding()
    }
}

/// Shows vertical picker in a toolbar context.
private struct VerticalPickerInToolbarPreview: View {
    @State private var selectedTab: PickerTab = .home

    var body: some View {
        SampleContentView("Vertical Picker in Toolbar", color: .teal.opacity(0.05))
            .glassBar(
                edge: .trailing,
                content: {
                    SegmentedPicker(selection: $selectedTab, style: .iconOnly, axis: .vertical) {
                        ForEach(PickerTab.allCases.prefix(3), id: \.rawValue) { tab in
                            SegmentedPickerItem(
                                tab,
                                systemImage: tab.systemImage,
                                style: .iconOnly,
                                isSelected: selectedTab == tab
                            ) {
                                Text(tab.title)
                            }
                        }
                    }
                }
            )
    }
}

/// Shows vertical picker with different styles.
private struct VerticalStyleComparisonView: View {
    @State private var selection1: PickerTab = .home
    @State private var selection2: PickerTab = .search
    @State private var selection3: PickerTab = .profile

    var body: some View {
        HStack(spacing: 32) {
            VStack(spacing: 8) {
                Text("Icon Only")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                SegmentedPicker(selection: $selection1, style: .iconOnly, axis: .vertical) {
                    ForEach(PickerTab.allCases, id: \.rawValue) { tab in
                        SegmentedPickerItem(
                            tab,
                            systemImage: tab.systemImage,
                            style: .iconOnly,
                            isSelected: selection1 == tab
                        ) {
                            Text(tab.title)
                        }
                    }
                }
                .padding(3)

            }

            VStack(spacing: 8) {
                Text("Title Only")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                SegmentedPicker(selection: $selection2, style: .titleOnly, axis: .vertical) {
                    ForEach(PickerTab.allCases, id: \.rawValue) { tab in
                        SegmentedPickerItem(
                            tab,
                            systemImage: tab.systemImage,
                            style: .titleOnly,
                            isSelected: selection2 == tab
                        ) {
                            Text(tab.title)
                        }
                    }
                }
                .padding(3)

            }

            VStack(spacing: 8) {
                Text("Title + Icon")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                SegmentedPicker(selection: $selection3, style: .titleAndIcon, axis: .vertical) {
                    ForEach(PickerTab.allCases, id: \.rawValue) { tab in
                        SegmentedPickerItem(
                            tab,
                            systemImage: tab.systemImage,
                            style: .titleAndIcon,
                            isSelected: selection3 == tab
                        ) {
                            Text(tab.title)
                        }
                    }
                }
                .padding(3)

            }
        }
        .padding()
    }
}

#Preview("Vertical - Icon Only") {
    VerticalPickerPreview(style: .iconOnly)
}

#Preview("Vertical - Title Only") {
    VerticalPickerPreview(style: .titleOnly)
}

#Preview("Vertical - Title and Icon") {
    VerticalPickerPreview(style: .titleAndIcon)
}

#Preview("Axis Comparison") {
    ScrollView {
        AxisComparisonView()
    }
}

#Preview("Vertical Style Comparison") {
    ScrollView {
        VerticalStyleComparisonView()
    }
}

#Preview("Vertical in Trailing Toolbar") {
    VerticalPickerInToolbarPreview()
}

#Preview("Vertical Drag Demo") {
    VStack(spacing: 24) {
        Text("Drag vertically to select")
            .font(.headline)

        VerticalPickerPreview(style: .iconOnly)

        Text("The capsule snaps to the nearest item")
            .font(.caption)
            .foregroundStyle(.tertiary)
    }
}

