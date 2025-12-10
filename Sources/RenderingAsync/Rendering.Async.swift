//
//  Rendering.Async.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Rendering

/// Extends the Rendering namespace with async streaming support.
extension Rendering {
    /// Namespace for async rendering types and protocols.
    ///
    /// The `Rendering.Async` enum provides types for progressive streaming:
    /// - `Rendering.Async.Protocol` - Protocol for async rendering with backpressure
    /// - `Rendering.Async.StreamProtocol` - Contract for async byte streams
    /// - `Rendering.Async.Stream` - Concrete stream implementation with bounded memory
    public enum Async {}
}
