//
//  Rendering.Empty.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

extension Rendering {
    /// An empty rendering type that produces no output.
    ///
    /// Use `Rendering.Empty` when you need to satisfy a type requirement but don't want
    /// to produce any rendered content.
    ///
    /// Note: This is a simple struct. Domain-specific modules (like HTML rendering)
    /// provide the `Rendering.Protocol` conformance with the appropriate `Context` type.
    public struct Empty {
        public init() {}
    }
}

extension Rendering.Empty: Sendable {}
extension Rendering.Empty: Hashable {}
extension Rendering.Empty: Equatable {}
#if Codable
extension Rendering.Empty: Codable {}
#endif

/// Typealias for backwards compatibility.
public typealias Empty = Rendering.Empty
