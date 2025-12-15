//
//  _Conditional+Async Tests.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Testing

@testable import Rendering
@testable import RenderingAsync

@Suite
struct `_Conditional_Async Tests` {

    // MARK: - First Branch Async Rendering

    @Test
    func `first branch renders asynchronously`() async {
        let conditional = Rendering._Conditional<AsyncTestRenderable, AsyncTestRenderable>
            .first(AsyncTestRenderable("FIRST"))

        let result = await renderAsync(conditional)
        #expect(result == "FIRST")
    }

    // MARK: - Second Branch Async Rendering

    @Test
    func `second branch renders asynchronously`() async {
        let conditional = Rendering._Conditional<AsyncTestRenderable, AsyncTestRenderable>
            .second(AsyncTestRenderable("SECOND"))

        let result = await renderAsync(conditional)
        #expect(result == "SECOND")
    }

    // MARK: - Context Propagation

    @Test
    func `context is passed to first branch during async render`() async {
        let conditional = Rendering._Conditional<
            AsyncContextualRenderable, AsyncContextualRenderable
        >
        .first(AsyncContextualRenderable("first-"))

        var context = AsyncTestContext()
        let result = await renderAsync(conditional, context: &context)

        #expect(result == "first-1")
        #expect(context.renderCount == 1)
    }

    @Test
    func `context is passed to second branch during async render`() async {
        let conditional = Rendering._Conditional<
            AsyncContextualRenderable, AsyncContextualRenderable
        >
        .second(AsyncContextualRenderable("second-"))

        var context = AsyncTestContext()
        let result = await renderAsync(conditional, context: &context)

        #expect(result == "second-1")
        #expect(context.renderCount == 1)
    }

    // MARK: - Empty Content

    @Test
    func `first branch with empty content renders empty`() async {
        let conditional = Rendering._Conditional<AsyncTestRenderable, AsyncTestRenderable>
            .first(AsyncTestRenderable(""))

        let result = await renderAsync(conditional)
        #expect(result.isEmpty)
    }

    // MARK: - Protocol Conformance

    @Test
    func `_Conditional conforms to Async.Protocol when both branches do`() {
        let conditional = Rendering._Conditional<AsyncTestRenderable, AsyncTestRenderable>
            .first(AsyncTestRenderable("test"))
        let _: any Rendering.Async.`Protocol` = conditional
        #expect(Bool(true))
    }
}
