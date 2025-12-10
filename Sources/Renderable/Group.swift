//
//  Group.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

/// A container that groups content together without adding a wrapper element.
///
/// `Group` allows you to group a collection of elements together
/// without introducing an additional element in the rendered output.
public struct Group<Content> {
    /// The grouped content.
    public let content: Content

    /// Creates a new group with the given HTML content.
    ///
    /// - Parameter content: A closure that returns the HTML content to group.
    public init(
        @Builder content: () -> Content
    ) {
        self.content = content()
    }
}

extension Group: Sendable where Content: Sendable {}
extension Group: Hashable where Content: Hashable {}
extension Group: Equatable where Content: Equatable {}
extension Group: Codable where Content: Codable {}

extension Group: Renderable where Content: Renderable {
    public typealias Context = Content.Context
    public typealias Output = Content.Output

    public var body: Content { content }
}

extension Group: AsyncRenderable where Content: AsyncRenderable {
    // Uses default implementation from protocol extension (delegates to body)
}
