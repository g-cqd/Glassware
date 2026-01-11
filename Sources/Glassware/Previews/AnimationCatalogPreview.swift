//
//  AnimationCatalogPreview.swift
//  Glassware
//
//  Previews demonstrating all animation effects in the toolkit.
//

import SwiftUI

// MARK: - Button Animation Preview

/// Demonstrates button press animations with symbol effects.
private struct ButtonAnimationPreview: View {
    @State private var isDisabled = false
    @State private var iconName = "house"

    private let icons = ["house", "magnifyingglass", "gearshape", "person", "bell"]

    var body: some View {
        VStack(spacing: 24) {
            PreviewSection(title: "Press Feedback") {
                Text("Tap buttons to see opacity + haptic feedback")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Button {} label: {
                        Label("Home", systemImage: "house")
                    }
                    .buttonStyle(.glass())

                    Button {} label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                    .buttonStyle(.glass(style: .iconOnly()))

                    Button {} label: {
                        Label("Add", systemImage: "plus")
                    }
                    .buttonStyle(.glassProminent(style: .iconOnly()))
                }
            }

            PreviewSection(title: "Disabled State Transition") {
                Toggle("Disabled", isOn: $isDisabled)

                HStack(spacing: 12) {
                    Button {} label: {
                        Label("Action", systemImage: "star")
                    }
                    .buttonStyle(.glass())
                    .disabled(isDisabled)

                    Button {} label: {
                        Label("Prominent", systemImage: "star.fill")
                    }
                    .buttonStyle(.glassProminent())
                    .disabled(isDisabled)
                }
            }

            PreviewSection(title: "Symbol Replace Transition") {
                Text("Change icon to see smooth replacement")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Button {
                        withAnimation {
                            let currentIndex = icons.firstIndex(of: iconName) ?? 0
                            iconName = icons[(currentIndex + 1) % icons.count]
                        }
                    } label: {
                        Label("Cycle Icon", systemImage: iconName)
                    }
                    .buttonStyle(.glass())
                }
            }

            PreviewSection(title: "Destructive Role") {
                HStack(spacing: 12) {
                    Button(role: .destructive) {} label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .buttonStyle(.glass())

                    Button(role: .destructive) {} label: {
                        Label("Remove", systemImage: "xmark")
                    }
                    .buttonStyle(.glassProminent(style: .iconOnly()))
                }
            }
        }
        .padding()
    }
}

// MARK: - Picker Animation Preview

/// Demonstrates segmented picker animations.
private struct PickerAnimationPreview: View {
    @State private var selection: PreviewTab = .home

    var body: some View {
        VStack(spacing: 24) {
            PreviewSection(title: "Selection Animation") {
                Text("Tap items to see bounce + thumb slide")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                SegmentedPicker(selection: $selection, style: .iconOnly) {
                    ForEach(PreviewTab.allCases, id: \.rawValue) { tab in
                        SegmentedPickerItem(
                            tab,
                            systemImage: tab.systemImage,
                            style: .iconOnly,
                            isSelected: selection == tab
                        ) {
                            Text(tab.title)
                        }
                    }
                }
                .padding(3)
            }

            PreviewSection(title: "Title and Icon") {
                SegmentedPicker(selection: $selection, style: .titleAndIcon) {
                    ForEach(PreviewTab.allCases, id: \.rawValue) { tab in
                        SegmentedPickerItem(
                            tab,
                            systemImage: tab.systemImage,
                            style: .titleAndIcon,
                            isSelected: selection == tab
                        ) {
                            Text(tab.title)
                        }
                    }
                }
                .padding(3)
            }

            Text("Current: \(selection.title)")
                .font(.caption.monospaced())
                .foregroundStyle(.tertiary)
        }
        .padding()
    }
}

// MARK: - Symbol Effects Catalog

/// Demonstrates individual symbol effect types.
private struct SymbolEffectsCatalog: View {
    @State private var bounceValue = false
    @State private var pulseActive = false
    @State private var variableColorActive = false

