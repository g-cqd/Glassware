//
//  View+ConditionalModifiers.swift
//  Glassware
//
//  Conditional view modifier extensions.
//

import SwiftUI

// MARK: - Conditional Modifier

extension View {
    /// Applies a transformation only when the optional value is non-nil.
    @ViewBuilder
    func ifLet<T, Content: View>(
        _ value: T?,
        @ViewBuilder transform: (Self, T) -> Content
    ) -> some View {
        if let value {
            transform(self, value)
        } else {
            self
        }
    }
}
