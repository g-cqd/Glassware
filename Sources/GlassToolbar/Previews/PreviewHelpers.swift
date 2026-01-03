//
//  PreviewHelpers.swift
//  GlassToolbar
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
    let density: ToolbarDensity

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
    let density: ToolbarDensity
    let style: ToolbarItemVisualStyle
    let paddingConfig: ToolbarPaddingConfiguration

    init(
        density: ToolbarDensity = .regular,
        style: ToolbarItemVisualStyle = .titleAndIcon(),
        paddingConfig: ToolbarPaddingConfiguration = .default
    ) {
        self.density = density
        self.style = style
        self.paddingConfig = paddingConfig
    }

    var body: some View {
        SampleContentView("Tap to Select Tabs")
            .glassToolbar(
                content: {
                    ForEach(PreviewTab.allCases, id: \.rawValue) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            Label(tab.title, systemImage: tab.systemImage)
                        }
                        .buttonStyle(.toolbarItem(style: style, isSelected: selectedTab == tab))
                    }
                }
            )
            .toolbarDensity(density)
            .toolbarPadding(paddingConfig)
    }
}

// MARK: - Button Style Grid

/// Grid showing button in different states.
struct ButtonStyleGrid: View {
    let intent: ToolbarItemIntent
    let density: ToolbarDensity

    init(intent: ToolbarItemIntent = .tab, density: ToolbarDensity = .regular) {
        self.intent = intent
        self.density = density
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title and Icon
            PreviewSection(title: "Title and Icon") {
                HStack(spacing: 12) {
                    buttonSample(style: .titleAndIcon(), isSelected: false)
                    buttonSample(style: .titleAndIcon(), isSelected: true)
                }
            }

            // Title Only
            PreviewSection(title: "Title Only") {
                HStack(spacing: 12) {
                    buttonSample(style: .titleOnly, isSelected: false)
                    buttonSample(style: .titleOnly, isSelected: true)
                }
            }

            // Icon Only
            PreviewSection(title: "Icon Only") {
                HStack(spacing: 12) {
                    buttonSample(style: .iconOnly(), isSelected: false)
                    buttonSample(style: .iconOnly(), isSelected: true)
                }
            }
        }
        .padding()
        .background(.background.secondary)
        .clipShape(.rect(cornerRadius: 12))
        .toolbarDensity(density)
    }

    @ViewBuilder
    private func buttonSample(style: ToolbarItemVisualStyle, isSelected: Bool) -> some View {
        VStack(spacing: 4) {
            Button {} label: {
                Label("Home", systemImage: "house")
            }
            .buttonStyle(.toolbarItem(intent: intent, style: style, isSelected: isSelected))


            Text(isSelected ? "Selected" : "Default")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }
}
