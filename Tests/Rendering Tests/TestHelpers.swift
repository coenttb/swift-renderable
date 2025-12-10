//
//  TestHelpers.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Foundation
import Testing
@testable import Rendering

// MARK: - Test Rendering Types

/// A minimal renderable type for testing
struct TestRenderable: Rendering.`Protocol`, Sendable, Equatable, Hashable, Codable {
    let value: String

    typealias Context = Void
    typealias Content = Never
    typealias Output = UInt8

    init(_ value: String = "test") {
        self.value = value
    }

    var body: Never {
        fatalError("This type uses direct rendering and doesn't have a body.")
    }

    static func _render<Buffer: RangeReplaceableCollection>(
        _ markup: TestRenderable,
        into buffer: inout Buffer,
        context: inout Void
    ) where Buffer.Element == UInt8 {
        buffer.append(contentsOf: markup.value.utf8)
    }
}

/// A renderable type with custom context for testing context propagation
struct ContextualRenderable: Rendering.`Protocol`, Sendable {
    let prefix: String

    typealias Context = TestContext
    typealias Content = Never
    typealias Output = UInt8

    init(_ prefix: String = "") {
        self.prefix = prefix
    }

    var body: Never {
        fatalError("This type uses direct rendering and doesn't have a body.")
    }

    static func _render<Buffer: RangeReplaceableCollection>(
        _ markup: ContextualRenderable,
        into buffer: inout Buffer,
        context: inout TestContext
    ) where Buffer.Element == UInt8 {
        context.renderCount += 1
        let output = "\(markup.prefix)\(context.renderCount)"
        buffer.append(contentsOf: output.utf8)
    }
}

/// Test context for tracking rendering state
struct TestContext: Sendable {
    var renderCount: Int = 0
    var metadata: String = ""

    init() {}
    init(renderCount: Int, metadata: String = "") {
        self.renderCount = renderCount
        self.metadata = metadata
    }
}

/// A renderable type that uses body delegation
struct CompositeRenderable: Rendering.`Protocol`, Sendable {
    let children: [TestRenderable]

    typealias Context = Void
    typealias Output = UInt8

    var body: Rendering._Array<TestRenderable> {
        Rendering._Array(children)
    }
}

// MARK: - Render Helpers

/// Renders a renderable to a String for easy testing
func render<T: Rendering.`Protocol`>(_ renderable: T) -> String where T.Context == Void, T.Output == UInt8 {
    var buffer: [UInt8] = []
    var context: Void = ()
    T._render(renderable, into: &buffer, context: &context)
    return String(decoding: buffer, as: UTF8.self)
}

/// Renders a renderable with context to a String
func render<T: Rendering.`Protocol`>(_ renderable: T, context: inout T.Context) -> String where T.Output == UInt8 {
    var buffer: [UInt8] = []
    T._render(renderable, into: &buffer, context: &context)
    return String(decoding: buffer, as: UTF8.self)
}

/// Renders a renderable to bytes
func renderBytes<T: Rendering.`Protocol`>(_ renderable: T) -> [UInt8] where T.Context == Void, T.Output == UInt8 {
    var buffer: [UInt8] = []
    var context: Void = ()
    T._render(renderable, into: &buffer, context: &context)
    return buffer
}
