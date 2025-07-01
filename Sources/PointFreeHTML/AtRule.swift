//
//  AtRule.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 16/04/2025.
//

import Foundation



/// Represents a CSS media query for conditional styling.
///
/// `MediaQuery` allows you to apply styles conditionally based on
/// device characteristics or user preferences.
///
/// Example:
/// ```swift
/// div { "Dark mode text" }
///     .inlineStyle("color", "white", atRule: .dark)
/// ```
///
/// You can use the predefined media queries or create custom ones.
/// This struct is provided for backward compatibility and should be replaced
/// with CSSAtRuleTypes.Media in the future.
public struct AtRule: RawRepresentable, Hashable, Sendable {
    /// Creates a media query with the specified CSS media query string.
    ///
    /// - Parameter rawValue: The CSS media query string.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    /// The CSS media query string.
    public var rawValue: String
}

//extension AtRule: AtRule {
//    public static var identifier: String {
//        return "media"
//    }
//}

/// Predefined common media queries.
extension AtRule {
    /// Targets devices in dark mode.
    public static let dark = Self(rawValue: "@media (prefers-color-scheme: dark)")
    
    /// Targets print media (when the page is being printed).
    public static let print = Self(rawValue: "@media print")
}
