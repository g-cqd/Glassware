//
//  GlassDensity.swift
//  Glassware
//
//  Density configuration for toolbar layout and sizing.
//

import SwiftUI

// MARK: - Edge Size Context

/// Context for edge-aware and collapse-aware sizing.
///
/// This type encapsulates the placement context that determines base button sizes
/// before density scaling is applied. It enables the toolbar to match native iOS
/// sizing patterns:
/// - Top edge: 44pt (native navigation bar)
/// - Bottom edge expanded: 50pt (native tab bar expanded)
/// - Bottom edge collapsed: 44pt (native tab bar collapsed)
/// - Accessory: 44pt (constant, never changes with collapse)
///
/// ## Usage
/// The context is injected by `EdgeGlassContainer` and read by button styles
/// to determine appropriate sizing. You typically don't need to create this directly.
public struct GlassEdgeContext: Sendable, Equatable {
    /// The edge where the toolbar is positioned.
    public let edge: GlassEdge

    /// Whether this content is in an accessory placement.
    public let isAccessory: Bool

    /// Current collapse state (only affects bottom edge non-accessory content).
    public let collapseState: GlassCollapseState

    /// Creates an edge size context.
    ///
    /// - Parameters:
    ///   - edge: The toolbar edge.
    ///   - isAccessory: Whether content is in accessory placement.
    ///   - collapseState: Current collapse state.
    public init(
        edge: GlassEdge,
        isAccessory: Bool = false,
        collapseState: GlassCollapseState = .expanded
    ) {
        self.edge = edge
        self.isAccessory = isAccessory
        self.collapseState = collapseState
    }

    /// Target container height for this context (final, including glass effect).
    ///
    /// Returns the exact container height matching native iOS patterns:
    /// - Top edge: 44pt
    /// - Bottom expanded (with primary): 62pt
    /// - Bottom collapsed: 48pt
    /// - Accessory: 48pt (constant, never changes)
    /// - Side edges / everywhere else: 48pt
    public var containerHeight: CGFloat {
        switch (edge, isAccessory, collapseState) {
        case (_, true, _):
            // Accessory: always 48pt, never animates
            48

        case (.top, false, _):
            // Top edge: 44pt
            44

        case (.bottom, false, .expanded):
            // Bottom expanded with primary: 62pt
            62

        case (.bottom, false, .collapsed):
            // Bottom collapsed: 48pt
            48

        case (.leading, false, _), (.trailing, false, _):
            // Side edges: 48pt
            48
        }
    }

    /// Component padding adjustment for this context.
    ///
    /// Tuned empirically to achieve target container heights after glass effect.
    /// Measured results used to calibrate:
    /// - Top was 49pt, target 44pt → need -5pt total
    /// - Accessory was 51pt, target 48pt → need -3pt total
    /// - Bottom was 61pt, target 62pt → need +1pt total
    public var componentPaddingAdjustment: CGFloat {
        switch (edge, isAccessory, collapseState) {
        case (_, true, _):
            // Accessory: 48pt target (was 51pt, need -3pt total = -1.5pt per side)
            -2.5

        case (.top, false, _):
            // Top: 44pt target (was 49pt, need -5pt total = -2.5pt per side)
            -3.5

        case (.bottom, false, .expanded):
            // Bottom expanded: 62pt target (was 61pt, need +1pt total = +0.5pt per side)
            2.5

        case (.bottom, false, .collapsed):
            // Bottom collapsed: 48pt target
            -2.5

        case (.leading, false, _), (.trailing, false, _):
            // Side edges: 48pt target
            -2.5
        }
    }

    /// Container padding adjustment for this context.
    public var containerPaddingAdjustment: CGFloat {
        switch (edge, isAccessory, collapseState) {
        case (_, true, _):
            // Accessory: 48pt target
            -2

        case (.top, false, _):
            // Top: 44pt target
            -3

        case (.bottom, false, .expanded):
            // Bottom expanded: 62pt target
            0

        case (.bottom, false, .collapsed):
            // Bottom collapsed: 48pt target
            -2

        case (.leading, false, _), (.trailing, false, _):
            // Side edges: 48pt target
            -2
        }
    }
}

// MARK: - Toolbar Padding Configuration

/// Controls bottom padding behavior for the glass toolbar.
///
/// Use this to customize how the toolbar handles safe area insets at the bottom edge.
public struct GlassPaddingConfiguration: Sendable, Equatable {
    /// Additional padding from the safe area (or screen edge if ignoring safe area).
    public let additionalPadding: CGFloat

    /// Whether to ignore the bottom safe area (home indicator).
    public let ignoresSafeArea: Bool

    /// External padding from screen edges (horizontal margins).
    /// This value is always used regardless of density.
    public let externalPadding: CGFloat

    /// Default configuration: respects safe area with density-based padding.
    public static let `default` = GlassPaddingConfiguration(
        additionalPadding: -1,  // Sentinel: use density-based value
        ignoresSafeArea: false,
        externalPadding: 16
    )

