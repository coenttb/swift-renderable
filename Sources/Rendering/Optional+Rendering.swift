//
//  Optional.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

/// Allows optional values to be used in rendering contexts.
extension Optional: Renderable where Wrapped: Renderable {
    public typealias Context = Wrapped.Context
    public typealias Content = Never

    /// Renders the optional element if it exists.
    public static func _render<Buffer: RangeReplaceableCollection>(
        _ markup: Self,
        into buffer: inout Buffer,
        context: inout Wrapped.Context
    ) where Buffer.Element == UInt8 {
        guard let markup else { return }
        Wrapped._render(markup, into: &buffer, context: &context)
    }

    /// This type uses direct rendering and doesn't have a body.
    public var body: Never { fatalError() }
}

extension Optional: AsyncRenderable where Wrapped: AsyncRenderable {
    /// Async renders the optional element if it exists.
    public static func _renderAsync<Stream: AsyncRenderingStreamProtocol>(
        _ markup: Self,
        into stream: Stream,
        context: inout Wrapped.Context
    ) async {
        guard let markup else { return }
        await Wrapped._renderAsync(markup, into: stream, context: &context)
    }
}
