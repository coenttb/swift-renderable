//
//  HTML.StreamingMode Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Rendering_HTML
import Testing

@Suite
struct `HTML.StreamingMode Tests` {

    // MARK: - Enum Cases

    @Test
    func `StreamingMode has batch case`() {
        let mode: HTML.StreamingMode = .batch
        #expect(mode == .batch)
    }

    @Test
    func `StreamingMode has progressive case`() {
        let mode: HTML.StreamingMode = .progressive
        #expect(mode == .progressive)
    }

    @Test
    func `StreamingMode has backpressure case`() {
        let mode: HTML.StreamingMode = .backpressure
        #expect(mode == .backpressure)
    }

    // MARK: - Sendable

    @Test
    func `StreamingMode is Sendable`() {
        let mode: HTML.StreamingMode = .batch
        Task {
            _ = mode
        }
        #expect(Bool(true)) // Compile-time check
    }

    // MARK: - Equality

    @Test
    func `StreamingMode cases are distinct`() {
        let batch: HTML.StreamingMode = .batch
        let progressive: HTML.StreamingMode = .progressive
        let backpressure: HTML.StreamingMode = .backpressure

        #expect(batch != progressive)
        #expect(batch != backpressure)
        #expect(progressive != backpressure)
    }
}
