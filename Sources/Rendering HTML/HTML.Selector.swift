//
//  HTML.Selector.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 16/04/2025.
//

import Rendering

extension HTML {
    /// Represents a CSS selector for targeting HTML elements.
    ///
    /// `HTML.Selector` provides a type-safe way to construct CSS selectors using Swift syntax.
    /// It supports all CSS selector types including element selectors, class selectors,
    /// ID selectors, attribute selectors, and complex combinators.
    ///
    /// ## Basic Usage
    ///
    /// ```swift
    /// // Element selector
    /// let div: HTML.Selector = "div"
    ///
    /// // Class selector
    /// let header: HTML.Selector = .class("header")
    ///
    /// // ID selector
    /// let main: HTML.Selector = .id("main")
    ///
    /// // Using with inline styles
    /// tag("div") { "Content" }
    ///     .inlineStyle("color", "red", selector: .init(rawValue: "div"))
    /// ```
    ///
    /// ## Combinators
    ///
    /// CSS combinators allow you to select elements based on their relationship:
    ///
    /// ```swift
    /// let div: HTML.Selector = "div"
    /// let p: HTML.Selector = "p"
    ///
    /// // Child combinator: div > p
    /// let childSelector = p.child(of: div)
    ///
    /// // Descendant combinator: div p
    /// let descendantSelector = p.descendant(of: div)
    ///
    /// // Next sibling combinator: div + p
    /// let nextSiblingSelector = p.nextSibling(of: div)
    ///
    /// // Subsequent sibling combinator: div ~ p
    /// let subsequentSiblingSelector = p.subsequentSibling(of: div)
    /// ```
    ///
    /// ## Attribute Selectors
    ///
    /// Target elements based on their attributes:
    ///
    /// ```swift
    /// // Element with attribute: [disabled]
    /// let disabled: HTML.Selector = .hasAttribute("disabled")
    ///
    /// // Attribute equals: [type="submit"]
    /// let submitButton: HTML.Selector = .attribute("type", equals: "submit")
    ///
    /// // Attribute starts with: [href^="https"]
    /// let httpsLinks: HTML.Selector = .attribute("href", startsWith: "https")
    /// ```
    ///
    /// ## Selector Lists and Compound Selectors
    ///
    /// ```swift
    /// // Selector list (OR): h1, h2, h3
    /// let headings: HTML.Selector = ("h1" as HTML.Selector).or("h2", "h3")
    ///
    /// // Compound selector (AND): div.header#main
    /// let specificDiv: HTML.Selector = ("div" as HTML.Selector).and(.class("header")).and(.id("main"))
    ///
    /// // Using convenience methods
    /// let navHeader: HTML.Selector = ("div" as HTML.Selector).withClass("nav").withId("header")
    /// ```
    public struct Selector: RawRepresentable, Hashable, Sendable, ExpressibleByStringLiteral,
        ExpressibleByStringInterpolation
    {
    /// The raw CSS selector string.
    public var rawValue: String

    /// Creates a selector with the specified CSS selector string.
    ///
    /// - Parameter rawValue: The CSS selector string (e.g., "div", ".class", "#id").
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Creates a selector from a string literal.
    ///
    /// This allows you to write:
    /// ```swift
    /// let div: Selector = "div"
    /// ```
    ///
    /// - Parameter value: The CSS selector string.
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
    }
}

// MARK: - CSS Combinators
extension HTML.Selector {

    /// Creates a descendant combinator selector.
    ///
    /// The descendant combinator selects all elements that are descendants of a specified element.
    /// It matches any element that is contained within another element, regardless of nesting depth.
    ///
    /// ```swift
    /// let div: Selector = "div"
    /// let span: Selector = "span"
    /// let selector = span.descendant(of: div)  // "div span"
    /// ```
    ///
    /// This generates the CSS selector `div span`, which matches all `<span>` elements
    /// that are descendants of `<div>` elements.
    ///
    /// - Parameter other: The ancestor selector.
    /// - Returns: A new selector representing the descendant relationship.
    public func descendant(of other: HTML.Selector) -> HTML.Selector {
        .init(rawValue: other.rawValue + " " + self.rawValue)
    }

    /// Creates a child combinator selector.
    ///
    /// The child combinator selects all elements that are direct children of a specified element.
    /// Unlike the descendant combinator, this only matches immediate children, not deeper descendants.
    ///
    /// ```swift
    /// let ul: HTML.Selector = "ul"
    /// let li: HTML.Selector = "li"
    /// let selector = li.child(of: ul)  // "ul > li"
    /// ```
    ///
    /// This generates the CSS selector `ul > li`, which matches only `<li>` elements
    /// that are direct children of `<ul>` elements.
    ///
    /// - Parameter other: The parent selector.
    /// - Returns: A new selector representing the child relationship.
    public func child(of other: HTML.Selector) -> HTML.Selector {
        .init(rawValue: other.rawValue + " > " + self.rawValue)
    }

