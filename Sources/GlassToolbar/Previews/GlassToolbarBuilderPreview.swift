//
//  GlassToolbarBuilderPreview.swift
//  GlassToolbar
//
//  Previews demonstrating GlassToolbarBuilder result builder patterns.
//

import SwiftUI

// MARK: - Extended Tab Enum

private enum ExtendedTab: Int, CaseIterable, Hashable {
  case dashboard, history, garage, stats, settings

  var title: String {
    switch self {
    case .dashboard: "Dashboard"
    case .history: "History"
    case .garage: "Garage"
    case .stats: "Stats"
    case .settings: "Settings"
    }
  }

  var systemImage: String {
    switch self {
    case .dashboard: "gauge"
    case .history: "clock"
    case .garage: "car"
    case .stats: "chart.bar"
    case .settings: "gearshape"
    }
  }
}

// MARK: - Conditional Items Preview

/// Shows if-else branching in GlassToolbarBuilder.
private struct ConditionalItemsPreview: View {
  @State private var selectedTab: PreviewTab = .home
  @State private var isEditing = false
  @State private var hasNotifications = true

  var body: some View {
    VStack {
      Toggle("Editing Mode", isOn: $isEditing)
      Toggle("Has Notifications", isOn: $hasNotifications)
      Spacer()
    }
    .padding()
    .ignoresSafeArea(edges: .bottom)
    .glassToolbarOverlay {
      // Leading changes based on edit mode
      if isEditing {
        GlassToolbarItem(placement: .bottomLeading) {
          Button("Cancel", systemImage: "xmark") {
            isEditing = false
          }
          .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly()))
        }
      } else {
        GlassToolbarItem(placement: .bottomLeading) {
          Button("Edit", systemImage: "pencil") {
            isEditing = true
          }
          .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly()))
        }
      }

      // Center tabs only show when not editing
      if !isEditing {
        GlassToolbarItemGroup(placement: .bottomPrimary) {
          ForEach(PreviewTab.allCases, id: \.rawValue) { tab in
            Button {
              selectedTab = tab
            } label: {
              Label(tab.title, systemImage: tab.systemImage)
            }
            .buttonStyle(.toolbarItem(isSelected: selectedTab == tab))
          }
        }
      }

      // Trailing with optional badge indicator
      if isEditing {
        GlassToolbarItem(placement: .bottomTrailing) {
          Button("Done", systemImage: "checkmark") {
            isEditing = false
          }
          .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly()))
        }
      } else if hasNotifications {
        GlassToolbarItem(placement: .bottomTrailing) {
          Button {} label: {
            Image(systemName: "bell.badge")
          }
          .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly()))
        }
      }
    }
  }
}

// MARK: - ForEach Items Preview

/// Shows ForEach loop in GlassToolbarBuilder.
private struct ForEachItemsPreview: View {
  @State private var selectedTab: ExtendedTab = .dashboard

  private var primaryTabs: [ExtendedTab] {
    [.dashboard, .history, .garage]
  }

  private var secondaryTabs: [ExtendedTab] {
    [.stats, .settings]
  }

  var body: some View {
    SampleContentView("ForEach in Builder", color: .indigo.opacity(0.05))
      .glassToolbarOverlay {
        // Primary tabs using ForEach
        GlassToolbarItemGroup(placement: .bottomPrimary) {
          ForEach(primaryTabs, id: \.rawValue) { tab in
            Button {
              selectedTab = tab
            } label: {
              Label(tab.title, systemImage: tab.systemImage)
            }
            .buttonStyle(.toolbarItem(isSelected: selectedTab == tab))
          }
        }

        // Secondary tabs at top
        GlassToolbarItemGroup(placement: .topTrailing) {
          ForEach(secondaryTabs, id: \.rawValue) { tab in
            Button {
              selectedTab = tab
            } label: {
              Label(tab.title, systemImage: tab.systemImage)
            }
            .buttonStyle(.toolbarItem(style: .iconOnly(), isSelected: selectedTab == tab))
          }
        }
      }
  }
}

// MARK: - Multi-Edge Layout Preview

/// Shows items at multiple edges simultaneously.
private struct MultiEdgeLayoutPreview: View {
  @State private var selectedTab: PreviewTab = .home
  @State private var filterActive = false

  var body: some View {
    SampleContentView("Multi-Edge Layout", color: .cyan.opacity(0.05))
      .glassToolbarOverlay {
        // Top leading: Back button
        GlassToolbarItem(placement: .topLeading) {
          Button {} label: {
            Label("Back", systemImage: "chevron.left")
          }
          .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly()))
        }

