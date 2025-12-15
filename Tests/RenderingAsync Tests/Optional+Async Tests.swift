//
//  Optional+Async Tests.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Testing

@testable import Rendering
@testable import RenderingAsync

@Suite
struct `Optional_Async Tests` {

    // MARK: - Some Value Async Rendering

    @Test
    func `some value renders content asynchronously`() async {
        let optional: AsyncTestRenderable? = AsyncTestRenderable("present")
        let result = await renderAsync(optional)
        #expect(result == "present")
    }

    // MARK: - Nil Value Async Rendering

    @Test
    func `nil value renders nothing asynchronously`() async {
        let optional: AsyncTestRenderable? = nil
        let result = await renderAsync(optional)
        #expect(result.isEmpty)
    }

    // MARK: - Context Propagation

    @Test
    func `context is passed to wrapped value during async render`() async {
        let optional: AsyncContextualRenderable? = AsyncContextualRenderable("opt")

        var context = AsyncTestContext()
        let result = await renderAsync(optional, context: &context)

        #expect(result == "opt1")
        #expect(context.renderCount == 1)
    }

    @Test
    func `nil does not modify context during async render`() async {
        let optional: AsyncContextualRenderable? = nil

        var context = AsyncTestContext(renderCount: 5)
        _ = await renderAsync(optional, context: &context)

        // Context should not be modified
        #expect(context.renderCount == 5)
    }

    // MARK: - Protocol Conformance

    @Test
    func `Optional conforms to Async.Protocol when Wrapped does`() {
        let optional: AsyncTestRenderable? = AsyncTestRenderable("test")
        let _: any Rendering.Async.`Protocol` = optional
        #expect(Bool(true))
    }
}
