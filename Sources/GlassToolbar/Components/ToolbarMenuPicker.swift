//
//  ToolbarMenuPicker.swift
//  GlassToolbar
//
//  Compact menu-based picker for toolbar use.
//

import SwiftUI

// MARK: - Toolbar Menu Picker

/// A compact picker that displays a single value with chevron indicator,
/// expanding into a menu for selection.
///
/// This component provides a space-efficient way to select from multiple options
/// within a glass toolbar. It displays the current selection with up/down chevrons,
/// and tapping reveals a menu with all available options.
///
/// ## Usage
/// ```swift
/// enum Tab: String, CaseIterable, Identifiable {
///     case home, search, profile
///     var id: Self { self }
///     var title: String { rawValue.capitalized }
/// }
///
/// @State private var selectedTab: Tab = .home
///
/// ToolbarMenuPicker(selection: $selectedTab, options: Tab.allCases) { tab in
///     Text(tab.title)
/// }
/// ```
///
/// ## With Icons
/// ```swift
/// ToolbarMenuPicker(selection: $selectedTab, options: Tab.allCases) { tab in
///     Label(tab.title, systemImage: tab.icon)
/// }
/// ```
public struct ToolbarMenuPicker<Value: Hashable, Label: View, Option: View>: View {
    // MARK: - Properties

    @Binding var selection: Value
    let options: [Value]
    let label: (Value) -> Label
    let optionLabel: (Value) -> Option

    @Environment(\.toolbarDensity) private var density

    // MARK: - Initializers

    /// Creates a toolbar menu picker with custom labels.
    ///
    /// - Parameters:
    ///   - selection: A binding to the selected value.
    ///   - options: An array of available options.
    ///   - label: A view builder for the compact display label.
    ///   - optionLabel: A view builder for each menu option.
    public init(
        selection: Binding<Value>,
        options: [Value],
        @ViewBuilder label: @escaping (Value) -> Label,
        @ViewBuilder optionLabel: @escaping (Value) -> Option
    ) {
        self._selection = selection
        self.options = options
        self.label = label
        self.optionLabel = optionLabel
    }

    // MARK: - Body

    public var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button {
                    selection = option
                } label: {
                    optionLabel(option)
                }
            }
        } label: {
            HStack(spacing: 4) {
                label(selection)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.toolbarItem(intent: .action, style: .titleOnly))
    }
}

// MARK: - Convenience Initializers

extension ToolbarMenuPicker where Label == Option {
    /// Creates a toolbar menu picker with the same label for display and options.
    ///
    /// - Parameters:
    ///   - selection: A binding to the selected value.
    ///   - options: An array of available options.
    ///   - label: A view builder for both the compact display and menu options.
    public init(
        selection: Binding<Value>,
        options: [Value],
        @ViewBuilder label: @escaping (Value) -> Label
    ) {
        self._selection = selection
        self.options = options
        self.label = label
        self.optionLabel = label
    }
}

extension ToolbarMenuPicker where Value: CustomStringConvertible, Label == Text, Option == Text {
    /// Creates a toolbar menu picker using the value's description as label.
    ///
    /// - Parameters:
    ///   - selection: A binding to the selected value.
    ///   - options: An array of available options.
    public init(
        selection: Binding<Value>,
        options: [Value]
    ) {
        self._selection = selection
        self.options = options
        self.label = { Text($0.description) }
        self.optionLabel = { Text($0.description) }
    }
}

// MARK: - Preview Helpers

private enum MenuPickerOption: String, CaseIterable, Hashable, CustomStringConvertible {
    case home, search, profile

    var description: String { rawValue.capitalized }

    var icon: String {
        switch self {
        case .home: "house"
        case .search: "magnifyingglass"
        case .profile: "person"
        }
    }
}

// MARK: - Previews

#Preview("Basic Text") {
    struct Preview: View {
        @State private var selection: MenuPickerOption = .home

        var body: some View {
            VStack {
                Spacer()
                ToolbarMenuPicker(selection: $selection, options: MenuPickerOption.allCases)
                    .padding()
                    .background(.ultraThinMaterial, in: .capsule)
                Text("Selected: \(selection.description)")
                    .font(.caption)
                Spacer()
            }
        }
    }
    return Preview()
}

#Preview("With Labels") {
    struct Preview: View {
        @State private var selection: MenuPickerOption = .home

        var body: some View {
            VStack {
                Spacer()
                ToolbarMenuPicker(
                    selection: $selection,
                    options: MenuPickerOption.allCases
                ) { tab in
                    Label(tab.description, systemImage: tab.icon)
                }
                .padding()
                .background(.ultraThinMaterial, in: .capsule)
                Text("Selected: \(selection.description)")
                    .font(.caption)
                Spacer()
            }
        }
    }
    return Preview()
}

#Preview("In Toolbar") {
    struct Preview: View {
        @State private var selection: MenuPickerOption = .home
        @State private var selectedTab: Int = 0

        var body: some View {
            Color.blue.opacity(0.1)
                .ignoresSafeArea()
                .glassToolbar(
                    leading: {
                        ToolbarMenuPicker(
                            selection: $selection,
                            options: MenuPickerOption.allCases
                        ) { tab in
                            Text(tab.description)
                        }
                    },
                    content: {
                        ForEach(0..<3, id: \.self) { index in
                            Button {
                                selectedTab = index
                            } label: {
                                Label("Tab \(index)", systemImage: "circle")
                            }
                            .buttonStyle(.toolbarItem(isSelected: selectedTab == index))
                        }
                    }
                )
        }
    }
    return Preview()
}

#Preview("Different Densities") {
    struct Preview: View {
        @State private var selection: MenuPickerOption = .home

        var body: some View {
            VStack(spacing: 24) {
                ForEach([ToolbarDensity.sparse, .regular, .compact, .dense], id: \.rawValue) { density in
                    VStack(spacing: 4) {
                        Text(densityName(density))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        ToolbarMenuPicker(
                            selection: $selection,
                            options: MenuPickerOption.allCases
                        ) { tab in
                            Label(tab.description, systemImage: tab.icon)
                        }
                        .toolbarDensity(density)
                        .padding()
                        .background(.ultraThinMaterial, in: .capsule)
                    }
                }
            }
            .padding()
        }

        private func densityName(_ density: ToolbarDensity) -> String {
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
    return Preview()
}
