//
//  _Tuple Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

@testable import Rendering
import Testing

@Suite
struct `_Tuple Tests` {

    // MARK: - Two Elements

    @Test
    func `_Tuple with two elements`() {
        let tuple = _Tuple((Raw("a"), Raw("b")))
        #expect(tuple.value.0.bytes == Array("a".utf8))
        #expect(tuple.value.1.bytes == Array("b".utf8))
    }

    // MARK: - Three Elements

    @Test
    func `_Tuple with three elements`() {
        let tuple = _Tuple((Raw("a"), Raw("b"), Raw("c")))
        #expect(tuple.value.0.bytes == Array("a".utf8))
        #expect(tuple.value.1.bytes == Array("b".utf8))
        #expect(tuple.value.2.bytes == Array("c".utf8))
    }

    // MARK: - Mixed Types

    @Test
    func `_Tuple with mixed Rendering types`() {
        struct CustomType: Rendering {
            typealias Context = Never
            typealias Content = Never
            let name: String
            var body: Never { fatalError() }
        }

        let tuple = _Tuple((Raw("raw"), CustomType(name: "custom")))
        #expect(tuple.value.0.bytes == Array("raw".utf8))
        #expect(tuple.value.1.name == "custom")
    }

    // MARK: - Sendable

    @Test
    func `_Tuple is Sendable when all elements are Sendable`() {
        let tuple = _Tuple((Raw("a"), Raw("b")))
        Task {
            _ = tuple.value
        }
        #expect(true) // Compile-time check
    }
}
