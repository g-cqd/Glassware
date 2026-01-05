//
//  ToolbarBuilderPreview.swift
//  Glassware
//
//  Previews demonstrating GlassContentBuilder patterns and spacer-based grouping.
//

import SwiftUI

// MARK: - Spacer Grouping Preview

/// Demonstrates how Spacer() creates visual groups in the toolbar content.
private struct SpacerGroupingPreview: View {
  @State private var selectedTab: PreviewTab = .home

  var body: some View {
    SampleContentView("Spacer Grouping", color: .blue.opacity(0.05))
      .glassBar(
        content: {
          // Group 1: First two tabs
          ForEach([PreviewTab.home, .search], id: \.rawValue) { tab in
            Button {
              selectedTab = tab
            } label: {
              Label(tab.title, systemImage: tab.systemImage)
            }
            .buttonStyle(.glass(isSelected: selectedTab == tab))
          }

          // Spacer creates visual separation
          Spacer()

          // Group 2: Profile tab alone
          Button {
            selectedTab = .profile
          } label: {
            Label(PreviewTab.profile.title, systemImage: PreviewTab.profile.systemImage)
          }
          .buttonStyle(.glass(isSelected: selectedTab == .profile))
        }
      )
      .overlay(alignment: .top) {
        Text("Home/Search grouped, Profile separate")
          .font(.caption)
          .padding(8)

          .padding(.top, 60)
      }
  }
}

// MARK: - Multiple Spacers Preview

/// Shows multiple spacer groups in a single toolbar.
private struct MultipleSpacersPreview: View {
  var body: some View {
    SampleContentView("Multiple Spacers", color: .green.opacity(0.05))
      .glassBar(
        content: {
          // Group 1
          Button {} label: {
            Label("Undo", systemImage: "arrow.uturn.backward")
          }
          .buttonStyle(.glass(intent: .action, style: .iconOnly()))

          Button {} label: {
            Label("Redo", systemImage: "arrow.uturn.forward")
          }
          .buttonStyle(.glass(intent: .action, style: .iconOnly()))

          Spacer()

          // Group 2
          Button {} label: {
            Label("Cut", systemImage: "scissors")
          }
          .buttonStyle(.glass(intent: .action, style: .iconOnly()))

          Button {} label: {
            Label("Copy", systemImage: "doc.on.doc")
          }
          .buttonStyle(.glass(intent: .action, style: .iconOnly()))

          Button {} label: {
            Label("Paste", systemImage: "doc.on.clipboard")
          }
          .buttonStyle(.glass(intent: .action, style: .iconOnly()))

          Spacer()

          // Group 3
          Button {} label: {
            Label("Share", systemImage: "square.and.arrow.up")
          }
          .buttonStyle(.glass(intent: .action, style: .iconOnly()))
        }
      )
      .overlay(alignment: .top) {
        Text("Undo/Redo | Cut/Copy/Paste | Share")
          .font(.caption)
          .padding(8)

          .padding(.top, 60)
      }
  }
}

// MARK: - Leading/Trailing with Spacer Preview

/// Shows leading and trailing items with spacer-grouped content.
private struct LeadingTrailingSpacerPreview: View {
  @State private var selectedTab: PreviewTab = .home

  var body: some View {
    SampleContentView("Leading/Trailing + Spacer", color: .orange.opacity(0.05))
      .glassBar(
        leading: {
          Button {} label: {
            Label("Menu", systemImage: "line.3.horizontal")
          }
          .buttonStyle(.glass(style: .iconOnly()))
        },
        content: {
          // Primary tabs
          ForEach(PreviewTab.allCases, id: \.rawValue) { tab in
            Button {
              selectedTab = tab
            } label: {
              Label(tab.title, systemImage: tab.systemImage)
            }
            .buttonStyle(.glass(isSelected: selectedTab == tab))
          }

          Spacer()

          // Additional action after spacer
          Button {} label: {
            Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
          }
          .buttonStyle(.glass(intent: .action, style: .iconOnly()))
        },
        trailing: {
          Button {} label: {
            Label("Add", systemImage: "plus")
          }
          .buttonStyle(.glass(intent: .action, style: .iconOnly()))
        }
      )
  }
}

// MARK: - Conditional Content Preview

/// Shows conditional content using if statements in builder.
private struct ConditionalContentPreview: View {
  @State private var selectedTab: PreviewTab = .home
  @State private var showExtras = true

  var body: some View {
    VStack {
      Toggle("Show Extra Buttons", isOn: $showExtras)
        .padding()
      Spacer()
    }
    .ignoresSafeArea(edges: .bottom)
    .glassBar(
      leading: {
        if showExtras {
          Button {} label: {
            Label("Settings", systemImage: "gearshape")
          }
          .buttonStyle(.glass(style: .iconOnly()))
        }
      },
      content: {
        ForEach(PreviewTab.allCases, id: \.rawValue) { tab in
          Button {
            selectedTab = tab
          } label: {
            Label(tab.title, systemImage: tab.systemImage)
          }
          .buttonStyle(.glass(isSelected: selectedTab == tab))
        }
      },
      trailing: {
        if showExtras {
          Button {} label: {
            Label("Add", systemImage: "plus")
          }
          .buttonStyle(.glass(intent: .action, style: .iconOnly()))
        }
      }
    )
  }
}

// MARK: - ForEach in Builder Preview

/// Demonstrates ForEach usage within the builder.
private struct ForEachBuilderPreview: View {
  private let actions = [
    ("Undo", "arrow.uturn.backward"),
    ("Redo", "arrow.uturn.forward"),
    ("Cut", "scissors"),
    ("Copy", "doc.on.doc"),
    ("Paste", "doc.on.clipboard")
  ]

