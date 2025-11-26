//
//  File.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 22/07/2025.
//

public import Rendering

public struct HTMLDocument<Body: HTML, Head: HTML>: HTMLDocumentProtocol {
    public let head: Head
    public let body: Body

    public init(
        @Builder body: () -> Body,
        @Builder head: () -> Head = { Empty() }
    ) {
        self.body = body()
        self.head = head()
    }
}

extension HTMLDocument {
    @_disfavoredOverload
    public init(
        @Builder head: () -> Head = { Empty() },
        @Builder body: () -> Body
    ) {
        self.body = body()
        self.head = head()
    }
}

extension HTMLDocument: Sendable where Body: Sendable, Head: Sendable {}
