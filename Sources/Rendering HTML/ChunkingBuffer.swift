//
//  File.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
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
