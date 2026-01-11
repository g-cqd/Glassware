//
//  DensityCatalogPreview.swift
//  Glassware
//
//  Previews demonstrating all density levels.
//

import SwiftUI

// MARK: - Density Comparison View

/// Shows a toolbar at a specific density with metrics overlay.
private struct DensityPreviewRow: View {
    let density: GlassDensity
    @State private var selectedTab: PreviewTab = .home

    private var metrics: GlassMetrics {
        GlassMetrics(density: density)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with density name and key metrics
            HStack {
                Text(densityName)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("Tap: \(Int(metrics.minimumTapTarget))pt")
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                Text("Edge: \(Int(metrics.edgePadding))pt")
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }

            // Toolbar preview
            HStack(spacing: 0) {
                ForEach(PreviewTab.allCases, id: \.rawValue) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        Label(tab.title, systemImage: tab.systemImage)
                    }
                    .buttonStyle(.glass())
                }
            }
            .padding(metrics.containerPadding)

            .glassDensity(density)
        }
        .padding(.horizontal)
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

// MARK: - Full Toolbar Density Preview

/// Shows a complete toolbar at each density level.
private struct FullGlassDensityPreview: View {
    let density: GlassDensity
    @State private var selectedTab: PreviewTab = .home

    var body: some View {
        SampleContentView(densityName, color: .blue.opacity(0.05))
            .glassBar(
                leading: {
                    Button {} label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                    .buttonStyle(.glass(style: .iconOnly()))
                },
                content: {
                    ForEach(PreviewTab.allCases, id: \.rawValue) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            Label(tab.title, systemImage: tab.systemImage)
                        }
                        .buttonStyle(.glass())
                    }
                },
                trailing: {
                    Button {} label: {
                        Label("Add", systemImage: "plus")
                    }
                    .buttonStyle(.glass(style: .iconOnly()))
                }
            )
            .glassDensity(density)
            .overlay(alignment: .topLeading) {
                DensityBadge(density: density)
                    .padding()
            }
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

// MARK: - Previews

#Preview("Density Catalog") {
    ScrollView {
        VStack(spacing: 24) {
            ForEach(GlassDensity.allCases, id: \.rawValue) { density in
                DensityPreviewRow(density: density)
            }
        }
        .padding(.vertical)
    }
    .background(.background)
}

#Preview("Extra Sparse") {
    FullGlassDensityPreview(density: .extraSparse)
}

#Preview("Sparse") {
    FullGlassDensityPreview(density: .sparse)
}

#Preview("Regular") {
    FullGlassDensityPreview(density: .regular)
}

#Preview("Compact") {
    FullGlassDensityPreview(density: .compact)
}

#Preview("Dense") {
    FullGlassDensityPreview(density: .dense)
}

#Preview("Extra Dense") {
    FullGlassDensityPreview(density: .extraDense)
}

#Preview("Density Metrics Table") {
    List {
        ForEach(GlassDensity.allCases, id: \.rawValue) { density in
            let metrics = GlassMetrics(density: density)
            HStack {
                Text(densityLabel(density))
                    .font(.headline)
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Tap: \(Int(metrics.minimumTapTarget))pt")
                    Text("Edge: \(Int(metrics.edgePadding))pt")
                    Text("Container: \(Int(metrics.containerSpacing))pt")
                }
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
    }
}

private func densityLabel(_ density: GlassDensity) -> String {
    switch density {
    case .extraSparse: "Extra Sparse"
    case .sparse: "Sparse"
    case .regular: "Regular"
    case .compact: "Compact"
    case .dense: "Dense"
    case .extraDense: "Extra Dense"
    }
}

// MARK: - Dark Mode Previews

#Preview("Dark Mode - Density Catalog") {
    ScrollView {
        VStack(spacing: 24) {
            ForEach(GlassDensity.allCases, id: \.rawValue) { density in
                DensityPreviewRow(density: density)
            }
        }
        .padding(.vertical)
    }
    .background(.background)
    .preferredColorScheme(.dark)
}

#Preview("Dark Mode - Regular Density") {
    FullGlassDensityPreview(density: .regular)
        .preferredColorScheme(.dark)
}

#Preview("Dark Mode - Compact Density") {
    FullGlassDensityPreview(density: .compact)
        .preferredColorScheme(.dark)
}
