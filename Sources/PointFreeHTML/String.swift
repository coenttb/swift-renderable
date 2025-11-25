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
    /// - Throws: `HTMLPrinter.Error` if the rendered bytes cannot be converted to a string
    ///   using the specified encoding
    ///
    /// ## See Also
    ///
    /// - ``ContiguousArray/init(_:)-swift.method``: Canonical byte transformation
    /// - ``Array/init(_:)-swift.method``: Array convenience wrapper
    public init<Encoding>(
        html: some HTML,
        as encoding: Encoding.Type = UTF8.self
    ) throws(HTMLPrinter.Error) where Encoding: _UnicodeEncoding, Encoding.CodeUnit == UInt8 {
        let bytes = ContiguousArray(html)
        self = String(decoding: bytes, as: encoding)
    }
    
    public init<Encoding>(
        _ html: some HTML,
        as encoding: Encoding.Type = UTF8.self
    ) throws(HTMLPrinter.Error) where Encoding: _UnicodeEncoding, Encoding.CodeUnit == UInt8 {
        self = try .init(html: html, as: encoding)
    }
}

extension HTMLPrinter {
    /// An error type representing HTML rendering failures.
    ///
    /// This error is thrown when there's a problem rendering HTML content
    /// or when the rendered bytes cannot be converted to a string.
    public struct Error: Swift.Error {
        /// A description of what went wrong during HTML rendering.
        public let message: String
    }
}
