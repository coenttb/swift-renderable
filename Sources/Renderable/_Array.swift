//
//  _Array.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

/// A container for an array of rendering elements.
///
/// This type is used internally by result builders to handle
/// arrays of elements, such as those created by `for` loops.
public struct _Array<Element: Renderable>: Renderable {
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

    public var body: Never {
        fatalError("This type uses direct rendering and doesn't have a body.")
    }
}

extension _Array: Sendable where Element: Sendable {}
extension _Array: Hashable where Element: Hashable {}
extension _Array: Equatable where Element: Equatable {}
extension _Array: Codable where Element: Codable {}

extension _Array: AsyncRenderable where Element: AsyncRenderable {
    /// Async renders all elements in the array, yielding at element boundaries.
    ///
    /// This is a key yield point for progressive streaming - each element
    /// is rendered and flushed before moving to the next.
    public static func _renderAsync<Stream: AsyncRenderingStreamProtocol>(
        _ markup: Self,
        into stream: Stream,
        context: inout Element.Context
    ) async {
        for element in markup.elements {
            await Element._renderAsync(element, into: stream, context: &context)
        }
    }
}
