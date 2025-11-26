//
//  Rendering.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

/// A protocol for types that can be rendered to a byte buffer.
///
/// The `Rendering` protocol provides a generic abstraction for rendering
/// content to byte buffers. It is designed to support various markup languages
/// like HTML, XML, SVG, etc. through specialized conforming protocols.
///
/// ## Example
///
/// ```swift
/// struct MyRenderer: Rendering {
///     var body: some Rendering { ... }
/// }
/// ```
public protocol Renderable {
    /// The type of content that this rendering type contains.
    /// For terminal types that implement their own `_render`, use `Never`.
    associatedtype Content

    /// The context type used during rendering.
    associatedtype Context

    /// The body of this rendering type, defining its structure and content.
    var body: Content { get }

    /// Renders this type into the provided byte buffer.
    ///
    /// - Parameters:
    ///   - markup: The content to render.
    ///   - buffer: The buffer to write bytes into.
    ///   - context: The rendering context.
    static func _render<Buffer: RangeReplaceableCollection>(
        _ markup: Self,
        into buffer: inout Buffer,
        context: inout Context
    ) where Buffer.Element == UInt8
}

extension Renderable where Content: Renderable, Content.Context == Context {
    /// Default implementation that delegates to the body's render method.
    @inlinable
    @_disfavoredOverload
    public static func _render<Buffer: RangeReplaceableCollection>(
        _ markup: Self,
        into buffer: inout Buffer,
        context: inout Context
    ) where Buffer.Element == UInt8 {
        Content._render(markup.body, into: &buffer, context: &context)
    }
}

