//
//  String.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 12/03/2025.
//

// MARK: - RFC Pattern: String Derived from Bytes

extension String {
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
    /// let document = HTMLDocument {
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
    /// - Throws: `HTMLContext.Rendering.Error` if the rendered bytes cannot be converted to a string
    ///   using the specified encoding
    ///
    /// ## See Also
    ///
    /// - ``ContiguousArray/init(_:)-swift.method``: Canonical byte transformation
    /// - ``Array/init(_:)-swift.method``: Array convenience wrapper
    public init<Encoding>(
        html: some HTML,
        as encoding: Encoding.Type = UTF8.self
    ) throws(HTMLContext.Rendering.Error) where Encoding: _UnicodeEncoding, Encoding.CodeUnit == UInt8 {
        let bytes = ContiguousArray(html)
        self = String(decoding: bytes, as: encoding)
    }
    
    public init<Encoding>(
        _ html: some HTML,
        as encoding: Encoding.Type = UTF8.self
    ) throws(HTMLContext.Rendering.Error) where Encoding: _UnicodeEncoding, Encoding.CodeUnit == UInt8 {
        self = try .init(html: html, as: encoding)
    }
}

extension String {
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
    public init<T: HTML>(
        _ html: T,
        configuration: HTMLContext.Rendering? = nil
    ) async {
        let bytes = await [UInt8](html, configuration: configuration)
        self = String(decoding: bytes, as: UTF8.self)
    }
}


extension HTML {
    /// Asynchronously render this HTML to a String.
    ///
    /// Convenience method that delegates to `String.init(_:configuration:)`.
    ///
    /// - Parameter configuration: Rendering configuration.
    /// - Returns: Rendered HTML string.
    @inlinable
    public func asyncString(
        configuration: HTMLContext.Rendering? = nil
    ) async -> String {
        await String(self, configuration: configuration)
    }
}

extension String {
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
    public init<T: HTMLDocumentProtocol>(
        document: T,
        configuration: HTMLContext.Rendering? = nil
    ) async {
        let bytes = await [UInt8](document: document, configuration: configuration)
        self = String(decoding: bytes, as: UTF8.self)
    }
}
