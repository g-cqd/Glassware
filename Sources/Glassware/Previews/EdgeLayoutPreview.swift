//
//  EdgeLayoutPreview.swift
//  Glassware
//
//  Previews demonstrating toolbar at all edge positions.
//

import SwiftUI

// MARK: - Edge Preview View

/// Shows a toolbar at a specific edge.
private struct EdgePreview: View {
    let edge: GlassEdge
    @State private var selectedTab: PreviewTab = .home

    var body: some View {
        SampleContentView(edgeName, color: .green.opacity(0.05))
            .glassBar(
                edge: edge,
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
            .overlay(alignment: .center) {
                Text(edgeName)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)

            }
    }

    private var edgeName: String {
        switch edge {
        case .top: "Top Edge"
        case .bottom: "Bottom Edge"
        case .leading: "Leading Edge"
        case .trailing: "Trailing Edge"
        }
    }
}

// MARK: - Edge Comparison View

/// Shows all edges in a grid for comparison.
private struct AllEdgesComparisonView: View {
    var body: some View {
        VStack(spacing: 24) {
            // Horizontal edges (top/bottom)
            PreviewSection(title: "Horizontal Edges") {
                VStack(spacing: 16) {
                    edgeRow(edge: .top)
                    edgeRow(edge: .bottom)
                }
            }

            // Vertical edges (leading/trailing)
            PreviewSection(title: "Vertical Edges") {
                HStack(spacing: 16) {
                    edgeColumn(edge: .leading)
                    edgeColumn(edge: .trailing)
                }
            }
        }
        .padding()
    }

    @ViewBuilder
    private func edgeRow(edge: GlassEdge) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(edge == .top ? "Top" : "Bottom")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 0) {
                Button {} label: {
                    Label("Settings", systemImage: "gearshape")
                }
                .buttonStyle(.glass(style: .iconOnly()))

                Spacer()

                ForEach(PreviewTab.allCases, id: \.rawValue) { tab in
                    Button {} label: {
                        Label(tab.title, systemImage: tab.systemImage)
                    }
                    .buttonStyle(.glass())
                }

                Spacer()

                Button {} label: {
                    Label("Add", systemImage: "plus")
                }
                .buttonStyle(.glass(style: .iconOnly()))
            }
            .padding(3)

        }
    }

    @ViewBuilder
    private func edgeColumn(edge: GlassEdge) -> some View {
        VStack(alignment: .center, spacing: 4) {
            Text(edge == .leading ? "Leading" : "Trailing")
                .font(.caption)
                .foregroundStyle(.secondary)

            VStack(spacing: 0) {
                Button {} label: {
                    Label("Settings", systemImage: "gearshape")
                }
                .buttonStyle(.glass(style: .iconOnly()))

                Spacer()

                ForEach(PreviewTab.allCases, id: \.rawValue) { tab in
                    Button {} label: {
                        Label(tab.title, systemImage: tab.systemImage)
                    }
                    .buttonStyle(.glass(style: .iconOnly()))
                }

                Spacer()

                Button {} label: {
                    Label("Add", systemImage: "plus")
                }
                .buttonStyle(.glass(style: .iconOnly()))
            }
            .padding(3)
            .frame(height: 200)

        }
    }
}

// MARK: - Layout Direction View

/// Demonstrates how layout direction changes per edge.
private struct LayoutDirectionView: View {
    var body: some View {
        VStack(spacing: 24) {
            PreviewSection(title: "Horizontal Layout (Top/Bottom)") {
                VStack(spacing: 8) {
                    Text("Items flow left-to-right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    HStack(spacing: 8) {
                        ForEach(1...4, id: \.self) { n in
                            Text("\(n)")
                                .font(.headline)
                                .frame(width: 44, height: 44)
                                .background(.blue.opacity(0.2), in: .circle)
                        }
                    }
                }
            }

            PreviewSection(title: "Vertical Layout (Leading/Trailing)") {
                VStack(spacing: 8) {
                    Text("Items flow top-to-bottom")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    VStack(spacing: 8) {
                        ForEach(1...4, id: \.self) { n in
                            Text("\(n)")
                                .font(.headline)
                                .frame(width: 44, height: 44)
                                .background(.green.opacity(0.2), in: .circle)
                        }
                    }
                }
            }
        }
        .padding()
    }
}

// MARK: - Previews

#Preview("Bottom Edge (Default)") {
    EdgePreview(edge: .bottom)
}

#Preview("Top Edge") {
    EdgePreview(edge: .top)
}

#Preview("Leading Edge") {
    EdgePreview(edge: .leading)
}

#Preview("Trailing Edge") {
    EdgePreview(edge: .trailing)
}

#Preview("Edge Comparison") {
    ScrollView {
        AllEdgesComparisonView()
    }
}

#Preview("Layout Direction") {
    LayoutDirectionView()
}

#Preview("Horizontal vs Vertical", traits: .landscapeLeft) {
    HStack(spacing: 0) {
        EdgePreview(edge: .bottom)
        EdgePreview(edge: .trailing)
    }
}
