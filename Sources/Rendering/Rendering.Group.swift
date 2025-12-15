//
//  Rendering.Group.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

extension Rendering {
    /// A container that groups content together without adding a wrapper element.
    ///
    /// `Rendering.Group` allows you to group a collection of elements together
    /// without introducing an additional element in the rendered output.
    public struct Group<Content> {
        /// The grouped content.
        public let content: Content

        /// Creates a new group with the given content.
        ///
        /// - Parameter content: A closure that returns the content to group.
        public init(
            @Rendering.Builder content: () -> Content
        ) {
            self.content = content()
        }
    }
}

extension Rendering.Group: Sendable where Content: Sendable {}
extension Rendering.Group: Hashable where Content: Hashable {}
extension Rendering.Group: Equatable where Content: Equatable {}
#if Codable
extension Rendering.Group: Codable where Content: Codable {}
#endif

extension Rendering.Group: Rendering.`Protocol` where Content: Rendering.`Protocol` {
    public typealias Context = Content.Context
    public typealias Output = Content.Output

    public var body: Content { content }
}

/// Typealias for backwards compatibility.
public typealias Group<Content> = Rendering.Group<Content>
