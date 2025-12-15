//
//  Rendering._Conditional.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

extension Rendering {
    /// A type to represent conditional content based on if/else conditions.
    ///
    /// This type is used internally by result builders to handle
    /// conditional content created by `if`/`else` statements.
    public enum _Conditional<First, Second> {
        /// Represents the "if" or "true" case.
        case first(First)
        /// Represents the "else" or "false" case.
        case second(Second)
    }
}

extension Rendering._Conditional: Sendable where First: Sendable, Second: Sendable {}
extension Rendering._Conditional: Hashable where First: Hashable, Second: Hashable {}
extension Rendering._Conditional: Equatable where First: Equatable, Second: Equatable {}
#if Codable
extension Rendering._Conditional: Codable where First: Codable, Second: Codable {}
#endif

// MARK: - Rendering.Protocol Conformance

extension Rendering._Conditional: Rendering.`Protocol`
where
    First: Rendering.`Protocol`, Second: Rendering.`Protocol`, First.Context == Second.Context,
    First.Output == Second.Output
{
    public typealias Content = Never
    public typealias Context = First.Context
    public typealias Output = First.Output

    /// Renders either the first or second component based on the case.
    public static func _render<Buffer: RangeReplaceableCollection>(
        _ markup: Self,
        into buffer: inout Buffer,
        context: inout First.Context
    ) where Buffer.Element == Output {
        switch markup {
        case .first(let first):
            First._render(first, into: &buffer, context: &context)
        case .second(let second):
            Second._render(second, into: &buffer, context: &context)
        }
    }

    public var body: Never {
        fatalError("This type uses direct rendering and doesn't have a body.")
    }
}

/// Typealias for backwards compatibility.
public typealias _Conditional<First, Second> = Rendering._Conditional<First, Second>
