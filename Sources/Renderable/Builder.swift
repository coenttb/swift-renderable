//
//  Builder.swift
//  swift-renderable
//
//  Created by Point-Free, Inc
//

/// A result builder that enables declarative content construction with a SwiftUI-like syntax.
///
/// `Builder` provides a DSL for constructing content in Swift code.
/// It transforms multiple statements in a closure into a single value,
/// allowing for a natural, hierarchical representation of structure.
///
/// This builder is generic and works with any type. Domain-specific modules
/// (like HTML Renderable, PDF Rendering) constrain the types appropriately
/// through their protocol requirements.
///
/// Example:
/// ```swift
/// let content = div {
///     h1 { "Hello, World!" }
///     p { "Welcome to HTML_Renderable." }
///     if showButton {
///         button { "Click me" }
///     }
///     for item in items {
///         li { item.name }
///     }
/// }
/// ```
///
/// The `Builder` supports Swift language features like conditionals, loops,
/// and optional unwrapping within the construction DSL.
@resultBuilder
public enum Builder {
    /// Combines an array of components into a single component.
    ///
    /// - Parameter components: An array of components to combine.
    /// - Returns: A single component representing the array of components.
    public static func buildArray<Element>(_ components: [Element]) -> _Array<Element> {
        _Array(components)
    }

    /// Passes through a single content component unchanged.
    ///
    /// - Parameter content: The component to pass through.
    /// - Returns: The same component.
    public static func buildBlock<Content>(_ content: Content) -> Content {
        content
    }

    /// Combines multiple components into a tuple of components.
    ///
    /// - Parameter content: The components to combine.
    /// - Returns: A tuple of components.
    public static func buildBlock<each Content>(
        _ content: repeat each Content
    ) -> _Tuple<repeat each Content> {
        _Tuple(repeat each content)
    }

    /// Handles the "if" or "true" case in a conditional statement.
    ///
    /// - Parameter component: The component for the "if" or "true" case.
    /// - Returns: A conditional component representing the "if" or "true" case.
    public static func buildEither<First, Second>(
        first component: First
    ) -> _Conditional<First, Second> {
        .first(component)
    }

    /// Handles the "else" or "false" case in a conditional statement.
    ///
    /// - Parameter component: The component for the "else" or "false" case.
    /// - Returns: A conditional component representing the "else" or "false" case.
    public static func buildEither<First, Second>(
        second component: Second
    ) -> _Conditional<First, Second> {
        .second(component)
    }

    /// Converts any expression to itself.
    ///
    /// - Parameter expression: The expression to convert.
    /// - Returns: The same expression.
    public static func buildExpression<T>(_ expression: T) -> T {
        expression
    }

    /// Handles optional components.
    ///
    /// - Parameter component: An optional component.
    /// - Returns: The same optional component.
    public static func buildOptional<T>(_ component: T?) -> T? {
        component
    }

    /// Finalizes the result of the builder.
    ///
    /// - Parameter component: The component to finalize.
    /// - Returns: The final component.
    public static func buildFinalResult<T>(_ component: T) -> T {
        component
    }
}
