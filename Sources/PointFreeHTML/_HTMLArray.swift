//
//  File.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

/// A container for an array of HTML elements.
///
/// This type is used internally by the `HTMLBuilder` to handle
/// arrays of elements, such as those created by `for` loops.
public struct _HTMLArray<Element: HTML>: HTML {
    /// The array of HTML elements contained in this container.
    let elements: [Element]

    /// Renders all elements in the array into the buffer.
    public static func _render<Buffer: RangeReplaceableCollection>(
        _ html: Self,
        into buffer: inout Buffer,
        context: inout HTMLContext
    ) where Buffer.Element == UInt8 {
        for element in html.elements {
            Element._render(element, into: &buffer, context: &context)
        }
    }

    /// This type uses direct rendering and doesn't have a body.
    public var body: Never { fatalError() }
}
