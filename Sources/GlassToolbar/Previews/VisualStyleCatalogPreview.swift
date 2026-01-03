//
//  VisualStyleCatalogPreview.swift
//  GlassToolbar
//
//  Previews demonstrating visual styles (titleAndIcon, titleOnly, iconOnly).
//

import SwiftUI

// MARK: - Style Comparison View

/// Shows all three visual styles side by side.
private struct VisualStyleComparisonView: View {
    let intent: ToolbarItemIntent
    @State private var selected: Int = 0

    var body: some View {
        VStack(spacing: 24) {
            // Title and Icon
            PreviewSection(title: "Title and Icon") {
                tabRow(style: .titleAndIcon())
            }

            // Title Only
            PreviewSection(title: "Title Only") {
                tabRow(style: .titleOnly)
            }

            // Icon Only
            PreviewSection(title: "Icon Only") {
                tabRow(style: .iconOnly())
            }
        }
        .padding()
    }

    @ViewBuilder
    private func tabRow(style: ToolbarItemVisualStyle) -> some View {
        HStack(spacing: 0) {
            ForEach(PreviewData.tabs.indices, id: \.self) { index in
                let tab = PreviewData.tabs[index]
                Button {
                    selected = index
                } label: {
                    Label(tab.title, systemImage: tab.systemImage)
                }
                .buttonStyle(.toolbarItem(intent: intent, style: style, isSelected: selected == index))
            }
        }
        .padding(3)

    }
}

// MARK: - Full Toolbar Style Preview

/// Shows a complete toolbar with a specific visual style.
private struct FullToolbarStylePreview: View {
    let style: ToolbarItemVisualStyle
    @State private var selectedTab: PreviewTab = .home

    var body: some View {
        SampleContentView(styleName, color: .purple.opacity(0.05))
            .glassToolbar(
                leading: {
                    Button {} label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                    .buttonStyle(.toolbarItem(style: .iconOnly()))
                },
                content: {
                    ForEach(PreviewTab.allCases, id: \.rawValue) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            Label(tab.title, systemImage: tab.systemImage)
                        }
                        .buttonStyle(.toolbarItem(style: style, isSelected: selectedTab == tab))
                    }
                },
                trailing: {
                    Button {} label: {
                        Label("Add", systemImage: "plus")
                    }
                    .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly()))
                }
            )
            .overlay(alignment: .topLeading) {
                Text(styleName)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)

                    .padding()
            }
    }

    private var styleName: String {
        switch style {
        case .titleOnly: "Title Only"
        case .titleAndIcon: "Title and Icon"
        case .iconOnly: "Icon Only"
        }
    }
}

// MARK: - Action Button Styles

/// Shows action buttons in different visual styles.
private struct ActionButtonStylesView: View {
    var body: some View {
        VStack(spacing: 24) {
            PreviewSection(title: "Action - Icon Only") {
                HStack(spacing: 12) {
                    ForEach(PreviewData.actions.indices, id: \.self) { index in
                        let action = PreviewData.actions[index]
                        Button {} label: {
                            Label(action.title, systemImage: action.systemImage)
                        }
                        .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly()))
                    }
                }
            }

            PreviewSection(title: "Action - Title Only") {
                HStack(spacing: 12) {
                    ForEach(PreviewData.actions.indices, id: \.self) { index in
                        let action = PreviewData.actions[index]
                        Button {} label: {
                            Label(action.title, systemImage: action.systemImage)
                        }
                        .buttonStyle(.toolbarItem(intent: .action, style: .titleOnly))
                    }
                }
            }

            PreviewSection(title: "Action - Title and Icon") {
                HStack(spacing: 12) {
                    ForEach(PreviewData.actions.prefix(3).indices, id: \.self) { index in
                        let action = PreviewData.actions[index]
                        Button {} label: {
                            Label(action.title, systemImage: action.systemImage)
                        }
                        .buttonStyle(.toolbarItem(intent: .action, style: .titleAndIcon()))
                    }
                }
            }
        }
        .padding()
    }
}

// MARK: - Previews

#Preview("Visual Style Catalog - Tabs") {
    ScrollView {
        VisualStyleComparisonView(intent: .tab)
    }
}

#Preview("Visual Style Catalog - Actions") {
    ScrollView {
        ActionButtonStylesView()
    }
}

