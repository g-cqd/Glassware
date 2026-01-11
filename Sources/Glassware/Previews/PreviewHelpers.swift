//
//  PreviewHelpers.swift
//  Glassware
//
//  Reusable preview components and mock data.
//

import SwiftUI

// MARK: - Preview Data

enum PreviewData {
    static let tabs: [(title: String, systemImage: String)] = [
        ("Home", "house"),
        ("Search", "magnifyingglass"),
        ("Profile", "person")
    ]

    static let extendedTabs: [(title: String, systemImage: String)] = [
        ("Dashboard", "gauge"),
        ("History", "clock"),
        ("Garage", "car"),
        ("Stats", "chart.bar"),
        ("Settings", "gearshape")
    ]

    static let actions: [(title: String, systemImage: String)] = [
        ("Add", "plus"),
        ("Share", "square.and.arrow.up"),
        ("Edit", "pencil"),
        ("Delete", "trash")
    ]
}

// MARK: - Preview Tab Enum

enum PreviewTab: Int, CaseIterable, Hashable {
    case home = 0
    case search = 1
    case profile = 2

    var title: String {
        switch self {
        case .home: "Home"
        case .search: "Search"
        case .profile: "Profile"
        }
    }

    var systemImage: String {
        switch self {
        case .home: "house"
        case .search: "magnifyingglass"
        case .profile: "person"
        }
    }
}

// MARK: - Preview Container

/// Wrapper view for organizing preview sections with titles.
struct PreviewSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)
            content()
        }
    }
}

// MARK: - Sample Content View

/// Placeholder content view for toolbar previews.
struct SampleContentView: View {
    let title: String
    let color: Color

    init(_ title: String = "Content", color: Color = .blue.opacity(0.1)) {
        self.title = title
        self.color = color
    }

    var body: some View {
        ZStack {
            color
            VStack(spacing: 8) {
                Image(systemName: "rectangle.3.group")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Density Badge

/// Badge showing the current density name.
struct DensityBadge: View {
    let density: GlassDensity

    var body: some View {
        Text(densityName)
            .font(.caption2.weight(.medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)

    }

    private var densityName: String {
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

// MARK: - Interactive Tab Toolbar Preview

/// Reusable interactive toolbar with tab selection.
struct InteractiveTabToolbar: View {
    @State private var selectedTab: PreviewTab = .home
    let density: GlassDensity
    let style: GlassVisualStyle
    let paddingConfig: GlassPaddingConfiguration

    init(
        density: GlassDensity = .regular,
        style: GlassVisualStyle = .titleAndIcon(),
        paddingConfig: GlassPaddingConfiguration = .default
    ) {
        self.density = density
        self.style = style
        self.paddingConfig = paddingConfig
    }

    var body: some View {
        SampleContentView("Tap to Select Tabs")
            .glassBar(
                content: {
                    ForEach(PreviewTab.allCases, id: \.rawValue) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            Label(tab.title, systemImage: tab.systemImage)
                        }
                        .buttonStyle(.glass(style: style))
                    }
                }
            )
            .glassDensity(density)
            .glassPadding(paddingConfig)
    }
}

// MARK: - Button Style Grid

/// Grid showing button styles in different configurations.
struct ButtonStyleGrid: View {
    let prominent: Bool
    let density: GlassDensity

    init(prominent: Bool = false, density: GlassDensity = .regular) {
        self.prominent = prominent
        self.density = density
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title and Icon
            PreviewSection(title: "Title and Icon") {
                HStack(spacing: 12) {
                    buttonSample(style: .titleAndIcon(), role: nil)
                    buttonSample(style: .titleAndIcon(), role: .destructive)
                }
            }

            // Title Only
            PreviewSection(title: "Title Only") {
                HStack(spacing: 12) {
                    buttonSample(style: .titleOnly, role: nil)
                    buttonSample(style: .titleOnly, role: .destructive)
                }
            }

            // Icon Only
            PreviewSection(title: "Icon Only") {
                HStack(spacing: 12) {
                    buttonSample(style: .iconOnly(), role: nil)
                    buttonSample(style: .iconOnly(), role: .destructive)
                }
            }

            // Disabled State
            PreviewSection(title: "Disabled") {
                HStack(spacing: 12) {
                    buttonSample(style: .titleAndIcon(), role: nil)
                        .disabled(true)
                    buttonSample(style: .iconOnly(), role: nil)
                        .disabled(true)
                }
            }
        }
        .padding()
        .background(.background.secondary)
        .clipShape(.rect(cornerRadius: 12))
        .glassDensity(density)
    }

    @ViewBuilder
    private func buttonSample(style: GlassVisualStyle, role: ButtonRole?) -> some View {
        VStack(spacing: 4) {
            Button(role: role) {} label: {
                Label("Home", systemImage: "house")
            }
            .buttonStyle(prominent ? AnyButtonStyle(.glassProminent(style: style)) : AnyButtonStyle(.glass(style: style)))

            Text(role == .destructive ? "Destructive" : "Default")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }
}

/// Type-erased button style wrapper.
private struct AnyButtonStyle: ButtonStyle {
    private let _makeBody: (Configuration) -> AnyView

    init<S: ButtonStyle>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }

    func makeBody(configuration: Configuration) -> some View {
        _makeBody(configuration)
    }
}
