//
//  File.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

/// A type to represent conditional HTML content based on if/else conditions.
///
/// This type is used internally by the `HTMLBuilder` to handle
/// conditional content created by `if`/`else` statements.
public enum _HTMLConditional<First: HTML, Second: HTML>: HTML {
    /// Represents the "if" or "true" case.
    case first(First)
    /// Represents the "else" or "false" case.
    case second(Second)

    /// Renders either the first or second HTML component based on the case.
    ///
    /// - Parameters:
    ///   - html: The conditional HTML to render.
    ///   - printer: The printer to render the HTML into.
    public static func _render(_ html: Self, into printer: inout HTMLPrinter) {
        switch html {
        case .first(let first):
            First._render(first, into: &printer)
        case .second(let second):
            Second._render(second, into: &printer)
        }
    }

    /// Streaming render - writes directly to any byte buffer.
    public static func _render<Buffer: RangeReplaceableCollection>(
        _ html: Self,
        into buffer: inout Buffer,
        context: inout HTMLContext
    ) where Buffer.Element == UInt8 {
        switch html {
        case .first(let first):
            First._render(first, into: &buffer, context: &context)
        case .second(let second):
            Second._render(second, into: &buffer, context: &context)
        }
    }

    /// This type uses direct rendering and doesn't have a body.
    public var body: Never { fatalError() }
}
