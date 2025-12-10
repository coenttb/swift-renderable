//
//  _Array+Async Tests.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Testing
@testable import Rendering
@testable import RenderingAsync

@Suite
struct `_Array_Async Tests` {

    // MARK: - Basic Async Rendering

    @Test
    func `_Array renders all elements asynchronously`() async {
        let array = Rendering._Array([
            AsyncTestRenderable("one"),
            AsyncTestRenderable("two"),
            AsyncTestRenderable("three")
        ])

        let result = await renderAsync(array)
        #expect(result == "onetwothree")
    }

    @Test
    func `empty _Array renders nothing asynchronously`() async {
        let array = Rendering._Array<AsyncTestRenderable>([])
        let result = await renderAsync(array)
        #expect(result == "")
    }

    @Test
    func `single element _Array renders asynchronously`() async {
        let array = Rendering._Array([AsyncTestRenderable("only")])
        let result = await renderAsync(array)
        #expect(result == "only")
    }

    // MARK: - Context Propagation

    @Test
    func `context is passed to each element during async render`() async {
        let array = Rendering._Array([
            AsyncContextualRenderable("a"),
            AsyncContextualRenderable("b"),
            AsyncContextualRenderable("c")
        ])

        var context = AsyncTestContext()
        let result = await renderAsync(array, context: &context)

        #expect(result == "a1b2c3")
        #expect(context.renderCount == 3)
    }

    // MARK: - Parameterized Tests

    @Test(arguments: [1, 5, 10, 50])
    func `_Array handles various sizes asynchronously`(count: Int) async {
        let elements = (0..<count).map { AsyncTestRenderable("\($0)") }
        let array = Rendering._Array(elements)

        let result = await renderAsync(array)
        let expected = (0..<count).map { "\($0)" }.joined()
        #expect(result == expected)
    }

    // MARK: - Protocol Conformance

    @Test
    func `_Array conforms to Async.Protocol when Element does`() {
        let array = Rendering._Array([AsyncTestRenderable("test")])
        let _: any Rendering.Async.`Protocol` = array
        #expect(Bool(true))
    }
}
