//
//  GlassMenuPicker.swift
//  Glassware
//
//  Compact menu-based picker for toolbar use.
//

import SwiftUI

// MARK: - Menu Picker Display Mode

/// Controls the visual presentation of a `GlassMenuPicker`.
///
/// - `.standard`: Full label with chevron indicator (default for multi-item containers)
/// - `.compact`: Icon-only with chevron, suitable for edge placement or constrained space
public enum MenuPickerDisplayMode: Sendable, Equatable {
    /// Full label display with icon, title, and chevron indicator.
    case standard

    /// Compact display showing only icon and chevron.
    /// Use when the picker is alone on a toolbar edge or in constrained space.
    case compact
}

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
/// GlassMenuPicker(selection: $selectedTab, options: Tab.allCases) { tab in
///     Text(tab.title)
/// }
/// ```
///
/// ## With Icons
/// ```swift
/// GlassMenuPicker(selection: $selectedTab, options: Tab.allCases) { tab in
///     Label(tab.title, systemImage: tab.icon)
/// }
/// ```
///
/// ## Compact Mode
/// Use `.compact` display mode when the picker appears alone on a toolbar edge:
/// ```swift
/// GlassMenuPicker(
///     selection: $selectedTab,
///     options: Tab.allCases,
///     displayMode: .compact
/// ) { tab in
///     Label(tab.title, systemImage: tab.icon)
/// }
/// ```
public struct GlassMenuPicker<Value: Hashable, Label: View, Option: View>: View {
    // MARK: - Properties

    @Binding private var selection: Value
    private let options: [Value]
    private let displayMode: MenuPickerDisplayMode
    private let label: (Value) -> Label
    private let optionLabel: (Value) -> Option

    @Environment(\.glassDensity) private var density
    @Environment(\.glassEdge) private var toolbarEdge
    @Environment(\.glassContainerContext) private var containerContext

    /// Effective display mode, accounting for vertical edge placement.
    ///
    /// When on a vertical edge (leading/trailing) and alone in container,
    /// automatically uses compact mode regardless of configured mode.
    private var effectiveDisplayMode: MenuPickerDisplayMode {
        if toolbarEdge.isVertical, containerContext.isSingleItem {
            .compact
        } else {
            displayMode
        }
    }

    /// Chevron font scaled appropriately for visual balance.
    private var chevronFont: Font {
        switch density {
        case .extraSparse, .sparse:
            .footnote.weight(.medium)
        case .regular, .compact:
            .caption.weight(.medium)
        case .dense, .extraDense:
            .caption2.weight(.medium)
        }
    }

    /// Spacing between label and chevron, density-aware.
    private var labelChevronSpacing: CGFloat {
        switch density {
        case .extraSparse, .sparse: 8
        case .regular: 6
        case .compact, .dense, .extraDense: 5
        }
    }

    /// Additional horizontal padding for picker content, density-aware.
    private var pickerHorizontalPadding: CGFloat {
        switch density {
        case .extraSparse, .sparse: 6
        case .regular, .compact: 4
        case .dense, .extraDense: 2
        }
    }

    // MARK: - Initializers

    /// Creates a toolbar menu picker with custom labels.
    ///
    /// - Parameters:
    ///   - selection: A binding to the selected value.
    ///   - options: An array of available options.
    ///   - displayMode: The visual presentation mode. Default is `.standard`.
    ///   - label: A view builder for the compact display label.
    ///   - optionLabel: A view builder for each menu option.
    public init(
        selection: Binding<Value>,
        options: [Value],
        displayMode: MenuPickerDisplayMode = .standard,
        @ViewBuilder label: @escaping (Value) -> Label,
        @ViewBuilder optionLabel: @escaping (Value) -> Option
    ) {
        self._selection = selection
        self.options = options
        self.displayMode = displayMode
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
            HStack(spacing: labelChevronSpacing) {
                labelContent
                Image(systemName: "chevron.up.chevron.down")
                    .font(chevronFont)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, pickerHorizontalPadding)
        }
        .buttonStyle(.glass(style: buttonStyle))
        .glassEffectTransition(.materialize)
    }

    // MARK: - Private Views

    @ViewBuilder
    private var labelContent: some View {
        switch effectiveDisplayMode {
        case .standard:
            label(selection)
        case .compact:
            label(selection)
                .labelStyle(.iconOnly)
        }
    }

    /// Button style based on effective display mode.
    private var buttonStyle: GlassVisualStyle {
        switch effectiveDisplayMode {
        case .standard:
            .titleOnly
        case .compact:
            .iconOnly()
        }
    }
}

