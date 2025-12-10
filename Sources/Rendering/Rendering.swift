//
//  Rendering.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 08/12/2025.
//

/// Namespace for rendering types and protocols.
///
/// The `Rendering` enum provides a namespace for all rendering-related types:
/// - `Rendering.Protocol` - The core rendering protocol
/// - `Rendering.Builder` - Result builder for DSL composition
/// - `Rendering._Tuple`, `Rendering._Conditional`, `Rendering._Array` - Composition primitives
/// - `Rendering.Empty`, `Rendering.Group`, `Rendering.ForEach` - Container types
/// - `Rendering.Raw`, `Rendering.AnyView` - Utility types
///
/// For async streaming support, import `RenderingAsync` which extends this namespace
/// with `Rendering.Async.Protocol` and related types.
public enum Rendering {}
