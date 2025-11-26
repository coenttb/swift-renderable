//
//  AnyRendering.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

/// Type-erased wrapper for any rendering content.
///
/// `AnyRendering` allows you to work with heterogeneous rendering types
/// by erasing their specific type while preserving their rendering behavior.
///
/// Example:
/// ```swift
/// func makeContent(condition: Bool) -> AnyRendering<MyContext> {
///     if condition {
///         AnyRendering(SomeContent())
///     } else {
///         AnyRendering(OtherContent())
///     }
/// }
/// ```
///
/// Note: This is a simple struct. Domain-specific modules (like RenderingHTML)
/// provide the `Rendering` conformance with the appropriate `Context` type.
public struct AnyRendering<Context>: @unchecked Sendable {
    /// The type-erased base content.
    public let base: any Rendering

    /// The render function captured from the concrete type.
    private let renderFunction: (inout ContiguousArray<UInt8>, inout Context) -> Void

    /// Creates a type-erased wrapper around the given rendering content.
    ///
    /// - Parameter base: The rendering content to wrap.
    public init<T: Rendering>(_ base: T) where T.Context == Context {
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
    public func render(into buffer: inout ContiguousArray<UInt8>, context: inout Context) {
        renderFunction(&buffer, &context)
    }
}
