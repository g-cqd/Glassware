//
//  AccessibilityPreview.swift
//  GlassToolbar
//
//  Previews demonstrating accessibility features.
//

import SwiftUI

// MARK: - Dynamic Type Preview

/// Shows toolbar at different Dynamic Type sizes.
private struct DynamicTypePreview: View {
    @State private var selectedTab: PreviewTab = .home

    var body: some View {
        VStack(spacing: 0) {
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
        .background(.ultraThinMaterial, in: .capsule)
    }
}

// MARK: - Tap Target Visualization

/// Visualizes minimum tap target sizes.
private struct TapTargetVisualization: View {
    let density: ToolbarDensity

    private var metrics: ToolbarMetrics {
        ToolbarMetrics(density: density)
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(densityName)
                .font(.headline)

            ZStack {
                // Tap target area
                RoundedRectangle(cornerRadius: 12)
                    .fill(.blue.opacity(0.1))
                    .frame(width: metrics.minimumTapTarget, height: metrics.minimumTapTarget)

                // Button representation
                Image(systemName: "house")
                    .imageScale(metrics.imageScale)
                    .foregroundStyle(.primary)
            }

            VStack(spacing: 4) {
                Text("Tap Target: \(Int(metrics.minimumTapTarget))pt")
                    .font(.caption.monospaced())

                if metrics.minimumTapTarget < 44 {
                    Label("Below 44pt guideline", systemImage: "exclamationmark.triangle")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                } else {
                    Label("Meets 44pt guideline", systemImage: "checkmark.circle")
                        .font(.caption2)
                        .foregroundStyle(.green)
                }
            }
        }
        .padding()
        .background(.background.secondary, in: .rect(cornerRadius: 12))
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

// MARK: - Accessibility Safe Density

/// Demonstrates accessibility-safe density adjustment.
private struct AccessibilitySafeDensityPreview: View {
    @State private var selectedDensity: ToolbarDensity = .dense
    @State private var isAccessibilityEnabled: Bool = true

    private var effectiveDensity: ToolbarDensity {
        selectedDensity.accessibilitySafe(isAccessibilityEnabled: isAccessibilityEnabled)
    }

