//
//  ForEach.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

/// A component that creates rendered content for each element in a collection.
///
/// `ForEach` provides a way to generate content by iterating over
/// a collection and applying a transform to each element. This is similar to
/// using a `for` loop in a result builder context, but provides a more
/// explicit and reusable way to handle collection iteration.
///
/// Example:
/// ```swift
/// let fruits = ["Apple", "Banana", "Cherry"]
///
/// var content: some Rendering {
///     ForEach(fruits) { fruit in
///         // render each fruit
///     }
/// }
/// ```
///
/// - Note: This component works around a bug in `buildArray` that causes
///   build failures when the element is `some Rendering`.
public struct ForEach<Content: Renderable> {
    /// The array of content generated from the collection.
    public let content: _Array<Content>

    /// Creates a new component that generates content for each element in a collection.
    ///
    /// - Parameters:
    ///   - data: The collection to iterate over.
    ///   - content: A closure that transforms each element of the collection into content.
    public init<Data: RandomAccessCollection>(
        _ data: Data,
        @Builder content: (Data.Element) -> Content
    ) {
        self.content = Builder.buildArray(data.map(content))
    }
}

extension ForEach: Renderable {
    public typealias Context = Content.Context

    /// The body of this component, which is the array of content.
    public var body: _Array<Content> {
        content
    }
}

extension ForEach: Sendable where Content: Sendable {}
extension ForEach: Hashable where Content: Hashable {}
extension ForEach: Equatable where Content: Equatable {}
extension ForEach: Codable where Content: Codable {}

