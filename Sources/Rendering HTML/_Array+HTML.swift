//
//  _Array+HTML.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

public import Rendering

// Extend the _Array type from Rendering module to conform to HTML.View
// Note: _Array is a top-level type exported from the Rendering module.
// Users can access it as _Array<Content> directly, not through HTML._Array.
extension _Array: HTML.View where Element: HTML.View {}
