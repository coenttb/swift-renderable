public import Rendering
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
    public init<T: HTML.View & Sendable>(
        _ html: T,
        chunkSize: Int = 4096,
        configuration: HTML.Context.Configuration? = nil
    ) {
        let config = configuration ?? .default
        self.init { continuation in
            Task { @Sendable in
                // Render synchronously into buffer
                var buffer: [UInt8] = []
                var context = HTML.Context(config)
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

extension HTML.View where Self: Sendable {
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
        configuration: HTML.Context.Configuration? = nil
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
    public init<T: HTML.DocumentProtocol & Sendable>(
        document: T,
        chunkSize: Int = 4096,
        configuration: HTML.Context.Configuration? = nil
    ) {
        let config = configuration ?? .default
        self.init { continuation in
            Task { @Sendable in
                // Two-phase render: body first to collect styles
                var buffer: [UInt8] = []
                var context = HTML.Context(config)
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

extension AsyncStream where Element == ArraySlice<UInt8> {
    /// Progressive streaming for HTML fragments (non-throwing).
    public init<T: HTML.View & Sendable>(
        progressive html: T,
        chunkSize: Int = 4096,
        configuration: HTML.Context.Configuration? = nil
    ) {
        let config = configuration ?? .default
        self.init { continuation in
            Task { @Sendable in
                var context = HTML.Context(config)
                var buffer = ChunkingBuffer(chunkSize: chunkSize) { chunk in
                    continuation.yield(chunk)
                }

                T._render(html, into: &buffer, context: &context)
                buffer.flushRemaining()
                continuation.finish()
            }
        }
    }

    /// Progressive streaming for HTML documents (non-throwing).
    public init<T: HTML.DocumentProtocol & Sendable>(
        progressiveDocument document: T,
        chunkSize: Int = 4096,
        configuration: HTML.Context.Configuration? = nil
    ) {
        let config = configuration ?? .default
        self.init { continuation in
            Task { @Sendable in
                var context = HTML.Context(config)
                var buffer = ChunkingBuffer(chunkSize: chunkSize) { chunk in
                    continuation.yield(chunk)
                }

                // Stream doctype and opening tags
                buffer.append(contentsOf: [UInt8].html.tag.doctype)
                buffer.append(contentsOf: config.newline)
                buffer.append(contentsOf: [UInt8].html.tag.open)
                buffer.append(contentsOf: config.newline)

                // Stream head
                buffer.append(contentsOf: [UInt8].html.tag.headOpen)
                buffer.append(contentsOf: config.newline)
                T.Head._render(document.head, into: &buffer, context: &context)
                buffer.append(contentsOf: config.newline)
                buffer.append(contentsOf: [UInt8].html.tag.headClose)
                buffer.append(contentsOf: config.newline)

                // Stream body opening
                buffer.append(contentsOf: [UInt8].html.tag.bodyOpen)

                // Stream body content progressively, collecting styles
                T.Content._render(document.body, into: &buffer, context: &context)

                // Emit collected styles at end of body
                if !context.styles.isEmpty {
                    buffer.append(contentsOf: config.newline)
                    buffer.append(contentsOf: [UInt8].html.tag.styleOpen)
                    let stylesheetBytes = context.stylesheetBytes
                    buffer.append(contentsOf: stylesheetBytes)
                    buffer.append(contentsOf: [UInt8].html.tag.styleClose)
                }

                // Close body and html
                buffer.append(contentsOf: config.newline)
                buffer.append(contentsOf: [UInt8].html.tag.bodyClose)
                buffer.append(contentsOf: config.newline)
                buffer.append(contentsOf: [UInt8].html.tag.close)

                buffer.flushRemaining()
                continuation.finish()
            }
        }
    }
}