#Preview("Title and Icon") {
    FullToolbarStylePreview(style: .titleAndIcon())
}

#Preview("Title Only") {
    FullToolbarStylePreview(style: .titleOnly)
}

#Preview("Icon Only") {
    FullToolbarStylePreview(style: .iconOnly())
}

#Preview("Tab vs Action Intent") {
    VStack(spacing: 32) {
        PreviewSection(title: "Tab Intent (Selection State)") {
            HStack(spacing: 0) {
                Button {} label: { Label("Home", systemImage: "house") }
                    .buttonStyle(.toolbarItem(intent: .tab, isSelected: true))
                Button {} label: { Label("Search", systemImage: "magnifyingglass") }
                    .buttonStyle(.toolbarItem(intent: .tab, isSelected: false))
            }
            .padding(3)

        }

        PreviewSection(title: "Action Intent (Press Feedback)") {
            HStack(spacing: 12) {
                Button {} label: { Label("Share", systemImage: "square.and.arrow.up") }
                    .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly()))
                Button {} label: { Label("Add", systemImage: "plus") }
                    .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly()))
                Button {} label: { Label("Edit", systemImage: "pencil") }
                    .buttonStyle(.toolbarItem(intent: .action, style: .titleAndIcon()))
            }
        }
    }
    .padding()
}

#Preview("Custom Icons") {
    VStack(spacing: 24) {
        PreviewSection(title: "Custom System Image") {
            HStack(spacing: 12) {
                Button {} label: { Label("Photos", systemImage: "photo") }
                    .buttonStyle(.toolbarItem(style: .iconOnly(systemImage: "photo.stack")))
                Button {} label: { Label("Camera", systemImage: "camera") }
                    .buttonStyle(.toolbarItem(style: .iconOnly(systemImage: "camera.fill")))
            }
        }

        PreviewSection(title: "Title and Custom Icon") {
            HStack(spacing: 12) {
                Button {} label: { Label("Favorites", systemImage: "star") }
                    .buttonStyle(.toolbarItem(style: .titleAndIcon(systemImage: "star.fill")))
                Button {} label: { Label("Bookmarks", systemImage: "bookmark") }
                    .buttonStyle(.toolbarItem(style: .titleAndIcon(systemImage: "bookmark.fill")))
            }
        }
    }
    .padding()
}

// MARK: - Dark Mode Previews

#Preview("Dark Mode - Title and Icon") {
    FullToolbarStylePreview(style: .titleAndIcon())
        .preferredColorScheme(.dark)
}

#Preview("Dark Mode - Icon Only") {
    FullToolbarStylePreview(style: .iconOnly())
        .preferredColorScheme(.dark)
}

#Preview("Light vs Dark Comparison") {
    VStack(spacing: 0) {
        FullToolbarStylePreview(style: .titleAndIcon())
            .preferredColorScheme(.light)
            .frame(height: 300)

        Divider()

        FullToolbarStylePreview(style: .titleAndIcon())
            .preferredColorScheme(.dark)
            .frame(height: 300)
    }
}

#Preview("Glass Material - Light") {
    GlassMaterialComparisonPreview()
        .preferredColorScheme(.light)
}

#Preview("Glass Material - Dark") {
    GlassMaterialComparisonPreview()
        .preferredColorScheme(.dark)
}

// MARK: - Glass Material Comparison

/// Shows how glass material appears on different backgrounds.
private struct GlassMaterialComparisonPreview: View {
    @State private var selectedTab: PreviewTab = .home

    var body: some View {
        VStack(spacing: 0) {
            // Light background
            backgroundSection(color: .white, title: "Light Background")

            // Dark background
            backgroundSection(color: .black, title: "Dark Background")

            // Colorful background
            backgroundSection(color: .blue, title: "Colorful Background")
        }
    }

    @ViewBuilder
    private func backgroundSection(color: Color, title: String) -> some View {
        ZStack(alignment: .bottom) {
            color.ignoresSafeArea()

            VStack(spacing: 8) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(color == .white ? .black : .white)

                HStack(spacing: 0) {
                    ForEach(PreviewTab.allCases, id: \.rawValue) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            Label(tab.title, systemImage: tab.systemImage)
                        }
                        .buttonStyle(.toolbarItem(isSelected: selectedTab == tab))
                    }
                }
                .padding(3)

            }
            .padding(.bottom, 24)
        }
        .frame(height: 120)
    }
}