// MARK: - Convenience Initializers

extension GlassMenuPicker where Label == Option {
    /// Creates a toolbar menu picker with the same label for display and options.
    ///
    /// - Parameters:
    ///   - selection: A binding to the selected value.
    ///   - options: An array of available options.
    ///   - displayMode: The visual presentation mode. Default is `.standard`.
    ///   - label: A view builder for both the compact display and menu options.
    public init(
        selection: Binding<Value>,
        options: [Value],
        displayMode: MenuPickerDisplayMode = .standard,
        @ViewBuilder label: @escaping (Value) -> Label
    ) {
        self._selection = selection
        self.options = options
        self.displayMode = displayMode
        self.label = label
        self.optionLabel = label
    }
}

extension GlassMenuPicker where Value: CustomStringConvertible, Label == Text, Option == Text {
    /// Creates a toolbar menu picker using the value's description as label.
    ///
    /// - Parameters:
    ///   - selection: A binding to the selected value.
    ///   - options: An array of available options.
    ///   - displayMode: The visual presentation mode. Default is `.standard`.
    public init(
        selection: Binding<Value>,
        options: [Value],
        displayMode: MenuPickerDisplayMode = .standard
    ) {
        self._selection = selection
        self.options = options
        self.displayMode = displayMode
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
                GlassMenuPicker(selection: $selection, options: MenuPickerOption.allCases)
                    .background(.blue)
                    .padding()

                Text("Selected: \(selection.description)")
                    .font(.caption)
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .background(.red.gradient)
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
                GlassMenuPicker(
                    selection: $selection,
                    options: MenuPickerOption.allCases
                ) { tab in
                    Label(tab.description, systemImage: tab.icon)
                }
                .padding()

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
                .glassBar(
                    leading: {
                        GlassMenuPicker(
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
                            .buttonStyle(.glass())
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
                ForEach([GlassDensity.sparse, .regular, .compact, .dense], id: \.rawValue) { density in
                    VStack(spacing: 4) {
                        Text(densityName(density))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        GlassMenuPicker(
                            selection: $selection,
                            options: MenuPickerOption.allCases
                        ) { tab in
                            Label(tab.description, systemImage: tab.icon)
                        }
                        .glassDensity(density)
                        .padding()

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
    return Preview()
}

#Preview("Display Modes") {
    struct Preview: View {
        @State private var selection: MenuPickerOption = .home

        var body: some View {
            VStack(spacing: 32) {
                VStack(spacing: 8) {
                    Text("Standard Mode")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    GlassMenuPicker(
                        selection: $selection,
                        options: MenuPickerOption.allCases,
                        displayMode: .standard
                    ) { tab in
                        Label(tab.description, systemImage: tab.icon)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.primary.opacity(0.08), in: .capsule)
                }

                VStack(spacing: 8) {
                    Text("Compact Mode")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    GlassMenuPicker(
                        selection: $selection,
                        options: MenuPickerOption.allCases,
                        displayMode: .compact
                    ) { tab in
                        Label(tab.description, systemImage: tab.icon)
                    }
                    .padding(10)
                    .background(Color.primary.opacity(0.08), in: .circle)
                }

                Text("Selected: \(selection.description)")
                    .font(.subheadline)
            }
            .padding()
        }
    }
    return Preview()
}

#Preview("Compact on Edge") {
    struct Preview: View {
        @State private var selection: MenuPickerOption = .home
        @State private var selectedTab: Int = 0

        var body: some View {
            Color.blue.opacity(0.05)
                .ignoresSafeArea()
                .glassBar(
                    leading: {
                        GlassMenuPicker(
                            selection: $selection,
                            options: MenuPickerOption.allCases,
                            displayMode: .compact
                        ) { tab in
                            Label(tab.description, systemImage: tab.icon)
                        }
                    },
                    content: {
                        ForEach(0..<3, id: \.self) { index in
                            Button {
                                selectedTab = index
                            } label: {
                                Label("Tab \(index)", systemImage: "circle")
                            }
                            .buttonStyle(.glass())
                        }
                    }
                )
        }
    }
    return Preview()
}
