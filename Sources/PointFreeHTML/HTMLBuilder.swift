//
//  HTMLBuilder.swift
//
//
//  Created by Point-Free, Inc
//

/// A result builder that enables declarative HTML construction with a SwiftUI-like syntax.
///
/// `HTMLBuilder` provides a DSL for constructing HTML content in Swift code.
/// It transforms multiple statements in a closure into a single HTML value,
/// allowing for a natural, hierarchical representation of HTML structure.
///
/// Example:
/// ```swift
/// let content = div {
///     h1 { "Hello, World!" }
///     p { "Welcome to PointFreeHTML." }
///     if showButton {
///         button { "Click me" }
///     }
///     for item in items {
///         li { item.name }
///     }
/// }
/// ```
///
/// The `HTMLBuilder` supports Swift language features like conditionals, loops,
/// and optional unwrapping within the HTML construction DSL.
@resultBuilder
public enum HTMLBuilder {
    /// Combines an array of components into a single HTML component.
    ///
    /// - Parameter components: An array of HTML components to combine.
    /// - Returns: A single HTML component representing the array of components.
    public static func buildArray<Element: HTML>(_ components: [Element]) -> _HTMLArray<Element> {
        _HTMLArray(elements: components)
    }
    
    /// Creates an empty HTML component when no content is provided.
    ///
    /// - Returns: An empty HTML component.
    public static func buildBlock() -> HTMLEmpty {
        HTMLEmpty()
    }
    
    /// Passes through a single content component unchanged.
    ///
    /// - Parameter content: The HTML component to pass through.
    /// - Returns: The same HTML component.
    public static func buildBlock<Content: HTML>(_ content: Content) -> Content {
        content
    }
    
    /// Combines multiple HTML components into a tuple of components.
    ///
    /// - Parameter content: The HTML components to combine.
    /// - Returns: A tuple of HTML components.
    public static func buildBlock<each Content: HTML>(
        _ content: repeat each Content
    ) -> _HTMLTuple<repeat each Content> {
        _HTMLTuple(content: repeat each content)
    }
    
    /// Handles the "if" or "true" case in a conditional statement.
    ///
    /// - Parameter component: The HTML component for the "if" or "true" case.
    /// - Returns: A conditional HTML component representing the "if" or "true" case.
    public static func buildEither<First: HTML, Second: HTML>(
        first component: First
    ) -> _HTMLConditional<First, Second> {
        .first(component)
    }
    
    /// Handles the "else" or "false" case in a conditional statement.
    ///
    /// - Parameter component: The HTML component for the "else" or "false" case.
    /// - Returns: A conditional HTML component representing the "else" or "false" case.
    public static func buildEither<First: HTML, Second: HTML>(
        second component: Second
    ) -> _HTMLConditional<First, Second> {
        .second(component)
    }
    
    /// Converts any HTML expression to itself.
    ///
    /// - Parameter expression: The HTML expression to convert.
    /// - Returns: The same HTML expression.
    public static func buildExpression<T: HTML>(_ expression: T) -> T {
        expression
    }
    
    /// Converts a text expression to HTML text.
    ///
    /// - Parameter expression: The HTML text to convert.
    /// - Returns: The same HTML text.
    public static func buildExpression(_ expression: HTMLText) -> HTMLText {
        expression
    }
    
    /// Handles optional HTML components.
    ///
    /// - Parameter component: An optional HTML component.
    /// - Returns: The same optional HTML component.
    public static func buildOptional<T: HTML>(_ component: T?) -> T? {
        component
    }
    
    /// Finalizes the result of the builder.
    ///
    /// - Parameter component: The HTML component to finalize.
    /// - Returns: The final HTML component.
    public static func buildFinalResult<T: HTML>(_ component: T) -> T {
        component
    }

    /// Combines an array of any HTML components into a single HTML component.
    /// This overload handles for loops where the element type cannot be inferred.
    ///
    /// - Parameter components: An array of any HTML components to combine.
    /// - Returns: A single HTML component representing the array of components.
    public static func buildArray(_ components: [any HTML]) -> _HTMLArray<AnyHTML> {
        _HTMLArray(elements: components.map(AnyHTML.init))
    }
}



/// A container for an array of HTML elements.
///
/// This type is used internally by the `HTMLBuilder` to handle
/// arrays of elements, such as those created by `for` loops.
public struct _HTMLArray<Element: HTML>: HTML {
    /// The array of HTML elements contained in this container.
    let elements: [Element]
    
    /// Renders all elements in the array into the printer.
    ///
    /// - Parameters:
    ///   - html: The HTML array to render.
    ///   - printer: The printer to render the HTML into.
    public static func _render(_ html: Self, into printer: inout HTMLPrinter) {
        for element in html.elements {
            Element._render(element, into: &printer)
        }
    }
    
