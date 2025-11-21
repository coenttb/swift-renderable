//
//  Array+HTML.swift
//  pointfree-html
//
//  RFC pattern implementation: Array<UInt8> convenience wrapper.
//

// MARK: - RFC Pattern: Array Convenience Wrapper

extension Array where Element == UInt8 {
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
    /// let document = HTMLDocument {
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