    var body: some View {
        VStack(spacing: 24) {
            PreviewSection(title: "Bounce Effect") {
                HStack(spacing: 24) {
                    Image(systemName: "bell")
                        .font(.title)
                        .symbolEffect(.bounce, value: bounceValue)

                    Button("Trigger") {
                        bounceValue.toggle()
                    }
                    .buttonStyle(.glass())
                }
            }

            PreviewSection(title: "Pulse Effect (Indefinite)") {
                HStack(spacing: 24) {
                    Image(systemName: "heart.fill")
                        .font(.title)
                        .foregroundStyle(.red)
                        .symbolEffect(.pulse, isActive: pulseActive)

                    Toggle("Active", isOn: $pulseActive)
                }
            }

            PreviewSection(title: "Variable Color (Indefinite)") {
                HStack(spacing: 24) {
                    Image(systemName: "wifi")
                        .font(.title)
                        .symbolEffect(.variableColor.iterative, isActive: variableColorActive)

                    Toggle("Active", isOn: $variableColorActive)
                }
            }
        }
        .padding()
    }
}

// MARK: - Content Transitions Catalog

/// Demonstrates content transition types.
private struct ContentTransitionsCatalog: View {
    @State private var showFilled = false
    @State private var count = 0

    var body: some View {
        VStack(spacing: 24) {
            PreviewSection(title: "Symbol Replace") {
                HStack(spacing: 24) {
                    Image(systemName: showFilled ? "heart.fill" : "heart")
                        .font(.title)
                        .foregroundStyle(showFilled ? .red : .primary)
                        .contentTransition(.symbolEffect(.replace))

                    Button("Toggle") {
                        withAnimation {
                            showFilled.toggle()
                        }
                    }
                    .buttonStyle(.glass())
                }
            }

            PreviewSection(title: "Numeric Text") {
                HStack(spacing: 24) {
                    Text("\(count)")
                        .font(.largeTitle.monospacedDigit())
                        .contentTransition(.numericText())

                    HStack {
                        Button("-") { withAnimation { count -= 1 } }
                            .buttonStyle(.glass(style: .iconOnly()))
                        Button("+") { withAnimation { count += 1 } }
                            .buttonStyle(.glass(style: .iconOnly()))
                    }
                }
            }

            PreviewSection(title: "Interpolate") {
                HStack(spacing: 24) {
                    Text("Score")
                        .font(.headline)
                        .foregroundStyle(showFilled ? .green : .primary)
                        .contentTransition(.interpolate)

                    Button("Toggle") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showFilled.toggle()
                        }
                    }
                    .buttonStyle(.glass())
                }
            }
        }
        .padding()
    }
}

// MARK: - Animation Tokens Preview

/// Shows animation timing values from GlassTokens.
private struct AnimationTokensPreview: View {
    var body: some View {
        List {
            Section("Durations") {
                tokenRow("Content Transition", "\(GlassTokens.Animation.contentTransitionDuration)s")
                tokenRow("Disabled Transition", "\(GlassTokens.Animation.disabledTransitionDuration)s")
            }

            Section("Spring - Selection") {
                tokenRow("Response", "\(GlassTokens.Animation.selectionSpringResponse)")
                tokenRow("Damping", "\(GlassTokens.Animation.selectionSpringDamping)")
            }

            Section("Spring - Collapse") {
                tokenRow("Response", "\(GlassTokens.Animation.collapseSpringResponse)")
                tokenRow("Bounce", "\(GlassTokens.Animation.collapseSpringBounce)")
            }
        }
    }

    @ViewBuilder
    private func tokenRow(_ name: String, _ value: String) -> some View {
        HStack {
            Text(name)
            Spacer()
            Text(value)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Previews

#Preview("Button Animations") {
    ScrollView {
        ButtonAnimationPreview()
    }
}

#Preview("Picker Animations") {
    ScrollView {
        PickerAnimationPreview()
    }
}

#Preview("Symbol Effects") {
    ScrollView {
        SymbolEffectsCatalog()
    }
}

#Preview("Content Transitions") {
    ScrollView {
        ContentTransitionsCatalog()
    }
}

#Preview("Animation Tokens") {
    AnimationTokensPreview()
}

#Preview("Reduce Motion Simulation") {
    VStack(spacing: 24) {
        Text("Test with Settings > Accessibility > Motion > Reduce Motion")
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding()

        ButtonAnimationPreview()
    }
}
