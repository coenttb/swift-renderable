//
//  Rendering._Conditional+Async.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Rendering

// MARK: - Rendering.Async.Protocol Conformance

extension Rendering._Conditional: Rendering.Async.`Protocol`
where
    First: Rendering.Async.`Protocol`, Second: Rendering.Async.`Protocol`,
    First.Context == Second.Context {
    /// Async renders either the first or second component based on the case.
    public static func _renderAsync<Sink: Rendering.Async.Sink.`Protocol`>(
        _ markup: Self,
        into sink: Sink,
        context: inout First.Context
    ) async {
        switch markup {
        case .first(let first):
            await First._renderAsync(first, into: sink, context: &context)
        case .second(let second):
            await Second._renderAsync(second, into: sink, context: &context)
        }
    }
}
