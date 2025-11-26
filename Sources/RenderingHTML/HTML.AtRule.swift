//
//  HTML.AtRule.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 16/04/2025.
//

import Rendering

extension HTML {
    /// Represents a CSS media query for conditional styling.
    ///
    /// `HTML.AtRule` allows you to apply styles conditionally based on
    /// device characteristics or user preferences.
    ///
    /// Example:
    /// ```swift
    /// div { "Dark mode text" }
    ///     .inlineStyle("color", "white", media: .dark)
    /// ```
    ///
    /// You can use the predefined media queries or create custom ones.
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
}
