//
//  ComprehensivePlacementPreview.swift
//  Glassware
//
//  Comprehensive previews demonstrating all GlassPlacement combinations.
//

import SwiftUI

// MARK: - All Positions on Single Edge

/// Shows all three positions (leading, primary, trailing) on a single edge.
private struct AllPositionsOnEdgePreview: View {
    let edge: GlassEdge
    @State private var selectedTab: PreviewTab = .home

    var body: some View {
        SampleContentView(edgeName, color: edgeColor.opacity(0.05))
            .glass {
                GlassItem(placement: leadingPlacement) {
                    Button("Leading", systemImage: "arrow.left") {}
                        .buttonStyle(.glass(style: .iconOnly()))
                }

                GlassItemGroup(placement: primaryPlacement) {
                    ForEach(PreviewTab.allCases, id: \.self) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            Label(tab.title, systemImage: tab.systemImage)
                        }
                        .buttonStyle(.glass(
                            style: edge.isVertical ? .iconOnly() : .titleAndIcon()
                        ))
                    }
                }

                GlassItem(placement: trailingPlacement) {
                    Button("Trailing", systemImage: "arrow.right") {}
                        .buttonStyle(.glass(style: .iconOnly()))
                }
            }
    }

    private var edgeName: String {
        switch edge {
        case .top: "Top Edge"
        case .bottom: "Bottom Edge"
        case .leading: "Leading Edge"
        case .trailing: "Trailing Edge"
        }
    }

    private var edgeColor: Color {
        switch edge {
        case .top: .blue
        case .bottom: .green
        case .leading: .orange
        case .trailing: .purple
        }
    }

    private var leadingPlacement: GlassPlacement {
        switch edge {
        case .top: .topLeading
        case .bottom: .bottomLeading
        case .leading: .leadingTop
        case .trailing: .trailingTop
        }
    }

    private var primaryPlacement: GlassPlacement {
        switch edge {
        case .top: .topPrimary
        case .bottom: .bottomPrimary
        case .leading: .leadingPrimary
        case .trailing: .trailingPrimary
        }
    }

    private var trailingPlacement: GlassPlacement {
        switch edge {
        case .top: .topTrailing
        case .bottom: .bottomTrailing
        case .leading: .leadingBottom
        case .trailing: .trailingBottom
        }
    }
}

// MARK: - Multi-Edge Overlay

/// Demonstrates toolbars on multiple edges simultaneously.
private struct MultiEdgeOverlayPreview: View {
    @State private var selectedTab: PreviewTab = .home
    @State private var filterActive = false
    @State private var sortAscending = true

    var body: some View {
        SampleContentView("Multi-Edge Layout", color: .indigo.opacity(0.05))
            .glass {
                // Top edge: filter and sort controls
                GlassItem(placement: .topLeading) {
                    Button("Filter", systemImage: filterActive ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle") {
                        filterActive.toggle()
                    }
                    .buttonStyle(.glass(style: .iconOnly()))
                }

                GlassItem(placement: .topTrailing) {
                    Button("Sort", systemImage: sortAscending ? "arrow.up" : "arrow.down") {
                        sortAscending.toggle()
                    }
                    .buttonStyle(.glass(style: .iconOnly()))
                }

                // Bottom edge: main navigation
                GlassItem(placement: .bottomLeading) {
                    Button("Menu", systemImage: "line.3.horizontal") {}
                        .buttonStyle(.glass(style: .iconOnly()))
                }

                GlassItemGroup(placement: .bottomPrimary) {
                    ForEach(PreviewTab.allCases, id: \.self) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            Label(tab.title, systemImage: tab.systemImage)
                        }
                        .buttonStyle(.glass())
                    }
                }

                GlassItem(placement: .bottomTrailing) {
                    Button("Add", systemImage: "plus") {}
                        .buttonStyle(.glass(style: .iconOnly()))
                }
            }
    }
}

// MARK: - Accessory Offset Comparison

/// Demonstrates different accessory offset values.
private struct AccessoryOffsetComparisonPreview: View {
    @State private var selectedTab: PreviewTab = .home

