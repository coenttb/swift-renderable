//
//  HTML.ForEach.swift
//
//
//  Created by Point-Free, Inc
//

public import Rendering

extension HTML {
    /// A component that creates HTML content for each element in a collection.
    ///
    /// `HTML.ForEach` provides a way to generate HTML content by iterating over
    /// a collection and applying a transform to each element. This is similar to
    /// using a `for` loop in a result builder context, but provides a more
    /// explicit and reusable way to handle collection iteration.
    ///
    /// Example:
    /// ```swift
    /// let fruits = ["Apple", "Banana", "Cherry"]
    ///
    /// var content: some HTML.View {
    ///     ul {
    ///         HTML.ForEach(fruits) { fruit in
    ///             li { fruit }
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// This would generate HTML similar to:
    /// ```html
    /// <ul>
    ///     <li>Apple</li>
    ///     <li>Banana</li>
    ///     <li>Cherry</li>
    /// </ul>
    /// ```
    ///
    /// - Note: This component works around a bug in `buildArray` that causes
    ///   build failures when the element is `some HTML.View`.
    public struct ForEach<Content: HTML.View>: HTML.View {
        let content: _Array<Content>

        public init<Data: RandomAccessCollection>(
            _ data: Data,
            @HTML.Builder content: (Data.Element) -> Content
        ) {
            self.content = Builder.buildArray(data.map(content))
        }

        public var body: _Array<Content> {
            content
        }
    }
}

extension HTML.ForEach: Sendable where Content: Sendable {}

// Keep ForEach (from Rendering module) conformance for generic rendering
// Note: ForEach is a top-level type in the Rendering module, not Rendering.ForEach
extension ForEach: HTML.View where Content: HTML.View {}
