//
//  Group+Async Tests.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Testing

@testable import Rendering
@testable import RenderingAsync

@Suite
struct `Group_Async Tests` {

    // MARK: - Basic Async Rendering

    @Test
    func `Group renders content asynchronously`() async {
        let group = Rendering.Group {
            AsyncTestRenderable("content")
        }

        let result = await renderAsync(group)
        #expect(result == "content")
    }

    // Note: Rendering multiple children requires _Tuple to conform to Rendering.Async.Protocol,
    // which would be provided by domain-specific modules. Single-item tests suffice for base module.

    // MARK: - Context Propagation

    @Test
    func `Group passes context to content during async render`() async {
        let group = Rendering.Group {
            AsyncContextualRenderable("g")
        }

        var context = AsyncTestContext()
        let result = await renderAsync(group, context: &context)

        #expect(result == "g1")
        #expect(context.renderCount == 1)
    }

    // MARK: - Protocol Conformance

    @Test
    func `Group conforms to Async.Protocol when Content does`() {
        let group = Rendering.Group {
            AsyncTestRenderable("test")
        }
        let _: any Rendering.Async.`Protocol` = group
        #expect(Bool(true))
    }
}
