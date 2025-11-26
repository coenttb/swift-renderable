//
//  _Tuple+HTML.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

public import Rendering

// Extend the _Tuple type from Rendering module to conform to HTML.View
// Note: _Tuple is a top-level type exported from the Rendering module.
// Users can access it as _Tuple<Content...> directly, not through HTML._Tuple.
extension _Tuple: Rendering where repeat each Content: HTML.View {
    public typealias Context = HTML.Context
    public typealias Content = Never
    public var body: Never { fatalError() }

    public static func _render<Buffer: RangeReplaceableCollection>(
        _ html: Self,
        into buffer: inout Buffer,
        context: inout HTML.Context
    ) where Buffer.Element == UInt8 {
        func render<T: HTML.View>(_ element: T) {
            let oldAttributes = context.attributes
            defer { context.attributes = oldAttributes }
            T._render(element, into: &buffer, context: &context)
        }
        repeat render(each html.content)
    }
}

extension _Tuple: HTML.View where repeat each Content: HTML.View {}
