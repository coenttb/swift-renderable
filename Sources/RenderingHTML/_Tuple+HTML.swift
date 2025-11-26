//
//  File.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

public import Rendering

/// A container for a tuple of HTML elements.
///
/// This type is used internally by the `HTMLBuilder` to handle
/// multiple HTML elements combined in a single block.
public typealias _HTMLTuple<each Content: HTML> = _Tuple<repeat each Content>

extension _Tuple: Rendering where repeat each Content: HTML {
    public typealias Context = HTMLContext
    public typealias Content = Never
    public var body: Never { fatalError() }

    public static func _render<Buffer: RangeReplaceableCollection>(
        _ html: Self,
        into buffer: inout Buffer,
        context: inout HTMLContext
    ) where Buffer.Element == UInt8 {
        func render<T: HTML>(_ element: T) {
            let oldAttributes = context.attributes
            defer { context.attributes = oldAttributes }
            T._render(element, into: &buffer, context: &context)
        }
        repeat render(each html.content)
    }
}

extension _Tuple: HTML where repeat each Content: HTML {}
