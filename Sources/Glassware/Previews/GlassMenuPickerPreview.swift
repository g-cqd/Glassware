//
//  GlassMenuPickerPreview.swift
//  Glassware
//
//  Previews demonstrating the GlassMenuPicker component.
//

import SwiftUI

// MARK: - Menu Picker Option Enum

private enum MenuOption: String, CaseIterable, Hashable, CustomStringConvertible {
    case home, search, profile, settings

    var description: String { rawValue.capitalized }

    var icon: String {
        switch self {
        case .home: "house"
        case .search: "magnifyingglass"
        case .profile: "person"
        case .settings: "gearshape"
        }
    }
}

// MARK: - Vehicle Option

private enum Vehicle: String, CaseIterable, Hashable {
    case model3 = "Tesla Model 3"
    case modelY = "Tesla Model Y"
    case bmwI4 = "BMW i4"
    case mercedesEQE = "Mercedes EQE"

    var displayName: String { rawValue }

    var icon: String {
        switch self {
        case .model3, .modelY: "bolt.car"
        case .bmwI4: "car"
        case .mercedesEQE: "car.side"
        }
    }
}

// MARK: - Basic Menu Picker Preview

/// Shows the most basic text-only menu picker usage.
private struct BasicMenuPickerPreview: View {
    @State private var selection: MenuOption = .home

