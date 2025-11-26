//
//  _Empty Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

@testable import Rendering
import Testing

@Suite
struct `_Empty Tests` {

    // MARK: - Initialization

    @Test
    func `Empty can be instantiated`() {
        let empty = Empty()
        _ = empty // Verify it exists
        #expect(true)
    }

    // MARK: - Sendable

    @Test
    func `Empty is Sendable`() {
        let empty = Empty()
        Task {
            _ = empty
        }
        #expect(true) // Compile-time check
    }
}
