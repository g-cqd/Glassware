//
//  ToolbarDensity.swift
//  GlassToolbar
//
//  Density configuration for toolbar layout and sizing.
//

import SwiftUI

// MARK: - Toolbar Padding Configuration

/// Controls bottom padding behavior for the glass toolbar.
///
/// Use this to customize how the toolbar handles safe area insets at the bottom edge.
public struct ToolbarPaddingConfiguration: Sendable, Equatable {
    /// Additional padding from the safe area (or screen edge if ignoring safe area).
    public let additionalPadding: CGFloat

    /// Whether to ignore the bottom safe area (home indicator).
    public let ignoresSafeArea: Bool

    /// External padding from screen edges (horizontal margins).
    /// This value is always used regardless of density.
    public let externalPadding: CGFloat

    /// Default configuration: respects safe area with density-based padding.
    public static let `default` = ToolbarPaddingConfiguration(
        additionalPadding: -1,  // Sentinel: use density-based value
        ignoresSafeArea: false,
        externalPadding: 16
    )

    /// Tight configuration: minimal padding, stays close to bottom edge.
    public static let tight = ToolbarPaddingConfiguration(
        additionalPadding: 0,
        ignoresSafeArea: false,
        externalPadding: 16
    )

    /// Edge-to-edge configuration: ignores safe area, positioned at screen bottom.
    public static let edgeToEdge = ToolbarPaddingConfiguration(
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
    func resolvedAdditionalPadding(density: ToolbarDensity) -> CGFloat {
        if additionalPadding < 0 {
            return ToolbarMetrics(density: density).edgePadding
        }
        return additionalPadding
    }
}

// MARK: - Toolbar Layout Distribution

/// Controls how toolbar containers distribute space when some compartments are empty.
///
/// When leading, primary, or trailing compartments are empty, this configuration
/// determines whether the remaining content centers naturally or distributes evenly.
public enum ToolbarLayoutDistribution: Int, Sendable, Equatable {
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
public enum ToolbarDensity: Int, Sendable, Equatable, CaseIterable {
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

/// Provides computed layout metrics based on the density setting.
///
/// This struct centralizes all spacing and sizing calculations, reading from
/// the environment and providing appropriate values for the current configuration.
/// Use this instead of hard-coded values to ensure consistent adaptation.
///
/// ## Usage
/// ```swift
/// struct MyToolbarView: View {
///     @Environment(\.toolbarDensity) private var density
///
///     var body: some View {
///         let metrics = ToolbarMetrics(density: density)
///         // Use metrics.edgePadding, metrics.containerSpacing, etc.
///     }
/// }
/// ```
public struct ToolbarMetrics: Sendable {
    public let density: ToolbarDensity

    public init(density: ToolbarDensity) {
        self.density = density
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

extension ToolbarDensity {
    /// Returns an accessibility-safe density, upgrading small tap targets when needed.
    ///
    /// When accessibility features suggest larger tap targets are beneficial,
    /// this method returns a denser option that still meets minimum guidelines.
    ///
    /// - Parameter isAccessibilityEnabled: Whether accessibility features are active.
    /// - Returns: The original density or an upgraded accessible alternative.
    public func accessibilitySafe(isAccessibilityEnabled: Bool) -> ToolbarDensity {
        guard isAccessibilityEnabled else { return self }

        switch self {
        case .dense, .extraDense:
            return .compact // Upgrade to at least 40pt tap targets
        default:
            return self
        }
    }
}
