//
//  HTML.InlineStyle.swift
//
//
//  Created by Point-Free, Inc
//

import OrderedCollections
import Rendering

extension HTML {
    /// A wrapper that applies CSS styles to an HTML element.
    ///
    /// `HTML.InlineStyle` applies CSS styles to HTML elements by generating
    /// unique class names and collecting the associated styles in a stylesheet.
    /// This approach allows for efficient CSS generation and prevents duplication
    /// of styles across multiple elements.
    ///
    /// You typically don't create this type directly but use the `inlineStyle` method
    /// on HTML elements.
    ///
    /// Example:
    /// ```swift
    /// div {
    ///     p { "Styled text" }
    ///         .inlineStyle("color", "blue")
    ///         .inlineStyle("margin", "1rem")
    /// }
    /// ```
    public struct InlineStyle<Content: HTML.View>: HTML.View {
        /// The HTML content being styled.
        private let content: Content

        /// The collection of styles to apply.
        private var styles: [HTML.Style]

        /// Creates a new styled HTML element.
        ///
        /// - Parameters:
        ///   - content: The HTML element to style.
        ///   - property: The CSS property name.
        ///   - value: The value for the CSS property.
        ///   - mediaQuery: Optional media query for conditional styling.
        ///   - selector: Optional selector prefix.
        ///   - pseudo: Optional pseudo-class or pseudo-element.
        init(
            content: Content,
            property: String,
            value: String?,
            atRule: HTML.AtRule?,
            selector: HTML.Selector? = nil,
            pseudo: HTML.Pseudo?
        ) {
            self.content = content
            self.styles =
                value.map {
                    [
                        HTML.Style(
                            property: property,
                            value: $0,
                            atRule: atRule,
                            selector: selector,
                            pseudo: pseudo
                        )
                    ]
                }
                ?? []
        }

        // NOTE: We intentionally do NOT provide an inlineStyle method here.
        // Chaining falls through to the HTML.View extension, which wraps in a new
        // HTML.InlineStyle. This creates a linked chain that's flattened at
        // render time in O(n), avoiding the O(n²) copy-on-write overhead
        // that would occur if we accumulated styles in a single array.

        // Helper function to build CSS selector
        private static func buildSelector(className: String, style: HTML.Style) -> String {
            // Pre-calculate total length to avoid reallocations
            var totalLength = 1 + className.count  // "." + className
            if let pre = style.selector?.rawValue {
                totalLength += pre.count + 1  // prefix + space
            }
            if let pseudo = style.pseudo?.rawValue {
                totalLength += pseudo.count
            }

            var selector = ""
            selector.reserveCapacity(totalLength)

            if let pre = style.selector?.rawValue {
                selector.append(pre)
                selector.append(" ")
            }

            selector.append(".")
            selector.append(className)

            if let pseudo = style.pseudo?.rawValue {
                selector.append(pseudo)
            }

            return selector
        }

        /// Renders this styled HTML element into the provided buffer.
        public static func _render<Buffer: RangeReplaceableCollection>(
            _ html: HTML.InlineStyle<Content>,
            into buffer: inout Buffer,
            context: inout HTML.Context
        ) where Buffer.Element == UInt8 {
            let previousClass = context.attributes["class"]
            defer { context.attributes["class"] = previousClass }

            // Collect all styles from nested elements
            var allStyles: [HTML.Style] = []
            allStyles.reserveCapacity(8)
            var coreContent: any HTML.View = html

            // Flatten style chain (traverses outer-to-inner)
            while let styledElement = coreContent as? any HTMLInlineStyleProtocol {
                allStyles.append(contentsOf: styledElement.extractStyles())
                coreContent = styledElement.extractContent()
            }

            // Reverse to get original application order (inner-to-outer = first applied first)
            allStyles.reverse()

            guard !allStyles.isEmpty else {
                coreContent.render(into: &buffer, context: &context)
                return
            }

            // Generate class names using context-local sequential naming
            let classNames = context.classNames(for: allStyles)
            var classComponents: [String] = []
            classComponents.reserveCapacity(classNames.count)

            for (style, className) in zip(allStyles, classNames) {
                let selector = buildSelector(className: className, style: style)

                // Add to stylesheet if not present
                let key = HTML.StyleKey(style.atRule, selector)
                if context.styles[key] == nil {
                    context.styles[key] = style.property + ":" + style.value
                }

                classComponents.append(className)
            }

            // Apply class names
            if let existingClass = context.attributes["class"] {
                let totalLength = existingClass.count + 1 + classComponents.reduce(0) { $0 + $1.count } + (classComponents.count - 1)
                var result = ""
                result.reserveCapacity(totalLength)
                result.append(existingClass)
                result.append(" ")
                for (index, className) in classComponents.enumerated() {
                    if index > 0 {
                        result.append(" ")
                    }
                    result.append(className)
                }
                context.attributes["class"] = result
            } else {
                let totalLength = classComponents.reduce(0) { $0 + $1.count } + (classComponents.count - 1)
                var result = ""
                result.reserveCapacity(totalLength)
                for (index, className) in classComponents.enumerated() {
                    if index > 0 {
                        result.append(" ")
                    }
                    result.append(className)
                }
                context.attributes["class"] = result
            }

            coreContent.render(into: &buffer, context: &context)
        }

