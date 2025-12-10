//
//  Rendering.Async.Protocol.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Rendering

extension Rendering.Async {
    /// A protocol for types that support async rendering with backpressure.
    ///
    /// The async rendering path allows suspension at element boundaries,
    /// enabling true progressive streaming where memory is bounded to O(chunkSize).
    ///
    /// Types conforming to `Rendering.Async.Protocol` must also conform to `Rendering.Protocol`
    /// with `Output == UInt8` (byte-based output). This is because async streaming
    /// is designed for progressive byte output (e.g., HTML streaming) where
    /// backpressure is needed to prevent unbounded memory growth.
    ///
    /// For non-byte output types (e.g., PDF operations), use synchronous rendering
    /// as those formats typically require full document assembly.
    ///
    /// ## Example
    ///
    /// ```swift
    /// extension MyView: Rendering.Async.Protocol {
    ///     static func _renderAsync(
    ///         _ markup: Self,
    ///         into sink: some Rendering.Async.Sink.Protocol,
    ///         context: inout Context
    ///     ) async {
    ///         await sink.write("<div>".utf8)
    ///         await Content._renderAsync(markup.body, into: sink, context: &context)
    ///         await sink.write("</div>".utf8)
    ///     }
    /// }
    /// ```
    public protocol `Protocol`: Rendering.`Protocol` where Output == UInt8 {
        /// Async render that can suspend at element boundaries.
        ///
        /// - Parameters:
        ///   - markup: The content to render.
        ///   - sink: The async sink to write bytes into (with backpressure).
        ///   - context: The rendering context.
        static func _renderAsync<Sink: Rendering.Async.Sink.`Protocol`>(
            _ markup: Self,
            into sink: Sink,
            context: inout Context
        ) async
    }
}

extension Rendering.Async.`Protocol` where Content: Rendering.Async.`Protocol`, Content.Context == Context {
    /// Default implementation that delegates to the content's async render method.
    @inlinable
    public static func _renderAsync<Sink: Rendering.Async.Sink.`Protocol`>(
        _ markup: Self,
        into sink: Sink,
        context: inout Context
    ) async {
        await Content._renderAsync(markup.body, into: sink, context: &context)
    }
}

extension Rendering.Async.`Protocol`
where Content: Rendering.`Protocol`, Content.Context == Context, Content.Output == UInt8 {
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
    public static func _renderAsync<Sink: Rendering.Async.Sink.`Protocol`>(
        _ markup: Self,
        into sink: Sink,
        context: inout Context
    ) async {
        // Get the body and dispatch to async rendering dynamically
        let body = markup.body
        await _renderAsyncDynamic(body, into: sink, context: &context)
    }
}

/// Dynamically dispatch async rendering based on runtime type conformance.
///
/// This function checks if the body type conforms to `Rendering.Async.Protocol` at runtime
/// and dispatches accordingly. This is necessary because opaque types (`some HTML.View`)
/// erase the `Rendering.Async.Protocol` conformance at compile time.
///
/// - Note: If the context type cast fails (which should not happen in well-formed
///   code), a debug assertion will fire to aid in debugging. In release builds,
///   the function falls back to sync rendering to maintain correctness.
@inlinable
public func _renderAsyncDynamic<T: Rendering.`Protocol`, Sink: Rendering.Async.Sink.`Protocol`>(
    _ markup: T,
    into sink: Sink,
    context: inout T.Context
) async where T.Output == UInt8 {
    // Check if T conforms to Rendering.Async.Protocol at runtime
    if let asyncType = T.self as? any Rendering.Async.`Protocol`.Type {
        // Open the existential to call _renderAsync with proper context handling
        var anyContext: Any = context
        var didRender = false

        func callRender<A: Rendering.Async.`Protocol`>(_ type: A.Type) async {
            guard let typedMarkup = markup as? A else {
                assertionFailure(
                    """
                    _renderAsyncDynamic: Failed to cast markup of type \(T.self) to \(A.self). \
                    This indicates a type system inconsistency.
                    """
                )
                return
            }
            guard var typedContext = anyContext as? A.Context else {
                assertionFailure(
                    """
                    _renderAsyncDynamic: Failed to cast context of type \(T.Context.self) to \(A.Context.self). \
                    Context mutations may be lost. Ensure Rendering.Async.Protocol types use compatible Context types.
                    """
                )
                return
            }
            await A._renderAsync(typedMarkup, into: sink, context: &typedContext)
            anyContext = typedContext
            didRender = true
        }
        await callRender(asyncType)

        // Copy back context if types match
        if let updatedContext = anyContext as? T.Context {
            context = updatedContext
        } else if didRender {
            assertionFailure(
                """
                _renderAsyncDynamic: Failed to cast updated context back to \(T.Context.self). \
                Context mutations from async rendering were lost.
                """
            )
        }

        // If we failed to render via async path, fall back to sync
        if !didRender {
            var buffer: [UInt8] = []
            T._render(markup, into: &buffer, context: &context)
            await sink.write(buffer)
        }
    } else {
        // True leaf node without Rendering.Async.Protocol conformance - sync render
        var buffer: [UInt8] = []
        T._render(markup, into: &buffer, context: &context)
        await sink.write(buffer)
    }
}

/// Typealias for backwards compatibility.
public typealias AsyncRenderable = Rendering.Async.`Protocol`
