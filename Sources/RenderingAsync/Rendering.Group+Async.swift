//
//  Rendering.Group+Async.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Rendering

// MARK: - Rendering.Async.Protocol Conformance

extension Rendering.Group: Rendering.Async.`Protocol` where Content: Rendering.Async.`Protocol` {
    // Uses default implementation from protocol extension (delegates to body)
}
