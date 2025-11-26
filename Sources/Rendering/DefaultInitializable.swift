//
//  DefaultInitializable.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

/// A protocol for types that can be initialized with no arguments.
///
/// This protocol enables generic code to create default instances of context types,
/// which is useful for rendering to strings where a default context is acceptable.
public protocol DefaultInitializable {
    init()
}
