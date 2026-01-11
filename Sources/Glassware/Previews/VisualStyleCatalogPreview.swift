//
//  VisualStyleCatalogPreview.swift
//  Glassware
//
//  Previews demonstrating visual styles (titleAndIcon, titleOnly, iconOnly).
//

import SwiftUI

// MARK: - Style Comparison View

/// Shows all three visual styles side by side.
private struct VisualStyleComparisonView: View {
    let prominent: Bool

    var body: some View {
        VStack(spacing: 24) {
            // Title and Icon
            PreviewSection(title: "Title and Icon") {
                buttonRow(style: .titleAndIcon())
            }

            // Title Only
            PreviewSection(title: "Title Only") {
                buttonRow(style: .titleOnly)
            }

            // Icon Only
            PreviewSection(title: "Icon Only") {
                buttonRow(style: .iconOnly())
            }
        }
        .padding()
    }

    @ViewBuilder
    private func buttonRow(style: GlassVisualStyle) -> some View {
        HStack(spacing: 12) {
            ForEach(Array(PreviewData.tabs.enumerated()), id: \.offset) { _, tab in
                if prominent {
                    Button {} label: {
                        Label(tab.title, systemImage: tab.systemImage)
                    }
                    .buttonStyle(.glassProminent(style: style))
                } else {
                    Button {} label: {
                        Label(tab.title, systemImage: tab.systemImage)
                    }
                    .buttonStyle(.glass(style: style))
                }
            }
        }
    }
}

// MARK: - Full Toolbar Style Preview

/// Shows a complete toolbar with a specific visual style.
private struct FullToolbarStylePreview: View {
    let style: GlassVisualStyle

    var body: some View {
        SampleContentView(styleName, color: .purple.opacity(0.05))
            .glassBar(
                leading: {
                    Button {} label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                    .buttonStyle(.glass(style: .iconOnly()))
                },
                content: {
                    ForEach(PreviewTab.allCases, id: \.rawValue) { tab in
                        Button {} label: {
                            Label(tab.title, systemImage: tab.systemImage)
                        }
                        .buttonStyle(.glass(style: style))
                    }
                },
                trailing: {
                    Button {} label: {
                        Label("Add", systemImage: "plus")
                    }
                    .buttonStyle(.glassProminent(style: .iconOnly()))
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

// MARK: - Button States Preview

/// Shows buttons in different states (normal, disabled, destructive).
private struct ButtonStatesView: View {
    var body: some View {
        VStack(spacing: 24) {
            PreviewSection(title: "Normal") {
                HStack(spacing: 12) {
                    Button {} label: { Label("Share", systemImage: "square.and.arrow.up") }
                        .buttonStyle(.glass(style: .iconOnly()))
                    Button {} label: { Label("Edit", systemImage: "pencil") }
                        .buttonStyle(.glass(style: .iconOnly()))
                    Button {} label: { Label("Save", systemImage: "checkmark") }
                        .buttonStyle(.glass(style: .titleOnly))
                }
            }

            PreviewSection(title: "Prominent") {
                HStack(spacing: 12) {
                    Button {} label: { Label("Add", systemImage: "plus") }
                        .buttonStyle(.glassProminent(style: .iconOnly()))
                    Button {} label: { Label("Create", systemImage: "plus.circle") }
                        .buttonStyle(.glassProminent(style: .titleAndIcon()))
                }
            }

            PreviewSection(title: "Destructive") {
                HStack(spacing: 12) {
                    Button(role: .destructive) {} label: { Label("Delete", systemImage: "trash") }
                        .buttonStyle(.glass(style: .iconOnly()))
                    Button(role: .destructive) {} label: { Label("Remove", systemImage: "minus.circle") }
                        .buttonStyle(.glass(style: .titleAndIcon()))
                    Button(role: .destructive) {} label: { Label("Clear All", systemImage: "trash") }
                        .buttonStyle(.glassProminent(style: .titleOnly))
                }
            }

            PreviewSection(title: "Disabled") {
                HStack(spacing: 12) {
                    Button {} label: { Label("Share", systemImage: "square.and.arrow.up") }
                        .buttonStyle(.glass(style: .iconOnly()))
                        .disabled(true)
                    Button {} label: { Label("Edit", systemImage: "pencil") }
                        .buttonStyle(.glassProminent(style: .iconOnly()))
                        .disabled(true)
                }
            }
        }
        .padding()
    }
}

// MARK: - Previews

#Preview("Visual Styles - Standard") {
    ScrollView {
        VisualStyleComparisonView(prominent: false)
    }
}

#Preview("Visual Styles - Prominent") {
    ScrollView {
        VisualStyleComparisonView(prominent: true)
    }
}

#Preview("Button States") {
    ScrollView {
        ButtonStatesView()
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

#Preview("Standard vs Prominent") {
    VStack(spacing: 32) {
        PreviewSection(title: "Standard (Subtle)") {
            HStack(spacing: 12) {
                Button {} label: { Label("Share", systemImage: "square.and.arrow.up") }
                    .buttonStyle(.glass(style: .iconOnly()))
                Button {} label: { Label("Add", systemImage: "plus") }
                    .buttonStyle(.glass(style: .iconOnly()))
                Button {} label: { Label("Edit", systemImage: "pencil") }
                    .buttonStyle(.glass(style: .titleAndIcon()))
            }
        }

        PreviewSection(title: "Prominent (Visible Background)") {
            HStack(spacing: 12) {
                Button {} label: { Label("Share", systemImage: "square.and.arrow.up") }
                    .buttonStyle(.glassProminent(style: .iconOnly()))
                Button {} label: { Label("Add", systemImage: "plus") }
                    .buttonStyle(.glassProminent(style: .iconOnly()))
                Button {} label: { Label("Edit", systemImage: "pencil") }
                    .buttonStyle(.glassProminent(style: .titleAndIcon()))
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
                    .buttonStyle(.glass(style: .iconOnly(systemImage: "photo.stack")))
                Button {} label: { Label("Camera", systemImage: "camera") }
                    .buttonStyle(.glass(style: .iconOnly(systemImage: "camera.fill")))
            }
        }

        PreviewSection(title: "Title and Custom Icon") {
            HStack(spacing: 12) {
                Button {} label: { Label("Favorites", systemImage: "star") }
                    .buttonStyle(.glass(style: .titleAndIcon(systemImage: "star.fill")))
                Button {} label: { Label("Bookmarks", systemImage: "bookmark") }
                    .buttonStyle(.glass(style: .titleAndIcon(systemImage: "bookmark.fill")))
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

                HStack(spacing: 12) {
                    ForEach(PreviewTab.allCases, id: \.rawValue) { tab in
                        Button {} label: {
                            Label(tab.title, systemImage: tab.systemImage)
                        }
                        .buttonStyle(.glass())
                    }
                }
            }
            .padding(.bottom, 24)
        }
        .frame(height: 120)
    }
}
