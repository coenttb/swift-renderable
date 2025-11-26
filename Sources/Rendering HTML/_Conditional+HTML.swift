//
//  _Conditional+HTML.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

public import Rendering

// Extend the _Conditional type from Rendering module to conform to HTML.View
// Note: _Conditional is a top-level type exported from the Rendering module.
// Users can access it as _Conditional<First, Second> directly, not through HTML._Conditional.
extension _Conditional: HTML.View where First: HTML.View, Second: HTML.View {}
