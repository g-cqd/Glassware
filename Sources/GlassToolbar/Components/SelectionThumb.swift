//
//  SelectionThumb.swift
//  GlassToolbar
//
//  Selection indicator for tab-style buttons and pickers.
//

import SwiftUI

// MARK: - Selection Thumb

/// Selection indicator that contrasts with the glass background.
///
/// Glass backgrounds are bright/white, so the thumb uses:
/// - Light mode: white fill (contrasts with dark text)
/// - Dark mode: black fill (contrasts with light text)
///
/// The inverted primary color ensures proper contrast in both schemes.
public struct SelectionThumb<S: Shape>: View {
    let shape: S

    public init(shape: S) {
        self.shape = shape
    }

    public var body: some View {
        shape
            .fill(Color.primary.inverted.opacity(ToolbarTokens.Opacity.backgroundFill))
            .overlay {
                shape
                    .stroke(
                        Color.primary.inverted.opacity(ToolbarTokens.Opacity.borderStroke),
                        lineWidth: ToolbarTokens.Border.lineWidth
                    )
            }
            .shadow(
                color: .black.opacity(ToolbarTokens.Shadow.opacity),
                radius: ToolbarTokens.Shadow.radius
            )
    }
}

// MARK: - Previews

#Preview("Selection Thumb") {
    VStack(spacing: 32) {
        HStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Capsule")
                    .font(.caption)
                SelectionThumb(shape: Capsule())
                    .frame(width: 100, height: 40)
            }
            VStack(spacing: 8) {
                Text("Circle")
                    .font(.caption)
                SelectionThumb(shape: Circle())
                    .frame(width: 40, height: 40)
            }
        }
    }
    .padding()
}
