//
//  Integration Tests.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Testing

@testable import Rendering

/// Integration tests that verify composition patterns across types.
///
/// Note: Some tests require `_Tuple` to conform to `Rendering.Protocol`.
/// In the base Rendering module, `_Tuple` does NOT have this conformance.
/// Domain-specific modules (e.g., HTML rendering) provide this conformance
/// to enable rendering of result builder compositions with multiple children.
///
/// Tests marked with `.disabled("Requires _Tuple conformance")` document
/// expected behavior when such conformance is provided.
@Suite
struct `Integration Tests` {

    // MARK: - Builder Composition

    @Test(.disabled("Requires _Tuple conformance from domain-specific module"))
    func `Group with two children renders both`() {
        // This test would pass when _Tuple<each Content: Rendering.Protocol>: Rendering.Protocol
        // is provided by a domain-specific module.
        //
        // let group = Rendering.Group {
        //     TestRenderable("first")
        //     TestRenderable("second")
        // }
        // let result = render(group)
        // #expect(result == "firstsecond")
    }

    @Test(.disabled("Requires _Tuple conformance from domain-specific module"))
    func `Group with three children renders all`() {
        // let group = Rendering.Group {
        //     TestRenderable("a")
        //     TestRenderable("b")
        //     TestRenderable("c")
        // }
        // let result = render(group)
        // #expect(result == "abc")
    }

    @Test(.disabled("Requires _Tuple conformance from domain-specific module"))
    func `Builder with mixed conditionals and content`() {
        // let condition = true
        // let group = Rendering.Group {
        //     TestRenderable("start")
        //     if condition {
        //         TestRenderable("middle")
        //     }
        //     TestRenderable("end")
        // }
        // let result = render(group)
        // #expect(result == "startmiddleend")
    }

    @Test(.disabled("Requires _Tuple conformance from domain-specific module"))
    func `Nested Groups with multiple children`() {
        // let inner = Rendering.Group {
        //     TestRenderable("a")
        //     TestRenderable("b")
        // }
        // let outer = Rendering.Group {
        //     TestRenderable("start")
        //     inner
        //     TestRenderable("end")
        // }
        // let result = render(outer)
        // #expect(result == "startabend")
    }

    // MARK: - ForEach with Multiple Siblings

    @Test(.disabled("Requires _Tuple conformance from domain-specific module"))
    func `ForEach alongside other content`() {
        // let items = ["x", "y"]
        // let group = Rendering.Group {
        //     TestRenderable("prefix")
        //     Rendering.ForEach(items) { item in
        //         TestRenderable(item)
        //     }
        //     TestRenderable("suffix")
        // }
        // let result = render(group)
        // #expect(result == "prefixxysuffix")
    }

    // MARK: - Complex Conditional Trees

    @Test(.disabled("Requires _Tuple conformance from domain-specific module"))
    func `Multiple conditionals in sequence`() {
        // let a = true
        // let b = false
        // let group = Rendering.Group {
        //     if a {
        //         TestRenderable("A")
        //     }
        //     if b {
        //         TestRenderable("B")
        //     } else {
        //         TestRenderable("notB")
        //     }
        // }
        // let result = render(group)
        // #expect(result == "AnotB")
    }

    // MARK: - Tests That Work Without _Tuple Conformance

    @Test
    func `Single item group renders correctly`() {
        let group = Rendering.Group {
            TestRenderable("solo")
        }
        let result = render(group)
        #expect(result == "solo")
    }

    @Test
    func `ForEach as sole content renders all items`() {
        let items = ["a", "b", "c"]
        let group = Rendering.Group {
            Rendering.ForEach(items) { item in
                TestRenderable(item)
            }
        }
        let result = render(group)
        #expect(result == "abc")
    }

    @Test
    func `Single conditional renders correct branch`() {
        let condition = true
        let group = Rendering.Group {
            if condition {
                TestRenderable("yes")
            } else {
                TestRenderable("no")
            }
        }
        let result = render(group)
        #expect(result == "yes")
    }

    @Test
    func `Optional binding as sole content`() {
        let maybeValue: String? = "found"
        let group = Rendering.Group {
            if let value = maybeValue {
                TestRenderable(value)
            }
        }
        let result = render(group)
        #expect(result == "found")
    }

