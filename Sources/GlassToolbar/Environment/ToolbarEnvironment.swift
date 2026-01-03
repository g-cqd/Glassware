//
//  ToolbarEnvironment.swift
//  GlassToolbar
//
//  Environment keys for toolbar configuration.
//

import SwiftUI

// MARK: - Toolbar Button Placement

/// Defines the placement context for toolbar buttons.
///
/// Performance note: Using enum with raw Int enables O(1) switch dispatch
/// via jump table. Sendable conformance allows safe cross-actor usage.
public enum ToolbarButtonPlacement: Int, Sendable, Equatable {
    case leading = 0
    case primary = 1
    case trailing = 2
}

// MARK: - Environment Keys

extension EnvironmentValues {
    /// The placement context for toolbar buttons.
    /// Set automatically by GlassToolbar based on container position.
    @Entry public var toolbarButtonPlacement: ToolbarButtonPlacement = .primary

    /// The density level for the toolbar.
    /// Affects both item sizing and spacing between items.
    @Entry public var toolbarDensity: ToolbarDensity = .regular

    /// The namespace for toolbar selection animation within a container.
    /// Each container creates its own namespace to ensure matchedGeometryEffect
    /// only animates between items in the same container.
    @Entry public var toolbarContainerNamespace: Namespace.ID? = nil

    /// Padding configuration for the glass toolbar.
    /// Controls safe area handling and external margins.
    @Entry public var toolbarPaddingConfiguration: ToolbarPaddingConfiguration = .default

    /// Layout distribution for the glass toolbar.
    /// Controls how containers distribute space when compartments are empty.
    @Entry public var toolbarLayoutDistribution: ToolbarLayoutDistribution = .natural
}

// MARK: - View Extension for Density

extension View {
    /// Sets the toolbar density for this view and its descendants.
    ///
    /// - Parameter density: The density level to apply.
    /// - Returns: A view with the modified toolbar density.
    public func toolbarDensity(_ density: ToolbarDensity) -> some View {
        environment(\.toolbarDensity, density)
    }

    /// Sets the toolbar padding configuration for this view and its descendants.
    ///
    /// - Parameter configuration: The padding configuration to apply.
    /// - Returns: A view with the modified toolbar padding.
    public func toolbarPadding(_ configuration: ToolbarPaddingConfiguration) -> some View {
        environment(\.toolbarPaddingConfiguration, configuration)
    }

    /// Sets the toolbar layout distribution for this view and its descendants.
    ///
    /// - Parameter distribution: The layout distribution to apply.
    /// - Returns: A view with the modified toolbar layout.
    public func toolbarDistribution(_ distribution: ToolbarLayoutDistribution) -> some View {
        environment(\.toolbarLayoutDistribution, distribution)
    }
}
