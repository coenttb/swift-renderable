//
//  Group Tests.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Foundation
import Testing

@testable import Rendering

@Suite
struct `Group Tests` {

    // MARK: - Initialization

    @Test
    func `Group can be created with builder syntax`() {
        let group = Rendering.Group {
            TestRenderable("content")
        }
        #expect(group.content.value == "content")
    }

    @Test
    func `Group stores content correctly`() {
        let group = Rendering.Group {
            TestRenderable("stored")
        }
        #expect(group.content.value == "stored")
    }

    // MARK: - Rendering

    @Test
    func `Group renders its content`() {
        let group = Rendering.Group {
            TestRenderable("hello")
        }
        let result = render(group)
        #expect(result == "hello")
    }

    // Note: Rendering multiple children requires _Tuple to conform to Rendering.Protocol,
    // which is provided by domain-specific modules. Single-item tests suffice for base module.

    @Test
    func `Group renders empty content`() {
        let group = Rendering.Group {
            TestRenderable("")
        }
        let result = render(group)
        #expect(result.isEmpty)
    }

    // MARK: - Body Property

    @Test
    func `body property returns content`() {
        let group = Rendering.Group {
            TestRenderable("body")
        }
        #expect(group.body.value == "body")
    }

    // MARK: - Protocol Conformance

    @Test
    func `Group conforms to Rendering.Protocol`() {
        let group = Rendering.Group {
            TestRenderable("test")
        }
        let _: any Rendering.`Protocol` = group
        #expect(Bool(true))
    }

    // MARK: - Equatable

    @Test
    func `Group is Equatable when Content is Equatable`() {
        let group1 = Rendering.Group { TestRenderable("x") }
        let group2 = Rendering.Group { TestRenderable("x") }
        let group3 = Rendering.Group { TestRenderable("y") }

        #expect(group1 == group2)
        #expect(group1 != group3)
    }

    // MARK: - Hashable

    @Test
    func `Group is Hashable when Content is Hashable`() {
        let group1 = Rendering.Group { TestRenderable("x") }
        let group2 = Rendering.Group { TestRenderable("x") }

        var set: Set<Rendering.Group<TestRenderable>> = []
        set.insert(group1)

        #expect(set.contains(group2))
        #expect(set.count == 1)
    }

    // MARK: - Sendable

    @Test
    func `Group is Sendable when Content is Sendable`() {
        let group = Rendering.Group {
            TestRenderable("test")
        }
        Task {
            _ = group.content
        }
        #expect(Bool(true))
    }

    // MARK: - Codable

    @Test
    func `Group is Codable when Content is Codable`() throws {
        let original = Rendering.Group { TestRenderable("encoded") }

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Rendering.Group<TestRenderable>.self, from: data)

        #expect(original == decoded)
    }

    // MARK: - Typealias

    @Test
    func `Group typealias works`() {
        let group: Group<TestRenderable> = Group {
            TestRenderable("alias")
        }
        #expect(render(group) == "alias")
    }

    // MARK: - Nested Groups

    @Test
    func `nested Groups render correctly`() {
        let inner = Rendering.Group { TestRenderable("inner") }
        let outer = Rendering.Group { inner }

        let result = render(outer)
        #expect(result == "inner")
    }

    // MARK: - Context Propagation

    @Test
    func `Group passes context to content`() {
        let group = Rendering.Group {
            ContextualRenderable("g")
        }
        var context = TestContext()
        let result = render(group, context: &context)

        #expect(result == "g1")
        #expect(context.renderCount == 1)
    }

    // MARK: - Builder Integration

    @Test
    func `Group works with conditional content`() {
        let condition = true
        let group = Rendering.Group {
            if condition {
                TestRenderable("true")
            } else {
                TestRenderable("false")
            }
        }
        let result = render(group)
        #expect(result == "true")
    }

    @Test
    func `Group works with optional content present`() {
        let maybeValue: String? = "present"
        let group = Rendering.Group {
            if let value = maybeValue {
                TestRenderable(value)
            }
        }
        let result = render(group)
        #expect(result == "present")
    }

    @Test
    func `Group works with optional content absent`() {
        let maybeValue: String? = nil
        let group = Rendering.Group {
            if let value = maybeValue {
                TestRenderable(value)
            }
        }
        let result = render(group)
        #expect(result.isEmpty)
    }
}
