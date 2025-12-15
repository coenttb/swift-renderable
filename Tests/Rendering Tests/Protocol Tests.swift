//
//  Protocol Tests.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Testing

@testable import Rendering

@Suite
struct `Protocol Tests` {

    // MARK: - Protocol Existence

    @Test
    func `Rendering.Protocol type exists`() {
        let _: any Rendering.`Protocol`.Type = TestRenderable.self
        #expect(Bool(true))
    }

    @Test
    func `Renderable typealias maps to Rendering.Protocol`() {
        let _: any Renderable.Type = TestRenderable.self
        #expect(Bool(true))
    }

    // MARK: - Basic Rendering

    @Test
    func `_render writes bytes to buffer`() {
        let renderable = TestRenderable("hello")
        let result = render(renderable)
        #expect(result == "hello")
    }

    @Test
    func `_render handles empty content`() {
        let renderable = TestRenderable("")
        let result = render(renderable)
        #expect(result.isEmpty)
    }

    @Test
    func `_render handles unicode content`() {
        let renderable = TestRenderable("héllo 世界 🎉")
        let result = render(renderable)
        #expect(result == "héllo 世界 🎉")
    }

    @Test(arguments: [
        ("simple", "simple"),
        ("with spaces", "with spaces"),
        ("with\ttabs", "with\ttabs"),
        ("with\nnewlines", "with\nnewlines"),
        ("<html>tags</html>", "<html>tags</html>"),
        ("\"quotes\"", "\"quotes\""),
        ("special: &<>", "special: &<>"),
    ])
    func `_render preserves content exactly`(input: String, expected: String) {
        let renderable = TestRenderable(input)
        let result = render(renderable)
        #expect(result == expected)
    }

    // MARK: - Context Propagation

    @Test
    func `_render receives mutable context`() {
        let renderable = ContextualRenderable("item-")
        var context = TestContext()
        let result = render(renderable, context: &context)
        #expect(result == "item-1")
        #expect(context.renderCount == 1)
    }

    @Test
    func `_render context mutations persist across calls`() {
        let renderable1 = ContextualRenderable("a")
        let renderable2 = ContextualRenderable("b")
        var context = TestContext()

        let result1 = render(renderable1, context: &context)
        let result2 = render(renderable2, context: &context)

        #expect(result1 == "a1")
        #expect(result2 == "b2")
        #expect(context.renderCount == 2)
    }

    // MARK: - Default Implementation (Body Delegation)

    @Test
    func `default _render delegates to body`() {
        let composite = CompositeRenderable(children: [
            TestRenderable("one"),
            TestRenderable("two"),
        ])
        let result = render(composite)
        #expect(result == "onetwo")
    }

    @Test
    func `body delegation with empty children`() {
        let composite = CompositeRenderable(children: [])
        let result = render(composite)
        #expect(result.isEmpty)
    }

    // MARK: - Buffer Types

    @Test
    func `_render works with Array buffer`() {
        var buffer: [UInt8] = []
        var context: Void = ()
        TestRenderable._render(TestRenderable("test"), into: &buffer, context: &context)
        #expect(buffer == Array("test".utf8))
    }

    @Test
    func `_render works with ContiguousArray buffer`() {
        var buffer: ContiguousArray<UInt8> = []
        var context: Void = ()
        TestRenderable._render(TestRenderable("test"), into: &buffer, context: &context)
        #expect(Array(buffer) == Array("test".utf8))
    }

    @Test
    func `_render appends to existing buffer content`() {
        var buffer: [UInt8] = Array("prefix-".utf8)
        var context: Void = ()
        TestRenderable._render(TestRenderable("suffix"), into: &buffer, context: &context)
        #expect(String(decoding: buffer, as: UTF8.self) == "prefix-suffix")
    }

    // MARK: - Associated Types

    @Test
    func `Output type can be UInt8`() {
        typealias OutputType = TestRenderable.Output
        let _: OutputType = 0
        #expect(Bool(true))
    }

    @Test
    func `Context type is accessible`() {
        typealias ContextType = TestRenderable.Context
        let _: ContextType = ()
        #expect(Bool(true))
    }

    @Test
    func `Content type is accessible`() {
        typealias ContentType = TestRenderable.Content
        // Never type - just verify it compiles
        #expect(Bool(true))
    }
}
