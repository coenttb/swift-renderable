//
//  Optional+Rendering Tests.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

@testable import Renderable
import Testing

@Suite
struct `Optional+Rendering Tests` {

    // MARK: - Optional Values

    @Test
    func `Optional some value`() {
        let optional: TestElement? = TestElement(id: "content")
        #expect(optional != nil)
        #expect(optional?.id == "content")
    }

    @Test
    func `Optional nil value`() {
        let optional: TestElement? = nil
        #expect(optional == nil)
    }

    // MARK: - Sendable

    @Test
    func `Optional is Sendable when Wrapped is Sendable`() {
        let optional: TestElement? = TestElement(id: "test")
        Task {
            _ = optional
        }
        #expect(Bool(true)) // Compile-time check
    }
}

// MARK: - Test Helpers

private struct TestElement: Renderable, Sendable {
    let id: String
    typealias Context = Void
    typealias Content = Never

    var body: Never { fatalError("This type uses direct rendering and doesn't have a body.") }

    static func _render<Buffer: RangeReplaceableCollection>(
        _ markup: TestElement,
        into buffer: inout Buffer,
        context: inout Void
    ) where Buffer.Element == UInt8 {}
}
