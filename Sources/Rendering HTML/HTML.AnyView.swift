//
//  HTML.AnyView.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

public import Rendering

extension HTML {
    /// Type-erased wrapper for any HTML content.
    ///
    /// `HTML.AnyView` allows you to work with heterogeneous HTML types
    /// by erasing their specific type while preserving their rendering behavior.
    ///
    /// Example:
    /// ```swift
    /// func makeContent(condition: Bool) -> HTML.AnyView {
    ///     if condition {
    ///         HTML.AnyView(div { "Hello" })
    ///     } else {
    ///         HTML.AnyView(span { "World" })
    ///     }
    /// }
    /// ```
    public struct AnyView: HTML.View, @unchecked Sendable {
        public let base: any HTML.View
        private let renderFunction: (inout ContiguousArray<UInt8>, inout HTML.Context) -> Void

        public init<T: HTML.View>(_ base: T) {
            self.base = base
            self.renderFunction = { buffer, context in
                T._render(base, into: &buffer, context: &context)
            }
        }

        public static func _render<Buffer: RangeReplaceableCollection>(
            _ html: HTML.AnyView,
            into buffer: inout Buffer,
            context: inout HTML.Context
        ) where Buffer.Element == UInt8 {
            var contiguousBuffer = ContiguousArray<UInt8>()
            html.renderFunction(&contiguousBuffer, &context)
            buffer.append(contentsOf: contiguousBuffer)
        }

        public var body: Never { fatalError() }
    }
}

extension HTML.AnyView {
    /// Creates a type-erased HTML wrapper from a builder closure.
    ///
    /// - Parameter closure: A closure that returns any HTML content.
    public init(
        @HTML.Builder _ closure: () -> any HTML.View
    ) {
        self.init(closure())
    }
}

// Keep AnyRendering conformance for interoperability
extension AnyRendering: Renderable where Context == HTML.Context {
    public typealias Content = Never

    public var body: Never { fatalError() }
}

extension AnyRendering: HTML.View where Context == HTML.Context {}
public typealias AnyHTML = HTML.AnyView
