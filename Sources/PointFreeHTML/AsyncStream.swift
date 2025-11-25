//
//  File.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

extension AsyncStream where Element == ArraySlice<UInt8> {
    /// Stream HTML as async byte chunks (non-throwing).
    ///
    /// This is the authoritative implementation for streaming HTML content
    /// without throwing errors. Cancellation is handled gracefully.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let page = div { "Hello" }
    ///
    /// for await chunk in AsyncStream(page, chunkSize: 4096) {
    ///     await response.write(chunk)
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
        configuration: HTMLPrinter.Configuration? = nil
    ) {
        let config = configuration ?? .default
        self.init { continuation in
            Task { @Sendable in
                // Render synchronously into buffer
                var buffer: [UInt8] = []
                var context = HTMLContext(config)
                T._render(html, into: &buffer, context: &context)

                // Yield in chunks with cooperative scheduling
                var offset = 0
                while offset < buffer.count {
                    await Task.yield()

                    // Check for cancellation (finish gracefully)
                    if Task.isCancelled {
                        continuation.finish()
                        return
                    }

                    let end = Swift.min(offset + chunkSize, buffer.count)
                    continuation.yield(buffer[offset..<end])
                    offset = end
                }
                continuation.finish()
            }
        }
    }
}

extension HTML where Self: Sendable {
    /// Stream this HTML as async byte chunks (non-throwing).
    ///
    /// Convenience method that delegates to `AsyncStream.init(_:chunkSize:configuration:)`.
    ///
    /// - Parameters:
    ///   - chunkSize: Size of each yielded chunk in bytes. Default is 4096.
    ///   - configuration: Rendering configuration. Uses default if nil.
    /// - Returns: An AsyncStream yielding byte chunks.
    @inlinable
    public func asyncStreamNonThrowing(
        chunkSize: Int = 4096,
        configuration: HTMLPrinter.Configuration? = nil
    ) -> AsyncStream<ArraySlice<UInt8>> {
        AsyncStream(self, chunkSize: chunkSize, configuration: configuration)
    }
}


extension AsyncStream where Element == ArraySlice<UInt8> {
    /// Stream an HTML document as async byte chunks (non-throwing).
    ///
    /// This is the authoritative implementation for streaming HTML documents
    /// without throwing errors. Cancellation is handled gracefully.
    ///
    /// - Parameters:
    ///   - document: The HTML document to stream.
    ///   - chunkSize: Size of each yielded chunk in bytes. Default is 4096.
    ///   - configuration: Rendering configuration. Uses default if nil.
    @inlinable
    public init<T: HTMLDocumentProtocol & Sendable>(
        document: T,
        chunkSize: Int = 4096,
        configuration: HTMLPrinter.Configuration? = nil
    ) {
        let config = configuration ?? .default
        self.init { continuation in
            Task { @Sendable in
                // Two-phase render: body first to collect styles
                var buffer: [UInt8] = []
                var context = HTMLContext(config)
                T._render(document, into: &buffer, context: &context)

                // Stream in chunks with cooperative scheduling
                var offset = 0
                while offset < buffer.count {
                    await Task.yield()

                    if Task.isCancelled {
                        continuation.finish()
                        return
                    }

                    let end = Swift.min(offset + chunkSize, buffer.count)
                    continuation.yield(buffer[offset..<end])
                    offset = end
                }
                continuation.finish()
            }
        }
    }
}