    var body: some View {
        SampleContentView("Accessory Offsets", color: .teal.opacity(0.05))
            .glass {
                // Overlapping accessory (-8pt = "melted" effect)
                GlassItem(placement: .bottomAccessory(offset: -8)) {
                    accessoryBadge(text: "offset: -8", color: .orange)
                }

                // Main tabs
                GlassItemGroup(placement: .bottomPrimary) {
                    ForEach(PreviewTab.allCases, id: \.self) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            Label(tab.title, systemImage: tab.systemImage)
                        }
                        .buttonStyle(.glass())
                    }
                }
            }
    }

    @ViewBuilder
    private func accessoryBadge(text: String, color: Color) -> some View {
        Text(text)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.2), in: .capsule)
            .overlay {
                Capsule()
                    .strokeBorder(color.opacity(0.5), lineWidth: 1)
            }
    }
}

// MARK: - All Accessory Types

/// Shows all four edge accessory placements.
private struct AllAccessoriesPreview: View {
    @State private var selectedTab: PreviewTab = .home

    var body: some View {
        SampleContentView("All Accessories", color: .mint.opacity(0.05))
            .glass {
                // Top accessory
                GlassItem(placement: .topAccessory(offset: 8)) {
                    accessoryPill("Top Accessory", icon: "arrow.down")
                }

                // Top primary content
                GlassItem(placement: .topPrimary) {
                    Text("Top Toolbar")
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)

                }

                // Bottom accessory (melted)
                GlassItem(placement: .bottomAccessoryMelted()) {
                    accessoryPill("Bottom Accessory", icon: "arrow.up")
                }

                // Bottom primary content
                GlassItemGroup(placement: .bottomPrimary) {
                    ForEach(PreviewTab.allCases, id: \.self) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            Label(tab.title, systemImage: tab.systemImage)
                        }
                        .buttonStyle(.glass())
                    }
                }
            }
    }

    @ViewBuilder
    private func accessoryPill(_ text: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption.weight(.medium))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)

    }
}

// MARK: - Semantic Accessory Helpers

/// Demonstrates the semantic helper methods for accessories.
private struct SemanticAccessoryHelpersPreview: View {
    @State private var selectedTab: PreviewTab = .home
    @State private var showMelted = true

    var body: some View {
        VStack(spacing: 0) {
            Toggle("Melted vs Separated", isOn: $showMelted)
                .padding()

            SampleContentView("Semantic Helpers", color: .cyan.opacity(0.05))
                .glass {
                    GlassItem(
                        placement: showMelted
                            ? .bottomAccessoryMelted()
                            : .bottomAccessorySeparated(spacing: 16)
                    ) {
                        HStack(spacing: 8) {
                            Image(systemName: showMelted ? "link" : "link.badge.plus")
                            Text(showMelted ? "Melted (-8pt)" : "Separated (+16pt)")
                                .font(.caption.weight(.medium))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)

                    }

                    GlassItemGroup(placement: .bottomPrimary) {
                        ForEach(PreviewTab.allCases, id: \.self) { tab in
                            Button {
                                selectedTab = tab
                            } label: {
                                Label(tab.title, systemImage: tab.systemImage)
                            }
                            .buttonStyle(.glass())
                        }
                    }
                }
        }
    }
}

// MARK: - Four-Edge Layout

/// Extreme example with toolbars on all four edges.
private struct FourEdgeLayoutPreview: View {
    @State private var selectedTab: PreviewTab = .home

