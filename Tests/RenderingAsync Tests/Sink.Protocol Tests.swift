//
//  Sink.Protocol Tests.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Testing
@testable import Rendering
@testable import RenderingAsync

@Suite
struct `Sink_Protocol Tests` {

    // MARK: - Protocol Existence

    @Test
    func `Sink.Protocol type exists`() {
        func requiresSinkProtocol<T: Rendering.Async.Sink.`Protocol`>(_ type: T.Type) {}
        requiresSinkProtocol(Rendering.Async.Sink.Buffered.self)
        #expect(Bool(true))
    }

    // MARK: - Protocol Requirements

    @Test
    func `Sink.Protocol requires write(bytes) method`() async {
        let sink = Rendering.Async.Sink.Buffered(chunkSize: 100)

        // Producer and consumer must run concurrently due to backpressure
        let producerTask = Task {
            await sink.write("test".utf8)
            await sink.finish()
        }

        var bytes: [UInt8] = []
        for await chunk in sink.chunks {
            bytes.append(contentsOf: chunk)
        }

        await producerTask.value
        #expect(String(decoding: bytes, as: UTF8.self) == "test")
    }

    @Test
    func `Sink.Protocol requires write(byte) method`() async {
        let sink = Rendering.Async.Sink.Buffered(chunkSize: 100)

        // Producer and consumer must run concurrently due to backpressure
        let producerTask = Task {
            await sink.write(UInt8(ascii: "A"))
            await sink.write(UInt8(ascii: "B"))
            await sink.write(UInt8(ascii: "C"))
            await sink.finish()
        }

        var bytes: [UInt8] = []
        for await chunk in sink.chunks {
            bytes.append(contentsOf: chunk)
        }

        await producerTask.value
        #expect(String(decoding: bytes, as: UTF8.self) == "ABC")
    }

    // MARK: - Sendable Requirement

    @Test
    func `Sink.Protocol is Sendable`() async {
        let sink = Rendering.Async.Sink.Buffered(chunkSize: 100)

        // Producer and consumer must run concurrently due to backpressure
        let producerTask = Task {
            await Task.detached {
                await sink.write("concurrent".utf8)
            }.value
            await sink.finish()
        }

        var bytes: [UInt8] = []
        for await chunk in sink.chunks {
            bytes.append(contentsOf: chunk)
        }

        await producerTask.value
        #expect(String(decoding: bytes, as: UTF8.self) == "concurrent")
    }

    // MARK: - Multiple Implementations

    @Test
    func `Sink.Buffered conforms to Sink.Protocol`() {
        let _: any Rendering.Async.Sink.`Protocol` = Rendering.Async.Sink.Buffered()
        #expect(Bool(true))
    }
}