    @Test
    func `Nested ForEach renders in order`() {
        let outer = ["a", "b"]
        let inner = ["1", "2"]
        let group = Rendering.Group {
            Rendering.ForEach(outer) { o in
                Rendering.ForEach(inner) { i in
                    TestRenderable("\(o)\(i)")
                }
            }
        }
        let result = render(group)
        #expect(result == "a1a2b1b2")
    }

    @Test
    func `_Array renders sequence of items`() {
        let array = Rendering._Array([
            TestRenderable("1"),
            TestRenderable("2"),
            TestRenderable("3"),
        ])
        let result = render(array)
        #expect(result == "123")
    }

    @Test
    func `_Conditional renders first branch`() {
        let conditional: Rendering._Conditional<TestRenderable, TestRenderable> = .first(
            TestRenderable("first")
        )
        let result = render(conditional)
        #expect(result == "first")
    }

    @Test
    func `_Conditional renders second branch`() {
        let conditional: Rendering._Conditional<TestRenderable, TestRenderable> = .second(
            TestRenderable("second")
        )
        let result = render(conditional)
        #expect(result == "second")
    }

    @Test
    func `AnyView type erasure works in collections`() {
        let items: [Rendering.AnyView<Void, [UInt8]>] = [
            Rendering.AnyView(TestRenderable("a")),
            Rendering.AnyView(TestRenderable("b")),
            Rendering.AnyView(TestRenderable("c")),
        ]
        var result = ""
        for item in items {
            var buffer: [UInt8] = []
            var context: Void = ()
            item.render(into: &buffer, context: &context)
            result += String(decoding: buffer, as: UTF8.self)
        }
        #expect(result == "abc")
    }

    @Test
    func `Context propagates through nested structures`() {
        var context = TestContext()
        let forEach = Rendering.ForEach(["a", "b", "c"]) { prefix in
            ContextualRenderable(prefix)
        }
        let result = render(forEach, context: &context)
        #expect(result == "a1b2c3")
        #expect(context.renderCount == 3)
    }

    @Test
    func `Empty can be instantiated`() {
        // Empty doesn't conform to Rendering.Protocol in base module,
        // but can be created and used structurally
        let empty = Rendering.Empty()
        // Empty is Equatable and Hashable
        #expect(empty == Rendering.Empty())
    }

    @Test
    func `Raw stores bytes correctly`() {
        // Raw doesn't conform to Rendering.Protocol in base module,
        // but stores bytes correctly for domain modules to render
        let raw = Rendering.Raw("<div>&amp;</div>")
        let expected = Array("<div>&amp;</div>".utf8)
        #expect(Array(raw.bytes) == expected)
    }
}

// MARK: - _Tuple Rendering Tests (Structural Only)

/// These tests verify _Tuple's structure but not its rendering,
/// since rendering requires domain-specific conformance.
@Suite
struct `_Tuple Structural Tests` {

    @Test
    func `_Tuple stores values correctly`() {
        let tuple = Rendering._Tuple(
            TestRenderable("a"),
            TestRenderable("b")
        )
        #expect(tuple.content.0.value == "a")
        #expect(tuple.content.1.value == "b")
    }

    @Test
    func `_Tuple with three elements`() {
        let tuple = Rendering._Tuple(
            TestRenderable("1"),
            TestRenderable("2"),
            TestRenderable("3")
        )
        #expect(tuple.content.0.value == "1")
        #expect(tuple.content.1.value == "2")
        #expect(tuple.content.2.value == "3")
    }

    @Test
    func `_Tuple with different types`() {
        // When domain provides conformance, these can be heterogeneous renderables
        let tuple = Rendering._Tuple(
            TestRenderable("text"),
            Rendering.Raw("raw")
        )
        #expect(tuple.content.0.value == "text")
        // Raw doesn't have a simple value property, but we verify it exists
    }

    @Test
    func `Deeply nested tuples`() {
        let inner = Rendering._Tuple(
            TestRenderable("a"),
            TestRenderable("b")
        )
        let outer = Rendering._Tuple(
            inner,
            TestRenderable("c")
        )
        #expect(outer.content.0.content.0.value == "a")
        #expect(outer.content.0.content.1.value == "b")
        #expect(outer.content.1.value == "c")
    }
}
