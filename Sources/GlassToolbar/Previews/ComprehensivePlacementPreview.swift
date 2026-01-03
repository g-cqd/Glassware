//
//  ComprehensivePlacementPreview.swift
//  GlassToolbar
//
//  Comprehensive previews demonstrating all GlassToolbarPlacement combinations.
//

import SwiftUI

// MARK: - All Positions on Single Edge

/// Shows all three positions (leading, primary, trailing) on a single edge.
private struct AllPositionsOnEdgePreview: View {
    let edge: ToolbarEdge
    @State private var selectedTab: PreviewTab = .home

    var body: some View {
        SampleContentView(edgeName, color: edgeColor.opacity(0.05))
            .glassToolbarOverlay {
                GlassToolbarItem(placement: leadingPlacement) {
                    Button("Leading", systemImage: "arrow.left") {}
                        .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly()))
                }

                GlassToolbarItemGroup(placement: primaryPlacement) {
                    ForEach(PreviewTab.allCases, id: \.self) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            Label(tab.title, systemImage: tab.systemImage)
                        }
                        .buttonStyle(.toolbarItem(
                            style: edge.isVertical ? .iconOnly() : .titleAndIcon(),
                            isSelected: selectedTab == tab
                        ))
                    }
                }

                GlassToolbarItem(placement: trailingPlacement) {
                    Button("Trailing", systemImage: "arrow.right") {}
                        .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly()))
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

    private var leadingPlacement: GlassToolbarPlacement {
        switch edge {
        case .top: .topLeading
        case .bottom: .bottomLeading
        case .leading: .leadingTop
        case .trailing: .trailingTop
        }
    }

    private var primaryPlacement: GlassToolbarPlacement {
        switch edge {
        case .top: .topPrimary
        case .bottom: .bottomPrimary
        case .leading: .leadingPrimary
        case .trailing: .trailingPrimary
        }
    }

    private var trailingPlacement: GlassToolbarPlacement {
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
            .glassToolbarOverlay {
                // Top edge: filter and sort controls
                GlassToolbarItem(placement: .topLeading) {
                    Button("Filter", systemImage: filterActive ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle") {
                        filterActive.toggle()
                    }
                    .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly()))
                }

                GlassToolbarItem(placement: .topTrailing) {
                    Button("Sort", systemImage: sortAscending ? "arrow.up" : "arrow.down") {
                        sortAscending.toggle()
                    }
                    .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly()))
                }

                // Bottom edge: main navigation
                GlassToolbarItem(placement: .bottomLeading) {
                    Button("Menu", systemImage: "line.3.horizontal") {}
                        .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly()))
                }

                GlassToolbarItemGroup(placement: .bottomPrimary) {
                    ForEach(PreviewTab.allCases, id: \.self) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            Label(tab.title, systemImage: tab.systemImage)
                        }
                        .buttonStyle(.toolbarItem(isSelected: selectedTab == tab))
                    }
                }

                GlassToolbarItem(placement: .bottomTrailing) {
                    Button("Add", systemImage: "plus") {}
                        .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly()))
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
            .glassToolbarOverlay {
                // Overlapping accessory (-8pt = "melted" effect)
                GlassToolbarItem(placement: .bottomAccessory(offset: -8)) {
                    accessoryBadge(text: "offset: -8", color: .orange)
                }

                // Main tabs
                GlassToolbarItemGroup(placement: .bottomPrimary) {
                    ForEach(PreviewTab.allCases, id: \.self) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            Label(tab.title, systemImage: tab.systemImage)
                        }
                        .buttonStyle(.toolbarItem(isSelected: selectedTab == tab))
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
            .glassToolbarOverlay {
                // Top accessory
                GlassToolbarItem(placement: .topAccessory(offset: 8)) {
                    accessoryPill("Top Accessory", icon: "arrow.down")
                }

                // Top primary content
                GlassToolbarItem(placement: .topPrimary) {
                    Text("Top Toolbar")
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)

                }

                // Bottom accessory (melted)
                GlassToolbarItem(placement: .bottomAccessoryMelted()) {
                    accessoryPill("Bottom Accessory", icon: "arrow.up")
                }

                // Bottom primary content
                GlassToolbarItemGroup(placement: .bottomPrimary) {
                    ForEach(PreviewTab.allCases, id: \.self) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            Label(tab.title, systemImage: tab.systemImage)
                        }
                        .buttonStyle(.toolbarItem(isSelected: selectedTab == tab))
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
                .glassToolbarOverlay {
                    GlassToolbarItem(
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

                    GlassToolbarItemGroup(placement: .bottomPrimary) {
                        ForEach(PreviewTab.allCases, id: \.self) { tab in
                            Button {
                                selectedTab = tab
                            } label: {
                                Label(tab.title, systemImage: tab.systemImage)
                            }
                            .buttonStyle(.toolbarItem(isSelected: selectedTab == tab))
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
            .glassToolbarOverlay {
                // Top
                GlassToolbarItem(placement: .topPrimary) {
                    Text("Top")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)

                }

                // Bottom
                GlassToolbarItemGroup(placement: .bottomPrimary) {
                    ForEach(PreviewTab.allCases, id: \.self) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            Label(tab.title, systemImage: tab.systemImage)
                        }
                        .buttonStyle(.toolbarItem(isSelected: selectedTab == tab))
                    }
                }

                // Leading
                GlassToolbarItem(placement: .leadingPrimary) {
                    VStack(spacing: 12) {
                        Button {} label: {
                            Image(systemName: "sidebar.left")
                        }
                        .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly()))

                        Button {} label: {
                            Image(systemName: "folder")
                        }
                        .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly()))
                    }
                    .padding(8)

                }

                // Trailing
                GlassToolbarItem(placement: .trailingPrimary) {
                    VStack(spacing: 12) {
                        Button {} label: {
                            Image(systemName: "info.circle")
                        }
                        .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly()))

                        Button {} label: {
                            Image(systemName: "ellipsis")
                        }
                        .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly()))
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
                .glassToolbarOverlay {
                    // Conditional: Only show when not editing
                    if !isEditing {
                        GlassToolbarItem(placement: .bottomLeading) {
                            Button("Edit", systemImage: "pencil") {
                                isEditing = true
                            }
                            .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly()))
                        }
                    }

                    // Always show primary tabs
                    GlassToolbarItemGroup(placement: .bottomPrimary) {
                        ForEach(PreviewTab.allCases, id: \.self) { tab in
                            Button {
                                selectedTab = tab
                            } label: {
                                Label(tab.title, systemImage: tab.systemImage)
                            }
                            .buttonStyle(.toolbarItem(isSelected: selectedTab == tab))
                        }
                    }

                    // Conditional: Show done button when editing
                    if isEditing {
                        GlassToolbarItem(placement: .bottomTrailing) {
                            Button("Done", systemImage: "checkmark") {
                                isEditing = false
                            }
                            .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly()))
                        }
                    }

                    // Conditional accessory with ForEach
                    if showExtra {
                        GlassToolbarItem(placement: .topTrailing) {
                            HStack(spacing: 8) {
                                ForEach(extraActions, id: \.self) { icon in
                                    Button {} label: {
                                        Image(systemName: icon)
                                    }
                                    .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly()))
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
