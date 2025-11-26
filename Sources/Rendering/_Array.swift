//
//  _Array.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

/// A container for an array of rendering elements.
///
/// This type is used internally by result builders to handle
/// arrays of elements, such as those created by `for` loops.
public struct _Array<Element: Rendering>: Rendering {
    public typealias Content = Never
    public typealias Context = Element.Context

    /// The array of elements contained in this container.
    public let elements: [Element]

    /// Creates a new array container.
    public init(_ elements: [Element]) {
        self.elements = elements
    }

    /// Renders all elements in the array into the buffer.
    public static func _render<Buffer: RangeReplaceableCollection>(
        _ markup: Self,
        into buffer: inout Buffer,
        context: inout Element.Context
    ) where Buffer.Element == UInt8 {
        for element in markup.elements {
            Element._render(element, into: &buffer, context: &context)
        }
    }

    /// This type uses direct rendering and doesn't have a body.
    public var body: Never { fatalError() }
}

extension _Array: Sendable where Element: Sendable {}
