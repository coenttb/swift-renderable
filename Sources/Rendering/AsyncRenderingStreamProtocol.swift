//
//  File.swift
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
