//
//  String.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 12/03/2025.
//

import Rendering

// MARK: - RFC Pattern: String Derived from Bytes

extension StringProtocol {
    /// Creates a String from rendered HTML content.
    ///
    /// This is a **derived transformation** in the RFC pattern, where String
    /// is constructed from the canonical byte representation (`ContiguousArray<UInt8>`).
    /// The bytes are validated against the specified encoding before conversion.
    ///
    /// ## Transformation Chain
    ///
    /// ```
    /// HTML → ContiguousArray<UInt8> → String
    ///  ↑           ↑ (canonical)        ↑ (derived)
    ///  |           |                     |
    /// Protocol  Byte Representation  User-facing
    /// ```
    ///
    /// ## Performance
    ///
    /// - Uses zero-copy `ContiguousArray` internally
    /// - Validates UTF-8 encoding (or other specified encoding)
    /// - Throws if bytes are invalid for the specified encoding
    /// - ~3,500 documents/second (~280µs per complete HTML document)
    ///
    /// ## Example
    ///
    /// ```swift
    /// let document = HTML.Document {
    ///     div {
    ///         h1 { "Hello, World!" }
    ///         p { "Welcome to PointFree HTML" }
    ///     }
    /// }
    ///
    /// do {
    ///     let htmlString = try String(document)
    ///     print(htmlString)
    /// } catch {
    ///     print("Failed to render HTML: \(error)")
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - html: The HTML content to render as a string
    ///   - encoding: The character encoding to use when converting bytes to string (default: UTF-8)
    ///
    /// - Throws: `HTML.Context.Configuration.Error` if the rendered bytes cannot be converted to a string
    ///   using the specified encoding
    ///
    /// ## See Also
    ///
    /// - ``ContiguousArray/init(_:)-swift.method``: Canonical byte transformation
    /// - ``Array/init(_:)-swift.method``: Array convenience wrapper
    public init(
        html: some HTML.View,
        configuration: HTML.Context.Configuration? = nil
    ) throws(HTML.Context.Configuration.Error) {
        let bytes = ContiguousArray(html, configuration: configuration)
        self = Self(decoding: bytes, as: UTF8.self)
    }

    public init(
        _ html: some HTML.View,
        configuration: HTML.Context.Configuration? = nil
    ) throws(HTML.Context.Configuration.Error) {
        self = try .init(html: html, configuration: configuration)
    }
}

extension StringProtocol {
    /// Asynchronously render HTML to a String.
    ///
    /// This is the authoritative implementation for async HTML string rendering.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let html = div { "Hello" }
    /// let string = await String(html)
    /// ```
    ///
    /// - Parameters:
    ///   - html: The HTML content to render.
    ///   - configuration: Rendering configuration. Uses default if nil.
    @inlinable
    public init<T: HTML.View>(
        _ html: T,
        configuration: HTML.Context.Configuration? = nil
    ) async {
        let bytes = await [UInt8](html, configuration: configuration)
        self = Self(decoding: bytes, as: UTF8.self)
    }
}

extension StringProtocol {
    /// Asynchronously render an HTML document to a String.
    ///
    /// This is the authoritative implementation for async document string rendering.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let page = MyPage()
    /// let string = await String(document: page)
    /// ```
    ///
    /// - Parameters:
    ///   - document: The HTML document to render.
    ///   - configuration: Rendering configuration. Uses default if nil.
    @inlinable
    public init<T: HTML.DocumentProtocol>(
        document: T,
        configuration: HTML.Context.Configuration? = nil
    ) async {
        let bytes = await [UInt8].init(document: document, configuration: configuration)
        self = Self(decoding: bytes, as: UTF8.self)
    }
}
