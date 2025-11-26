//
//  _Array Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

@testable import Rendering
import Testing

@Suite
struct `_Array Tests` {

    // MARK: - Initialization

    @Test
    func `_Array init with elements`() {
        let array = _Array([Raw("a"), Raw("b"), Raw("c")])
        #expect(array.value.count == 3)
    }

    @Test
    func `_Array init with empty array`() {
        let array = _Array<Raw>([])
        #expect(array.value.isEmpty)
    }

    // MARK: - Value Access

    @Test
    func `_Array value property returns underlying array`() {
        let elements = [Raw("x"), Raw("y")]
        let array = _Array(elements)
        #expect(array.value.count == 2)
        #expect(array.value[0].bytes == Array("x".utf8))
        #expect(array.value[1].bytes == Array("y".utf8))
    }

    // MARK: - Sendable

    @Test
    func `_Array is Sendable when Element is Sendable`() {
        let array = _Array([Raw("test")])
        Task {
            _ = array.value
        }
        #expect(true) // Compile-time check
    }
}
