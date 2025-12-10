//
//  Rendering._Tuple.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

extension Rendering {
    /// A container for a tuple of rendering elements.
    ///
    /// This type is used internally by result builders to handle
    /// multiple elements combined in a single block.
    ///
    /// Note: This is a minimal struct. Domain-specific modules (like HTML rendering)
    /// provide the `Rendering.Protocol` conformance with the appropriate Context type.
    public struct _Tuple<each Content> {
        /// The tuple of elements.
        public let content: (repeat each Content)

        /// Creates a new tuple of elements.
        public init(_ content: repeat each Content) {
            self.content = (repeat each content)
        }
    }
}

extension Rendering._Tuple: Sendable where repeat each Content: Sendable {}
// extension Rendering._Tuple: Hashable where repeat each Content: Hashable {}
// extension Rendering._Tuple: Equatable where repeat each Content: Equatable {}
// extension Rendering._Tuple: Codable where repeat each Content: Codable {}

/// Typealias for backwards compatibility.
public typealias _Tuple<each Content> = Rendering._Tuple<repeat each Content>
