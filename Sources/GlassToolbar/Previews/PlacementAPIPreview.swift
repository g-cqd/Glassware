//
//  PlacementAPIPreview.swift
//  GlassToolbar
//
//  Previews for the placement-based toolbar API.
//

import SwiftUI

// MARK: - Basic Placement Preview

#Preview("Placement API - Basic") {
    struct Preview: View {
        @State private var selectedTab: PreviewTab = .home

        var body: some View {
            Color.blue.opacity(0.1)
                .ignoresSafeArea()
                .glassToolbarOverlay {
                    GlassToolbarItem(placement: .bottomLeading) {
                        Button("Settings", systemImage: "gearshape") { }
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
                        Button("Add", systemImage: "plus") { }
                            .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly()))
                    }
                }
        }
    }
    return Preview()
}

// MARK: - Multi-Edge Preview

#Preview("Placement API - Multi-Edge") {
    struct Preview: View {
        @State private var selectedTab: PreviewTab = .home
        @State private var showFilter = false

        var body: some View {
            Color.green.opacity(0.1)
                .ignoresSafeArea()
                .glassToolbarOverlay {
                    // Top trailing filter button
                    GlassToolbarItem(placement: .topTrailing) {
                        Button("Filter", systemImage: showFilter ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle") {
                            showFilter.toggle()
                        }
                        .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly()))
                    }

                    // Bottom toolbar
                    GlassToolbarItem(placement: .bottomLeading) {
                        Button("Menu", systemImage: "line.3.horizontal") { }
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
                }
        }
    }
    return Preview()
}

// MARK: - Accessory Preview

#Preview("Placement API - Accessory") {
    struct Preview: View {
        @State private var selectedTab: PreviewTab = .home
        @State private var selectedVehicle = "Tesla Model 3"
        let vehicles = ["Tesla Model 3", "BMW i4", "Mercedes EQE"]

        var body: some View {
            Color.orange.opacity(0.1)
                .ignoresSafeArea()
                .glassToolbarOverlay {
                    // Accessory picker above the toolbar (melted effect)
                    GlassToolbarItem(placement: .bottomAccessory(offset: 24)) {
                        ToolbarMenuPicker(
                            selection: $selectedVehicle,
                            options: vehicles
                        ) { vehicle in
                            Text(vehicle)
                        }
                    }
                    .toolbarDensity(.extraDense)

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
    }
    return Preview()
}

// MARK: - Separated Accessory Preview

#Preview("Placement API - Separated Accessory") {
    struct Preview: View {
        @State private var selectedTab: PreviewTab = .home

        var body: some View {
            Color.purple.opacity(0.1)
                .ignoresSafeArea()
                .glassToolbarOverlay {
                    // Accessory separated by 16pt
                    GlassToolbarItem(placement: .bottomAccessorySeparated(spacing: 16)) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text("Fuel low - 15% remaining")
                                .font(.caption)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
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
    }
    return Preview()
}

// MARK: - Local Density Override Preview

#Preview("Placement API - Density Override") {
    struct Preview: View {
        @State private var selectedTab: PreviewTab = .home

        var body: some View {
            Color.teal.opacity(0.1)
                .ignoresSafeArea()
                .glassToolbarOverlay {
                    // Compact settings button
                    GlassToolbarItem(placement: .bottomLeading) {
                        Button("Settings", systemImage: "gearshape") { }
                            .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly()))
                    }
                    .toolbarDensity(.compact)

                    // Regular density tabs
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

                    // Dense action button
                    GlassToolbarItem(placement: .bottomTrailing) {
                        Button("Add", systemImage: "plus") { }
                            .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly()))
                    }
                    .toolbarDensity(.dense)
                }
                .toolbarDensity(.regular)
        }
    }
    return Preview()
}

// MARK: - Conditional Content Preview

#Preview("Placement API - Conditional") {
    struct Preview: View {
        @State private var selectedTab: PreviewTab = .home
        @State private var isEditing = false

        var body: some View {
            VStack {
                Toggle("Editing Mode", isOn: $isEditing)
                    .padding()
                Spacer()
            }
            .ignoresSafeArea(edges: .bottom)
            .glassToolbarOverlay {
                GlassToolbarItem(placement: .bottomLeading) {
                    Button(isEditing ? "Cancel" : "Edit", systemImage: isEditing ? "xmark" : "pencil") {
                        isEditing.toggle()
                    }
                    .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly()))
                }

                if !isEditing {
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

                if isEditing {
                    GlassToolbarItem(placement: .bottomTrailing) {
                        Button("Done", systemImage: "checkmark") {
                            isEditing = false
                        }
                        .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly()))
                    }
                }
            }
            .animation(.interactiveSpring, value: isEditing)
        }
    }
    return Preview()
}
