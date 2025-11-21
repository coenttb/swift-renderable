//
//  ContiguousArray+HTML.swift
//  pointfree-html
//
//  RFC pattern implementation: ContiguousArray<UInt8> as canonical byte representation.
//

import Dependencies

// MARK: - RFC Pattern: Bytes as Canonical Representation

extension ContiguousArray where Element == UInt8 {
    /// Creates a contiguous array of UTF-8 bytes from rendered HTML.
    ///
    /// This is the **canonical, zero-copy transformation** from HTML to bytes,
    /// following the RFC pattern where byte representation is authoritative.
    /// All other representations (String, Array) are derived from this.
    ///
    /// ## Performance
    ///
    /// This is the most efficient way to get bytes from HTML:
    /// - **Zero-copy**: Returns the printer's byte buffer directly
    /// - **No allocations**: Beyond what HTMLPrinter already creates
    /// - **Cache-friendly**: Contiguous memory layout
    /// - **~780,000 elements/second** for plain HTML
    /// - **~10,000 elements/second** for styled HTML with deduplication
    ///
    /// ## Use Cases
    ///
    /// Prefer this initialization when you need to:
    /// - Write HTML to a file or network stream
    /// - Pass bytes to a lower-level API
    /// - Integrate with other byte-based systems
    /// - Maximize performance (avoid Array copy)
    /// - Build custom String encoding pipelines
    ///
    /// ## Configuration
    ///
    /// Rendering behavior is controlled via the `htmlPrinter` dependency:
    ///
    /// ```swift
    /// withDependencies {
    ///     $0.htmlPrinter = .init(.pretty)  // Pretty-printed output
    /// } operation: {
    ///     let bytes = ContiguousArray(myHTMLDocument)
    /// }
    /// ```
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
    /// // Zero-copy byte representation
    /// let bytes = ContiguousArray(document)
    ///
    /// // Write to file
    /// try Data(bytes).write(to: fileURL)
    /// ```
    ///
    /// - Parameter html: The HTML content to render to bytes
    /// - Returns: Contiguous array of UTF-8 encoded bytes representing the HTML
    ///
    /// ## See Also
    ///
    /// - ``Array/init(_:)-swift.method``: Convenience wrapper (incurs one copy)
    /// - ``String/init(_:encoding:)``: String derived from bytes (validates UTF-8)
    /// - ``HTML/render()``: Legacy method (deprecated, use this instead)
    @inlinable
    public init<T: HTML>(_ html: T) {
        @Dependency(\.htmlPrinter) var htmlPrinter
        var printer = htmlPrinter
        T._render(html, into: &printer)
        self = printer.bytes
    }
}
