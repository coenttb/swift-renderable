//
//  File.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

/// A container for a tuple of HTML elements.
///
/// This type is used internally by the `HTMLBuilder` to handle
/// multiple HTML elements combined in a single block.
public struct _HTMLTuple<each Content: HTML>: HTML {
    /// The tuple of HTML elements.
    let content: (repeat each Content)

    /// Creates a new tuple of HTML elements.
    ///
    /// - Parameter content: The tuple of HTML elements.
    init(content: repeat each Content) {
        self.content = (repeat each content)
    }

    /// Renders all elements in the tuple into the buffer.
    public static func _render<Buffer: RangeReplaceableCollection>(
        _ html: Self,
        into buffer: inout Buffer,
        context: inout HTMLContext
    ) where Buffer.Element == UInt8 {
        func render<T: HTML>(_ html: T) {
            let oldAttributes = context.attributes
            defer { context.attributes = oldAttributes }
            T._render(html, into: &buffer, context: &context)
        }
        repeat render(each html.content)
    }

    /// This type uses direct rendering and doesn't have a body.
    public var body: Never { fatalError() }
}

extension _HTMLTuple: Sendable where repeat each Content: Sendable {}
