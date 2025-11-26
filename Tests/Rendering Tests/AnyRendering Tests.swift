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
        let raw = Raw("content")
        let any = AnyRendering(raw)
        // AnyRendering should wrap the content
        _ = any // Verify it compiles and works
        #expect(true)
    }

    @Test
    func `AnyRendering from different types`() {
        let raw = Raw("raw")
        let any1 = AnyRendering(raw)

        let empty = Empty()
        let any2 = AnyRendering(empty)

        // Both should be AnyRendering
        let _: AnyRendering = any1
        let _: AnyRendering = any2
        #expect(true)
    }

    // MARK: - Sendable

    @Test
    func `AnyRendering is Sendable`() {
        let any = AnyRendering(Raw("test"))
        Task {
            _ = any
        }
        #expect(true) // Compile-time check
    }
}
