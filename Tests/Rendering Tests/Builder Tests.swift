//
//  Builder Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

@testable import Rendering
import Testing

@Suite
struct `Builder Tests` {

    // MARK: - buildBlock

    @Test
    func `Builder buildBlock with single component`() {
        @Builder var result: Raw {
            Raw("hello")
        }
        #expect(result.bytes == Array("hello".utf8))
    }

    @Test
    func `Builder buildBlock with multiple components`() {
        @Builder var result: _Tuple<Raw, Raw> {
            Raw("hello")
            Raw(" world")
        }
        // Verify it creates a tuple
        #expect(result.value.0.bytes == Array("hello".utf8))
        #expect(result.value.1.bytes == Array(" world".utf8))
    }

    // MARK: - buildOptional

    @Test
    func `Builder buildOptional with some value`() {
        let showContent = true
        @Builder var result: Raw? {
            if showContent {
                Raw("content")
            }
        }
        #expect(result != nil)
        #expect(result?.bytes == Array("content".utf8))
    }

    @Test
    func `Builder buildOptional with nil`() {
        let showContent = false
        @Builder var result: Raw? {
            if showContent {
                Raw("content")
            }
        }
        #expect(result == nil)
    }

    // MARK: - buildEither

    @Test
    func `Builder buildEither first branch`() {
        let condition = true
        @Builder var result: _Conditional<Raw, Raw> {
            if condition {
                Raw("first")
            } else {
                Raw("second")
            }
        }
        // The conditional should contain the first branch
        switch result.value {
        case .first(let raw):
            #expect(raw.bytes == Array("first".utf8))
        case .second:
            Issue.record("Expected first branch")
        }
    }

    @Test
    func `Builder buildEither second branch`() {
        let condition = false
        @Builder var result: _Conditional<Raw, Raw> {
            if condition {
                Raw("first")
            } else {
                Raw("second")
            }
        }
        switch result.value {
        case .first:
            Issue.record("Expected second branch")
        case .second(let raw):
            #expect(raw.bytes == Array("second".utf8))
        }
    }

    // MARK: - buildArray

    @Test
    func `Builder buildArray with for loop`() {
        let items = ["a", "b", "c"]
        @Builder var result: _Array<Raw> {
            for item in items {
                Raw(item)
            }
        }
        #expect(result.value.count == 3)
        #expect(result.value[0].bytes == Array("a".utf8))
        #expect(result.value[1].bytes == Array("b".utf8))
        #expect(result.value[2].bytes == Array("c".utf8))
    }

    @Test
    func `Builder buildArray with empty loop`() {
        let items: [String] = []
        @Builder var result: _Array<Raw> {
            for item in items {
                Raw(item)
            }
        }
        #expect(result.value.isEmpty)
    }

    // MARK: - buildExpression

    @Test
    func `Builder buildExpression converts to Rendering type`() {
        @Builder var result: Raw {
            Raw("test")
        }
        #expect(result.bytes == Array("test".utf8))
    }
}
