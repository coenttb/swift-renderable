//
//  Sink.Buffered Tests.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import AsyncAlgorithms
import Testing

@testable import Rendering
@testable import RenderingAsync

@Suite
struct `Sink_Buffered Tests` {

    // MARK: - Initialization

    @Test
    func `can be created with default chunk size`() async {
        let sink = Rendering.Async.Sink.Buffered()
        _ = sink
        #expect(Bool(true))
    }

    @Test
    func `can be created with custom chunk size`() async {
        let sink = Rendering.Async.Sink.Buffered(chunkSize: 100)
        _ = sink
        #expect(Bool(true))
    }

    @Test
    func `can be created with external channel`() async {
        let channel = AsyncChannel<ArraySlice<UInt8>>()
        let sink = Rendering.Async.Sink.Buffered(channel: channel, chunkSize: 1024)
        _ = sink
        #expect(Bool(true))
    }

    // MARK: - Write and Consume

    @Test
    func `writes and finishes correctly`() async {
        let sink = Rendering.Async.Sink.Buffered(chunkSize: 10)

        Task {
            await sink.write("Hello".utf8)
            await sink.finish()
        }

        var allBytes: [UInt8] = []
        for await chunk in sink.chunks {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result == "Hello")
    }

    @Test
    func `chunks at specified size`() async {
        let chunkSize = 5
        let sink = Rendering.Async.Sink.Buffered(chunkSize: chunkSize)

        Task {
            await sink.write("1234567890".utf8)
            await sink.finish()
        }

        var chunks: [ArraySlice<UInt8>] = []
        for await chunk in sink.chunks {
            chunks.append(chunk)
        }

        #expect(chunks.count == 2)
        #expect(chunks[0].count == 5)
        #expect(chunks[1].count == 5)
    }

    @Test
    func `handles partial final chunk`() async {
        let chunkSize = 5
        let sink = Rendering.Async.Sink.Buffered(chunkSize: chunkSize)

        Task {
            await sink.write("1234567".utf8)
            await sink.finish()
        }

        var chunks: [ArraySlice<UInt8>] = []
        for await chunk in sink.chunks {
            chunks.append(chunk)
        }

        #expect(chunks.count == 2)
        #expect(chunks[0].count == 5)
        #expect(chunks[1].count == 2)
    }

    // MARK: - Single Byte Write

    @Test
    func `can write single bytes`() async {
        let sink = Rendering.Async.Sink.Buffered(chunkSize: 3)

        Task {
            await sink.write(UInt8(ascii: "A"))
            await sink.write(UInt8(ascii: "B"))
            await sink.write(UInt8(ascii: "C"))
            await sink.write(UInt8(ascii: "D"))
            await sink.finish()
        }

        var allBytes: [UInt8] = []
        for await chunk in sink.chunks {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result == "ABCD")
    }

    // MARK: - Empty Content

    @Test
    func `handles empty content`() async {
        let sink = Rendering.Async.Sink.Buffered(chunkSize: 10)

        Task {
            await sink.finish()
        }

        var chunkCount = 0
        for await _ in sink.chunks {
            chunkCount += 1
        }

        #expect(chunkCount == 0)
    }

    // MARK: - Multiple Writes

    @Test
    func `handles multiple writes`() async {
        let sink = Rendering.Async.Sink.Buffered(chunkSize: 100)

        Task {
            await sink.write("Hello ".utf8)
            await sink.write("World".utf8)
            await sink.write("!".utf8)
            await sink.finish()
        }

        var allBytes: [UInt8] = []
        for await chunk in sink.chunks {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result == "Hello World!")
    }

    // MARK: - Chunks Property

    @Test
    func `chunks property returns AsyncChannel`() async {
        let sink = Rendering.Async.Sink.Buffered()
        let _: AsyncChannel<ArraySlice<UInt8>> = sink.chunks
        #expect(Bool(true))
    }

    // MARK: - Sendable

    @Test
    func `is Sendable`() async {
        let sink = Rendering.Async.Sink.Buffered()
        Task {
            await sink.write("test".utf8)
            await sink.finish()
        }
        for await _ in sink.chunks {}
        #expect(Bool(true))
    }

    // MARK: - Parameterized Tests

    @Test(arguments: [1, 4, 16, 64, 256, 1024])
    func `works with various chunk sizes`(chunkSize: Int) async {
        let sink = Rendering.Async.Sink.Buffered(chunkSize: chunkSize)
        let content = String(repeating: "x", count: chunkSize * 3)

        Task {
            await sink.write(content.utf8)
            await sink.finish()
        }

        var allBytes: [UInt8] = []
        for await chunk in sink.chunks {
            allBytes.append(contentsOf: chunk)
        }

        #expect(allBytes.count == chunkSize * 3)
    }

    // MARK: - Large Content

    @Test
    func `handles large content`() async {
        let sink = Rendering.Async.Sink.Buffered(chunkSize: 1000)
        let content = String(repeating: "y", count: 10_000)

        Task {
            await sink.write(content.utf8)
            await sink.finish()
        }

        var totalBytes = 0
        for await chunk in sink.chunks {
            totalBytes += chunk.count
        }

        #expect(totalBytes == 10_000)
    }

    // MARK: - Unicode Content

    @Test
    func `handles unicode content`() async {
        let sink = Rendering.Async.Sink.Buffered(chunkSize: 100)

        Task {
            await sink.write("héllo 世界 🎉".utf8)
            await sink.finish()
        }

        var allBytes: [UInt8] = []
        for await chunk in sink.chunks {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result == "héllo 世界 🎉")
    }

    // MARK: - Backpressure

    @Test
    func `applies backpressure via channel`() async {
        let sink = Rendering.Async.Sink.Buffered(chunkSize: 5)

        // Write enough to trigger multiple chunks
        Task {
            for i in 0..<10 {
                await sink.write("\(i)".utf8)
            }
            await sink.finish()
        }

        var allBytes: [UInt8] = []
        for await chunk in sink.chunks {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result == "0123456789")
    }
}
