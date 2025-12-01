//
//  _Empty Tests.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Testing

@testable import Renderable

@Suite
struct `_Empty Tests` {

    // MARK: - Initialization

    @Test
    func `Empty can be instantiated`() {
        let empty = Empty()
        _ = empty  // Verify it exists
        #expect(true)
    }

    // MARK: - Sendable

    @Test
    func `Empty is Sendable`() {
        let empty = Empty()
        Task {
            _ = empty
        }
        #expect(true)  // Compile-time check
    }
}
