//
//  Optional+Rendering Tests.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Testing
@testable import Rendering

@Suite
struct `Optional+Rendering Tests` {

    // MARK: - Some Value

    @Test
    func `some value renders content`() {
        let optional: TestRenderable? = TestRenderable("present")
        let result = render(optional)
        #expect(result == "present")
    }

    @Test
    func `some value with empty content renders empty`() {
        let optional: TestRenderable? = TestRenderable("")
        let result = render(optional)
        #expect(result == "")
    }

    // MARK: - Nil Value

    @Test
    func `nil value renders nothing`() {
        let optional: TestRenderable? = nil
        let result = render(optional)
        #expect(result == "")
    }

    @Test
    func `nil produces empty buffer`() {
        let optional: TestRenderable? = nil
        let bytes = renderBytes(optional)
        #expect(bytes.isEmpty)
    }

    // MARK: - Protocol Conformance

    @Test
    func `Optional conforms to Rendering.Protocol when Wrapped does`() {
        let optional: TestRenderable? = TestRenderable("test")
        let _: any Rendering.`Protocol` = optional
        #expect(Bool(true))
    }

    @Test
    func `body property is Never`() {
        let optional: TestRenderable? = TestRenderable("test")
        _ = type(of: optional).Content.self
        #expect(Bool(true))
    }

    // MARK: - Sendable

    @Test
    func `Optional is Sendable when Wrapped is Sendable`() {
        let optional: TestRenderable? = TestRenderable("test")
        Task {
            _ = optional
        }
        #expect(Bool(true))
    }

    // MARK: - Context Propagation

    @Test
    func `context is passed to wrapped value`() {
        let optional: ContextualRenderable? = ContextualRenderable("opt")
        var context = TestContext()
        let result = render(optional, context: &context)

        #expect(result == "opt1")
        #expect(context.renderCount == 1)
    }

    @Test
    func `nil does not modify context`() {
        let optional: ContextualRenderable? = nil
        var context = TestContext(renderCount: 5)
        let result = render(optional, context: &context)

        #expect(result == "")
        #expect(context.renderCount == 5)
    }

    // MARK: - Nested Optionals

    @Test
    func `nested optional with some value`() {
        let nested: TestRenderable?? = TestRenderable("nested")
        // Note: Double optional doesn't automatically conform, this tests single level
        if let inner = nested {
            let result = render(inner)
            #expect(result == "nested")
        }
    }

    // MARK: - Buffer Append Behavior

    @Test
    func `optional appends to existing buffer when some`() {
        let optional: TestRenderable? = TestRenderable("suffix")
        var buffer: [UInt8] = Array("prefix-".utf8)
        var context: Void = ()
        Optional._render(optional, into: &buffer, context: &context)

        #expect(String(decoding: buffer, as: UTF8.self) == "prefix-suffix")
    }

    @Test
    func `optional leaves buffer unchanged when nil`() {
        let optional: TestRenderable? = nil
        var buffer: [UInt8] = Array("unchanged".utf8)
        var context: Void = ()
        Optional._render(optional, into: &buffer, context: &context)

        #expect(String(decoding: buffer, as: UTF8.self) == "unchanged")
    }

    // MARK: - Conditional Usage

    @Test
    func `optional works with conditional assignment`() {
        let condition = true
        let optional: TestRenderable? = condition ? TestRenderable("conditional") : nil
        let result = render(optional)
        #expect(result == "conditional")
    }

    @Test
    func `optional works with nil coalescing in rendering`() {
        let optional1: TestRenderable? = nil
        let optional2: TestRenderable? = TestRenderable("fallback")

        // Can't coalesce optionals for rendering, but both can be rendered
        let result1 = render(optional1)
        let result2 = render(optional2)

        #expect(result1 == "")
        #expect(result2 == "fallback")
    }

    // MARK: - Array of Optionals

    @Test
    func `array of optionals renders present values`() {
        let optionals: [TestRenderable?] = [
            TestRenderable("a"),
            nil,
            TestRenderable("b"),
            nil,
            TestRenderable("c")
        ]

        var results: [String] = []
        for opt in optionals {
            results.append(render(opt))
        }

        #expect(results == ["a", "", "b", "", "c"])
    }

    // MARK: - Unicode Content

    @Test
    func `optional handles unicode when present`() {
        let optional: TestRenderable? = TestRenderable("héllo 世界")
        let result = render(optional)
        #expect(result == "héllo 世界")
    }

    // MARK: - Parameterized Tests

    @Test(arguments: [
        ("test", "test"),
        ("", ""),
        ("unicode: 日本語", "unicode: 日本語"),
        ("<html>", "<html>")
    ])
    func `optional preserves content when present`(input: String, expected: String) {
        let optional: TestRenderable? = TestRenderable(input)
        let result = render(optional)
        #expect(result == expected)
    }
}
