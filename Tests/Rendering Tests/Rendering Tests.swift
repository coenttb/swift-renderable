//
//  Rendering Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

@testable import Rendering
import Testing

@Suite
struct `Rendering Tests` {

    // MARK: - Protocol Conformance

    @Test
    func `Rendering protocol has required associated types`() {
        // Verify the protocol structure exists
        // This is a compile-time test - if it compiles, the protocol is correctly defined
        func requiresRendering<T: Rendering>(_ type: T.Type) {}
        requiresRendering(Raw.self)
    }

    @Test
    func `Rendering protocol _render method signature`() {
        // The _render static method should be available
        struct TestView: Rendering {
            typealias Context = Never
            typealias Content = Never
            var body: Never { fatalError() }
        }
        // Compile-time verification that the type conforms
        let _: any Rendering.Type = TestView.self
    }
}
