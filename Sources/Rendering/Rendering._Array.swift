//
//  Rendering._Array.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

extension Rendering {
    /// A container for an array of rendering elements.
    ///
    /// This type is used internally by result builders to handle
    /// arrays of elements, such as those created by `for` loops.
    public struct _Array<Element> {
        /// The array of elements contained in this container.
        public let elements: [Element]

        /// Creates a new array container.
        public init(_ elements: [Element]) {
            self.elements = elements
        }
    }
}

extension Rendering._Array: Sendable where Element: Sendable {}
extension Rendering._Array: Hashable where Element: Hashable {}
extension Rendering._Array: Equatable where Element: Equatable {}
extension Rendering._Array: Codable where Element: Codable {}

// MARK: - Rendering.Protocol Conformance

extension Rendering._Array: Rendering.`Protocol` where Element: Rendering.`Protocol` {
    public typealias Content = Never
    public typealias Context = Element.Context
    public typealias Output = Element.Output

    /// Renders all elements in the array into the buffer.
    public static func _render<Buffer: RangeReplaceableCollection>(
        _ markup: Self,
        into buffer: inout Buffer,
        context: inout Element.Context
    ) where Buffer.Element == Output {
        for element in markup.elements {
            Element._render(element, into: &buffer, context: &context)
        }
    }

    public var body: Never {
        fatalError("This type uses direct rendering and doesn't have a body.")
    }
}

/// Typealias for backwards compatibility.
public typealias _Array<Element> = Rendering._Array<Element>