    /// This type uses direct rendering and doesn't have a body.
    public var body: Never { fatalError() }
}

/// A type to represent conditional HTML content based on if/else conditions.
///
/// This type is used internally by the `HTMLBuilder` to handle
/// conditional content created by `if`/`else` statements.
public enum _HTMLConditional<First: HTML, Second: HTML>: HTML {
    /// Represents the "if" or "true" case.
    case first(First)
    /// Represents the "else" or "false" case.
    case second(Second)
    
    /// Renders either the first or second HTML component based on the case.
    ///
    /// - Parameters:
    ///   - html: The conditional HTML to render.
    ///   - printer: The printer to render the HTML into.
    public static func _render(_ html: Self, into printer: inout HTMLPrinter) {
        switch html {
        case let .first(first):
            First._render(first, into: &printer)
        case let .second(second):
            Second._render(second, into: &printer)
        }
    }
    
    /// This type uses direct rendering and doesn't have a body.
    public var body: Never { fatalError() }
}

/// Represents plain text content in HTML, with proper escaping.
///
/// `HTMLText` handles escaping special characters in text content to ensure
/// proper HTML rendering without security vulnerabilities.
public struct HTMLText: HTML {
    /// The raw text content.
    let text: String
    
    /// Creates a new HTML text component with the given text.
    ///
    /// - Parameter text: The text content to represent.
    public init(_ text: String) {
        self.text = text
    }
    
    /// Renders the text content with proper HTML escaping.
    ///
    /// This method escapes special characters (`&`, `<`, `>`) to prevent HTML injection
    /// and ensure the text renders correctly in an HTML document.
    ///
    /// - Parameters:
    ///   - html: The HTML text to render.
    ///   - printer: The printer to render the HTML into.
    public static func _render(_ html: Self, into printer: inout HTMLPrinter) {
        printer.bytes.reserveCapacity(printer.bytes.count + html.text.utf8.count)
        for byte in html.text.utf8 {
            switch byte {
            case UInt8(ascii: "&"):
                printer.bytes.append(contentsOf: "&amp;".utf8)
            case UInt8(ascii: "<"):
                printer.bytes.append(contentsOf: "&lt;".utf8)
            case UInt8(ascii: ">"):
                printer.bytes.append(contentsOf: "&gt;".utf8)
            default:
                printer.bytes.append(byte)
            }
        }
    }
    
    /// This type uses direct rendering and doesn't have a body.
    public var body: Never { fatalError() }
    
    /// Concatenates two HTML text components.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side text.
    ///   - rhs: The right-hand side text.
    /// - Returns: A new HTML text component containing the concatenated text.
    public static func + (lhs: Self, rhs: Self) -> Self {
        HTMLText(lhs.text + rhs.text)
    }
}

/// Allows HTML text to be created from string literals.
extension HTMLText: ExpressibleByStringLiteral {
    /// Creates a new HTML text component from a string literal.
    ///
    /// - Parameter value: The string literal to use as content.
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

/// Allows HTML text to be created with string interpolation.
extension HTMLText: ExpressibleByStringInterpolation {}

/// A container for a tuple of HTML elements.
///
/// This type is used internally by the `HTMLBuilder` to handle
/// multiple HTML elements combined in a single block.
public struct _HTMLTuple<each Content: HTML>: HTML {
    /// The tuple of HTML elements.
    let content: (repeat each Content)
    
    /// Creates a new tuple of HTML elements.
    ///
    /// - Parameter content: The tuple of HTML elements.
    init(content: repeat each Content) {
        self.content = (repeat each content)
    }
    
    /// Renders all elements in the tuple into the printer.
    ///
    /// - Parameters:
    ///   - html: The HTML tuple to render.
    ///   - printer: The printer to render the HTML into.
    public static func _render(_ html: Self, into printer: inout HTMLPrinter) {
        func render<T: HTML>(_ html: T) {
            let oldAttributes = printer.attributes
            defer { printer.attributes = oldAttributes }
            T._render(html, into: &printer)
        }
        repeat render(each html.content)
    }
    
    /// This type uses direct rendering and doesn't have a body.
    public var body: Never { fatalError() }
}

/// Allows optional values to be used as HTML elements.
///
/// This conformance allows for convenient handling of optional HTML content,
/// where `nil` values simply render nothing.
extension Optional: HTML where Wrapped: HTML {
    /// Renders the optional HTML element if it exists.
    ///
    /// - Parameters:
    ///   - html: The optional HTML to render.
    ///   - printer: The printer to render the HTML into.
    public static func _render(_ html: Self, into printer: inout HTMLPrinter) {
        guard let html else { return }
        Wrapped._render(html, into: &printer)
    }
    
    /// This type uses direct rendering and doesn't have a body.
    public var body: Never { fatalError() }
}
