# GlassToolbar

A SwiftUI package for creating beautiful glass-effect toolbars using iOS 26+ glass effects.

## Requirements

- iOS 26.0+
- macOS 26.0+ (best-effort support)
- Swift 6.0+
- Xcode 26.0+

## Installation

### Swift Package Manager

Add GlassToolbar to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/GlassToolbar.git", from: "1.0.0")
]
```

## Quick Start

```swift
import SwiftUI
import GlassToolbar

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        Text("Hello, World!")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .glassToolbar {
                Button("Home") { selectedTab = 0 }
                    .buttonStyle(.toolbarItem(isSelected: selectedTab == 0))
                Button("Search") { selectedTab = 1 }
                    .buttonStyle(.toolbarItem(isSelected: selectedTab == 1))
            } trailing: {
                Button("Settings") { }
                    .buttonStyle(.toolbarItem(intent: .action, style: .iconOnly(systemImage: "gear")))
            }
    }
}
```

## Features

### Glass Effect Toolbar

Position toolbars at any edge with automatic layout adaptation:

```swift
// Bottom toolbar (default)
.glassToolbar { ... }

// Top toolbar
.glassToolbar(edge: .top) { ... }

// Side toolbars (vertical layout)
.glassToolbar(edge: .leading) { ... }
.glassToolbar(edge: .trailing) { ... }
```

### Button Styles

Two button intents for different use cases:

```swift
// Tab navigation with selection state
Button("Home", systemImage: "house") { }
    .buttonStyle(.toolbarItem(isSelected: true))

// Action buttons
Button("Share", systemImage: "square.and.arrow.up") { }
    .buttonStyle(.toolbarItem(intent: .action))
```

### Visual Styles

Three visual layouts for buttons:

```swift
// Title and icon (default)
.buttonStyle(.toolbarItem(style: .titleAndIcon))

// Icon only
.buttonStyle(.toolbarItem(style: .iconOnly(systemImage: "plus")))

// Title only
.buttonStyle(.toolbarItem(style: .titleOnly))
```

### Density Control

Adjust toolbar density for different use cases:

```swift
.glassToolbar { ... }
    .toolbarDensity(.sparse)      // Spacious
    .toolbarDensity(.regular)     // Default
    .toolbarDensity(.compact)     // Tighter
    .toolbarDensity(.dense)       // Compact
```

### Segmented Picker

A custom picker with draggable selection capsule:

```swift
@State private var selected: Tab = .home

SegmentedPicker(selection: $selected, style: .titleAndIcon) {
    ForEach(Tab.allCases, id: \.self) { tab in
        SegmentedPickerItem(
            tab,
            systemImage: tab.icon,
            style: .titleAndIcon,
            isSelected: selected == tab
        ) {
            Text(tab.title)
        }
    }
}
```

## Accessibility

GlassToolbar includes comprehensive accessibility support:

- **VoiceOver**: All buttons include accessibility hints and traits
- **Dynamic Type**: Sizes scale with user's text size preferences
- **Reduced Motion**: Animations respect `accessibilityReduceMotion`
- **Adjustable Action**: SegmentedPicker supports swipe gestures for VoiceOver

## Design Tokens

All magic numbers are centralized in `ToolbarTokens` for easy customization:

```swift
ToolbarTokens.Opacity.backgroundFill   // 0.3
ToolbarTokens.Shadow.radius            // 5
ToolbarTokens.Animation.selectionDuration  // 0.25
```

## Architecture

```
GlassToolbar/
├── Tokens/           # Design tokens
├── Environment/      # Density, Edge, Environment keys
├── Styles/           # Button and label styles
├── Components/       # Container, Builder, Picker
├── Modifiers/        # View modifiers
└── Extensions/       # View, Color extensions
```

## License

MIT License
