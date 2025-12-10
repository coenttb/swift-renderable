//
//  Rendering.AnyView.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

extension Rendering {
    /// Type-erased wrapper for any renderable content.
    ///
    /// `Rendering.AnyView` allows you to work with heterogeneous renderable types
    /// by erasing their specific type while preserving their rendering behavior.
    ///
    /// Example:
    /// ```swift
    /// func makeContent(condition: Bool) -> Rendering.AnyView<MyContext, [UInt8]> {
    ///     if condition {
    ///         Rendering.AnyView(SomeContent())
    ///     } else {
    ///         Rendering.AnyView(OtherContent())
    ///     }
    /// }
    /// ```
    ///
    /// Note: This is a simple struct. Domain-specific modules (like HTML rendering)
    /// provide the `Rendering.Protocol` conformance with the appropriate `Context` type.
    public struct AnyView<Context, Bytes>: @unchecked Sendable
    where Bytes: RangeReplaceableCollection, Bytes.Element == UInt8 {
        /// The type-erased base content.
        public let base: any Rendering.`Protocol`

        /// The render function captured from the concrete type.
        private let renderFunction: (inout Bytes, inout Context) -> Void

        /// Creates a type-erased wrapper around the given rendering content.
        ///
        /// - Parameter base: The rendering content to wrap.
        public init<T: Rendering.`Protocol`>(_ base: T) where T.Context == Context, T.Output == UInt8 {
            self.base = base
            self.renderFunction = { buffer, context in
                T._render(base, into: &buffer, context: &context)
            }
        }

        /// Invokes the stored render function.
        ///
        /// - Parameters:
        ///   - buffer: The buffer to render into.
        ///   - context: The rendering context.
        public func render(into buffer: inout Bytes, context: inout Context) {
            renderFunction(&buffer, &context)
        }
    }
}

/// Typealias for backwards compatibility.
public typealias AnyRenderable<Context, Bytes> = Rendering.AnyView<Context, Bytes>
    where Bytes: RangeReplaceableCollection, Bytes.Element == UInt8
