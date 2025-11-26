//
//  ProgressiveStream.swift
//  pointfree-html
//
//  True progressive streaming - flushes chunks as content renders.
//

import Rendering

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
        // Use offset tracking to avoid O(n²) from repeated removeFirst calls
        var offset = 0
        while buffer.count - offset >= chunkSize {
            let end = offset + chunkSize
            flush(buffer[offset..<end])
            offset = end
        }
        if offset > 0 {
            buffer.removeFirst(offset)  // Single O(n) operation at end
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
}

// MARK: - Progressive Streaming for Documents (styles at end)



// MARK: - Non-throwing variants



// MARK: - Convenience methods