        // Top trailing: Filter toggle
        GlassToolbarItem(placement: .topTrailing) {
          Button {
            filterActive.toggle()
          } label: {
            Label(
              "Filter",
              systemImage: filterActive
                ? "line.3.horizontal.decrease.circle.fill"
                : "line.3.horizontal.decrease.circle"
            )
          }
          .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly()))
        }

        // Bottom leading: Settings
        GlassToolbarItem(placement: .bottomLeading) {
          Button {} label: {
            Label("Settings", systemImage: "gearshape")
          }
          .buttonStyle(.toolbarItem(style: .iconOnly()))
        }

        // Bottom primary: Tabs
        GlassToolbarItemGroup(placement: .bottomPrimary) {
          ForEach(PreviewTab.allCases, id: \.rawValue) { tab in
            Button {
              selectedTab = tab
            } label: {
              Label(tab.title, systemImage: tab.systemImage)
            }
            .buttonStyle(.toolbarItem(isSelected: selectedTab == tab))
          }
        }

        // Bottom trailing: Add
        GlassToolbarItem(placement: .bottomTrailing) {
          Button {} label: {
            Label("Add", systemImage: "plus")
          }
          .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly()))
        }
      }
  }
}

// MARK: - Optional Items Preview

/// Shows optional items that may or may not appear.
private struct OptionalItemsPreview: View {
  @State private var selectedTab: PreviewTab = .home
  @State private var showLeading = true
  @State private var showTrailing = true
  @State private var showAccessory = true

  var body: some View {
    VStack {
      Toggle("Show Leading", isOn: $showLeading)
      Toggle("Show Trailing", isOn: $showTrailing)
      Toggle("Show Accessory", isOn: $showAccessory)
      Spacer()
    }
    .padding()
    .ignoresSafeArea(edges: .bottom)
    .glassToolbarOverlay {
      if showLeading {
        GlassToolbarItem(placement: .bottomLeading) {
          Button {} label: {
            Label("Menu", systemImage: "line.3.horizontal")
          }
          .buttonStyle(.toolbarItem(style: .iconOnly()))
        }
      }

      GlassToolbarItemGroup(placement: .bottomPrimary) {
        ForEach(PreviewTab.allCases, id: \.rawValue) { tab in
          Button {
            selectedTab = tab
          } label: {
            Label(tab.title, systemImage: tab.systemImage)
          }
          .buttonStyle(.toolbarItem(isSelected: selectedTab == tab))
        }
      }

      if showTrailing {
        GlassToolbarItem(placement: .bottomTrailing) {
          Button {} label: {
            Label("Add", systemImage: "plus")
          }
          .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly()))
        }
      }

      if showAccessory {
        GlassToolbarItem(placement: .bottomAccessory(offset: -8)) {
          Text("Accessory View")
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)

        }
      }
    }
  }
}

// MARK: - Accessory Variations Preview

/// Shows different accessory offset configurations.
private struct AccessoryVariationsPreview: View {
  @State private var selectedTab: PreviewTab = .home
  @State private var accessoryOffset: CGFloat = -8

  var body: some View {
    VStack {
      Text("Accessory Offset: \(Int(accessoryOffset))pt")
        .font(.headline)

      Slider(value: $accessoryOffset, in: -16...32, step: 4) {
        Text("Offset")
      }
      .padding(.horizontal)

      Text(accessoryDescription)
        .font(.caption)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal)

      Spacer()
    }
    .padding(.top)
    .ignoresSafeArea(edges: .bottom)
    .glassToolbarOverlay {
      GlassToolbarItem(placement: .bottomAccessory(offset: accessoryOffset)) {
        HStack {
          Image(systemName: "car")
          Text("Tesla Model 3")
        }
        .font(.caption)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)

      }

