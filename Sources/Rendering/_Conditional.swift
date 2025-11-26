//
//  _Conditional.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

/// A type to represent conditional content based on if/else conditions.
///
/// This type is used internally by result builders to handle
/// conditional content created by `if`/`else` statements.
public enum _Conditional<First: Rendering, Second: Rendering>: Rendering
where First.Context == Second.Context {
    public typealias Content = Never
    public typealias Context = First.Context

    /// Represents the "if" or "true" case.
    case first(First)
    /// Represents the "else" or "false" case.
    case second(Second)

    /// Renders either the first or second component based on the case.
    public static func _render<Buffer: RangeReplaceableCollection>(
        _ markup: Self,
        into buffer: inout Buffer,
        context: inout First.Context
    ) where Buffer.Element == UInt8 {
        switch markup {
        case .first(let first):
            First._render(first, into: &buffer, context: &context)
        case .second(let second):
            Second._render(second, into: &buffer, context: &context)
        }
    }

    /// This type uses direct rendering and doesn't have a body.
    public var body: Never { fatalError() }
}

extension _Conditional: Sendable where First: Sendable, Second: Sendable {}