    /// Creates a next-sibling combinator selector.
    ///
    /// The next-sibling combinator selects the first element that immediately follows
    /// another element, and both elements share the same parent.
    ///
    /// ```swift
    /// let h1: HTML.Selector = "h1"
    /// let p: HTML.Selector = "p"
    /// let selector = p.nextSibling(of: h1)  // "h1 + p"
    /// ```
    ///
    /// This generates the CSS selector `h1 + p`, which matches `<p>` elements
    /// that immediately follow `<h1>` elements.
    ///
    /// - Parameter other: The preceding sibling selector.
    /// - Returns: A new selector representing the next-sibling relationship.
    public func nextSibling(of other: HTML.Selector) -> HTML.Selector {
        .init(rawValue: other.rawValue + " + " + self.rawValue)
    }

    /// Creates a next-sibling combinator selector (alias for `nextSibling`).
    ///
    /// This is an alias for `nextSibling(of:)` for those familiar with the
    /// "adjacent sibling" terminology.
    ///
    /// - Parameter other: The preceding sibling selector.
    /// - Returns: A new selector representing the next-sibling relationship.
    public func adjacent(to other: HTML.Selector) -> HTML.Selector {
        nextSibling(of: other)
    }

    /// Creates a subsequent-sibling combinator selector.
    ///
    /// The subsequent-sibling combinator selects all elements that follow
    /// another element (not necessarily immediately), and both elements share the same parent.
    ///
    /// ```swift
    /// let h1: HTML.Selector = "h1"
    /// let p: HTML.Selector = "p"
    /// let selector = p.subsequentSibling(of: h1)  // "h1 ~ p"
    /// ```
    ///
    /// This generates the CSS selector `h1 ~ p`, which matches all `<p>` elements
    /// that follow `<h1>` elements as siblings.
    ///
    /// - Parameter other: The preceding sibling selector.
    /// - Returns: A new selector representing the subsequent-sibling relationship.
    public func subsequentSibling(of other: HTML.Selector) -> HTML.Selector {
        .init(rawValue: other.rawValue + " ~ " + self.rawValue)
    }

    /// Creates a subsequent-sibling combinator selector (alias for `subsequentSibling`).
    ///
    /// This is an alias for `subsequentSibling(of:)` for those familiar with the
    /// "general sibling" terminology.
    ///
    /// - Parameter other: The preceding sibling selector.
    /// - Returns: A new selector representing the subsequent-sibling relationship.
    public func sibling(of other: HTML.Selector) -> HTML.Selector {
        subsequentSibling(of: other)
    }

    /// Creates a column combinator selector.
    ///
    /// The column combinator selects elements that belong to a column in a table.
    /// This is a newer CSS feature primarily used with CSS Grid and table layouts.
    ///
    /// ```swift
    /// let col: HTML.Selector = "col"
    /// let td: HTML.Selector = "td"
    /// let selector = td.column(of: col)  // "col || td"
    /// ```
    ///
    /// This generates the CSS selector `col || td`, which matches `<td>` elements
    /// that belong to the column defined by the `<col>` element.
    ///
    /// - Parameter other: The column selector.
    /// - Returns: A new selector representing the column relationship.
    public func column(of other: HTML.Selector) -> HTML.Selector {
        .init(rawValue: other.rawValue + " || " + self.rawValue)
    }
}

// MARK: - Selector Lists and Compound Selectors
extension HTML.Selector {
    /// Creates a selector list (comma-separated selectors).
    ///
    /// Selector lists allow you to apply styles to multiple different selectors.
    /// This is equivalent to the CSS comma operator for grouping selectors.
    ///
    /// ```swift
    /// // Using string literal (most common)
    /// h1 { "Heading" }
    ///     .inlineStyle("font-weight", "bold", selector: "h1, h2")
    ///
    /// // Using method (equivalent)
    /// let h1: Selector = "h1"
    /// let h2: Selector = "h2"
    /// let headings: Selector = h1.or(h2)  // "h1, h2"
    /// ```
    ///
    /// This generates the CSS selector `h1, h2`, which matches both `<h1>` and `<h2>` elements.
    ///
    /// - Parameter other: The additional selector to include in the list.
    /// - Returns: A new selector representing the selector list.
    public func or(_ other: HTML.Selector) -> HTML.Selector {
        .init(rawValue: self.rawValue + ", " + other.rawValue)
    }

