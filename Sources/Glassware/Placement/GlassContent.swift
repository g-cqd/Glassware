//
//  GlassContent.swift
//  Glassware
//
//  Protocol and result builder for composing placement-based toolbar content.
//

import SwiftUI

// MARK: - Glass Toolbar Content Protocol

/// Protocol for views that can be placed in a glass toolbar overlay.
///
/// Types conforming to this protocol provide placement information used by
/// the toolbar overlay modifier to position content at the appropriate edges.
public protocol GlassContent: View {
    /// The placement determining where this content appears in the overlay.
    var placement: GlassPlacement { get }
}

// MARK: - Glass Toolbar Builder

/// A result builder for composing glass toolbar content.
///
/// Use this builder with `glassToolbarOverlay` to declaratively specify
/// toolbar items at multiple placements.
///
/// ## Usage
/// ```swift
/// .glass {
///     GlassItem(placement: .bottomLeading) { settingsButton }
///     GlassItemGroup(placement: .bottomPrimary) { tabs }
///     if showFilter {
///         GlassItem(placement: .topTrailing) { filterButton }
///     }
/// }
/// ```
@MainActor
@resultBuilder
public struct GlassBuilder {
    /// Builds an array from a single content element.
    public static func buildExpression<Content: GlassContent>(_ expression: Content) -> [AnyGlassContent] {
        [AnyGlassContent(expression)]
    }

    /// Combines multiple content arrays into one.
    public static func buildBlock(_ components: [AnyGlassContent]...) -> [AnyGlassContent] {
        components.flatMap { $0 }
    }

    /// Handles optional content.
    public static func buildOptional(_ component: [AnyGlassContent]?) -> [AnyGlassContent] {
        component ?? []
    }

    /// Handles the first branch of an if-else.
    public static func buildEither(first component: [AnyGlassContent]) -> [AnyGlassContent] {
        component
    }

    /// Handles the second branch of an if-else.
    public static func buildEither(second component: [AnyGlassContent]) -> [AnyGlassContent] {
        component
    }

    /// Handles for-in loops.
    public static func buildArray(_ components: [[AnyGlassContent]]) -> [AnyGlassContent] {
        components.flatMap { $0 }
    }

    /// Handles availability checks.
    public static func buildLimitedAvailability(_ component: [AnyGlassContent]) -> [AnyGlassContent] {
        component
    }
}

// MARK: - Type-Erased Toolbar Content

/// Type-erased wrapper for glass toolbar content.
///
/// This wrapper enables heterogeneous collections of toolbar content
/// while preserving placement information.
public struct AnyGlassContent: GlassContent {
    public let placement: GlassPlacement
    private let _body: AnyView

    /// Creates a type-erased wrapper around the given toolbar content.
    public init<Content: GlassContent>(_ content: Content) {
        self.placement = content.placement
        self._body = AnyView(content)
    }

    public var body: some View {
        _body
    }
}
