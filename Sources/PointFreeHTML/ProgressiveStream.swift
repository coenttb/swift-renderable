//
//  ProgressiveStream.swift
//  pointfree-html
//
//  True progressive streaming - flushes chunks as content renders.
//

/// A buffer that flushes to a continuation when it reaches capacity.
///
/// This enables true progressive streaming by emitting chunks during
/// rendering rather than buffering everything first.
@usableFromInline
struct ChunkingBuffer: RangeReplaceableCollection {
    @usableFromInline
    typealias Element = UInt8

    @usableFromInline
    typealias Index = Int

    @usableFromInline
    var buffer: [UInt8]

    @usableFromInline
    let chunkSize: Int

    @usableFromInline
    let flush: @Sendable (ArraySlice<UInt8>) -> Void

    @usableFromInline
    var startIndex: Int { buffer.startIndex }

    @usableFromInline
    var endIndex: Int { buffer.endIndex }

    @usableFromInline
    subscript(position: Int) -> UInt8 {
        get { buffer[position] }
        set { buffer[position] = newValue }
    }

    @usableFromInline
    func index(after i: Int) -> Int { buffer.index(after: i) }

    @usableFromInline
    init(chunkSize: Int, flush: @escaping @Sendable (ArraySlice<UInt8>) -> Void) {
        self.buffer = []
        self.buffer.reserveCapacity(chunkSize)
        self.chunkSize = chunkSize
        self.flush = flush
    }

    @usableFromInline
    init() {
        self.buffer = []
        self.chunkSize = 4096
        self.flush = { _ in }
    }

    @usableFromInline
    mutating func replaceSubrange<C: Collection>(
        _ subrange: Range<Int>,
        with newElements: C
    ) where C.Element == UInt8 {
        buffer.replaceSubrange(subrange, with: newElements)
        flushIfNeeded()
    }

    @usableFromInline
    mutating func append(_ newElement: UInt8) {
        buffer.append(newElement)
        flushIfNeeded()
    }

    @usableFromInline
    mutating func append<S: Sequence>(contentsOf newElements: S) where S.Element == UInt8 {
        buffer.append(contentsOf: newElements)
        flushIfNeeded()
    }

    @usableFromInline
    mutating func flushIfNeeded() {
        while buffer.count >= chunkSize {
            let chunk = buffer.prefix(chunkSize)
            flush(ArraySlice(chunk))
            buffer.removeFirst(chunkSize)
        }
    }

    /// Flush any remaining content.
    @usableFromInline
    mutating func flushRemaining() {
        if !buffer.isEmpty {
            flush(ArraySlice(buffer))
            buffer.removeAll(keepingCapacity: true)
        }
    }
}

// MARK: - Progressive Streaming for HTML Fragments

