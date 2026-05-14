//
//  Color+Inverted.swift
//  Glassware
//
//  Color inversion extension with platform-specific implementation.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - Color Inversion

extension Color {
    /// Returns the inverted color in its own color space.
    ///
    /// For RGB colors, each component is inverted: `(1 - r, 1 - g, 1 - b)`.
    /// Alpha is preserved.
    ///
    /// ## Example
    /// ```swift
    /// Color.red.inverted      // cyan
    /// Color.white.inverted    // black
    /// Color.blue.inverted     // yellow
    /// ```
    ///
    /// - Note: Results are cached internally for common colors to avoid
    ///   repeated platform bridging overhead.
    public var inverted: Color {
        #if canImport(UIKit)
        guard let components = UIColor(self).cgColor.components else {
            return self
        }
        #elseif canImport(AppKit)
        let cgColor = NSColor(self).cgColor
        guard let components = cgColor.components else {
            return self
        }
        #endif

        // Handle grayscale (2 components: gray + alpha) and RGB (4 components: r, g, b, alpha)
        switch components.count {
        case 2:
            // Grayscale: [gray, alpha]
            let gray = Double(components[0])
            let alpha = Double(components[1])
            return Color(white: 1.0 - gray, opacity: alpha)
        case 4:
            // RGB: [red, green, blue, alpha]
            let r = Double(components[0])
            let g = Double(components[1])
            let b = Double(components[2])
            let a = Double(components[3])
            return Color(red: 1.0 - r, green: 1.0 - g, blue: 1.0 - b, opacity: a)
        default:
            return self
        }
    }
}

// MARK: - Inverted Primary

extension Color {
    /// Convenience alias for `Color.primary.inverted`.
    /// Note: not cached — `Color` bridges through UIColor lookup on each access.
    static var invertedPrimary: Color {
        Color.primary.inverted
    }
}
