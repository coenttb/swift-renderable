//
//  HTML.TextTag.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

import Rendering

extension HTML {
    /// Represents an HTML tag that typically contains text content.
    ///
    /// `HTML.TextTag` is a specialization of HTML tags for elements that primarily
    /// contain text content, such as `title`, `option`, and `textarea`. It provides
    /// a simpler API for setting text content.
    ///
    /// Example:
    /// ```swift
    /// // Empty title
    /// let emptyTitle = title()
    ///
    /// // Title with text
    /// let contentTitle = title("Page Title")
    ///
    /// // Title with dynamic text
    /// let dynamicTitle = title { getPageTitle() }
    /// ```
    public struct TextTag: ExpressibleByStringLiteral {
        /// The name of the HTML tag.
        public let rawValue: String

        /// Creates a new HTML text tag with the specified name.
        ///
        /// - Parameter rawValue: The name of the HTML tag.
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }

        /// Creates a new HTML text tag from a string literal.
        ///
        /// - Parameter value: The string literal representing the tag name.
        public init(stringLiteral value: String) {
            self.init(value)
        }

        /// Creates an HTML element with this tag and the provided text content.
        ///
        /// - Parameter content: The text content for this element.
        /// - Returns: An HTML element with this tag and the provided text content.
        public func callAsFunction(_ content: String = "") -> HTML.Element<HTML.Text> {
            tag(self.rawValue) { HTML.Text(content) }
        }

        /// Creates an HTML element with this tag and dynamically generated text content.
        ///
        /// - Parameter content: A closure that returns the text content for this element.
        /// - Returns: An HTML element with this tag and the provided text content.
        public func callAsFunction(_ content: () -> String) -> HTML.Element<HTML.Text> {
            tag(self.rawValue) { HTML.Text(content()) }
        }
    }
}
