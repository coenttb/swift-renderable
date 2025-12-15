//
//  AnyView Tests.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Testing

@testable import Rendering

@Suite
struct `AnyView Tests` {

    // MARK: - Initialization

    @Test
    func `AnyView can wrap a renderable`() {
        let anyView = Rendering.AnyView<Void, [UInt8]>(TestRenderable("wrapped"))
        #expect(anyView.base is TestRenderable)
    }

    @Test
    func `AnyView preserves wrapped value type`() {
        let original = TestRenderable("test")
        let anyView = Rendering.AnyView<Void, [UInt8]>(original)
        #expect(anyView.base is TestRenderable)
    }

    // MARK: - Rendering

    @Test
    func `render method produces correct output`() {
        let anyView = Rendering.AnyView<Void, [UInt8]>(TestRenderable("hello"))
        var buffer: [UInt8] = []
        var context: Void = ()
        anyView.render(into: &buffer, context: &context)

        #expect(String(decoding: buffer, as: UTF8.self) == "hello")
    }

    @Test
    func `render handles empty content`() {
        let anyView = Rendering.AnyView<Void, [UInt8]>(TestRenderable(""))
        var buffer: [UInt8] = []
        var context: Void = ()
        anyView.render(into: &buffer, context: &context)

        #expect(buffer.isEmpty)
    }

    @Test
    func `render appends to existing buffer`() {
        let anyView = Rendering.AnyView<Void, [UInt8]>(TestRenderable("suffix"))
        var buffer: [UInt8] = Array("prefix-".utf8)
        var context: Void = ()
        anyView.render(into: &buffer, context: &context)

        #expect(String(decoding: buffer, as: UTF8.self) == "prefix-suffix")
    }

    // MARK: - Type Erasure

    @Test
    func `AnyView erases concrete type`() {
        let renderable1 = TestRenderable("a")
        let renderable2 = OtherTestRenderable("b")

        let any1 = Rendering.AnyView<Void, [UInt8]>(renderable1)
        let any2 = Rendering.AnyView<Void, [UInt8]>(renderable2)

        // Both are AnyView<Void, [UInt8]> despite different underlying types
        let array: [Rendering.AnyView<Void, [UInt8]>] = [any1, any2]
        #expect(array.count == 2)
    }

    @Test
    func `AnyView can be returned from function`() {
        func makeAny(condition: Bool) -> Rendering.AnyView<Void, [UInt8]> {
            if condition {
                return Rendering.AnyView(TestRenderable("true"))
            } else {
                return Rendering.AnyView(OtherTestRenderable("false"))
            }
        }

        let trueCase = makeAny(condition: true)
        let falseCase = makeAny(condition: false)

        var buffer1: [UInt8] = []
        var buffer2: [UInt8] = []
        var context: Void = ()

        trueCase.render(into: &buffer1, context: &context)
        falseCase.render(into: &buffer2, context: &context)

        #expect(String(decoding: buffer1, as: UTF8.self) == "true")
        #expect(String(decoding: buffer2, as: UTF8.self) == "false")
    }

    // MARK: - Heterogeneous Collections

    @Test
    func `AnyView enables heterogeneous arrays`() {
        let items: [Rendering.AnyView<Void, [UInt8]>] = [
            Rendering.AnyView(TestRenderable("one")),
            Rendering.AnyView(OtherTestRenderable("two")),
            Rendering.AnyView(TestRenderable("three")),
        ]

        var results: [String] = []
        for item in items {
            var buffer: [UInt8] = []
            var context: Void = ()
            item.render(into: &buffer, context: &context)
            results.append(String(decoding: buffer, as: UTF8.self))
        }

        #expect(results == ["one", "two", "three"])
    }

    // MARK: - Sendable

    @Test
    func `AnyView is Sendable`() {
        let anyView = Rendering.AnyView<Void, [UInt8]>(TestRenderable("test"))
        Task {
            _ = anyView.base
        }
        #expect(Bool(true))
    }

    // MARK: - Typealias

    @Test
    func `AnyRenderable typealias works`() {
        let anyRenderable: AnyRenderable<Void, [UInt8]> = AnyRenderable(TestRenderable("alias"))
        var buffer: [UInt8] = []
        var context: Void = ()
        anyRenderable.render(into: &buffer, context: &context)

        #expect(String(decoding: buffer, as: UTF8.self) == "alias")
    }

    // MARK: - Buffer Types

    @Test
    func `render works with ContiguousArray buffer`() {
        let anyView = Rendering.AnyView<Void, ContiguousArray<UInt8>>(TestRenderable("test"))
        var buffer: ContiguousArray<UInt8> = []
        var context: Void = ()
        anyView.render(into: &buffer, context: &context)

        #expect(String(decoding: buffer, as: UTF8.self) == "test")
    }

    // MARK: - Context Types

    @Test
    func `AnyView works with custom context`() {
        let anyView = Rendering.AnyView<TestContext, [UInt8]>(ContextualRenderable("ctx"))
        var buffer: [UInt8] = []
        var context = TestContext()
        anyView.render(into: &buffer, context: &context)

        #expect(String(decoding: buffer, as: UTF8.self) == "ctx1")
        #expect(context.renderCount == 1)
    }

    // MARK: - Multiple Renders

    @Test
    func `AnyView can be rendered multiple times`() {
        let anyView = Rendering.AnyView<Void, [UInt8]>(TestRenderable("repeat"))

        var results: [String] = []
        for _ in 0..<3 {
            var buffer: [UInt8] = []
            var context: Void = ()
            anyView.render(into: &buffer, context: &context)
            results.append(String(decoding: buffer, as: UTF8.self))
        }

        #expect(results == ["repeat", "repeat", "repeat"])
    }

    // MARK: - Base Property

    @Test
    func `base property returns wrapped value`() {
        let original = TestRenderable("original")
        let anyView = Rendering.AnyView<Void, [UInt8]>(original)

        #expect(anyView.base is TestRenderable)
        #expect((anyView.base as? TestRenderable)?.value == "original")
    }

    // MARK: - Unicode Content

    @Test
    func `AnyView handles unicode content`() {
        let anyView = Rendering.AnyView<Void, [UInt8]>(TestRenderable("héllo 世界 🎉"))
        var buffer: [UInt8] = []
        var context: Void = ()
        anyView.render(into: &buffer, context: &context)

        #expect(String(decoding: buffer, as: UTF8.self) == "héllo 世界 🎉")
    }
}

// MARK: - Test Helpers

private struct OtherTestRenderable: Rendering.`Protocol`, Sendable {
    let value: String

    typealias Context = Void
    typealias Content = Never
    typealias Output = UInt8

    init(_ value: String) {
        self.value = value
    }

    var body: Never {
        fatalError("This type uses direct rendering and doesn't have a body.")
    }

    static func _render<Buffer: RangeReplaceableCollection>(
        _ markup: OtherTestRenderable,
        into buffer: inout Buffer,
        context: inout Void
    ) where Buffer.Element == UInt8 {
        buffer.append(contentsOf: markup.value.utf8)
    }
}