    var body: some View {
        VStack(spacing: 24) {
            Toggle("Accessibility Mode", isOn: $isAccessibilityEnabled)
                .padding(.horizontal)

            Picker("Density", selection: $selectedDensity) {
                ForEach(ToolbarDensity.allCases, id: \.rawValue) { density in
                    Text(densityName(density)).tag(density)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            VStack(spacing: 8) {
                Text("Requested: \(densityName(selectedDensity))")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("Effective: \(densityName(effectiveDensity))")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(selectedDensity != effectiveDensity ? .orange : .primary)

                if selectedDensity != effectiveDensity {
                    Text("Upgraded for accessibility")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }

            DynamicTypePreview()
                .toolbarDensity(effectiveDensity)
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

// MARK: - Color Contrast Preview

/// Shows button states with their color contrast.
private struct ColorContrastPreview: View {
    var body: some View {
        VStack(spacing: 24) {
            PreviewSection(title: "Tab States") {
                HStack(spacing: 16) {
                    stateColumn(title: "Unselected", isSelected: false)
                    stateColumn(title: "Selected", isSelected: true)
                }
            }

            PreviewSection(title: "Action State") {
                Button {} label: {
                    Label("Action", systemImage: "plus")
                }
                .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly()))
                .background(.ultraThinMaterial, in: .circle)
            }

            PreviewSection(title: "Disabled State") {
                Button {} label: {
                    Label("Disabled", systemImage: "xmark")
                }
                .buttonStyle(.toolbarItem(style: .iconOnly()))
                .disabled(true)
                .background(.ultraThinMaterial, in: .circle)
            }
        }
        .padding()
    }

    @ViewBuilder
    private func stateColumn(title: String, isSelected: Bool) -> some View {
        VStack(spacing: 8) {
            Button {} label: {
                Label("Tab", systemImage: "house")
            }
            .buttonStyle(.toolbarItem(isSelected: isSelected))
            .background(.ultraThinMaterial, in: .capsule)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(isSelected ? ".primary" : ".secondary")
                .font(.caption2.monospaced())
                .foregroundStyle(.tertiary)
        }
    }
}

// MARK: - VoiceOver Labels Preview

/// Demonstrates accessibility labels and hints.
private struct VoiceOverPreview: View {
    @State private var selectedTab: PreviewTab = .home

    var body: some View {
        VStack(spacing: 24) {
            Text("VoiceOver Support")
                .font(.headline)

            VStack(alignment: .leading, spacing: 16) {
                accessibilityRow(
                    title: "Tab Button (Selected)",
                    traits: ".isSelected",
                    hint: "Currently selected"
                )

                accessibilityRow(
                    title: "Tab Button (Unselected)",
                    traits: "none",
                    hint: "Double tap to switch"
                )

                accessibilityRow(
                    title: "Action Button",
                    traits: "none",
                    hint: "Double tap to activate"
                )
            }

            Divider()

            Text("Interactive Demo")
                .font(.subheadline.weight(.medium))

            DynamicTypePreview()

            Text("Enable VoiceOver to test")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
    }

    @ViewBuilder
    private func accessibilityRow(title: String, traits: String, hint: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline.weight(.medium))

            HStack {
                Label(traits, systemImage: "accessibility")
                    .font(.caption.monospaced())
                    .foregroundStyle(.blue)

                Spacer()

                Text(hint)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.background.secondary, in: .rect(cornerRadius: 8))
    }
}

// MARK: - Previews

#Preview("Dynamic Type - Default") {
    DynamicTypePreview()
        .padding()
}

#Preview("Dynamic Type - Large") {
    DynamicTypePreview()
        .dynamicTypeSize(.xxxLarge)
        .padding()
}

#Preview("Dynamic Type - Accessibility XXL") {
    DynamicTypePreview()
        .dynamicTypeSize(.accessibility5)
        .padding()
}

#Preview("Tap Target Visualization") {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 16) {
            ForEach(ToolbarDensity.allCases, id: \.rawValue) { density in
                TapTargetVisualization(density: density)
            }
        }
        .padding()
    }
}

#Preview("Accessibility Safe Density") {
    AccessibilitySafeDensityPreview()
}

#Preview("Color Contrast") {
    ColorContrastPreview()
}

#Preview("VoiceOver Labels") {
    ScrollView {
        VoiceOverPreview()
    }
}

#Preview("Reduced Motion") {
    VStack(spacing: 24) {
        PreviewSection(title: "With Animation") {
            DynamicTypePreview()
        }

        PreviewSection(title: "Reduced Motion (simulated)") {
            // Note: accessibilityReduceMotion is read-only
            // In real testing, enable Reduce Motion in Settings
            DynamicTypePreview()
        }

        Text("Enable Reduce Motion in Settings to test")
            .font(.caption)
            .foregroundStyle(.tertiary)
    }
    .padding()
}

#Preview("Full Accessibility Audit") {
    NavigationStack {
        List {
            Section("Tap Targets") {
                ForEach(ToolbarDensity.allCases, id: \.rawValue) { density in
                    let metrics = ToolbarMetrics(density: density)
                    HStack {
                        Text(densityLabel(density))
                        Spacer()
                        Text("\(Int(metrics.minimumTapTarget))pt")
                            .foregroundStyle(metrics.minimumTapTarget >= 44 ? .green : .orange)
                    }
                }
            }

            Section("Color Usage") {
                LabeledContent("Selected Tab", value: ".primary")
                LabeledContent("Unselected Tab", value: ".secondary")
                LabeledContent("Action", value: ".primary")
                LabeledContent("Disabled", value: ".primary @ 30%")
            }

            Section("Traits") {
                LabeledContent("Selected Tab", value: ".isSelected")
                LabeledContent("Unselected Tab", value: "none")
                LabeledContent("Picker", value: ".adjustable")
            }
        }
        .navigationTitle("Accessibility Audit")
    }
}

private func densityLabel(_ density: ToolbarDensity) -> String {
    switch density {
    case .extraSparse: "Extra Sparse"
    case .sparse: "Sparse"
    case .regular: "Regular"
    case .compact: "Compact"
    case .dense: "Dense"
    case .extraDense: "Extra Dense"
    }
}
