//
//  _Array Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

@testable import Rendering
import Testing

// Note: _Array requires Element: Rendering, so we use a test helper type.
// Full rendering behavior tests are in domain-specific test modules.

@Suite
struct `_Array Tests` {

    // MARK: - Structure

    @Test
    func `_Array can hold elements`() {
        let array = _Array([TestElement(), TestElement(), TestElement()])
        #expect(array.elements.count == 3)
    }

    @Test
    func `_Array can be empty`() {
        let array = _Array<TestElement>([])
        #expect(array.elements.isEmpty)
    }

    @Test
    func `_Array elements property returns underlying array`() {
        let elements = [TestElement(), TestElement()]
        let array = _Array(elements)
        #expect(array.elements.count == 2)
    }

    // MARK: - Sendable

    @Test
    func `_Array is Sendable when Element is Sendable`() {
        let array = _Array([TestElement()])
        Task {
            _ = array.elements
        }
        #expect(Bool(true)) // Compile-time check
    }
}

// MARK: - Test Helpers

/// A minimal Rendering type for testing _Array
private struct TestElement: Renderable, Sendable {
    typealias Context = Void
    typealias Content = Never

    var body: Never { fatalError() }

    static func _render<Buffer: RangeReplaceableCollection>(
        _ markup: TestElement,
        into buffer: inout Buffer,
        context: inout Void
    ) where Buffer.Element == UInt8 {
        // No-op
    }
}
