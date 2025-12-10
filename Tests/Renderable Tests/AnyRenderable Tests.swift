//
//  AnyRenderable Tests.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Testing

@testable import Renderable

@Suite
struct `AnyRenderable Tests` {

    // MARK: - Type Erasure

    @Test
    func `AnyRenderable erases concrete type`() {
        let element = TestElement(id: "content")
        let any = AnyRenderable<Void, [UInt8]>(element)
        _ = any  // Verify it compiles and works
        #expect(Bool(true))
    }

    @Test
    func `AnyRenderable from different types`() {
        let element1 = TestElement(id: "first")
        let any1 = AnyRenderable<Void, [UInt8]>(element1)

        let element2 = OtherElement()
        let any2 = AnyRenderable<Void, [UInt8]>(element2)

        // Both should be AnyRenderable with same type parameters
        let _: AnyRenderable<Void, [UInt8]> = any1
        let _: AnyRenderable<Void, [UInt8]> = any2
        #expect(Bool(true))
    }

    // MARK: - Rendering

    @Test
    func `AnyRenderable can render to buffer`() {
        let element = TestElement(id: "test")
        let any = AnyRenderable<Void, [UInt8]>(element)

        var buffer: [UInt8] = []
        var context: Void = ()
        any.render(into: &buffer, context: &context)
        // Buffer contains rendered content (empty in this case since TestElement is a no-op)
        #expect(Bool(true))
    }

    // MARK: - Sendable

    @Test
    func `AnyRenderable is Sendable`() {
        let any = AnyRenderable<Void, [UInt8]>(TestElement(id: "test"))
        Task {
            _ = any
        }
        #expect(Bool(true))  // Compile-time check
    }
}

// MARK: - Test Helpers

private struct TestElement: Renderable, Sendable {
    let id: String
    typealias Context = Void
    typealias Content = Never
    typealias Output = UInt8

    var body: Never { fatalError("This type uses direct rendering and doesn't have a body.") }

    static func _render<Buffer: RangeReplaceableCollection>(
        _ markup: TestElement,
        into buffer: inout Buffer,
        context: inout Void
    ) where Buffer.Element == Output {}
}

private struct OtherElement: Renderable, Sendable {
    typealias Context = Void
    typealias Content = Never
    typealias Output = UInt8
    var body: Never { fatalError("This type uses direct rendering and doesn't have a body.") }

    static func _render<Buffer: RangeReplaceableCollection>(
        _ markup: OtherElement,
        into buffer: inout Buffer,
        context: inout Void
    ) where Buffer.Element == Output {}
}
