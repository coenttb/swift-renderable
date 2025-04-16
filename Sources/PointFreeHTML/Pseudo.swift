//
//  File.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 16/04/2025.
//

import Foundation

/// Represents CSS pseudo-classes and pseudo-elements.
///
/// `Pseudo` allows you to apply styles to elements in specific states
/// or to target specific parts of elements.
///
/// Example:
/// ```swift
/// button { "Hover me" }
///     .inlineStyle("background-color", "blue")
///     .inlineStyle("background-color", "red", pseudo: .hover)
/// ```
public struct Pseudo: RawRepresentable, Hashable, Sendable {
    /// The CSS pseudo-class or pseudo-element selector.
    public var rawValue: String
    
    /// Creates a pseudo-selector with the specified CSS selector string.
    ///
    /// - Parameter rawValue: The CSS pseudo-selector string.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public static let active = Self(rawValue: ":active")
    public static let after = Self(rawValue: "::after")
    public static let before = Self(rawValue: "::before")
    public static let checked = Self(rawValue: ":checked")
    public static let disabled = Self(rawValue: ":disabled")
    public static let empty = Self(rawValue: ":empty")
    public static let enabled = Self(rawValue: ":enabled")
    public static let firstChild = Self(rawValue: ":first-child")
    public static let firstOfType = Self(rawValue: ":first-of-type")
    public static let focus = Self(rawValue: ":focus")
    public static let hover = Self(rawValue: ":hover")
    public static let inRange = Self(rawValue: ":in-range")
    public static let invalid = Self(rawValue: ":invalid")
    public static func `is`(_ s: String) -> Self { Self(rawValue: ":is(\(s))") }
    public static let lang = Self(rawValue: ":lang")
    public static let lastChild = Self(rawValue: ":last-child")
    public static let lastOfType = Self(rawValue: ":last-of-type")
    public static let link = Self(rawValue: ":link")
    public static func nthChild(_ n: String) -> Self { Self(rawValue: ":nth-child(\(n))") }
    public static func nthLastChild(_ n: String) -> Self { Self(rawValue: ":nth-last-child(\(n))") }
    public static func nthLastOfType(_ n: String) -> Self { Self(rawValue: ":nth-last-of-type(\(n))")
}
    public static func nthOfType(_ n: String) -> Self { Self(rawValue: ":nth-of-type(\(n))") }
    public static let onlyChild = Self(rawValue: ":only-child")
    public static let onlyOfType = Self(rawValue: ":only-of-type")
    public static let optional = Self(rawValue: ":optional")
    public static let outOfRange = Self(rawValue: ":out-of-range")
    public static let readOnly = Self(rawValue: ":read-only")
    public static let readWrite = Self(rawValue: ":read-write")
    public static let required = Self(rawValue: ":required")
    public static let root = Self(rawValue: ":root")
    public static let target = Self(rawValue: ":target")
    public static let valid = Self(rawValue: ":valid")
    public static let visited = Self(rawValue: ":visited")
    public static func not(_ other: Self) -> Self { Self(rawValue: ":not(\(other.rawValue))") }

    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(rawValue: lhs.rawValue + rhs.rawValue)
    }
}