      GlassToolbarItemGroup(placement: .bottomPrimary) {
        ForEach(PreviewTab.allCases, id: \.rawValue) { tab in
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

  private var accessoryDescription: String {
    if accessoryOffset < 0 {
      return "Negative offset: Accessory overlaps toolbar (melting effect)"
    } else if accessoryOffset == 0 {
      return "Zero offset: Accessory touches toolbar edge"
    } else {
      return "Positive offset: Accessory separated from toolbar"
    }
  }
}

// MARK: - Complex Layout Preview

/// Shows a complex real-world layout scenario.
private struct ComplexLayoutPreview: View {
  @State private var selectedTab: ExtendedTab = .dashboard
  @State private var selectedVehicle = "Tesla Model 3"
  @State private var showingNotifications = false

  private let vehicles = ["Tesla Model 3", "BMW i4", "Mercedes EQE"]

  var body: some View {
    SampleContentView("Complex Layout", color: .orange.opacity(0.05))
      .glassToolbarOverlay {
        // Top bar with vehicle picker
        GlassToolbarItem(placement: .topLeading) {
          ToolbarMenuPicker(
            selection: $selectedVehicle,
            options: vehicles
          ) { vehicle in
            Label(vehicle, systemImage: "car")
          }
          .padding(.horizontal, 8)
          .padding(.vertical, 6)

        }

        GlassToolbarItem(placement: .topTrailing) {
          Button {
            showingNotifications.toggle()
          } label: {
            Label("Notifications", systemImage: showingNotifications ? "bell.fill" : "bell")
          }
          .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly()))
        }

        // Vehicle status accessory
        GlassToolbarItem(placement: .bottomAccessory(offset: -8)) {
          HStack(spacing: 8) {
            Image(systemName: "battery.75percent")
            Text("75%")
            Divider().frame(height: 16)
            Image(systemName: "location")
            Text("Charging")
          }
          .font(.caption)
          .padding(.horizontal, 12)
          .padding(.vertical, 8)

        }

        // Main navigation
        GlassToolbarItemGroup(placement: .bottomPrimary) {
          ForEach(ExtendedTab.allCases.prefix(4), id: \.rawValue) { tab in
            Button {
              selectedTab = tab
            } label: {
              Label(tab.title, systemImage: tab.systemImage)
            }
            .buttonStyle(.toolbarItem(isSelected: selectedTab == tab))
          }
        }

        // Settings button
        GlassToolbarItem(placement: .bottomTrailing) {
          Button {
            selectedTab = .settings
          } label: {
            Label("Settings", systemImage: "gearshape")
          }
          .buttonStyle(.toolbarItem(style: .iconOnly(), isSelected: selectedTab == .settings))
        }
      }
  }
}

// MARK: - Previews

#Preview("Conditional Items") {
  ConditionalItemsPreview()
}

#Preview("ForEach Items") {
  ForEachItemsPreview()
}

#Preview("Multi-Edge Layout") {
  MultiEdgeLayoutPreview()
}

#Preview("Optional Items") {
  OptionalItemsPreview()
}

#Preview("Accessory Variations") {
  AccessoryVariationsPreview()
}

#Preview("Complex Layout") {
  ComplexLayoutPreview()
}

#Preview("Empty Builder") {
  // Edge case: Empty builder should not crash
  Color.blue.opacity(0.1)
    .ignoresSafeArea()
    .glassToolbarOverlay {
      // No items - should render cleanly with no toolbar
    }
}

#Preview("Single Item") {
  // Edge case: Only one item
  Color.green.opacity(0.1)
    .ignoresSafeArea()
    .glassToolbarOverlay {
      GlassToolbarItem(placement: .bottomPrimary) {
        Button {} label: {
          Label("Single", systemImage: "star")
        }
        .buttonStyle(.toolbarItem())
      }
    }
}

#Preview("All Placements") {
  // Shows all available placements at once
  Color.purple.opacity(0.1)
    .ignoresSafeArea()
    .glassToolbarOverlay {
      GlassToolbarItem(placement: .topLeading) {
        Text("TL").font(.caption2).padding(8).background(.red.opacity(0.3), in: .capsule)
      }
      GlassToolbarItem(placement: .topPrimary) {
        Text("T").font(.caption2).padding(8).background(.orange.opacity(0.3), in: .capsule)
      }
      GlassToolbarItem(placement: .topTrailing) {
        Text("TR").font(.caption2).padding(8).background(.yellow.opacity(0.3), in: .capsule)
      }

      GlassToolbarItem(placement: .bottomLeading) {
        Text("BL").font(.caption2).padding(8).background(.green.opacity(0.3), in: .capsule)
      }
      GlassToolbarItem(placement: .bottomPrimary) {
        Text("B").font(.caption2).padding(8).background(.blue.opacity(0.3), in: .capsule)
      }
      GlassToolbarItem(placement: .bottomTrailing) {
        Text("BR").font(.caption2).padding(8).background(.purple.opacity(0.3), in: .capsule)
      }

      GlassToolbarItem(placement: .bottomAccessory(offset: 8)) {
        Text("Accessory").font(.caption2).padding(8).background(.pink.opacity(0.3), in: .capsule)
      }
    }
}
