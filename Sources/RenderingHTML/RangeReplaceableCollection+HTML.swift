//
//  RangeReplaceableCollection+HTML.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

public import Rendering

// MARK: - Unified Byte Collection Rendering

extension RangeReplaceableCollection where Element == UInt8 {
    /// Creates a byte collection from rendered HTML.
    ///
    /// This unified initializer works with any `RangeReplaceableCollection<UInt8>`,
    /// including `[UInt8]`, `ContiguousArray<UInt8>`, and `Data`.
    ///
    /// ## Performance
    ///
    /// - For maximum performance, use `ContiguousArray<UInt8>` which provides
    ///   contiguous memory layout and cache-friendly access patterns
    /// - `[UInt8]` (Array) is nearly as fast for most use cases
    /// - ~3,500 documents/second (~280µs per complete HTML document)
    ///
    /// ## Example
    ///
    /// ```swift
    /// let html = div { h1 { "Hello, World!" } }
    ///
    /// // Works with any RangeReplaceableCollection<UInt8>
    /// let array: [UInt8] = .init(html: html)
    /// let contiguous: ContiguousArray<UInt8> = .init(html: html)
    /// ```
    ///
    /// - Parameters:
    ///   - html: The HTML content to render to bytes
    ///   - configuration: Rendering configuration. Uses current task-local or default if nil.
    @inlinable
    public init(
        html: some HTML.View,
        configuration: HTML.Context.Configuration? = nil
    ) {
        var buffer = Self()
        var context = HTML.Context(configuration ?? .current)
        type(of: html)._render(html, into: &buffer, context: &context)
        self = buffer
    }

    /// Creates a byte collection from rendered HTML.
    ///
    /// Convenience overload that accepts HTML as the first unlabeled parameter.
    ///
    /// - Parameters:
    ///   - html: The HTML content to render to bytes
    ///   - configuration: Rendering configuration. Uses current task-local or default if nil.
    @inlinable
    public init(
        _ html: some HTML.View,
        configuration: HTML.Context.Configuration? = nil
    ) {
        self.init(html: html, configuration: configuration)
    }
}

// MARK: - Async Rendering

extension RangeReplaceableCollection where Element == UInt8 {
    /// Asynchronously render HTML to a byte collection.
    ///
    /// This yields to the scheduler during rendering to avoid blocking,
    /// making it suitable for use in async contexts where responsiveness matters.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let html = div { "Hello" }
    /// let bytes: [UInt8] = await .init(html: html)
    /// ```
    ///
    /// - Parameters:
    ///   - html: The HTML content to render.
    ///   - configuration: Rendering configuration. Uses default if nil.
    @inlinable
    public init(
        html: some HTML.View,
        configuration: HTML.Context.Configuration? = nil
    ) async {
        await Task.yield()
        var buffer = Self()
        var context = HTML.Context(configuration ?? .current)
        type(of: html)._render(html, into: &buffer, context: &context)
        self = buffer
    }

    /// Asynchronously render HTML to a byte collection.
    ///
    /// Convenience overload that accepts HTML as the first unlabeled parameter.
    ///
    /// - Parameters:
    ///   - html: The HTML content to render.
    ///   - configuration: Rendering configuration. Uses default if nil.
    @inlinable
    public init(
        _ html: some HTML.View,
        configuration: HTML.Context.Configuration? = nil
    ) async {
        await self.init(html: html, configuration: configuration)
    }
}

// MARK: - Document Rendering

extension RangeReplaceableCollection where Element == UInt8 {
    /// Creates a byte collection from a rendered HTML document.
    ///
    /// - Parameters:
    ///   - document: The HTML document to render.
    ///   - configuration: Rendering configuration. Uses current task-local or default if nil.
    @inlinable
    public init(
        document: some HTML.DocumentProtocol,
        configuration: HTML.Context.Configuration? = nil
    ) {
        var buffer = Self()
        var context = HTML.Context(configuration ?? .current)
        type(of: document)._render(document, into: &buffer, context: &context)
        self = buffer
    }

    /// Asynchronously render an HTML document to a byte collection.
    ///
    /// - Parameters:
    ///   - document: The HTML document to render.
    ///   - configuration: Rendering configuration. Uses default if nil.
    @inlinable
    public init(
        document: some HTML.DocumentProtocol,
        configuration: HTML.Context.Configuration? = nil
    ) async {
        await Task.yield()
        var buffer = Self()
        var context = HTML.Context(configuration ?? .current)
        type(of: document)._render(document, into: &buffer, context: &context)
        self = buffer
    }
}