    /// Creates a selector list with multiple selectors.
    ///
    /// This is a variadic version of `or(_:)` that allows you to combine
    /// multiple selectors into a single selector list.
    ///
    /// ```swift
    /// // Using string literal (most common)
    /// h1 { "Heading" }
    ///     .inlineStyle("color", "blue", selector: "h1, h2, h3")
    ///
    /// // Using method (equivalent)
    /// let h1: HTML.Selector = "h1"
    /// let h2: HTML.Selector = "h2"
    /// let h3: HTML.Selector = "h3"
    /// let headings: HTML.Selector = h1.or(h2, h3)  // "h1, h2, h3"
    /// ```
    ///
    /// - Parameter others: Additional selectors to include in the list.
    /// - Returns: A new selector representing the combined selector list.
    public func or(_ others: HTML.Selector...) -> HTML.Selector {
        let allSelectors = [self] + others
        return .init(rawValue: allSelectors.map(\.rawValue).joined(separator: ", "))
    }

    /// Creates a compound selector by combining this selector with another.
    ///
    /// Compound selectors combine multiple simple selectors without any combinator,
    /// meaning all conditions must match the same element.
    ///
    /// ```swift
    /// // Using string literal (most common)
    /// div { "Content" }
    ///     .inlineStyle("background", "gray", selector: "div.header")
    ///
    /// // Using method (equivalent)
    /// let div: HTML.Selector = "div"
    /// let headerClass: HTML.Selector = .class("header")
    /// let compound: HTML.Selector = div.and(headerClass)  // "div.header"
    /// ```
    ///
    /// This generates the CSS selector `div.header`, which matches `<div>` elements
    /// that also have the class "header".
    ///
    /// - Parameter other: The selector to combine with this one.
    /// - Returns: A new compound selector.
    public func and(_ other: HTML.Selector) -> HTML.Selector {
        .init(rawValue: self.rawValue + other.rawValue)
    }
}

// MARK: - Convenience Methods
extension HTML.Selector {
    /// Adds a CSS class to this selector.
    ///
    /// This is a convenience method for creating compound selectors with classes.
    /// It's equivalent to using `and(Selector.class(className))`.
    ///
    /// ```swift
    /// // Using string literal (most common)
    /// div { "Content" }
    ///     .inlineStyle("background", "blue", selector: "div.navigation")
    ///
    /// // Using method (equivalent)
    /// let div: Selector = "div"
    /// let navDiv: Selector = div.withClass("navigation")  // "div.navigation"
    /// ```
    ///
    /// - Parameter className: The CSS class name to add.
    /// - Returns: A new selector with the class added.
    public func withClass(_ className: String) -> HTML.Selector {
        self.and(.class(className))
    }

    /// Adds a CSS ID to this selector.
    ///
    /// This is a convenience method for creating compound selectors with IDs.
    /// It's equivalent to using `and(HTML.Selector.id(idName))`.
    ///
    /// ```swift
    /// // Using string literal (most common)
    /// div { "Content" }
    ///     .inlineStyle("width", "100%", selector: "div#main")
    ///
    /// // Using method (equivalent)
    /// let div: HTML.Selector = "div"
    /// let mainDiv: HTML.Selector = div.withId("main")  // "div#main"
    /// ```
    ///
    /// - Parameter idName: The CSS ID to add.
    /// - Returns: A new selector with the ID added.
    public func withId(_ idName: String) -> HTML.Selector {
        self.and(.id(idName))
    }

    /// Adds an attribute selector to this selector.
    ///
    /// This is a convenience method for creating compound selectors with attribute conditions.
    /// It's equivalent to using `and(HTML.Selector.attribute(name, equals: value))`.
    ///
    /// ```swift
    /// // Using string literal (most common)
    /// input { "" }
    ///     .inlineStyle("background", "green", selector: "input[type=\"submit\"]")
    ///
    /// // Using method (equivalent)
    /// let input: HTML.Selector = "input"
    /// let submitButton: HTML.Selector = input.withAttribute("type", equals: "submit")  // "input[type=\"submit\"]"
    /// ```
    ///
    /// - Parameters:
    ///   - name: The attribute name.
    ///   - value: The required attribute value.
    /// - Returns: A new selector with the attribute condition added.
    public func withAttribute(_ name: String, equals value: String) -> HTML.Selector {
        self.and(.attribute(name, equals: value))
    }

    /// Adds a pseudo-class or pseudo-element to this selector.
    ///
    /// This method appends a pseudo-class or pseudo-element to the selector.
    /// Unlike other `with` methods, this doesn't use `and()` because pseudo-classes
    /// and pseudo-elements are part of the same selector, not compound selectors.
    ///
    /// ```swift
    /// // Using string literal (most common)
    /// button { "Click me" }
    ///     .inlineStyle("background", "red", selector: "button:hover")
    ///
    /// // Using method (equivalent)
    /// let button: HTML.Selector = "button"
    /// let hoverButton: HTML.Selector = button.withPseudo(.hover)  // "button:hover"
    /// ```
    ///
    /// - Parameter pseudo: The pseudo-class or pseudo-element to add.
    /// - Returns: A new selector with the pseudo added.
    public func withPseudo(_ pseudo: HTML.Pseudo) -> HTML.Selector {
        .init(rawValue: self.rawValue + pseudo.rawValue)
    }
}

