//
//  VisualSelectionEnvironment.swift
//  Glassware
//
//  Environment support for visual selection during picker drag.
//

import SwiftUI

// MARK: - Visual Selection State

/// Sendable wrapper for visual selection state.
///
/// - Note: Uses hash comparison which could theoretically have collisions.
///   For the expected use case (small number of picker items), this is acceptable.
struct VisualSelectionState: Sendable, Equatable {
    private let hashValue: Int

    init<Value: Hashable>(_ value: Value) {
        self.hashValue = value.hashValue
    }

    func matches<Value: Hashable>(_ value: Value) -> Bool {
        value.hashValue == hashValue
    }
}

// MARK: - Environment Key

/// Environment key for passing visual selection ID during drag.
struct VisualSelectionKey: EnvironmentKey {
    static let defaultValue: VisualSelectionState? = nil
}

extension EnvironmentValues {
    /// The value currently under the drag thumb (visual selection during drag).
    var pickerVisualSelection: VisualSelectionState? {
        get { self[VisualSelectionKey.self] }
        set { self[VisualSelectionKey.self] = newValue }
    }
}
