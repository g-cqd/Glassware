//
//  Collection+SafeAccess.swift
//  Glassware
//
//  Safe subscript access for collections.
//

import Foundation

// MARK: - Safe Collection Access

extension RandomAccessCollection {
    /// Safely access element at index, returning nil if out of bounds.
    subscript(safe index: Index?) -> Element? {
        if let index, index >= startIndex, index < endIndex {
            self[index]
        } else {
            nil
        }
    }
}
