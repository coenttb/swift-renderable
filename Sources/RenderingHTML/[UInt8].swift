public import Rendering

//
//  File.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

import INCITS_4_1986

extension [UInt8] {
    /// Asynchronously render HTML to a complete byte array.
    ///
    /// This is the authoritative implementation for async HTML rendering.
    /// It yields to the scheduler during rendering to avoid blocking,
    /// making it suitable for use in async contexts where responsiveness matters.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let html = div { "Hello" }
    /// let bytes = await [UInt8](html)
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
        // Yield to allow other tasks to run
        await Task.yield()

        var buffer: [UInt8] = []
        var context = HTMLContext(configuration ?? .default)
        T._render(html, into: &buffer, context: &context)
        self = buffer
    }
}

extension [UInt8] {
    /// Creates an array of UTF-8 bytes from rendered HTML.
    ///
    /// This is a **convenience wrapper** around the canonical ContiguousArray
    /// transformation. It provides Array compatibility at the cost of one
    /// memory copy operation.
    ///
    /// ## Performance Trade-off
    ///
    /// This initialization incurs one O(n) copy:
    /// - **ContiguousArray → Array** copy: ~500MB/sec on Apple Silicon
    /// - Acceptable for most use cases (< 100K elements)
    /// - **Recommended alternative**: Use `ContiguousArray<UInt8>.init(_:)` for zero-copy
    ///
    /// ## When to Use
    ///
    /// Use this initialization when:
    /// - You need Array specifically (not ContiguousArray)
    /// - API you're calling requires `[UInt8]` type
    /// - Performance is not critical
    /// - Code simplicity is preferred
    ///
    /// Use `ContiguousArray<UInt8>.init(_:)` when:
    /// - Maximum performance required
    /// - Zero-copy semantics desired
    /// - Writing to streams/files directly
    /// - Rendering large documents (> 100K elements)
    ///
    /// ## Example
    ///
    /// ```swift
    /// let document = Document {
    ///     div { h1 { "Hello!" } }
    /// }
    ///
    /// // Convenience path (one copy)
    /// let array: [UInt8] = Array(document)
    ///
    /// // Zero-copy path (preferred)
    /// let contiguous: ContiguousArray<UInt8> = ContiguousArray(document)
    /// ```
    ///
    /// - Parameter html: The HTML content to render to bytes
    /// - Returns: Array of UTF-8 encoded bytes representing the HTML
    ///
    /// ## See Also
    ///
    /// - ``ContiguousArray/init(_:)-swift.method``: Zero-copy canonical transformation
    /// - ``String/init(_:encoding:)``: String derived from bytes (validates UTF-8)
    /// - ``HTML/render()``: Legacy method (deprecated, use ContiguousArray instead)
    @inlinable
    public init<T: HTML>(_ html: T) {
        self.init(ContiguousArray(html))
    }
}

extension HTML {
    /// Asynchronously render this HTML to a complete byte array.
    ///
    /// Convenience method that delegates to `[UInt8].init(_:configuration:)`.
    ///
    /// - Parameter configuration: Rendering configuration.
    /// - Returns: Complete rendered bytes.
    @inlinable
    public func asyncBytes(
        configuration: HTMLContext.Rendering? = nil
    ) async -> [UInt8] {
        await [UInt8](self, configuration: configuration)
    }
}

extension Array where Element == UInt8 {
    /// Asynchronously render an HTML document to a complete byte array.
    ///
    /// This is the authoritative implementation for async document rendering.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let page = MyPage()
    /// let bytes = await [UInt8](document: page)
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
        await Task.yield()

        var buffer: [UInt8] = []
        var context = HTMLContext(configuration ?? .default)
        T._render(document, into: &buffer, context: &context)
        self = buffer
    }
}

extension [UInt8] {
    /// &quot; - Double quotation mark HTML entity
    package static let htmlEntityQuot: [UInt8] = [
        .ascii.ampersand,
        .ascii.q,
        .ascii.u,
        .ascii.o,
        .ascii.t,
        .ascii.semicolon
    ]

    /// &#39; - Apostrophe HTML entity
    package static let htmlEntityApos: [UInt8] = [
        .ascii.ampersand,
        .ascii.numberSign,
        .ascii.3,
        .ascii.9,
        .ascii.semicolon
    ]

    /// &amp; - Ampersand HTML entity
    package static let htmlEntityAmp: [UInt8] = [
        .ascii.ampersand,
        .ascii.a,
        .ascii.m,
        .ascii.p,
        .ascii.semicolon
    ]

    /// &lt; - Less-than HTML entity
    package static let htmlEntityLt: [UInt8] = [
        .ascii.ampersand,
        .ascii.l,
        .ascii.t,
        .ascii.semicolon
    ]

    /// &gt; - Greater-than HTML entity
    package static let htmlEntityGt: [UInt8] = [
        .ascii.ampersand,
        .ascii.g,
        .ascii.t,
        .ascii.semicolon
    ]

    // MARK: - Document Structure Tags

    /// <!doctype html>
    package static let doctypeHTML: [UInt8] = [
        .ascii.lessThanSign, .ascii.exclamationPoint,
        .ascii.d, .ascii.o, .ascii.c, .ascii.t, .ascii.y, .ascii.p, .ascii.e,
        .ascii.space,
        .ascii.h, .ascii.t, .ascii.m, .ascii.l,
        .ascii.greaterThanSign
    ]

    /// <html>
    package static let htmlOpen: [UInt8] = [
        .ascii.lessThanSign,
        .ascii.h, .ascii.t, .ascii.m, .ascii.l,
        .ascii.greaterThanSign
    ]

    /// </html>
    package static let htmlClose: [UInt8] = [
        .ascii.lessThanSign, .ascii.slant,
        .ascii.h, .ascii.t, .ascii.m, .ascii.l,
        .ascii.greaterThanSign
    ]

    /// <head>
    package static let headOpen: [UInt8] = [
        .ascii.lessThanSign,
        .ascii.h, .ascii.e, .ascii.a, .ascii.d,
        .ascii.greaterThanSign
    ]

    /// </head>
    package static let headClose: [UInt8] = [
        .ascii.lessThanSign, .ascii.slant,
        .ascii.h, .ascii.e, .ascii.a, .ascii.d,
        .ascii.greaterThanSign
    ]

    /// <body>
    package static let bodyOpen: [UInt8] = [
        .ascii.lessThanSign,
        .ascii.b, .ascii.o, .ascii.d, .ascii.y,
        .ascii.greaterThanSign
    ]

    /// </body>
    package static let bodyClose: [UInt8] = [
        .ascii.lessThanSign, .ascii.slant,
        .ascii.b, .ascii.o, .ascii.d, .ascii.y,
        .ascii.greaterThanSign
    ]

    /// <style>
    package static let styleOpen: [UInt8] = [
        .ascii.lessThanSign,
        .ascii.s, .ascii.t, .ascii.y, .ascii.l, .ascii.e,
        .ascii.greaterThanSign
    ]

    /// </style>
    package static let styleClose: [UInt8] = [
        .ascii.lessThanSign, .ascii.slant,
        .ascii.s, .ascii.t, .ascii.y, .ascii.l, .ascii.e,
        .ascii.greaterThanSign
    ]
}
