//
//  Empty.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

/// An empty rendering type that produces no output.
///
/// Use `Empty` when you need to satisfy a type requirement but don't want
/// to produce any rendered content.
///
/// Note: This is a simple struct. Domain-specific modules (like RenderingHTML)
/// provide the `Rendering` conformance with the appropriate `Context` type.
public struct Empty {
    public init() {}
}

extension Empty: Sendable {}
extension Empty: Hashable {}
extension Empty: Equatable {}
extension Empty: Codable {}
