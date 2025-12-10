//
//  Rendering.Async.Sink.Protocol.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Rendering

extension Rendering.Async.Sink {
    /// A protocol for async sinks that accept bytes with backpressure.
    ///
    /// Sinks are the destination for rendered bytes during async rendering.
    /// Conforming types provide an async `write` method that may suspend to apply
    /// backpressure when the consumer is slower than the producer.
    public protocol `Protocol`: Sendable {
        /// Write bytes to the sink, potentially suspending for backpressure.
        func write(_ bytes: some Sequence<UInt8> & Sendable) async

        /// Write a single byte to the sink.
        func write(_ byte: UInt8) async
    }
}
