//
//  File.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

public import Rendering

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
    public init<T: HTML.View & Sendable>(
        _ html: T,
        chunkSize: Int = 4096,
        configuration: HTML.Context.Configuration? = nil
    ) {
        let config = configuration ?? .default
        self.init { continuation in
            Task { @Sendable in
                do {
                    // Render synchronously into buffer
                    var buffer: [UInt8] = []
                    var context = HTML.Context(config)
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
    ///     var head: some HTML.View { title { "My Page" } }
    ///     var body: some HTML.View { div { "Content" } }
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
    public init<T: HTML.DocumentProtocol & Sendable>(
        document: T,
        chunkSize: Int = 4096,
        configuration: HTML.Context.Configuration? = nil
    ) {
        let config = configuration ?? .default
        self.init { continuation in
            Task { @Sendable in
                do {
                    // Two-phase render: body first to collect styles
                    var buffer: [UInt8] = []
                    var context = HTML.Context(config)
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

extension AsyncThrowingStream where Element == ArraySlice<UInt8>, Failure == any Error {
    /// Progressive streaming for HTML documents with styles at end of body.
    ///
    /// This enables true progressive streaming for documents by placing the
    /// `<style>` tag at the end of `<body>` instead of in `<head>`. This is
    /// valid HTML5 and allows content to start rendering before all styles
    /// are collected.
    ///
    /// ## Structure
    ///
    /// The document is streamed in this order:
    /// 1. `<!doctype html><html><head>` + user head content + `</head><body>`
    /// 2. Body content (streamed progressively)
    /// 3. `<style>` with collected styles + `</body></html>`
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct MyPage: HTMLDocumentProtocol, Sendable {
    ///     var head: some HTML.View { title { "Progressive Page" } }
    ///     var body: some HTML.View {
    ///         div {
    ///             h1 { "Hello" }.inlineStyle("color", "navy")
    ///         }
    ///     }
    /// }
    ///
    /// for try await chunk in AsyncThrowingStream(progressiveDocument: MyPage()) {
    ///     try await response.write(chunk)
    /// }
    /// ```
    ///
    /// - Note: For strict HTML compliance with styles in `<head>`, use the
    ///   non-progressive `init(document:)` instead.
    ///
    /// - Parameters:
    ///   - document: The HTML document to stream.
    ///   - chunkSize: Size of each yielded chunk in bytes. Default is 4096.
    ///   - configuration: Rendering configuration. Uses default if nil.
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
                buffer.append(contentsOf: [UInt8].doctypeHTML)
                buffer.append(contentsOf: config.newline)
                buffer.append(contentsOf: [UInt8].htmlOpen)
                buffer.append(contentsOf: config.newline)

                // Stream head
                buffer.append(contentsOf: [UInt8].headOpen)
                buffer.append(contentsOf: config.newline)
                T.Head._render(document.head, into: &buffer, context: &context)
                buffer.append(contentsOf: config.newline)
                buffer.append(contentsOf: [UInt8].headClose)
                buffer.append(contentsOf: config.newline)

                // Stream body opening
                buffer.append(contentsOf: [UInt8].bodyOpen)

                // Stream body content progressively, collecting styles
                T.Content._render(document.body, into: &buffer, context: &context)

                // Emit collected styles at end of body
                if !context.styles.isEmpty {
                    buffer.append(contentsOf: config.newline)
                    buffer.append(contentsOf: [UInt8].styleOpen)
                    let stylesheetBytes = context.stylesheetBytes
                    buffer.append(contentsOf: stylesheetBytes)
                    buffer.append(contentsOf: [UInt8].styleClose)
                }

                // Close body and html
                buffer.append(contentsOf: config.newline)
                buffer.append(contentsOf: [UInt8].bodyClose)
                buffer.append(contentsOf: config.newline)
                buffer.append(contentsOf: [UInt8].htmlClose)

                buffer.flushRemaining()
                continuation.finish()
            }
        }
    }
}

extension HTML.View where Self: Sendable {
    /// Progressive stream this HTML as async byte chunks.
    ///
    /// True progressive streaming - chunks are emitted as content renders.
    ///
    /// - Parameters:
    ///   - chunkSize: Size of each yielded chunk in bytes. Default is 4096.
    ///   - configuration: Rendering configuration. Uses default if nil.
    /// - Returns: An AsyncThrowingStream yielding byte chunks progressively.
    public func progressiveStream(
        chunkSize: Int = 4096,
        configuration: HTML.Context.Configuration? = nil
    ) -> AsyncThrowingStream<ArraySlice<UInt8>, any Error> {
        AsyncThrowingStream(progressive: self, chunkSize: chunkSize, configuration: configuration)
    }
}

extension HTML.DocumentProtocol where Self: Sendable {
    /// Progressive stream this document with styles at end of body.
    ///
    /// Enables true progressive streaming by placing `<style>` at end of `<body>`.
    /// Content starts rendering before styles are fully collected.
    ///
    /// - Parameters:
    ///   - chunkSize: Size of each yielded chunk in bytes. Default is 4096.
    ///   - configuration: Rendering configuration. Uses default if nil.
    /// - Returns: An AsyncThrowingStream yielding byte chunks progressively.
    public func progressiveDocumentStream(
        chunkSize: Int = 4096,
        configuration: HTML.Context.Configuration? = nil
    ) -> AsyncThrowingStream<ArraySlice<UInt8>, any Error> {
        AsyncThrowingStream(progressiveDocument: self, chunkSize: chunkSize, configuration: configuration)
    }
}