    var body: some View {
        VStack(spacing: 24) {
            Text("Basic Text Picker")
                .font(.headline)

            GlassMenuPicker(
                selection: $selection,
                options: MenuOption.allCases
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 10)


            VStack(spacing: 4) {
                Text("Selected: \(selection.description)")
                    .font(.subheadline)
                Text("Uses CustomStringConvertible")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
    }
}

// MARK: - Labeled Menu Picker Preview

/// Shows menu picker with icon labels.
private struct LabeledMenuPickerPreview: View {
    @State private var selection: MenuOption = .search

    var body: some View {
        VStack(spacing: 24) {
            Text("With Labels")
                .font(.headline)

            GlassMenuPicker(
                selection: $selection,
                options: MenuOption.allCases
            ) { option in
                Label(option.description, systemImage: option.icon)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)


            Text("Selected: \(selection.description)")
                .font(.subheadline)
        }
        .padding()
    }
}

// MARK: - Dual Label Preview

/// Shows menu picker with different display and option labels.
private struct DualLabelMenuPickerPreview: View {
    @State private var selection: Vehicle = .model3

    var body: some View {
        VStack(spacing: 24) {
            Text("Dual Labels")
                .font(.headline)

            GlassMenuPicker(
                selection: $selection,
                options: Vehicle.allCases,
                label: { vehicle in
                    // Compact display: icon only
                    Label(vehicle.displayName, systemImage: vehicle.icon)
                        .labelStyle(.iconOnly)
                },
                optionLabel: { vehicle in
                    // Menu options: full label
                    Label(vehicle.displayName, systemImage: vehicle.icon)
                }
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 10)


            VStack(spacing: 4) {
                Text("Selected: \(selection.displayName)")
                    .font(.subheadline)
                Text("Display shows icon, menu shows full label")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
    }
}

// MARK: - Menu Picker in Toolbar Preview

/// Shows menu picker integrated with glass toolbar.
private struct MenuPickerInToolbarPreview: View {
    @State private var vehicle: Vehicle = .model3
    @State private var selectedTab: PreviewTab = .home

    var body: some View {
        SampleContentView("Menu Picker in Toolbar", color: .cyan.opacity(0.05))
            .glassBar(
                leading: {
                    GlassMenuPicker(
                        selection: $vehicle,
                        options: Vehicle.allCases
                    ) { v in
                        Label(v.displayName, systemImage: v.icon)
                    }
                },
                content: {
                    ForEach(PreviewTab.allCases, id: \.rawValue) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            Label(tab.title, systemImage: tab.systemImage)
                        }
                        .buttonStyle(.glass(isSelected: selectedTab == tab))
                    }
                },
                trailing: {
                    Button {} label: {
                        Label("Add", systemImage: "plus")
                    }
                    .buttonStyle(.glass(intent: .action, style: .iconOnly()))
                }
            )
    }
}

// MARK: - Menu Picker Density Preview

/// Shows menu picker at different density levels.
private struct MenuPickerDensityPreview: View {
    @State private var selection: MenuOption = .home

    var body: some View {
        VStack(spacing: 24) {
            ForEach(GlassDensity.allCases, id: \.rawValue) { density in
                VStack(alignment: .leading, spacing: 8) {
                    Text(densityName(density))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    GlassMenuPicker(
                        selection: $selection,
                        options: MenuOption.allCases
                    ) { option in
                        Label(option.description, systemImage: option.icon)
                    }
                    .glassDensity(density)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)

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

// MARK: - Menu Picker with Accessory Preview

/// Shows menu picker as an accessory above the toolbar.
private struct MenuPickerAccessoryPreview: View {
    @State private var vehicle: Vehicle = .modelY
    @State private var selectedTab: PreviewTab = .home

    var body: some View {
        SampleContentView("Menu Picker Accessory", color: .orange.opacity(0.05))
            .glass {
                GlassItem(placement: .bottomAccessory(offset: -8)) {
                    GlassMenuPicker(
                        selection: $vehicle,
                        options: Vehicle.allCases
                    ) { v in
                        Label(v.displayName, systemImage: v.icon)
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
                        .buttonStyle(.glass(isSelected: selectedTab == tab))
                    }
                }
            }
    }
}

// MARK: - Multiple Menu Pickers Preview

/// Shows multiple menu pickers in different positions.
private struct MultipleMenuPickersPreview: View {
    @State private var vehicle: Vehicle = .model3
    @State private var filter: MenuOption = .home
    @State private var selectedTab: PreviewTab = .home

    var body: some View {
        SampleContentView("Multiple Pickers", color: .purple.opacity(0.05))
            .glass {
                GlassItem(placement: .topLeading) {
                    GlassMenuPicker(
                        selection: $vehicle,
                        options: Vehicle.allCases
                    ) { v in
                        Label(v.displayName, systemImage: v.icon)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)

                }

                GlassItem(placement: .topTrailing) {
                    GlassMenuPicker(
                        selection: $filter,
                        options: MenuOption.allCases
                    ) { option in
                        Label(option.description, systemImage: option.icon)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)

                }

                GlassItemGroup(placement: .bottomPrimary) {
                    ForEach(PreviewTab.allCases, id: \.self) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            Label(tab.title, systemImage: tab.systemImage)
                        }
                        .buttonStyle(.glass(isSelected: selectedTab == tab))
                    }
                }
            }
    }
}

// MARK: - Previews

#Preview("Basic Text") {
    BasicMenuPickerPreview()
}

#Preview("With Labels") {
    LabeledMenuPickerPreview()
}

#Preview("Dual Labels") {
    DualLabelMenuPickerPreview()
}

#Preview("In Toolbar") {
    MenuPickerInToolbarPreview()
}

#Preview("Density Comparison") {
    ScrollView {
        MenuPickerDensityPreview()
    }
}

#Preview("As Accessory") {
    MenuPickerAccessoryPreview()
}

#Preview("Multiple Pickers") {
    MultipleMenuPickersPreview()
}

#Preview("Dark Mode") {
    LabeledMenuPickerPreview()
        .preferredColorScheme(.dark)
}

#Preview("Light vs Dark") {
    HStack(spacing: 0) {
        LabeledMenuPickerPreview()
            .preferredColorScheme(.light)
            .frame(maxWidth: .infinity)
            .background(.background)

        LabeledMenuPickerPreview()
            .preferredColorScheme(.dark)
            .frame(maxWidth: .infinity)
            .background(.background)
    }
}
