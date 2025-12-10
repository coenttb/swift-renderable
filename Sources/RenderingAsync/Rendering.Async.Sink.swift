//
//  Rendering.Async.Sink.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Rendering

extension Rendering.Async {
    /// Namespace for async sink types (destinations for rendered bytes).
    ///
    /// The `Rendering.Async.Sink` enum provides:
    /// - `Rendering.Async.Sink.Protocol` - Contract for byte sinks with backpressure
    /// - `Rendering.Async.Sink.Buffered` - Actor-based sink using AsyncChannel
    /// - `Rendering.Async.Sink.Chunked` - Alternative sink using AsyncStream
    public enum Sink {}
}
