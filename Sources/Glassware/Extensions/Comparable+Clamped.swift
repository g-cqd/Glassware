//
//  Comparable+Clamped.swift
//  Glassware
//
//  Clamping extension for comparable types.
//

import Foundation

// MARK: - Clamped Extension

extension Comparable {
    /// Returns the value clamped to the given closed range.
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
