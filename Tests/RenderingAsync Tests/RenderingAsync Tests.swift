//
//  RenderingAsync Tests.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Testing

@testable import Rendering
@testable import RenderingAsync

@Suite
struct `RenderingAsync Tests` {

    // MARK: - Namespace Existence

    @Test
    func `Rendering.Async namespace exists`() {
        let _: Rendering.Async.Type = Rendering.Async.self
        #expect(Bool(true))
    }

    @Test
    func `Rendering.Async.Sink namespace exists`() {
        let _: Rendering.Async.Sink.Type = Rendering.Async.Sink.self
        #expect(Bool(true))
    }

    // MARK: - Protocol Existence

    @Test
    func `Rendering.Async.Protocol exists`() {
        let _: any Rendering.Async.`Protocol`.Type = AsyncTestRenderable.self
        #expect(Bool(true))
    }

    @Test
    func `Rendering.Async.Sink.Protocol exists`() {
        func requiresSinkProtocol<T: Rendering.Async.Sink.`Protocol`>(_ type: T.Type) {}
        requiresSinkProtocol(Rendering.Async.Sink.Buffered.self)
        #expect(Bool(true))
    }

    // MARK: - Typealias

    @Test
    func `AsyncRenderable typealias works`() {
        let _: any AsyncRenderable.Type = AsyncTestRenderable.self
        #expect(Bool(true))
    }

    // MARK: - Protocol Inheritance

    @Test
    func `Async.Protocol inherits from Rendering.Protocol`() {
        // AsyncTestRenderable conforms to both
        let _: any Rendering.`Protocol`.Type = AsyncTestRenderable.self
        let _: any Rendering.Async.`Protocol`.Type = AsyncTestRenderable.self
        #expect(Bool(true))
    }

    @Test
    func `Async.Protocol requires Output == UInt8`() {
        // This is enforced at compile time
        typealias OutputType = AsyncTestRenderable.Output
        let _: UInt8.Type = OutputType.self
        #expect(Bool(true))
    }
}
