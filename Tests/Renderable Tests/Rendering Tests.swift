//
//  Rendering Tests.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

@testable import Renderable
import Testing

@Suite
struct `Rendering Tests` {

    // MARK: - Protocol Structure

    @Test
    func `Rendering protocol exists`() {
        // Verify the protocol type exists
        let _: any Renderable.Type = TestRendering.self
        #expect(Bool(true))
    }

    @Test
    func `AsyncRenderable protocol exists`() {
        // Verify the async protocol type exists
        let _: any AsyncRenderable.Type = TestRendering.self
        #expect(Bool(true))
    }

    @Test
    func `AsyncRenderableStreamProtocol exists`() {
        // Verify the stream protocol exists
        func requiresStreamProtocol<T: AsyncRenderingStreamProtocol>(_ type: T.Type) {}
        requiresStreamProtocol(AsyncRenderingStream.self)
        #expect(Bool(true))
    }
}

// MARK: - Test Helpers

/// A minimal Rendering implementation for testing protocol structure
private struct TestRendering: Renderable, AsyncRenderable {
    typealias Context = Void
    typealias Content = Never

    var body: Never { fatalError() }

    static func _render<Buffer: RangeReplaceableCollection>(
        _ markup: TestRendering,
        into buffer: inout Buffer,
        context: inout Void
    ) where Buffer.Element == UInt8 {
        // No-op for testing
    }

    static func _renderAsync<Stream: AsyncRenderingStreamProtocol>(
        _ markup: TestRendering,
        into stream: Stream,
        context: inout Void
    ) async {
        // No-op for testing
    }
}
