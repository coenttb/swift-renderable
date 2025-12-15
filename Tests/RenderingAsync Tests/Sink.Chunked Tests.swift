//
//  Sink.Chunked Tests.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Testing

@testable import Rendering
@testable import RenderingAsync

@Suite
struct `Sink_Chunked Tests` {

    // MARK: - Basic Functionality

    @Test
    func `chunks at specified size`() async {
        let (stream, continuation) = AsyncStream<ArraySlice<UInt8>>.makeStream()
        let sink = Rendering.Async.Sink.Chunked(chunkSize: 5, continuation: continuation)

        Task {
            await sink.append(contentsOf: "1234567890".utf8)
            await sink.finish()
        }

        var chunks: [ArraySlice<UInt8>] = []
        for await chunk in stream {
            chunks.append(chunk)
        }

        #expect(chunks.count == 2)
        #expect(chunks[0].count == 5)
        #expect(chunks[1].count == 5)
    }

    @Test
    func `handles partial final chunk`() async {
        let (stream, continuation) = AsyncStream<ArraySlice<UInt8>>.makeStream()
        let sink = Rendering.Async.Sink.Chunked(chunkSize: 5, continuation: continuation)

        Task {
            await sink.append(contentsOf: "1234567".utf8)
            await sink.finish()
        }

        var chunks: [ArraySlice<UInt8>] = []
        for await chunk in stream {
            chunks.append(chunk)
        }

        #expect(chunks.count == 2)
        #expect(chunks[0].count == 5)
        #expect(chunks[1].count == 2)
    }

    // MARK: - Single Byte Append

    @Test
    func `can append single bytes`() async {
        let (stream, continuation) = AsyncStream<ArraySlice<UInt8>>.makeStream()
        let sink = Rendering.Async.Sink.Chunked(chunkSize: 3, continuation: continuation)

        Task {
            await sink.append(UInt8(ascii: "A"))
            await sink.append(UInt8(ascii: "B"))
            await sink.append(UInt8(ascii: "C"))
            await sink.append(UInt8(ascii: "D"))
            await sink.finish()
        }

        var allBytes: [UInt8] = []
        for await chunk in stream {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result == "ABCD")
    }

    // MARK: - Empty Content

    @Test
    func `handles empty content`() async {
        let (stream, continuation) = AsyncStream<ArraySlice<UInt8>>.makeStream()
        let sink = Rendering.Async.Sink.Chunked(chunkSize: 10, continuation: continuation)

        Task {
            await sink.finish()
        }

        var chunkCount = 0
        for await _ in stream {
            chunkCount += 1
        }

        #expect(chunkCount == 0)
    }

    // MARK: - Multiple Appends

    @Test
    func `handles multiple appends`() async {
        let (stream, continuation) = AsyncStream<ArraySlice<UInt8>>.makeStream()
        let sink = Rendering.Async.Sink.Chunked(chunkSize: 100, continuation: continuation)

        Task {
            await sink.append(contentsOf: "Hello ".utf8)
            await sink.append(contentsOf: "World".utf8)
            await sink.append(contentsOf: "!".utf8)
            await sink.finish()
        }

        var allBytes: [UInt8] = []
        for await chunk in stream {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result == "Hello World!")
    }

    // MARK: - Yield Interval

    @Test
    func `respects yield interval`() async {
        let (stream, continuation) = AsyncStream<ArraySlice<UInt8>>.makeStream()
        let sink = Rendering.Async.Sink.Chunked(
            chunkSize: 10,
            yieldInterval: 5,
            continuation: continuation
        )

        Task {
            await sink.append(contentsOf: "12345678901234567890".utf8)
            await sink.finish()
        }

        var allBytes: [UInt8] = []
        for await chunk in stream {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result == "12345678901234567890")
    }

    // MARK: - Large Content

    @Test
    func `handles large content`() async {
        let (stream, continuation) = AsyncStream<ArraySlice<UInt8>>.makeStream()
        let sink = Rendering.Async.Sink.Chunked(chunkSize: 100, continuation: continuation)

        let content = String(repeating: "X", count: 1000)

        Task {
            await sink.append(contentsOf: content.utf8)
            await sink.finish()
        }

        var totalBytes = 0
        var chunkCount = 0
        for await chunk in stream {
            totalBytes += chunk.count
            chunkCount += 1
        }

        #expect(totalBytes == 1000)
        #expect(chunkCount == 10)
    }

    // MARK: - Parameterized Tests

    @Test(arguments: [1, 4, 16, 64, 256])
    func `works with various chunk sizes`(chunkSize: Int) async {
        let (stream, continuation) = AsyncStream<ArraySlice<UInt8>>.makeStream()
        let sink = Rendering.Async.Sink.Chunked(chunkSize: chunkSize, continuation: continuation)

        let content = String(repeating: "z", count: chunkSize * 5)

        Task {
            await sink.append(contentsOf: content.utf8)
            await sink.finish()
        }

        var totalBytes = 0
        for await chunk in stream {
            totalBytes += chunk.count
        }

        #expect(totalBytes == chunkSize * 5)
    }

    // MARK: - Unicode Content

    @Test
    func `handles unicode content`() async {
        let (stream, continuation) = AsyncStream<ArraySlice<UInt8>>.makeStream()
        let sink = Rendering.Async.Sink.Chunked(chunkSize: 100, continuation: continuation)

        Task {
            await sink.append(contentsOf: "héllo 世界 🎉".utf8)
            await sink.finish()
        }

        var allBytes: [UInt8] = []
        for await chunk in stream {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result == "héllo 世界 🎉")
    }

    // MARK: - Yield Interval Variations

    @Test(arguments: [1, 10, 100, 1000])
    func `works with various yield intervals`(yieldInterval: Int) async {
        let (stream, continuation) = AsyncStream<ArraySlice<UInt8>>.makeStream()
        let sink = Rendering.Async.Sink.Chunked(
            chunkSize: 10,
            yieldInterval: yieldInterval,
            continuation: continuation
        )

        let content = String(repeating: "a", count: 100)

        Task {
            await sink.append(contentsOf: content.utf8)
            await sink.finish()
        }

        var totalBytes = 0
        for await chunk in stream {
            totalBytes += chunk.count
        }

        #expect(totalBytes == 100)
    }
}
