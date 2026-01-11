//
//  PlacementAPIPreview.swift
//  Glassware
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
                .glass {
                    GlassItem(placement: .bottomLeading) {
                        Button("Settings", systemImage: "gearshape") { }
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
                        Button("Add", systemImage: "plus") { }
                            .buttonStyle(.glass(style: .iconOnly()))
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
                .glass {
                    // Top trailing filter button
                    GlassItem(placement: .topTrailing) {
                        Button("Filter", systemImage: showFilter ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle") {
                            showFilter.toggle()
                        }
                        .buttonStyle(.glass(style: .iconOnly()))
                    }

                    // Bottom toolbar
                    GlassItem(placement: .bottomLeading) {
                        Button("Menu", systemImage: "line.3.horizontal") { }
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
                .glass {
                    // Accessory picker above the toolbar (melted effect)
                    GlassItem(placement: .bottomAccessory(offset: 24)) {
                        GlassMenuPicker(
                            selection: $selectedVehicle,
                            options: vehicles
                        ) { vehicle in
                            Text(vehicle)
                        }
                    }
                    .glassDensity(.extraDense)

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
                .glass {
                    // Accessory separated by 16pt
                    GlassItem(placement: .bottomAccessorySeparated(spacing: 16)) {
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
    return Preview()
}

// MARK: - Local Density Override Preview

#Preview("Placement API - Density Override") {
    struct Preview: View {
        @State private var selectedTab: PreviewTab = .home

        var body: some View {
            Color.teal.opacity(0.1)
                .ignoresSafeArea()
                .glass {
                    // Compact settings button
                    GlassItem(placement: .bottomLeading) {
                        Button("Settings", systemImage: "gearshape") { }
                            .buttonStyle(.glass(style: .iconOnly()))
                    }
                    .glassDensity(.compact)

                    // Regular density tabs
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

                    // Dense action button
                    GlassItem(placement: .bottomTrailing) {
                        Button("Add", systemImage: "plus") { }
                            .buttonStyle(.glass(style: .iconOnly()))
                    }
                    .glassDensity(.dense)
                }
                .glassDensity(.regular)
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
            .glass {
                GlassItem(placement: .bottomLeading) {
                    Button(isEditing ? "Cancel" : "Edit", systemImage: isEditing ? "xmark" : "pencil") {
                        isEditing.toggle()
                    }
                    .buttonStyle(.glass(style: .iconOnly()))
                }

                if !isEditing {
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

                if isEditing {
                    GlassItem(placement: .bottomTrailing) {
                        Button("Done", systemImage: "checkmark") {
                            isEditing = false
                        }
                        .buttonStyle(.glass(style: .iconOnly()))
                    }
                }
            }
            .animation(.interactiveSpring, value: isEditing)
        }
    }
    return Preview()
}