        /// This type uses direct rendering and doesn't have a body.
        public var body: Never { fatalError() }
    }
}

/// Extension to add inline styling capabilities to all HTML elements.
extension HTML.View {
    /// Applies a CSS style property to an HTML element.
    ///
    /// This method enables a type-safe, declarative approach to styling HTML elements
    /// directly in Swift code. It generates CSS classes and stylesheets automatically.
    ///
    /// Example:
    /// ```swift
    /// div {
    ///     "Hello, World!"
    /// }
    /// .inlineStyle("color", "red")
    /// .inlineStyle("font-weight", "bold", pseudo: .hover)
    /// ```
    ///
    /// - Parameters:
    ///   - property: The CSS property name (e.g., "color", "margin", "font-size").
    ///   - value: The value for the CSS property. Pass nil to omit this style.
    ///   - atRule: Optional media query to apply this style conditionally.
    ///   - pre: Optional selector prefix for more complex CSS selectors.
    ///   - pseudo: Optional pseudo-class or pseudo-element to apply (e.g., `:hover`, `::before`).
    /// - Returns: An HTML element with the specified style applied.
    public func inlineStyle(
        _ property: String,
        _ value: String?,
        atRule: HTML.AtRule? = nil,
        selector: HTML.Selector? = nil,
        pseudo: HTML.Pseudo? = nil
    ) -> HTML.InlineStyle<Self> {
        HTML.InlineStyle(
            content: self,
            property: property,
            value: value,
            atRule: atRule,
            selector: selector,
            pseudo: pseudo
        )
    }

    @_disfavoredOverload
    public func inlineStyle(
        _ property: String,
        _ value: String?,
        media: HTML.AtRule.Media? = nil,
        selector: HTML.Selector? = nil,
        pseudo: HTML.Pseudo? = nil
    ) -> HTML.InlineStyle<Self> {
        HTML.InlineStyle(
            content: self,
            property: property,
            value: value,
            atRule: media,
            selector: selector,
            pseudo: pseudo
        )
    }

    // For backwards compatibility. Also for future to transform the Media type into an AtRule.
    @available(*, deprecated, message: "change 'pre' to 'selector'")
    @_disfavoredOverload
    public func inlineStyle(
        _ property: String,
        _ value: String?,
        media mediaQuery: HTML.AtRule.Media? = nil,
        pre selector: HTML.Selector? = nil,
        pseudo: HTML.Pseudo? = nil
    ) -> HTML.InlineStyle<Self> {
        HTML.InlineStyle(
            content: self,
            property: property,
            value: value,
            atRule: mediaQuery,
            selector: selector,
            pseudo: pseudo
        )
    }
}

extension HTML {
    /// Represents a CSS style with its property, value, and selectors.
    ///
    /// Used internally for tracking styles and generating deterministic class names.
    package struct Style: Hashable, Sendable {
        let property: String
        let value: String
        let atRule: HTML.AtRule?
        let selector: HTML.Selector?
        let pseudo: HTML.Pseudo?
    }
}

// Make HTML.InlineStyle conform to the protocol
extension HTML.InlineStyle: HTMLInlineStyleProtocol {
    func extractStyles() -> [HTML.Style] {
        return styles
    }

    func extractContent() -> any HTML.View {
        return content
    }
}

extension HTML.InlineStyle: Sendable where Content: Sendable {}