  var body: some View {
    SampleContentView("ForEach in Builder", color: .purple.opacity(0.05))
      .glassBar(
        content: {
          ForEach(actions.indices, id: \.self) { index in
            let action = actions[index]
            Button {} label: {
              Label(action.0, systemImage: action.1)
            }
            .buttonStyle(.glass(intent: .action, style: .iconOnly()))
          }
        }
      )
  }
}

// MARK: - Layout Distribution Preview

/// Shows different layout distribution options.
private struct LayoutDistributionPreview: View {
  @State private var selectedTab: PreviewTab = .home
  @State private var distribution: GlassLayoutDistribution = .distributed

  var body: some View {
    VStack {
      Picker("Distribution", selection: $distribution) {
        Text("Natural").tag(GlassLayoutDistribution.natural)
        Text("Distributed").tag(GlassLayoutDistribution.distributed)
        Text("Centered").tag(GlassLayoutDistribution.centered)
      }
      .pickerStyle(.segmented)
      .padding()

      Spacer()
    }
    .ignoresSafeArea(edges: .bottom)
    .glassBar(
      leading: {
        Button {} label: {
          Label("Menu", systemImage: "line.3.horizontal")
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
          .buttonStyle(.glass(isSelected: selectedTab == tab))
        }
      },
      trailing: {
        Button {} label: {
          Label("Add", systemImage: "plus")
        }
        .buttonStyle(.glass(intent: .action, style: .iconOnly()))
      }
    )
    .glassLayout(distribution)
  }
}

// MARK: - Distribution Comparison

/// Side-by-side comparison of all distribution modes.
private struct DistributionComparisonPreview: View {
  @State private var selectedTab: PreviewTab = .home

  var body: some View {
    VStack(spacing: 24) {
      distributionRow(distribution: .natural, title: "Natural")
      distributionRow(distribution: .distributed, title: "Distributed")
      distributionRow(distribution: .centered, title: "Centered")
    }
    .padding()
  }

  @ViewBuilder
  private func distributionRow(distribution: GlassLayoutDistribution, title: String) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)

      HStack(spacing: 0) {
        // Leading
        Button {} label: {
          Label("Menu", systemImage: "line.3.horizontal")
        }
        .buttonStyle(.glass(style: .iconOnly()))


        // Spacer logic based on distribution
        if distribution == .natural {
          Spacer(minLength: 8)
        } else {
          Spacer()
        }

        // Center content
        HStack(spacing: 0) {
          ForEach(PreviewTab.allCases.prefix(2), id: \.rawValue) { tab in
            Button {} label: {
              Label(tab.title, systemImage: tab.systemImage)
            }
            .buttonStyle(.glass(isSelected: tab == .home))
          }
        }
        .padding(3)


        if distribution == .natural {
          Spacer(minLength: 8)
        } else {
          Spacer()
        }

        // Trailing
        Button {} label: {
          Label("Add", systemImage: "plus")
        }
        .buttonStyle(.glass(intent: .action, style: .iconOnly()))

      }
      .frame(maxWidth: .infinity)
      .padding(8)
      .background(.background.secondary, in: .rect(cornerRadius: 12))
    }
  }
}

// MARK: - Previews

#Preview("Spacer Grouping") {
  SpacerGroupingPreview()
}

#Preview("Multiple Spacers") {
  MultipleSpacersPreview()
}

#Preview("Leading/Trailing + Spacer") {
  LeadingTrailingSpacerPreview()
}

#Preview("Conditional Content") {
  ConditionalContentPreview()
}

#Preview("ForEach in Builder") {
  ForEachBuilderPreview()
}

#Preview("Layout Distribution") {
  LayoutDistributionPreview()
}

#Preview("Distribution Comparison") {
  ScrollView {
    DistributionComparisonPreview()
  }
}

#Preview("Empty Leading/Trailing") {
  // Shows that empty leading/trailing don't create visual artifacts
  struct Preview: View {
    @State private var selectedTab: PreviewTab = .home

    var body: some View {
      SampleContentView("No Leading/Trailing", color: .teal.opacity(0.05))
        .glassBar(
          content: {
            ForEach(PreviewTab.allCases, id: \.rawValue) { tab in
              Button {
                selectedTab = tab
              } label: {
                Label(tab.title, systemImage: tab.systemImage)
              }
              .buttonStyle(.glass(isSelected: selectedTab == tab))
            }
          }
        )
    }
  }
  return Preview()
}

#Preview("Only Leading") {
  SampleContentView("Only Leading", color: .mint.opacity(0.05))
    .glassBar(
      leading: {
        Button {} label: {
          Label("Menu", systemImage: "line.3.horizontal")
        }
        .buttonStyle(.glass(style: .iconOnly()))

        Button {} label: {
          Label("Search", systemImage: "magnifyingglass")
        }
        .buttonStyle(.glass(style: .iconOnly()))
      },
      content: {}
    )
}

#Preview("Only Trailing") {
  SampleContentView("Only Trailing", color: .pink.opacity(0.05))
    .glassBar(
      content: {},
      trailing: {
        Button {} label: {
          Label("Share", systemImage: "square.and.arrow.up")
        }
        .buttonStyle(.glass(intent: .action, style: .iconOnly()))

        Button {} label: {
          Label("Add", systemImage: "plus")
        }
        .buttonStyle(.glass(intent: .action, style: .iconOnly()))
      }
    )
}
