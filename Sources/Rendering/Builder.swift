//
//  HTMLBuilder.swift
//
//
//  Created by Point-Free, Inc
//

public import Rendering

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
public enum Builder {
    /// Combines an array of components into a single HTML component.
    ///
    /// - Parameter components: An array of HTML components to combine.
    /// - Returns: A single HTML component representing the array of components.
    public static func buildArray<Element: Rendering>(_ components: [Element]) -> _Array<Element> {
        _Array(components)
    }

    /// Passes through a single content component unchanged.
    ///
    /// - Parameter content: The HTML component to pass through.
    /// - Returns: The same HTML component.
    public static func buildBlock<Content: Rendering>(_ content: Content) -> Content {
        content
    }

    /// Combines multiple HTML components into a tuple of components.
    ///
    /// - Parameter content: The HTML components to combine.
    /// - Returns: A tuple of HTML components.
    public static func buildBlock<each Content: Rendering>(
        _ content: repeat each Content
    ) -> _Tuple<repeat each Content> {
        _Tuple(repeat each content)
    }

    /// Handles the "if" or "true" case in a conditional statement.
    ///
    /// - Parameter component: The HTML component for the "if" or "true" case.
    /// - Returns: A conditional HTML component representing the "if" or "true" case.
    public static func buildEither<First: Rendering, Second: Rendering>(
        first component: First
    ) -> _Conditional<First, Second> {
        .first(component)
    }

    /// Handles the "else" or "false" case in a conditional statement.
    ///
    /// - Parameter component: The HTML component for the "else" or "false" case.
    /// - Returns: A conditional HTML component representing the "else" or "false" case.
    public static func buildEither<First: Rendering, Second: Rendering>(
        second component: Second
    ) -> _Conditional<First, Second> {
        .second(component)
    }

    /// Converts any HTML expression to itself.
    ///
    /// - Parameter expression: The HTML expression to convert.
    /// - Returns: The same HTML expression.
    public static func buildExpression<T: Rendering>(_ expression: T) -> T {
        expression
    }

    /// Handles optional HTML components.
    ///
    /// - Parameter component: An optional HTML component.
    /// - Returns: The same optional HTML component.
    public static func buildOptional<T: Rendering>(_ component: T?) -> T? {
        component
    }

    /// Finalizes the result of the builder.
    ///
    /// - Parameter component: The HTML component to finalize.
    /// - Returns: The final HTML component.
    public static func buildFinalResult<T: Rendering>(_ component: T) -> T {
        component
    }
}
