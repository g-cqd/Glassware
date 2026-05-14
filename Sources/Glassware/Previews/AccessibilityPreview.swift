//
//  AccessibilityPreview.swift
//  Glassware
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
                .buttonStyle(.glass())
            }
        }
        .padding(3)

    }
}

// MARK: - Tap Target Visualization

/// Visualizes minimum tap target sizes.
private struct TapTargetVisualization: View {
    let density: GlassDensity

    private var metrics: GlassMetrics {
        GlassMetrics(density: density)
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
    @State private var selectedDensity: GlassDensity = .dense
    @State private var isAccessibilityEnabled: Bool = true

    private var effectiveDensity: GlassDensity {
        selectedDensity.accessibilitySafe(isAccessibilityEnabled: isAccessibilityEnabled)
    }

    var body: some View {
        VStack(spacing: 24) {
            Toggle("Accessibility Mode", isOn: $isAccessibilityEnabled)
                .padding(.horizontal)

            Picker("Density", selection: $selectedDensity) {
                ForEach(GlassDensity.allCases, id: \.rawValue) { density in
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
                .glassDensity(effectiveDensity)
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

// MARK: - Color Contrast Preview

/// Shows button states with their color contrast.
private struct ColorContrastPreview: View {
    var body: some View {
        VStack(spacing: 24) {
            PreviewSection(title: "Standard Button") {
                HStack(spacing: 16) {
                    stateColumn(title: "Enabled", foregroundLabel: ".primary") {
                        Button {} label: {
                            Label("Action", systemImage: "house")
                        }
                        .buttonStyle(.glass())
                    }

                    stateColumn(title: "Disabled", foregroundLabel: ".primary @ 30%") {
                        Button {} label: {
                            Label("Action", systemImage: "house")
                        }
                        .buttonStyle(.glass())
                        .disabled(true)
                    }
                }
            }

            PreviewSection(title: "Destructive Role") {
                stateColumn(title: "Destructive", foregroundLabel: ".red") {
                    Button(role: .destructive) {} label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .buttonStyle(.glass())
                }
            }

            PreviewSection(title: "Prominent Style") {
                HStack(spacing: 16) {
                    stateColumn(title: "Prominent", foregroundLabel: ".primary") {
                        Button {} label: {
                            Label("Add", systemImage: "plus")
                        }
                        .buttonStyle(.glassProminent())
                    }

                    stateColumn(title: "Prominent Destructive", foregroundLabel: ".white") {
                        Button(role: .destructive) {} label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .buttonStyle(.glassProminent())
                    }
                }
            }
        }
        .padding()
    }

    @ViewBuilder
    private func stateColumn<Content: View>(
        title: String,
        foregroundLabel: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(spacing: 8) {
            content()

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(foregroundLabel)
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
                    title: "Standard Button",
                    traits: ".isButton",
                    hint: "Double tap to activate"
                )

                accessibilityRow(
                    title: "Destructive Button",
                    traits: ".isButton",
                    hint: "Double tap to delete"
                )

                accessibilityRow(
                    title: "Disabled Button",
                    traits: ".isButton, .notEnabled",
                    hint: "Dimmed"
                )

                accessibilityRow(
                    title: "Segmented Picker",
                    traits: ".adjustable",
                    hint: "Swipe up or down to adjust"
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
            ForEach(GlassDensity.allCases, id: \.rawValue) { density in
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
    ReducedMotionDemoPreview()
}

// MARK: - Reduced Motion Demo

/// Demonstrates how components behave with reduced motion.
private struct ReducedMotionDemoPreview: View {
    @State private var selectedTab: PreviewTab = .home
    @State private var pickerSelection: PreviewTab = .home
    @State private var simulateReducedMotion = false

    var body: some View {
        VStack(spacing: 24) {
            Toggle("Simulate Reduced Motion", isOn: $simulateReducedMotion)
                .padding(.horizontal)

            PreviewSection(title: "Tab Selection") {
                HStack(spacing: 0) {
                    ForEach(PreviewTab.allCases, id: \.rawValue) { tab in
                        Button {
                            if simulateReducedMotion {
                                // Instant update without animation
                                selectedTab = tab
                            } else {
                                withAnimation(.snappy) {
                                    selectedTab = tab
                                }
                            }
                        } label: {
                            Label(tab.title, systemImage: tab.systemImage)
                        }
                        .buttonStyle(.glass())
                    }
                }
                .padding(3)

            }

            PreviewSection(title: "Segmented Picker") {
                SegmentedPicker(selection: $pickerSelection, style: .iconOnly) {
                    ForEach(PreviewTab.allCases, id: \.rawValue) { tab in
                        SegmentedPickerItem(
                            tab,
                            systemImage: tab.systemImage,
                            style: .iconOnly,
                            isSelected: pickerSelection == tab
                        ) {
                            Text(tab.title)
                        }
                    }
                }
                .padding(3)

                // Note: SegmentedPicker reads @Environment(\.accessibilityReduceMotion)
            }

            VStack(spacing: 8) {
                Text("When Reduce Motion is enabled:")
                    .font(.subheadline.weight(.medium))

                VStack(alignment: .leading, spacing: 4) {
                    BulletPoint("Selection changes instantly (no spring)")
                    BulletPoint("Drag gestures update without animation")
                    BulletPoint("Capsule snaps to position")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding()
            .background(.background.secondary, in: .rect(cornerRadius: 12))

            Text("Enable Reduce Motion in Settings > Accessibility > Motion")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

/// Simple bullet point view for lists.
private struct BulletPoint: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\u{2022}")
            Text(text)
        }
    }
}

#Preview("Full Accessibility Audit") {
    NavigationStack {
        List {
            Section("Tap Targets") {
                ForEach(GlassDensity.allCases, id: \.rawValue) { density in
                    let metrics = GlassMetrics(density: density)
                    HStack {
                        Text(densityLabel(density))
                        Spacer()
                        Text("\(Int(metrics.minimumTapTarget))pt")
                            .foregroundStyle(metrics.minimumTapTarget >= 44 ? .green : .orange)
                    }
                }
            }

            Section("Color Usage") {
                LabeledContent("Standard Button", value: ".primary")
                LabeledContent("Standard Pressed", value: ".primary @ 60%")
                LabeledContent("Destructive Button", value: ".red")
                LabeledContent("Destructive Pressed", value: ".red @ 60%")
                LabeledContent("Prominent Button", value: ".primary")
                LabeledContent("Prominent Destructive", value: ".white")
                LabeledContent("Disabled", value: ".primary @ 30%")
            }

            Section("Traits") {
                LabeledContent("Standard Button", value: ".isButton")
                LabeledContent("Destructive Button", value: ".isButton")
                LabeledContent("Disabled Button", value: ".notEnabled")
                LabeledContent("Segmented Picker", value: ".adjustable")
            }
        }
        .navigationTitle("Accessibility Audit")
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
