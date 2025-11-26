//
//  AnyRenderable.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

/// Type-erased wrapper for any renderable content.
///
/// `AnyRenderable` allows you to work with heterogeneous renderable types
/// by erasing their specific type while preserving their rendering behavior.
///
/// Example:
/// ```swift
/// func makeContent(condition: Bool) -> AnyRenderable<MyContext> {
///     if condition {
///         AnyRenderable(SomeContent())
///     } else {
///         AnyRenderable(OtherContent())
///     }
/// }
/// ```
///
/// Note: This is a simple struct. Domain-specific modules (like RenderingHTML)
/// provide the `Renderable` conformance with the appropriate `Context` type.
public struct AnyRenderable<Context, Bytes>: @unchecked Sendable where Bytes: RangeReplaceableCollection, Bytes.Element == UInt8 {
    /// The type-erased base content.
    public let base: any Renderable

    /// The render function captured from the concrete type.
    private let renderFunction: (inout Bytes, inout Context) -> Void

    /// Creates a type-erased wrapper around the given rendering content.
    ///
    /// - Parameter base: The rendering content to wrap.
    public init<T: Renderable>(_ base: T) where T.Context == Context {
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