    /// Tight configuration: minimal padding, stays close to bottom edge.
    public static let tight = GlassPaddingConfiguration(
        additionalPadding: 0,
        ignoresSafeArea: false,
        externalPadding: 16
    )

    /// Edge-to-edge configuration: ignores safe area, positioned at screen bottom.
    public static let edgeToEdge = GlassPaddingConfiguration(
        additionalPadding: 0,
        ignoresSafeArea: true,
        externalPadding: 16
    )

    /// Creates a custom padding configuration.
    ///
    /// - Parameters:
    ///   - additionalPadding: Extra padding from safe area/screen edge. Use `-1` for density-based.
    ///   - ignoresSafeArea: If true, positions toolbar at screen bottom ignoring home indicator.
    ///   - externalPadding: Horizontal padding from screen edges. Defaults to 16.
    public init(
        additionalPadding: CGFloat = -1,
        ignoresSafeArea: Bool = false,
        externalPadding: CGFloat = 16
    ) {
        self.additionalPadding = additionalPadding
        self.ignoresSafeArea = ignoresSafeArea
        self.externalPadding = externalPadding
    }

    /// Resolves additional padding, using density-based value if sentinel is set.
    func resolvedAdditionalPadding(density: GlassDensity) -> CGFloat {
        if additionalPadding < 0 {
            return GlassMetrics(density: density).edgePadding
        }
        return additionalPadding
    }
}

// MARK: - Toolbar Layout Distribution

/// Controls how toolbar containers distribute space when some compartments are empty.
///
/// When leading, primary, or trailing compartments are empty, this configuration
/// determines whether the remaining content centers naturally or distributes evenly.
public enum GlassLayoutDistribution: Int, Sendable, Equatable {
    /// Containers are placed naturally without extra spacers.
    /// When some compartments are empty, content shifts toward the empty side.
    /// This is the default behavior.
    case natural = 0

    /// Containers are evenly distributed with spacers filling empty compartments.
    /// Leading container stays at leading edge, trailing at trailing edge,
    /// and primary content centers between them.
    case distributed = 1

    /// Containers are centered when possible.
    /// All content groups together in the center, ignoring empty compartments.
    case centered = 2
}

// MARK: - Toolbar Density

/// Controls both the size and spacing of toolbar items.
///
/// Density follows SwiftUI naming conventions similar to `DynamicTypeSize`,
/// ranging from sparse (most spacious) to dense (most compact).
///
/// - `.extraSparse`: Maximum spacing and size (44pt tap targets, 32pt edge padding)
/// - `.sparse`: Generous spacing (44pt tap targets, 28pt edge padding)
/// - `.regular`: Default balance (44pt tap targets, 24pt edge padding)
/// - `.compact`: Tighter layout (40pt tap targets, 20pt edge padding)
/// - `.dense`: Minimum spacing (36pt tap targets, 16pt edge padding)
/// - `.extraDense`: Ultra-compact layout (32pt tap targets, 12pt edge padding)
///
/// Use lower densities (.sparse, .extraSparse) for accessibility or when
/// emphasizing touch-friendliness. Use higher densities (.compact, .dense)
/// when screen space is limited or content density is preferred.
///
/// - Warning: `.dense` and `.extraDense` have tap targets below the recommended
///   44pt minimum. These are automatically upgraded to `.compact` when
///   accessibility features are enabled.
public enum GlassDensity: Int, Sendable, Equatable, CaseIterable {
    /// Maximum spacing with full-size items.
    /// Best for accessibility and large touch targets.
    case extraSparse = 0

    /// Generous spacing with comfortable touch targets.
    case sparse = 1

    /// Balanced layout with standard sizing (default).
    case regular = 2

    /// Tighter layout with slightly reduced spacing.
    case compact = 3

    /// Dense layout with smaller items and tight spacing.
    /// - Warning: 36pt tap targets may be below accessibility guidelines.
    case dense = 4

    /// Ultra-compact layout for maximum content density.
    /// - Warning: 32pt tap targets are below recommended minimum.
    case extraDense = 5
}

// MARK: - Toolbar Metrics

/// Provides computed layout metrics based on density and edge context.
///
/// This struct centralizes all spacing and sizing calculations, reading from
/// the environment and providing appropriate values for the current configuration.
/// Use this instead of hard-coded values to ensure consistent adaptation.
///
/// ## Context-Aware Sizing
/// When initialized with an `GlassEdgeContext`, metrics adapt based on:
/// - Edge position (top vs bottom)
/// - Collapse state (expanded vs collapsed)
/// - Placement type (primary vs accessory)
///
/// ## Usage
/// ```swift
/// struct MyToolbarView: View {
///     @Environment(\.glassDensity) private var density
///     @Environment(\.glassSizeContext) private var sizeContext
///
///     var body: some View {
///         let metrics = GlassMetrics(density: density, context: sizeContext)
///         // Use metrics.effectiveButtonSize for context-aware sizing
///     }
/// }
/// ```
public struct GlassMetrics: Sendable {
    public let density: GlassDensity

