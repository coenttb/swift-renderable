//
//  Rendering.ForEach.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

extension Rendering {
    /// A component that creates rendered content for each element in a collection.
    ///
    /// `Rendering.ForEach` provides a way to generate content by iterating over
    /// a collection and applying a transform to each element. This is similar to
    /// using a `for` loop in a result builder context, but provides a more
    /// explicit and reusable way to handle collection iteration.
    ///
    /// Example:
    /// ```swift
    /// let fruits = ["Apple", "Banana", "Cherry"]
    ///
    /// var content: some Rendering.Protocol {
    ///     Rendering.ForEach(fruits) { fruit in
    ///         // render each fruit
    ///     }
    /// }
    /// ```
    ///
    /// - Note: This component works around a bug in `buildArray` that causes
    ///   build failures when the element is `some Rendering.Protocol`.
    public struct ForEach<Content: Rendering.`Protocol`> {
        /// The array of content generated from the collection.
        public let content: Rendering._Array<Content>

        /// Creates a new component that generates content for each element in a collection.
        ///
        /// - Parameters:
        ///   - data: The collection to iterate over.
        ///   - content: A closure that transforms each element of the collection into content.
        public init<Data: RandomAccessCollection>(
            _ data: Data,
            @Rendering.Builder content: (Data.Element) -> Content
        ) {
            self.content = Rendering.Builder.buildArray(data.map(content))
        }
    }
}

extension Rendering.ForEach: Rendering.`Protocol` where Content: Rendering.`Protocol` {
    public typealias Context = Content.Context
    public typealias Output = Content.Output

    /// The body of this component, which is the array of content.
    public var body: Rendering._Array<Content> {
        content
    }
}

extension Rendering.ForEach: Sendable where Content: Sendable {}
extension Rendering.ForEach: Hashable where Content: Hashable {}
extension Rendering.ForEach: Equatable where Content: Equatable {}
extension Rendering.ForEach: Codable where Content: Codable {}

/// Typealias for backwards compatibility.
public typealias ForEach<Content: Rendering.`Protocol`> = Rendering.ForEach<Content>
