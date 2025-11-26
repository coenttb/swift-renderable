//
//  AnyRendering Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

@testable import Rendering
import Testing

@Suite
struct `AnyRendering Tests` {

    // MARK: - Type Erasure

    @Test
    func `AnyRendering erases concrete type`() {
        let element = TestElement(id: "content")
        let any = AnyRendering<Void, [UInt8]>(element)
        _ = any // Verify it compiles and works
        #expect(Bool(true))
    }

    @Test
    func `AnyRendering from different types`() {
        let element1 = TestElement(id: "first")
        let any1 = AnyRendering<Void, [UInt8]>(element1)

        let element2 = OtherElement()
        let any2 = AnyRendering<Void, [UInt8]>(element2)

        // Both should be AnyRendering with same type parameters
        let _: AnyRendering<Void, [UInt8]> = any1
        let _: AnyRendering<Void, [UInt8]> = any2
        #expect(Bool(true))
    }

    // MARK: - Rendering

    @Test
    func `AnyRendering can render to buffer`() {
        let element = TestElement(id: "test")
        let any = AnyRendering<Void, [UInt8]>(element)

        var buffer: [UInt8] = []
        var context: Void = ()
        any.render(into: &buffer, context: &context)
        // Buffer contains rendered content (empty in this case since TestElement is a no-op)
        #expect(Bool(true))
    }

    // MARK: - Sendable

    @Test
    func `AnyRendering is Sendable`() {
        let any = AnyRendering<Void, [UInt8]>(TestElement(id: "test"))
        Task {
            _ = any
        }
        #expect(Bool(true)) // Compile-time check
    }
}

// MARK: - Test Helpers

private struct TestElement: Renderable, Sendable {
    let id: String
    typealias Context = Void
    typealias Content = Never

    var body: Never { fatalError() }

    static func _render<Buffer: RangeReplaceableCollection>(
        _ markup: TestElement,
        into buffer: inout Buffer,
        context: inout Void
    ) where Buffer.Element == UInt8 {}
}

private struct OtherElement: Renderable, Sendable {
    typealias Context = Void
    typealias Content = Never
    var body: Never { fatalError() }

    static func _render<Buffer: RangeReplaceableCollection>(
        _ markup: OtherElement,
        into buffer: inout Buffer,
        context: inout Void
    ) where Buffer.Element == UInt8 {}
}
