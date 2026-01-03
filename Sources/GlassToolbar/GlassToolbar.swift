//
//  GlassToolbar.swift
//  GlassToolbar
//
//  A SwiftUI package for creating glass-effect toolbars with iOS 26+ glass effects.
//
//  Created with Claude Code.
//

import SwiftUI

// MARK: - Public Exports
//
// This file serves as the main entry point for the GlassToolbar package.
// All public types are re-exported from their respective modules.

// Types are automatically available through their individual files:
//
// Environment:
// - ToolbarDensity
// - ToolbarEdge
// - ToolbarButtonPlacement
// - ToolbarMetrics
// - ToolbarPaddingConfiguration
// - ToolbarLayoutDistribution
//
// Placement API:
// - GlassToolbarPlacement
// - GlassToolbarItem
// - GlassToolbarItemGroup
// - GlassToolbarContent
// - GlassToolbarBuilder
// - AnyGlassToolbarContent
//
// Styles:
// - ToolbarItemIntent
// - ToolbarItemVisualStyle
// - ToolbarItemButtonStyle
// - PrimaryToolbarLabelStyle
//
// Components:
// - ToolbarItem
// - ToolbarContentBuilder
// - SegmentedPicker
// - SegmentedPickerItem
// - SegmentedPickerStyle
// - ToolbarMenuPicker
//
// Tokens:
// - ToolbarTokens
//
// Collapse/Fusion:
// - ToolbarMergeSide
// - ToolbarCollapseState
// - ToolbarCollapseConfiguration
// - ToolbarHeightReport
//
// View Extensions:
// - View.glassToolbar(edge:glass:leading:content:trailing:)
// - View.glassToolbarOverlay(glass:content:)
// - View.toolbarDensity(_:)
// - View.toolbarPadding(_:)
// - View.toolbarDistribution(_:)
// - View.trackScrollOffset(_:)
// - View.toolbarCollapseEnabled(configuration:scrollOffset:)
// - View.toolbarCollapseConfiguration(_:)
// - View.glassToolbarContentPadding()
//
// Button Style Extensions:
// - ButtonStyle.toolbarItem(intent:style:isSelected:)
//
// Color Extensions:
// - Color.inverted