// MARK: - Universal and Namespace Selectors
extension HTML.Selector {
    /// Universal selector: `*`
    public static let universal: Self = "*"

    /// Namespace separator for XML namespaces: `namespace|element`
    /// Note: This is different from the selector list operator |
    ///
    /// ```swift
    /// // Using string literal (most common)
    /// let svgCircle: HTML.Selector = "svg|circle"
    ///
    /// // Using method (equivalent)
    /// let circle: HTML.Selector = "circle"
    /// let result: HTML.Selector = circle.namespace("svg")  // "svg|circle"
    /// ```
    public func namespace(_ ns: String) -> HTML.Selector {
        .init(rawValue: "\(ns)|\(self.rawValue)")
    }

    /// Create a namespaced selector: `ns|element`
    ///
    /// ```swift
    /// // Using string literal (most common)
    /// let svgCircle: HTML.Selector = "svg|circle"
    ///
    /// // Using static method (equivalent)
    /// let circle: HTML.Selector = "circle"
    /// let result: HTML.Selector = .namespace("svg", element: circle)  // "svg|circle"
    /// ```
    public static func namespace(_ ns: String, element: HTML.Selector) -> HTML.Selector {
        element.namespace(ns)
    }
}

// MARK: - Attribute Selectors
extension HTML.Selector {
    /// Attribute exists: `[attr]`
    public static func hasAttribute(_ name: String) -> Self {
        "[\(name)]"
    }

    /// Attribute equals: `[attr="value"]`
    public static func attribute(_ name: String, equals value: String) -> Self {
        "[\(name)=\"\(value)\"]"
    }

    /// Attribute contains word: `[attr~="value"]`
    public static func attribute(_ name: String, containsWord value: String) -> Self {
        "[\(name)~=\"\(value)\"]"
    }

    /// Attribute starts with: `[attr^="value"]`
    public static func attribute(_ name: String, startsWith value: String) -> Self {
        "[\(name)^=\"\(value)\"]"
    }

    /// Attribute ends with: `[attr$="value"]`
    public static func attribute(_ name: String, endsWith value: String) -> Self {
        "[\(name)$=\"\(value)\"]"
    }

    /// Attribute contains substring: `[attr*="value"]`
    public static func attribute(_ name: String, contains value: String) -> Self {
        "[\(name)*=\"\(value)\"]"
    }

    /// Attribute starts with or followed by hyphen: `[attr|="value"]`
    public static func attribute(_ name: String, startsWithOrHyphen value: String) -> Self {
        "[\(name)|=\"\(value)\"]"
    }
}

// MARK: - Class and ID Selectors
extension HTML.Selector {
    /// Class selector: `.class-name`
    public static func `class`(_ name: String) -> Self {
        ".\(name)"
    }

    /// ID selector: `#id-name`
    public static func id(_ name: String) -> Self {
        "#\(name)"
    }
}

// MARK: - Form Input Types
extension HTML.Selector {
    /// Input type selector: `input[type="text"]`
    public static func inputType(_ type: String) -> Self {
        "input[type=\"\(type)\"]"
    }

    // Common input types
    public static let inputText: Self = "input[type=\"text\"]"
    public static let inputPassword: Self = "input[type=\"password\"]"
    public static let inputEmail: Self = "input[type=\"email\"]"
    public static let inputNumber: Self = "input[type=\"number\"]"
    public static let inputTel: Self = "input[type=\"tel\"]"
    public static let inputUrl: Self = "input[type=\"url\"]"
    public static let inputSearch: Self = "input[type=\"search\"]"
    public static let inputDate: Self = "input[type=\"date\"]"
    public static let inputTime: Self = "input[type=\"time\"]"
    public static let inputDatetime: Self = "input[type=\"datetime-local\"]"
    public static let inputMonth: Self = "input[type=\"month\"]"
    public static let inputWeek: Self = "input[type=\"week\"]"
    public static let inputColor: Self = "input[type=\"color\"]"
    public static let inputRange: Self = "input[type=\"range\"]"
    public static let inputFile: Self = "input[type=\"file\"]"
    public static let inputCheckbox: Self = "input[type=\"checkbox\"]"
    public static let inputRadio: Self = "input[type=\"radio\"]"
    public static let inputSubmit: Self = "input[type=\"submit\"]"
    public static let inputReset: Self = "input[type=\"reset\"]"
    public static let inputButton: Self = "input[type=\"button\"]"
    public static let inputHidden: Self = "input[type=\"hidden\"]"
}
