//
//  Optional+Async.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Rendering

// MARK: - Rendering.Async.Protocol Conformance

extension Optional: Rendering.Async.`Protocol` where Wrapped: Rendering.Async.`Protocol` {
    /// Async renders the optional element if it exists.
    public static func _renderAsync<Sink: Rendering.Async.Sink.`Protocol`>(
        _ markup: Self,
        into sink: Sink,
        context: inout Wrapped.Context
    ) async {
        guard let markup else { return }
        await Wrapped._renderAsync(markup, into: sink, context: &context)
    }
}
