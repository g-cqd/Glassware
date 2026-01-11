//
//  PaddingConfigurationPreview.swift
//  Glassware
//
//  Previews demonstrating padding configurations.
//

import SwiftUI

// MARK: - Padding Preview View

/// Shows a toolbar with a specific padding configuration.
private struct PaddingPreview: View {
    let config: GlassPaddingConfiguration
    let title: String
    @State private var selectedTab: PreviewTab = .home

    var body: some View {
        SampleContentView(title, color: .orange.opacity(0.05))
            .glassBar(
                content: {
                    ForEach(PreviewTab.allCases, id: \.rawValue) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            Label(tab.title, systemImage: tab.systemImage)
                        }
                        .buttonStyle(.glass())
                    }
                }
            )
            .glassPadding(config)
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption.weight(.semibold))
                    Text(configDescription)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)

                .padding()
            }
    }

    private var configDescription: String {
        var parts: [String] = []

        if config.additionalPadding < 0 {
            parts.append("Density-based padding")
        } else {
            parts.append("Additional: \(Int(config.additionalPadding))pt")
        }

        if config.ignoresSafeArea {
            parts.append("Ignores safe area")
        } else {
            parts.append("Respects safe area")
        }

        parts.append("External: \(Int(config.externalPadding))pt")

        return parts.joined(separator: " | ")
    }
}

// MARK: - Configuration Comparison View

/// Compares all preset padding configurations.
private struct PaddingComparisonView: View {
    var body: some View {
        VStack(spacing: 24) {
            configRow(
                title: "Default",
                config: .default,
                description: "Uses density-based bottom padding, respects safe area"
            )

            configRow(
                title: "Tight",
                config: .tight,
                description: "Zero additional padding, respects safe area"
            )

            configRow(
                title: "Edge to Edge",
                config: .edgeToEdge,
                description: "Zero padding, ignores safe area (home indicator)"
            )

            configRow(
                title: "Custom (24pt)",
                config: GlassPaddingConfiguration(additionalPadding: 24),
                description: "Custom 24pt additional padding"
            )
        }
        .padding()
    }

    @ViewBuilder
    private func configRow(
        title: String,
        config: GlassPaddingConfiguration,
        description: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Group {
                    if config.ignoresSafeArea {
                        Image(systemName: "rectangle.dashed")
                    } else {
                        Image(systemName: "rectangle")
                    }
                }
                .foregroundStyle(.secondary)
            }

            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)

            // Visual representation
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.background.secondary)
                    .frame(height: 80)

                // Safe area indicator
                if !config.ignoresSafeArea {
                    Rectangle()
                        .fill(.blue.opacity(0.1))
                        .frame(height: 34) // Approximate home indicator height
                        .overlay(alignment: .top) {
                            Text("Safe Area")
                                .font(.caption2)
                                .foregroundStyle(.blue)
                                .padding(.top, 4)
                        }
                }

                // Toolbar representation
                let bottomOffset = config.ignoresSafeArea ? 0 : 34
                let padding = config.additionalPadding < 0 ? 24 : config.additionalPadding

                RoundedRectangle(cornerRadius: 20)
                    .fill(.primary.opacity(0.2))
                    .frame(width: 200, height: 44)
                    .padding(.bottom, CGFloat(bottomOffset) + padding)
            }
            .clipShape(.rect(cornerRadius: 12))
        }
        .padding()
        .background(.background.tertiary, in: .rect(cornerRadius: 12))
    }
}

// MARK: - Custom Padding Builder

/// Interactive preview for building custom padding configurations.
private struct CustomPaddingBuilder: View {
    @State private var additionalPadding: CGFloat = 0
    @State private var ignoresSafeArea: Bool = false
    @State private var externalPadding: CGFloat = 16
    @State private var selectedTab: PreviewTab = .home

    private var config: GlassPaddingConfiguration {
        GlassPaddingConfiguration(
            additionalPadding: additionalPadding,
            ignoresSafeArea: ignoresSafeArea,
            externalPadding: externalPadding
        )
    }

    var body: some View {
        SampleContentView("Custom Configuration", color: .indigo.opacity(0.05))
            .glassBar(
                content: {
                    ForEach(PreviewTab.allCases, id: \.rawValue) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            Label(tab.title, systemImage: tab.systemImage)
                        }
                        .buttonStyle(.glass())
                    }
                }
            )
            .glassPadding(config)
            .safeAreaInset(edge: .top) {
                VStack(spacing: 12) {
                    Slider(value: $additionalPadding, in: 0...48, step: 4) {
                        Text("Additional Padding")
                    } minimumValueLabel: {
                        Text("0")
                    } maximumValueLabel: {
                        Text("48")
                    }

                    Slider(value: $externalPadding, in: 0...32, step: 4) {
                        Text("External Padding")
                    } minimumValueLabel: {
                        Text("0")
                    } maximumValueLabel: {
                        Text("32")
                    }

                    Toggle("Ignore Safe Area", isOn: $ignoresSafeArea)
                }
                .padding()
                
            }
    }
}

// MARK: - Previews

#Preview("Default Padding") {
    PaddingPreview(config: .default, title: "Default")
}

#Preview("Tight Padding") {
    PaddingPreview(config: .tight, title: "Tight")
}

#Preview("Edge to Edge") {
    PaddingPreview(config: .edgeToEdge, title: "Edge to Edge")
}

#Preview("Padding Comparison") {
    ScrollView {
        PaddingComparisonView()
    }
}

#Preview("Custom Padding Builder") {
    CustomPaddingBuilder()
}

#Preview("Density + Padding Interaction") {
    VStack(spacing: 0) {
        PaddingPreview(config: .default, title: "Default + Regular Density")
            .glassDensity(.regular)
            .frame(height: 300)

        Divider()

        PaddingPreview(config: .default, title: "Default + Dense Density")
            .glassDensity(.dense)
            .frame(height: 300)
    }
}
