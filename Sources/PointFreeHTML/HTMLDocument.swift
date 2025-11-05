//
//  File.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 22/07/2025.
//

public struct HTMLDocument<Body: HTML, Head: HTML>: HTMLDocumentProtocol {
    public let head: Head
    public let body: Body

    public init(
        @HTMLBuilder body: () -> Body,
        @HTMLBuilder head: () -> Head = { HTMLEmpty() }
    ) {
        self.body = body()
        self.head = head()
    }
}

extension HTMLDocument {
    @_disfavoredOverload
    public init(
        @HTMLBuilder head: () -> Head = { HTMLEmpty() },
        @HTMLBuilder body: () -> Body
    ) {
        self.body = body()
        self.head = head()
    }
}
