//
//  Optional+Rendering Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

@testable import Rendering
import Testing

@Suite
struct `Optional+Rendering Tests` {

    // MARK: - Optional Rendering Conformance

    @Test
    func `Optional some value conforms to Rendering`() {
        let optional: Raw? = Raw("content")
        #expect(optional != nil)
        #expect(optional?.bytes == Array("content".utf8))
    }

    @Test
    func `Optional nil conforms to Rendering`() {
        let optional: Raw? = nil
        #expect(optional == nil)
    }

    // MARK: - In Builder Context

    @Test
    func `Optional in builder produces optional result`() {
        let showContent = true
        @Builder var result: Raw? {
            if showContent {
                Raw("shown")
            }
        }
        #expect(result?.bytes == Array("shown".utf8))
    }

    @Test
    func `Optional nil in builder`() {
        let showContent = false
        @Builder var result: Raw? {
            if showContent {
                Raw("hidden")
            }
        }
        #expect(result == nil)
    }
}
