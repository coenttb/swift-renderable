//
//  File.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

/// Represents an HTML void element that cannot contain content.
///
/// `HTMLVoidTag` is a specialization of HTML tags for elements that are
/// self-closing and cannot contain content, such as `img`, `br`, and `input`.
///
/// Example:
/// ```swift
/// // Create an image element
/// let image = img().src("image.jpg").alt("An image")
///
/// // Create a line break
/// let lineBreak = br()
/// ```
public struct HTMLVoidTag: ExpressibleByStringLiteral {
    /// A set of all HTML void element tag names.
    public static let allTags: Set<String> = [
        "area",
        "base",
        "br",
        "col",
        "command",
        "embed",
        "hr",
        "img",
        "input",
        "keygen",
        "link",
        "meta",
        "param",
        "source",
        "track",
        "wbr",
    ]

    /// The name of the HTML void tag.
    public let rawValue: String

    /// Creates a new HTML void tag with the specified name.
    ///
    /// - Parameter rawValue: The name of the HTML void tag.
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    /// Creates a new HTML void tag from a string literal.
    ///
    /// - Parameter value: The string literal representing the tag name.
    public init(stringLiteral value: String) {
        self.init(value)
    }

    /// Creates an HTML void element with this tag.
    ///
    /// - Returns: An HTML void element with this tag.
    public func callAsFunction() -> HTMLElement<HTMLEmpty> {
        tag(self.rawValue) { HTMLEmpty() }
    }
}