extension AsyncThrowingStream where Element == ArraySlice<UInt8>, Failure == any Error {
    /// Progressive streaming for HTML fragments.
    ///
    /// This streams chunks as they are rendered, providing true progressive
    /// delivery with minimal buffering. Each chunk is yielded as soon as
    /// the buffer fills, enabling Time To First Byte (TTFB) optimization.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let content = div {
    ///     for item in largeDataset {
    ///         p { item.description }
    ///     }
    /// }
    ///
    /// for try await chunk in AsyncThrowingStream(progressive: content, chunkSize: 1024) {
    ///     try await response.write(chunk)
    /// }
    /// ```
    ///
    /// - Note: This method is for HTML fragments only. For complete documents
    ///   with styles, use `init(progressiveDocument:)`.
    ///
    /// - Parameters:
    ///   - html: The HTML content to stream.
    ///   - chunkSize: Size of each yielded chunk in bytes. Default is 4096.
    ///   - configuration: Rendering configuration. Uses default if nil.
    public init<T: HTML & Sendable>(
        progressive html: T,
        chunkSize: Int = 4096,
        configuration: HTMLPrinter.Configuration? = nil
    ) {
        let config = configuration ?? .default
        self.init { continuation in
            Task { @Sendable in
                do {
                    var context = HTMLContext(config)
                    var buffer = ChunkingBuffer(chunkSize: chunkSize) { chunk in
                        continuation.yield(chunk)
                    }

                    T._render(html, into: &buffer, context: &context)
                    buffer.flushRemaining()
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

// MARK: - Progressive Streaming for Documents (styles at end)

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
    ///     var head: some HTML { title { "Progressive Page" } }
    ///     var body: some HTML {
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
    public init<T: HTMLDocumentProtocol & Sendable>(
        progressiveDocument document: T,
        chunkSize: Int = 4096,
        configuration: HTMLPrinter.Configuration? = nil
    ) {
        let config = configuration ?? .default
        self.init { continuation in
            Task { @Sendable in
                do {
                    var context = HTMLContext(config)
                    var buffer = ChunkingBuffer(chunkSize: chunkSize) { chunk in
                        continuation.yield(chunk)
                    }

                    // Stream doctype and opening tags
                    buffer.append(contentsOf: "<!doctype html>".utf8)
                    buffer.append(contentsOf: config.newline)
                    buffer.append(contentsOf: "<html>".utf8)
                    buffer.append(contentsOf: config.newline)

                    // Stream head
                    buffer.append(contentsOf: "<head>".utf8)
                    buffer.append(contentsOf: config.newline)
                    T.Head._render(document.head, into: &buffer, context: &context)
                    buffer.append(contentsOf: config.newline)
                    buffer.append(contentsOf: "</head>".utf8)
                    buffer.append(contentsOf: config.newline)

                    // Stream body opening
                    buffer.append(contentsOf: "<body>".utf8)

                    // Stream body content progressively, collecting styles
                    T.Content._render(document.body, into: &buffer, context: &context)

                    // Emit collected styles at end of body
                    if !context.styles.isEmpty {
                        buffer.append(contentsOf: config.newline)
                        buffer.append(contentsOf: "<style>".utf8)
                        let stylesheetBytes = context.stylesheetBytes
                        buffer.append(contentsOf: stylesheetBytes)
                        buffer.append(contentsOf: "</style>".utf8)
                    }

                    // Close body and html
                    buffer.append(contentsOf: config.newline)
                    buffer.append(contentsOf: "</body>".utf8)
                    buffer.append(contentsOf: config.newline)
                    buffer.append(contentsOf: "</html>".utf8)

                    buffer.flushRemaining()
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

// MARK: - Non-throwing variants

extension AsyncStream where Element == ArraySlice<UInt8> {
    /// Progressive streaming for HTML fragments (non-throwing).
    public init<T: HTML & Sendable>(
        progressive html: T,
        chunkSize: Int = 4096,
        configuration: HTMLPrinter.Configuration? = nil
    ) {
        let config = configuration ?? .default
        self.init { continuation in
            Task { @Sendable in
                var context = HTMLContext(config)
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
    public init<T: HTMLDocumentProtocol & Sendable>(
        progressiveDocument document: T,
        chunkSize: Int = 4096,
        configuration: HTMLPrinter.Configuration? = nil
    ) {
        let config = configuration ?? .default
        self.init { continuation in
            Task { @Sendable in
                var context = HTMLContext(config)
                var buffer = ChunkingBuffer(chunkSize: chunkSize) { chunk in
                    continuation.yield(chunk)
                }

                // Stream doctype and opening tags
                buffer.append(contentsOf: "<!doctype html>".utf8)
                buffer.append(contentsOf: config.newline)
                buffer.append(contentsOf: "<html>".utf8)
                buffer.append(contentsOf: config.newline)

                // Stream head
                buffer.append(contentsOf: "<head>".utf8)
                buffer.append(contentsOf: config.newline)
                T.Head._render(document.head, into: &buffer, context: &context)
                buffer.append(contentsOf: config.newline)
                buffer.append(contentsOf: "</head>".utf8)
                buffer.append(contentsOf: config.newline)

                // Stream body opening
                buffer.append(contentsOf: "<body>".utf8)

                // Stream body content progressively, collecting styles
                T.Content._render(document.body, into: &buffer, context: &context)

                // Emit collected styles at end of body
                if !context.styles.isEmpty {
                    buffer.append(contentsOf: config.newline)
                    buffer.append(contentsOf: "<style>".utf8)
                    let stylesheetBytes = context.stylesheetBytes
                    buffer.append(contentsOf: stylesheetBytes)
                    buffer.append(contentsOf: "</style>".utf8)
                }

                // Close body and html
                buffer.append(contentsOf: config.newline)
                buffer.append(contentsOf: "</body>".utf8)
                buffer.append(contentsOf: config.newline)
                buffer.append(contentsOf: "</html>".utf8)

                buffer.flushRemaining()
                continuation.finish()
            }
        }
    }
}

// MARK: - Convenience methods

extension HTML where Self: Sendable {
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
        configuration: HTMLPrinter.Configuration? = nil
    ) -> AsyncThrowingStream<ArraySlice<UInt8>, any Error> {
        AsyncThrowingStream(progressive: self, chunkSize: chunkSize, configuration: configuration)
    }
}

extension HTMLDocumentProtocol where Self: Sendable {
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
        configuration: HTMLPrinter.Configuration? = nil
    ) -> AsyncThrowingStream<ArraySlice<UInt8>, any Error> {
        AsyncThrowingStream(progressiveDocument: self, chunkSize: chunkSize, configuration: configuration)
    }
}
