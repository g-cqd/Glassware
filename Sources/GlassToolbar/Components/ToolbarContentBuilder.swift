//
//  ToolbarContentBuilder.swift
//  GlassToolbar
//
//  Result builder for toolbar content DSL.
//

import SwiftUI

// MARK: - Toolbar Item

/// Represents a single element in toolbar content.
///
/// Note on AnyView: While AnyView has performance implications (type erasure
/// prevents structural identity optimization), it's necessary here for
/// heterogeneous collection support. The impact is mitigated by:
/// - Single AnyView wrap per item (not double)
/// - Index-based stable identity (not UUID)
/// - Parsing happens once in modifier init, not in body
public enum ToolbarItem {
    case view(AnyView)
    case spacer(Spacer)
}

// MARK: - Result Builder

/// Result builder for toolbar content DSL.
///
/// Enables declarative syntax for defining toolbar content:
/// ```swift
/// .glassToolbar {
///     Button("Home") { }
///         .buttonStyle(.toolbarItem(isSelected: true))
///     Spacer()
///     Button("Settings") { }
///         .buttonStyle(.toolbarItem(intent: .action))
/// }
/// ```
///
/// - Complexity: O(n) where n is the number of builder expressions
@resultBuilder
public struct ToolbarContentBuilder {
    public static func buildExpression(_ spacer: Spacer) -> [ToolbarItem] {
        [.spacer(spacer)]
    }

    public static func buildExpression<V: View>(_ view: V) -> [ToolbarItem] {
        [.view(AnyView(view))]
    }

    public static func buildBlock(_ components: [ToolbarItem]...) -> [ToolbarItem] {
        components.flatMap { $0 }
    }

    public static func buildOptional(_ component: [ToolbarItem]?) -> [ToolbarItem] {
        component ?? []
    }

    public static func buildEither(first component: [ToolbarItem]) -> [ToolbarItem] {
        component
    }

    public static func buildEither(second component: [ToolbarItem]) -> [ToolbarItem] {
        component
    }

    public static func buildArray(_ components: [[ToolbarItem]]) -> [ToolbarItem] {
        components.flatMap { $0 }
    }
}

// MARK: - Toolbar Group

/// Groups views between spacers with stable identity.
struct ToolbarGroup: Identifiable {
    let id: Int
    let items: [AnyView]
    let trailingSpacer: CGFloat?
}

// MARK: - Item Parsing

/// Parses flat element array into groups separated by spacers.
///
/// - Parameter elements: Flat array of toolbar items
/// - Returns: Array of groups, each containing items and optional trailing spacer
/// - Complexity: O(n) where n is element count
func parseItems(_ items: [ToolbarItem]) -> [ToolbarGroup] {
    var groups: [ToolbarGroup] = []
    var currentItems: [AnyView] = []

    for item in items {
        switch item {
        case .view(let view):
            currentItems.append(view)
        case .spacer(let spacer):
            if !currentItems.isEmpty {
                groups.append(
                    ToolbarGroup(
                        id: groups.count,
                        items: currentItems,
                        trailingSpacer: spacer.minLength
                    )
                )
                currentItems = []
            }
        }
    }

    if !currentItems.isEmpty {
        groups.append(
            ToolbarGroup(
                id: groups.count,
                items: currentItems,
                trailingSpacer: nil
            )
        )
    }

    return groups
}
