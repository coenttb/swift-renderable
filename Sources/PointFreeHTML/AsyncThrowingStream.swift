//
//  File.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

extension AsyncThrowingStream where Element == ArraySlice<UInt8>, Failure == any Error {
    /// Stream HTML as async byte chunks (throwing).
    ///
    /// This is the authoritative implementation for streaming HTML content.
    /// It enables HTML to be streamed chunk-by-chunk to HTTP responses,
    /// providing cooperative scheduling and backpressure support through Swift's
    /// structured concurrency.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let page = div {
    ///     h1 { "Hello" }
    ///     p { "Streaming HTML!" }
    /// }
    ///
    /// // Stream to HTTP response
    /// for try await chunk in AsyncThrowingStream(page, chunkSize: 4096) {
    ///     try await response.write(chunk)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - html: The HTML content to stream.
    ///   - chunkSize: Size of each yielded chunk in bytes. Default is 4096.
    ///   - configuration: Rendering configuration. Uses default if nil.
    @inlinable
    public init<T: HTML & Sendable>(
        _ html: T,
        chunkSize: Int = 4096,
        configuration: HTMLContext.Rendering? = nil
    ) {
        let config = configuration ?? .default
        self.init { continuation in
            Task { @Sendable in
                do {
                    // Render synchronously into buffer
                    var buffer: [UInt8] = []
                    var context = HTMLContext(config)
                    T._render(html, into: &buffer, context: &context)

                    // Yield in chunks with cooperative scheduling
                    var offset = 0
                    while offset < buffer.count {
                        // Cooperative scheduling - allow other tasks to run
                        await Task.yield()

                        // Check for cancellation
                        try Task.checkCancellation()

                        let end = Swift.min(offset + chunkSize, buffer.count)
                        continuation.yield(buffer[offset..<end])
                        offset = end
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}


extension AsyncThrowingStream where Element == ArraySlice<UInt8>, Failure == any Error {
    /// Stream an HTML document as async byte chunks (throwing).
    ///
    /// This is the authoritative implementation for streaming HTML documents.
    /// Documents require two-phase rendering (body first to collect styles),
    /// so the entire document is rendered before streaming begins. However,
    /// the chunked delivery still provides benefits for HTTP responses:
    /// - Cooperative scheduling via `Task.yield()`
    /// - Cancellation support
    /// - Backpressure through Swift concurrency
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct MyPage: HTMLDocumentProtocol, Sendable {
    ///     var head: some HTML { title { "My Page" } }
    ///     var body: some HTML { div { "Content" } }
    /// }
    ///
    /// let page = MyPage()
    /// for try await chunk in AsyncThrowingStream(document: page, chunkSize: 4096) {
    ///     try await response.write(chunk)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - document: The HTML document to stream.
    ///   - chunkSize: Size of each yielded chunk in bytes. Default is 4096.
    ///   - configuration: Rendering configuration. Uses default if nil.
    @inlinable
    public init<T: HTMLDocumentProtocol & Sendable>(
        document: T,
        chunkSize: Int = 4096,
        configuration: HTMLContext.Rendering? = nil
    ) {
        let config = configuration ?? .default
        self.init { continuation in
            Task { @Sendable in
                do {
                    // Two-phase render: body first to collect styles
                    var buffer: [UInt8] = []
                    var context = HTMLContext(config)
                    T._render(document, into: &buffer, context: &context)

                    // Stream in chunks with cooperative scheduling
                    var offset = 0
                    while offset < buffer.count {
                        await Task.yield()
                        try Task.checkCancellation()

                        let end = Swift.min(offset + chunkSize, buffer.count)
                        continuation.yield(buffer[offset..<end])
                        offset = end
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
