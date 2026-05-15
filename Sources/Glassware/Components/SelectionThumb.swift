//
//  SelectionThumb.swift
//  Glassware
//
//  Selection indicator for tab-style buttons and pickers.
//

import AemiSDR
import SwiftUI

// MARK: - Selection Thumb

/// Selection indicator with a subtle, elegant appearance on glass backgrounds.
///
/// Design approach:
/// - Solid white fill with transparency (not material-based)
/// - Slight black stroke for edge definition
/// - Very soft, small shadow for subtle depth
///
/// This white-based approach works universally:
/// - Dark mode: white glows softly against dark frosted glass
/// - Light mode: white adds brightness, stroke/shadow define edges
public struct SelectionThumb<S: Shape>: View {
    let shape: S

    public init(shape: S) {
        self.shape = shape
    }

    public var body: some View {
        shape
            .fill(.clear)
            .background {
                BackdropBlurView(
                    colorTint: Color.primary,
                    colorTintAlpha: GlassTokens.SelectionThumb.fillOpacity,
                    blurRadius: 10
                ).clipShape(shape)
            }
            .overlay {
                shape
                    .stroke(
                        Color.primary.opacity(GlassTokens.SelectionThumb.strokeOpacity),
                        lineWidth: GlassTokens.Border.lineWidth
                    )
            }
            .shadow(
                color: .black.opacity(GlassTokens.SelectionThumb.shadowOpacity),
                radius: GlassTokens.SelectionThumb.shadowRadius
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

#Preview("On Glass Background - Light") {
    ZStack {
        // Simulated glass background
        LinearGradient(
            colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        VStack(spacing: 24) {
            // Simulated glass container
            HStack(spacing: 16) {
                SelectionThumb(shape: Capsule())
                    .frame(width: 80, height: 36)

                SelectionThumb(shape: Circle())
                    .frame(width: 36, height: 36)
            }
            .padding(8)
            .background(.ultraThinMaterial, in: Capsule())

            // On solid dark background for comparison
            HStack(spacing: 16) {
                SelectionThumb(shape: Capsule())
                    .frame(width: 80, height: 36)

                SelectionThumb(shape: Circle())
                    .frame(width: 36, height: 36)
            }
            .padding(8)
            .background(Color.black.opacity(0.8), in: Capsule())

            // On solid light background for comparison
            HStack(spacing: 16) {
                SelectionThumb(shape: Capsule())
                    .frame(width: 80, height: 36)

                SelectionThumb(shape: Circle())
                    .frame(width: 36, height: 36)
            }
            .padding(8)
            .background(Color.white.opacity(0.9), in: Capsule())
        }
    }
    .preferredColorScheme(.light)
}

#Preview("On Glass Background - Dark") {
    ZStack {
        // Simulated glass background
        LinearGradient(
            colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        VStack(spacing: 24) {
            // Simulated glass container
            HStack(spacing: 16) {
                SelectionThumb(shape: Capsule())
                    .frame(width: 80, height: 36)

                SelectionThumb(shape: Circle())
                    .frame(width: 36, height: 36)
            }
            .padding(8)
            .background(.ultraThinMaterial, in: Capsule())

            // On solid dark background for comparison
            HStack(spacing: 16) {
                SelectionThumb(shape: Capsule())
                    .frame(width: 80, height: 36)

                SelectionThumb(shape: Circle())
                    .frame(width: 36, height: 36)
            }
            .padding(8)
            .background(Color.black.opacity(0.8), in: Capsule())

            // On solid light background for comparison
            HStack(spacing: 16) {
                SelectionThumb(shape: Capsule())
                    .frame(width: 80, height: 36)

                SelectionThumb(shape: Circle())
                    .frame(width: 36, height: 36)
            }
            .padding(8)
            .background(Color.white.opacity(0.9), in: Capsule())
        }
    }
    .preferredColorScheme(.dark)
}
