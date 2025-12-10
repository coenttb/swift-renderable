//
//  Rendering._Array+Async.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Rendering

// MARK: - Rendering.Async.Protocol Conformance

extension Rendering._Array: Rendering.Async.`Protocol` where Element: Rendering.Async.`Protocol` {
    /// Async renders all elements in the array, yielding at element boundaries.
    ///
    /// This is a key yield point for progressive streaming - each element
    /// is rendered and flushed before moving to the next.
    public static func _renderAsync<Sink: Rendering.Async.Sink.`Protocol`>(
        _ markup: Self,
        into sink: Sink,
        context: inout Element.Context
    ) async {
        for element in markup.elements {
            await Element._renderAsync(element, into: sink, context: &context)
        }
    }
}
