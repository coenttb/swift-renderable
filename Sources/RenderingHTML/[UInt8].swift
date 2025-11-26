//
//  File.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

import INCITS_4_1986

extension HTML {
    /// &quot; - Double quotation mark HTML entity
    package static let doubleQuotationMark: [UInt8] = [
        .ascii.ampersand,
        .ascii.q,
        .ascii.u,
        .ascii.o,
        .ascii.t,
        .ascii.semicolon
    ]

    /// &#39; - Apostrophe HTML entity
    package static let apostrophe: [UInt8] = [
        .ascii.ampersand,
        .ascii.numberSign,
        .ascii.3,
        .ascii.9,
        .ascii.semicolon
    ]

    /// &amp; - Ampersand HTML entity
    package static let ampersand: [UInt8] = [
        .ascii.ampersand,
        .ascii.a,
        .ascii.m,
        .ascii.p,
        .ascii.semicolon
    ]

    /// &lt; - Less-than HTML entity
    package static let lessThan: [UInt8] = [
        .ascii.ampersand,
        .ascii.l,
        .ascii.t,
        .ascii.semicolon
    ]

    /// &gt; - Greater-than HTML entity
    package static let greaterThan: [UInt8] = [
        .ascii.ampersand,
        .ascii.g,
        .ascii.t,
        .ascii.semicolon
    ]
}


extension Collection where Element == UInt8 {
    public static var html: HTML.Type {
        HTML.self
    }
}


extension HTML {
    
    public static var tag: HTML.Tag.Type {
        HTML.Tag.self
    }
}

extension HTML.Tag {
    /// <!doctype html>
    package static let doctype: [UInt8] = [
        .ascii.lessThanSign, .ascii.exclamationPoint,
        .ascii.d, .ascii.o, .ascii.c, .ascii.t, .ascii.y, .ascii.p, .ascii.e,
        .ascii.space,
        .ascii.h, .ascii.t, .ascii.m, .ascii.l,
        .ascii.greaterThanSign
    ]

    /// <html>
    package static let open: [UInt8] = [
        .ascii.lessThanSign,
        .ascii.h, .ascii.t, .ascii.m, .ascii.l,
        .ascii.greaterThanSign
    ]

    /// </html>
    package static let close: [UInt8] = [
        .ascii.lessThanSign, .ascii.slant,
        .ascii.h, .ascii.t, .ascii.m, .ascii.l,
        .ascii.greaterThanSign
    ]

    /// <head>
    package static let headOpen: [UInt8] = [
        .ascii.lessThanSign,
        .ascii.h, .ascii.e, .ascii.a, .ascii.d,
        .ascii.greaterThanSign
    ]

    /// </head>
    package static let headClose: [UInt8] = [
        .ascii.lessThanSign, .ascii.slant,
        .ascii.h, .ascii.e, .ascii.a, .ascii.d,
        .ascii.greaterThanSign
    ]

    /// <body>
    package static let bodyOpen: [UInt8] = [
        .ascii.lessThanSign,
        .ascii.b, .ascii.o, .ascii.d, .ascii.y,
        .ascii.greaterThanSign
    ]

    /// </body>
    package static let bodyClose: [UInt8] = [
        .ascii.lessThanSign, .ascii.slant,
        .ascii.b, .ascii.o, .ascii.d, .ascii.y,
        .ascii.greaterThanSign
    ]

    /// <style>
    package static let styleOpen: [UInt8] = [
        .ascii.lessThanSign,
        .ascii.s, .ascii.t, .ascii.y, .ascii.l, .ascii.e,
        .ascii.greaterThanSign
    ]

    /// </style>
    package static let styleClose: [UInt8] = [
        .ascii.lessThanSign, .ascii.slant,
        .ascii.s, .ascii.t, .ascii.y, .ascii.l, .ascii.e,
        .ascii.greaterThanSign
    ]
}
