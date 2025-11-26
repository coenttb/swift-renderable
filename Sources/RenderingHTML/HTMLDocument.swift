//
//  Document.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 22/07/2025.
//

public import Rendering

/// A complete HTML document with head and body sections.
///
/// `Document` represents a full HTML page with proper structure including
/// doctype, html, head, and body elements. Use this type when you need
/// to render a complete HTML document rather than just a fragment.
///
/// Example:
/// ```swift
/// let page = Document {
///     div {
///         h1 { "Welcome" }
///         p { "Hello, World!" }
///     }
/// } head: {
///     title { "My Page" }
///     meta().charset("utf-8")
/// }
/// ```
public struct Document<Body: HTML, Head: HTML>: HTMLDocumentProtocol {
    public let head: Head
    public let body: Body

    /// Creates a new HTML document.
    ///
    /// - Parameters:
    ///   - body: A builder closure that returns the body content.
    ///   - head: A builder closure that returns the head content. Defaults to empty.
    public init(
        @Builder body: () -> Body,
        @Builder head: () -> Head = { Empty() }
    ) {
        self.body = body()
        self.head = head()
    }
}

extension Document {
    /// Creates a new HTML document with head specified first.
    ///
    /// This overload allows specifying head before body for cases where
    /// that ordering reads more naturally.
    ///
    /// - Parameters:
    ///   - head: A builder closure that returns the head content. Defaults to empty.
    ///   - body: A builder closure that returns the body content.
    @_disfavoredOverload
    public init(
        @Builder head: () -> Head = { Empty() },
        @Builder body: () -> Body
    ) {
        self.body = body()
        self.head = head()
    }
}

extension Document: Sendable where Body: Sendable, Head: Sendable {}

/// Backward compatibility typealias.
///
/// - Note: `HTMLDocument` has been renamed to `Document`. This typealias
///   is provided for backward compatibility and will be removed in a future version.
public typealias HTMLDocument = Document
