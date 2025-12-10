//
//  Rendering.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

/// A protocol for types that can be rendered to a buffer.
///
/// The `Renderable` protocol provides a generic abstraction for rendering
/// content to buffers. It is designed to support various markup languages
/// like HTML, XML, SVG, etc. through specialized conforming protocols.
///
/// The `Output` associated type determines the buffer element type:
/// - HTML rendering uses `Output == UInt8` (byte buffers)
/// - PDF rendering uses `Output == PDF.Render.Operation` (operation buffers)
///
/// ## Example
///
/// ```swift
/// struct MyRenderer: Renderable {
///     typealias Output = UInt8
///     var body: some Renderable { ... }
/// }
/// ```
public protocol Renderable {
    /// The type of content that this rendering type contains.
    /// For terminal types that implement their own `_render`, use `Never`.
    associatedtype Content

    /// The context type used during rendering.
    associatedtype Context

    /// The output element type for the rendering buffer.
    /// - For HTML/byte-based rendering: `UInt8`
    /// - For PDF/operation-based rendering: `PDF.Render.Operation`
    associatedtype Output

    /// The body of this rendering type, defining its structure and content.
    var body: Content { get }

    /// Renders this type into the provided buffer.
    ///
    /// - Parameters:
    ///   - markup: The content to render.
    ///   - buffer: The buffer to write output into.
    ///   - context: The rendering context.
    static func _render<Buffer: RangeReplaceableCollection>(
        _ markup: Self,
        into buffer: inout Buffer,
        context: inout Context
    ) where Buffer.Element == Output
}

extension Renderable
where Content: Renderable, Content.Context == Context, Content.Output == Output {
    /// Default implementation that delegates to the body's render method.
    @inlinable
    @_disfavoredOverload
    public static func _render<Buffer: RangeReplaceableCollection>(
        _ markup: Self,
        into buffer: inout Buffer,
        context: inout Context
    ) where Buffer.Element == Output {
        Content._render(markup.body, into: &buffer, context: &context)
    }
}
