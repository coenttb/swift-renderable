//
//  Rendering.Element.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 08/12/2025.
//

import OrderedCollections

/// Namespace for rendering primitives shared between HTML and PDF.
public enum Rendering {}

extension Rendering {
    /// A generic element with a tag name, attributes, and content.
    ///
    /// `Rendering.Element` provides the foundational structure for elements in both
    /// HTML and PDF rendering. The tag identifies the element type, and metadata
    /// (isBlock, isVoid) controls rendering behavior in each format.
    ///
    /// ## Usage
    ///
    /// This type is typically not used directly. Instead, use format-specific
    /// typealiases like `HTML.Element` which provide convenient initializers:
    ///
    /// ```swift
    /// // Via HTML.Element typealias
    /// HTML.Element(for: WHATWG_HTML.Grouping.Div.self) {
    ///     "Hello, world!"
    /// }
    /// ```
    ///
    /// ## Dual Rendering
    ///
    /// When `Content` conforms to both `HTML.View` and `PDF.View`, this element
    /// can be rendered to either format:
    ///
    /// ```swift
    /// let element = div { p { "Hello" } }
    ///
    /// // Render to HTML
    /// let html = [UInt8](element)
    ///
    /// // Render to PDF
    /// element.renderToPDF(context: &pdfContext)
    /// ```
    public struct Element<Content> {
        /// The tag name (e.g., "div", "p", "span").
        public let tagName: String

        /// Whether this is a block-level element.
        ///
        /// Block elements start on a new line and take up the full width available.
        /// In HTML, this affects pretty-printing indentation.
        /// In PDF, this triggers inline run flushing.
        public let isBlock: Bool

        /// Whether this is a void element (no closing tag).
        ///
        /// Void elements like `<br>`, `<img>`, `<input>` have no content and
        /// no closing tag in HTML. In PDF, they render as atomic units.
        public let isVoid: Bool

        /// Whether whitespace should be preserved.
        ///
        /// When true (e.g., for `<pre>` elements), whitespace in content
        /// is preserved rather than collapsed.
        public let preservesWhitespace: Bool

        /// The element's attributes as key-value pairs.
        ///
        /// Attributes are rendered in insertion order.
        public var attributes: OrderedDictionary<String, String>

        /// The element's content (children).
        ///
        /// Nil for void elements or elements with no content.
        public let content: Content?

        /// Creates a new element with the specified properties.
        ///
        /// - Parameters:
        ///   - tagName: The HTML tag name.
        ///   - isBlock: Whether this is a block-level element. Defaults to `true`.
        ///   - isVoid: Whether this is a void element. Defaults to `false`.
        ///   - preservesWhitespace: Whether to preserve whitespace. Defaults to `false`.
        ///   - attributes: Initial attributes. Defaults to empty.
        ///   - content: The element's content.
        public init(
            tagName: String,
            isBlock: Bool = true,
            isVoid: Bool = false,
            preservesWhitespace: Bool = false,
            attributes: OrderedDictionary<String, String> = [:],
            content: Content?
        ) {
            self.tagName = tagName
            self.isBlock = isBlock
            self.isVoid = isVoid
            self.preservesWhitespace = preservesWhitespace
            self.attributes = attributes
            self.content = content
        }
    }
}

// MARK: - Conditional Conformances

extension Rendering.Element: Sendable where Content: Sendable {}
extension Rendering.Element: Equatable where Content: Equatable {}
extension Rendering.Element: Hashable where Content: Hashable {}

// NOTE: Rendering.Element does NOT conform to Renderable here.
// Format-specific packages (swift-html-rendering, swift-pdf-rendering) provide
// the conformance through their own protocols (HTML.View, PDF.View) that inherit
// from Renderable. This avoids conflicts between multiple _render implementations.

// MARK: - Attribute Modification

extension Rendering.Element {
    /// Returns a copy of this element with an additional attribute.
    ///
    /// - Parameters:
    ///   - name: The attribute name.
    ///   - value: The attribute value. Pass `nil` to add a boolean attribute,
    ///            or an empty string for attributes without values.
    /// - Returns: A new element with the attribute added.
    public func attribute(_ name: String, _ value: String? = "") -> Self {
        var copy = self
        if let value = value {
            copy.attributes[name] = value
        }
        return copy
    }

    /// Returns a copy of this element with modified attributes.
    ///
    /// - Parameter modifier: A closure that modifies the attributes dictionary.
    /// - Returns: A new element with modified attributes.
    public func modifyingAttributes(
        _ modifier: (inout OrderedDictionary<String, String>) -> Void
    ) -> Self {
        var copy = self
        modifier(&copy.attributes)
        return copy
    }
}