    var body: some View {
        SampleContentView("Four Edges", color: .gray.opacity(0.05))
            .glass {
                // Top
                GlassItem(placement: .topPrimary) {
                    Text("Top")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)

                }

                // Bottom
                GlassItemGroup(placement: .bottomPrimary) {
                    ForEach(PreviewTab.allCases, id: \.self) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            Label(tab.title, systemImage: tab.systemImage)
                        }
                        .buttonStyle(.glass())
                    }
                }

                // Leading
                GlassItem(placement: .leadingPrimary) {
                    VStack(spacing: 12) {
                        Button {} label: {
                            Image(systemName: "sidebar.left")
                        }
                        .buttonStyle(.glass(style: .iconOnly()))

                        Button {} label: {
                            Image(systemName: "folder")
                        }
                        .buttonStyle(.glass(style: .iconOnly()))
                    }
                    .padding(8)

                }

                // Trailing
                GlassItem(placement: .trailingPrimary) {
                    VStack(spacing: 12) {
                        Button {} label: {
                            Image(systemName: "info.circle")
                        }
                        .buttonStyle(.glass(style: .iconOnly()))

                        Button {} label: {
                            Image(systemName: "ellipsis")
                        }
                        .buttonStyle(.glass(style: .iconOnly()))
                    }
                    .padding(8)

                }
            }
    }
}

// MARK: - Builder Pattern Demo

/// Demonstrates the result builder with conditionals and loops.
private struct BuilderPatternDemoPreview: View {
    @State private var selectedTab: PreviewTab = .home
    @State private var isEditing = false
    @State private var showExtra = true

    let extraActions = ["star", "bookmark", "flag"]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Toggle("Editing", isOn: $isEditing)
                Toggle("Extra", isOn: $showExtra)
            }
            .padding()

            SampleContentView("Builder Pattern", color: .yellow.opacity(0.05))
                .glass {
                    // Conditional: Only show when not editing
                    if !isEditing {
                        GlassItem(placement: .bottomLeading) {
                            Button("Edit", systemImage: "pencil") {
                                isEditing = true
                            }
                            .buttonStyle(.glass(style: .iconOnly()))
                        }
                    }

                    // Always show primary tabs
                    GlassItemGroup(placement: .bottomPrimary) {
                        ForEach(PreviewTab.allCases, id: \.self) { tab in
                            Button {
                                selectedTab = tab
                            } label: {
                                Label(tab.title, systemImage: tab.systemImage)
                            }
                            .buttonStyle(.glass())
                        }
                    }

                    // Conditional: Show done button when editing
                    if isEditing {
                        GlassItem(placement: .bottomTrailing) {
                            Button("Done", systemImage: "checkmark") {
                                isEditing = false
                            }
                            .buttonStyle(.glass(style: .iconOnly()))
                        }
                    }

                    // Conditional accessory with ForEach
                    if showExtra {
                        GlassItem(placement: .topTrailing) {
                            HStack(spacing: 8) {
                                ForEach(extraActions, id: \.self) { icon in
                                    Button {} label: {
                                        Image(systemName: icon)
                                    }
                                    .buttonStyle(.glass(style: .iconOnly()))
                                }
                            }
                            .padding(6)

                        }
                    }
                }
        }
    }
}

// MARK: - Previews

#Preview("Bottom Edge - All Positions") {
    AllPositionsOnEdgePreview(edge: .bottom)
}

#Preview("Top Edge - All Positions") {
    AllPositionsOnEdgePreview(edge: .top)
}

#Preview("Leading Edge - All Positions") {
    AllPositionsOnEdgePreview(edge: .leading)
}

#Preview("Trailing Edge - All Positions") {
    AllPositionsOnEdgePreview(edge: .trailing)
}

#Preview("Multi-Edge Overlay") {
    MultiEdgeOverlayPreview()
}

#Preview("Accessory Offsets") {
    AccessoryOffsetComparisonPreview()
}

#Preview("All Accessories") {
    AllAccessoriesPreview()
}

#Preview("Semantic Helpers") {
    SemanticAccessoryHelpersPreview()
}

#Preview("Four-Edge Layout") {
    FourEdgeLayoutPreview()
}

#Preview("Builder Pattern") {
    BuilderPatternDemoPreview()
}

#Preview("Dark Mode - Multi-Edge") {
    MultiEdgeOverlayPreview()
        .preferredColorScheme(.dark)
}

#Preview("iPad Layout", traits: .landscapeLeft) {
    FourEdgeLayoutPreview()
}
