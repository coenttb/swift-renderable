//
//  AsyncRendering.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

/// A protocol for async rendering streams that accept bytes with backpressure.
///
/// Conforming types provide an async `write` method that may suspend to apply
/// backpressure when the consumer is slower than the producer.
public protocol AsyncRenderingStreamProtocol: Sendable {
    /// Write bytes to the stream, potentially suspending for backpressure.
    func write(_ bytes: some Sequence<UInt8> & Sendable) async

    /// Write a single byte to the stream.
    func write(_ byte: UInt8) async
}

/// A protocol for types that support async rendering with backpressure.
///
/// The async rendering path allows suspension at element boundaries,
/// enabling true progressive streaming where memory is bounded to O(chunkSize).
///
/// Types conforming to `AsyncRendering` must also conform to `Rendering`.
/// The async path is used for progressive streaming scenarios where backpressure
/// is needed to prevent unbounded memory growth.
///
/// ## Example
///
/// ```swift
/// extension MyView: AsyncRendering {
///     static func _renderAsync(
///         _ markup: Self,
///         into stream: some AsyncRenderingStreamProtocol,
///         context: inout Context
///     ) async {
///         await stream.write("<div>".utf8)
///         await Content._renderAsync(markup.body, into: stream, context: &context)
///         await stream.write("</div>".utf8)
///     }
/// }
/// ```
public protocol AsyncRendering: Rendering {
    /// Async render that can suspend at element boundaries.
    ///
    /// - Parameters:
    ///   - markup: The content to render.
    ///   - stream: The async stream to write bytes into (with backpressure).
    ///   - context: The rendering context.
    static func _renderAsync<Stream: AsyncRenderingStreamProtocol>(
        _ markup: Self,
        into stream: Stream,
        context: inout Context
    ) async
}

extension AsyncRendering where Content: AsyncRendering, Content.Context == Context {
    /// Default implementation that delegates to the content's async render method.
    @inlinable
    public static func _renderAsync<Stream: AsyncRenderingStreamProtocol>(
        _ markup: Self,
        into stream: Stream,
        context: inout Context
    ) async {
        await Content._renderAsync(markup.body, into: stream, context: &context)
    }
}

extension AsyncRendering where Content: Rendering, Content.Context == Context {
    /// Fallback implementation that recursively renders the body asynchronously.
    ///
    /// This fallback traverses the view tree by getting the body and dispatching
    /// to its async render implementation. This ensures progressive streaming
    /// works even when the body is an opaque type (`some HTML.View`).
    ///
    /// The traversal continues until reaching a primitive type (like `HTML.Element`,
    /// `_Array`, `_Tuple`, etc.) that has a custom `_renderAsync` implementation
    /// with actual suspension points.
    @inlinable
    @_disfavoredOverload
    public static func _renderAsync<Stream: AsyncRenderingStreamProtocol>(
        _ markup: Self,
        into stream: Stream,
        context: inout Context
    ) async {
        // Get the body and dispatch to async rendering dynamically
        let body = markup.body
        await _renderAsyncDynamic(body, into: stream, context: &context)
    }
}

/// Dynamically dispatch async rendering based on runtime type conformance.
///
/// This function checks if the body type conforms to `AsyncRendering` at runtime
/// and dispatches accordingly. This is necessary because opaque types (`some HTML.View`)
/// erase the `AsyncRendering` conformance at compile time.
///
/// - Note: If the context type cast fails (which should not happen in well-formed
///   code), a debug assertion will fire to aid in debugging. In release builds,
///   the function falls back to sync rendering to maintain correctness.
@inlinable
public func _renderAsyncDynamic<T: Rendering, Stream: AsyncRenderingStreamProtocol>(
    _ markup: T,
    into stream: Stream,
    context: inout T.Context
) async {
    // Check if T conforms to AsyncRendering at runtime
    if let asyncType = T.self as? any AsyncRendering.Type {
        // Open the existential to call _renderAsync with proper context handling
        var anyContext: Any = context
        var didRender = false

        func callRender<A: AsyncRendering>(_ type: A.Type) async {
            guard let typedMarkup = markup as? A else {
                assertionFailure("""
                    _renderAsyncDynamic: Failed to cast markup of type \(T.self) to \(A.self). \
                    This indicates a type system inconsistency.
                    """)
                return
            }
            guard var typedContext = anyContext as? A.Context else {
                assertionFailure("""
                    _renderAsyncDynamic: Failed to cast context of type \(T.Context.self) to \(A.Context.self). \
                    Context mutations may be lost. Ensure AsyncRendering types use compatible Context types.
                    """)
                return
            }
            await A._renderAsync(typedMarkup, into: stream, context: &typedContext)
            anyContext = typedContext
            didRender = true
        }
        await callRender(asyncType)

        // Copy back context if types match
        if let updatedContext = anyContext as? T.Context {
            context = updatedContext
        } else if didRender {
            assertionFailure("""
                _renderAsyncDynamic: Failed to cast updated context back to \(T.Context.self). \
                Context mutations from async rendering were lost.
                """)
        }

        // If we failed to render via async path, fall back to sync
        if !didRender {
            var buffer: [UInt8] = []
            T._render(markup, into: &buffer, context: &context)
            await stream.write(buffer)
        }
    } else {
        // True leaf node without AsyncRendering conformance - sync render
        var buffer: [UInt8] = []
        T._render(markup, into: &buffer, context: &context)
        await stream.write(buffer)
    }
}