    /// Optional edge context for adaptive sizing.
    public let context: GlassEdgeContext?

    /// Creates metrics with density only (legacy behavior).
    public init(density: GlassDensity) {
        self.density = density
        self.context = nil
    }

    /// Creates metrics with density and edge context for adaptive sizing.
    public init(density: GlassDensity, context: GlassEdgeContext?) {
        self.density = density
        self.context = context
    }

    // MARK: - Context-Aware Sizing

    /// The effective button size.
    ///
    /// Button size stays consistent (based on density) - we adjust padding
    /// to achieve target container heights instead of scaling buttons.
    public var effectiveButtonSize: CGFloat {
        minimumTapTarget
    }

    /// The effective container height considering edge context.
    ///
    /// Returns context-aware container height if context provided, otherwise
    /// falls back to minimumTapTarget + padding.
    public var effectiveContainerHeight: CGFloat {
        guard let context else {
            return minimumTapTarget + (containerPadding * 2)
        }
        return context.containerHeight
    }

    /// Effective component padding with context adjustments.
    ///
    /// Adjusts base component padding to achieve target container heights
    /// while keeping text and icon sizes unchanged.
    public var effectiveComponentPadding: CGFloat {
        let base = componentPadding
        guard let context else { return base }
        return max(0, base + context.componentPaddingAdjustment)
    }

    /// Effective container padding with context adjustments.
    public var effectiveContainerPadding: CGFloat {
        let base = containerPadding
        guard let context else { return base }
        return max(0, base + context.containerPaddingAdjustment)
    }

    // MARK: - Size Metrics

    /// Minimum tap target size for buttons.
    /// Ranges from 44pt (extraSparse/sparse/regular) down to 32pt (extraDense).
    public var minimumTapTarget: CGFloat {
        switch density {
        case .extraSparse, .sparse, .regular: 44
        case .compact: 40
        case .dense: 36
        case .extraDense: 32
        }
    }

    /// Icon button size (square). Same as tap target.
    public var iconButtonSize: CGFloat {
        minimumTapTarget
    }

    /// Minimum width for primary buttons with labels.
    public var primaryButtonMinWidth: CGFloat {
        switch density {
        case .extraSparse, .sparse: 68
        case .regular: 62
        case .compact: 56
        case .dense: 50
        case .extraDense: 44
        }
    }

    /// Padding inside glass containers.
    public var containerPadding: CGFloat {
        switch density {
        case .extraSparse: 6
        case .sparse: 4
        case .regular: 3
        case .compact, .dense, .extraDense: 2
        }
    }

    /// Image scale for icons.
    public var imageScale: Image.Scale {
        switch density {
        case .extraSparse, .sparse, .regular, .compact: .medium
        case .dense, .extraDense: .small
        }
    }

    // MARK: - Spacing Metrics

    /// Padding from screen edges to toolbar content.
    public var edgePadding: CGFloat {
        switch density {
        case .extraSparse: 32
        case .sparse: 28
        case .regular: 24
        case .compact: 20
        case .dense: 16
        case .extraDense: 12
        }
    }

    /// Spacing between glass effect containers.
    public var containerSpacing: CGFloat {
        switch density {
        case .extraSparse: 24
        case .sparse: 20
        case .regular: 16
        case .compact: 12
        case .dense: 10
        case .extraDense: 6
        }
    }

    /// Padding for a component.
    public var componentPadding: CGFloat {
        switch density {
        case .extraSparse: 5
        case .sparse: 4
        case .regular: 3.5
        case .compact: 2
        case .dense: 1
        case .extraDense: 1
        }
    }

    /// Minimum spacing between container groups (for ViewThatFits).
    public var interGroupSpacing: CGFloat {
        0
    }

    /// Spacing between icon and label in primary buttons.
    public var primaryButtonSpacing: CGFloat {
        switch density {
        case .extraSparse, .sparse, .regular: 4
        case .compact, .dense: 3
        case .extraDense: 2
        }
    }
}

// MARK: - Accessibility-Safe Density

extension GlassDensity {
    /// Returns an accessibility-safe density, upgrading small tap targets when needed.
    ///
    /// When accessibility features suggest larger tap targets are beneficial,
    /// this method returns a denser option that still meets minimum guidelines.
    ///
    /// - Parameter isAccessibilityEnabled: Whether accessibility features are active.
    /// - Returns: The original density or an upgraded accessible alternative.
    public func accessibilitySafe(isAccessibilityEnabled: Bool) -> GlassDensity {
        guard isAccessibilityEnabled else { return self }

        switch self {
        case .dense, .extraDense:
            return .compact // Upgrade to at least 40pt tap targets
        default:
            return self
        }
    }
}
