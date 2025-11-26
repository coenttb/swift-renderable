//
//  AsyncStream.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

public import Rendering

extension AsyncStream<ArraySlice<UInt8>> {
    /// Stream HTML as async byte chunks (non-throwing).
    ///
    /// ## Streaming Modes
    ///
    /// - **Batch**: Renders entire HTML first, then streams chunks. Simple and predictable.
    /// - **Progressive**: Streams chunks as content renders. Lower Time To First Byte.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Batch mode (default)
    /// for await chunk in AsyncStream(chunkSize: 4096) {
    ///     div { "Hello" }
    /// } {
    ///     await response.write(chunk)
    /// }
    ///
    /// // Progressive mode
    /// for await chunk in AsyncStream(mode: .progressive, chunkSize: 4096) {
    ///     div { "Hello" }
    /// } {
    ///     await response.write(chunk)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - mode: Streaming mode. Default is `.batch`.
    ///   - chunkSize: Size of each yielded chunk in bytes. Default is 4096.
    ///   - configuration: Rendering configuration. Uses default if nil.
    ///   - view: The HTML content to stream.
    @inlinable
    public init<View: HTML.View & Sendable>(
        mode: HTML.StreamingMode = .batch,
        chunkSize: Int = 4096,
        configuration: HTML.Context.Configuration? = nil,
        @HTML.Builder _ view: () -> View
    ) {
        let view = view()
        let config = configuration ?? .default

        switch mode {
        case .batch:
            self.init { continuation in
                Task { @Sendable in
                    var buffer: [UInt8] = []
                    var context = HTML.Context(config)
                    View._render(view, into: &buffer, context: &context)

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

        case .progressive, .backpressure:
            // Note: .backpressure with true backpressure is handled via progressiveStream().
            // For AsyncStream, fall back to progressive mode.
            self.init { continuation in
                Task { @Sendable in
                    var context = HTML.Context(config)
                    var buffer = ChunkingBuffer(chunkSize: chunkSize) { chunk in
                        continuation.yield(chunk)
                    }

                    View._render(view, into: &buffer, context: &context)
                    buffer.flushRemaining()
                    continuation.finish()
                }
            }
        }
    }
}

extension AsyncStream<ArraySlice<UInt8>> {
    /// Stream an HTML document as async byte chunks (non-throwing).
    ///
    /// ## Streaming Modes
    ///
    /// - **Batch**: Renders entire document first (styles in `<head>`), then streams chunks.
    /// - **Progressive**: Streams as content renders, with styles at end of `<body>` (valid HTML5).
    ///
    /// - Parameters:
    ///   - mode: Streaming mode. Default is `.batch`.
    ///   - chunkSize: Size of each yielded chunk in bytes. Default is 4096.
    ///   - configuration: Rendering configuration. Uses default if nil.
    ///   - document: The HTML document to stream.
    @inlinable
    public init<Document: HTML.DocumentProtocol & Sendable>(
        mode: HTML.StreamingMode = .batch,
        chunkSize: Int = 4096,
        configuration: HTML.Context.Configuration? = nil,
        @HTML.Builder _ document: () -> Document
    ) {
        let document = document()
        let config = configuration ?? .default

        switch mode {
        case .batch:
            self.init { continuation in
                Task { @Sendable in
                    var buffer: [UInt8] = []
                    var context = HTML.Context(config)
                    Document._render(document, into: &buffer, context: &context)

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

        case .progressive, .backpressure:
            // Note: .backpressure with true backpressure is handled via progressiveStream().
            // For AsyncStream, fall back to progressive mode.
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
                    Document.Head._render(document.head, into: &buffer, context: &context)
                    buffer.append(contentsOf: config.newline)
                    buffer.append(contentsOf: [UInt8].html.tag.headClose)
                    buffer.append(contentsOf: config.newline)

                    // Stream body opening
                    buffer.append(contentsOf: [UInt8].html.tag.bodyOpen)

                    // Stream body content progressively, collecting styles
                    Document.Content._render(document.body, into: &buffer, context: &context)

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
}

extension HTML.View where Self: Sendable {
    /// Stream this HTML as async byte chunks (non-throwing).
    ///
    /// - Parameters:
    ///   - mode: Streaming mode. Default is `.batch`.
    ///   - chunkSize: Size of each yielded chunk in bytes. Default is 4096.
    ///   - configuration: Rendering configuration. Uses default if nil.
    /// - Returns: An AsyncStream yielding byte chunks.
    @inlinable
    public func asyncStream(
        mode: HTML.StreamingMode = .batch,
        chunkSize: Int = 4096,
        configuration: HTML.Context.Configuration? = nil
    ) -> AsyncStream<ArraySlice<UInt8>> {
        AsyncStream(mode: mode, chunkSize: chunkSize, configuration: configuration) {
            self
        }
    }
}

extension HTML.DocumentProtocol where Self: Sendable {
    /// Stream this document as async byte chunks (non-throwing).
    ///
    /// - Parameters:
    ///   - mode: Streaming mode. Default is `.batch`.
    ///   - chunkSize: Size of each yielded chunk in bytes. Default is 4096.
    ///   - configuration: Rendering configuration. Uses default if nil.
    /// - Returns: An AsyncStream yielding byte chunks.
    @inlinable
    public func asyncStream(
        mode: HTML.StreamingMode = .batch,
        chunkSize: Int = 4096,
        configuration: HTML.Context.Configuration? = nil
    ) -> AsyncStream<ArraySlice<UInt8>> {
        AsyncStream(mode: mode, chunkSize: chunkSize, configuration: configuration) {
            self
        }
    }
}
